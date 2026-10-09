import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:ngclass/core/di/injection.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/formatting.dart';
import 'package:ngclass/core/platform/photo_source.dart';
import 'package:ngclass/core/router/routes.dart';
import 'package:ngclass/data/files/scan_processor_impl.dart';
import 'package:ngclass/domain/model/scan.dart';
import 'package:ngclass/view/screens/teacher/contents/contents_screen.dart';
import 'package:ngclass/view/screens/teacher/contents/crop_screen.dart';
import 'package:ngclass/view/screens/teacher/contents/document_form_panel.dart';
import 'package:ngclass/view/screens/teacher/contents/scan_screen.dart';
import 'package:ngclass/view/screens/teacher/teacher_destinations.dart';
import 'package:ngclass/view/stateManager/scan/crop_cubit.dart';
import 'package:ngclass/view/stateManager/scan/scan_cubit.dart';
import 'package:ngclass/view/widgets/adaptive_shell.dart';

import '../helpers/content_fixtures.dart';
import '../helpers/pump_app.dart';
import '../helpers/student_fixtures.dart' show now;

ScanPage page(String id, {int width = 30, int height = 40}) =>
    ScanPage(id: id, bytes: tinyPng, width: width, height: height, preview: tinyPng);

void main() {
  setUpAll(initializeAppDates);

  group('ScanPage', () {
    test('a quarter turn turns the corners with the photo, and the shape', () {
      final p = page('a').withCorner(0, const ScanPoint(0.1, 0.2));
      final turned = p.rotated();

      expect(turned.quarterTurns, 1);
      expect(turned.turnedAspect, 40 / 30);
      // The old bottom left becomes the top left; the old top left (0.1, 0.2) goes to the top right.
      expect(turned.corners[0], const ScanPoint(0, 0));
      expect(turned.corners[1], const ScanPoint(0.8, 0.1));
      expect(turned.rotated().rotated().rotated().corners, p.corners);
      expect(turned.reset(), page('a'));
      expect(page('a').edited, isFalse);
    });

    test('a corner stays on the photo', () {
      expect(page('a').withCorner(2, const ScanPoint(1.4, -0.2)).corners[2], const ScanPoint(1, 0));
    });
  });

  group('ScanProcessorImpl', () {
    final photo = Uint8List.fromList(img.encodeJpg(img.Image(width: 300, height: 400)));

    test('a photo becomes an upright page with a preview; a broken one is refused', () async {
      final processor = ScanProcessorImpl();
      final loaded = await processor.load('p1', photo);

      expect(loaded!.width, 300);
      expect(loaded.height, 400);
      expect(img.decodeImage(loaded.preview), isNotNull);
      expect(await processor.load('p2', Uint8List.fromList([1, 2, 3])), isNull);
    });

    test('pages become one PDF, straightened and in black and white when asked', () async {
      final processor = ScanProcessorImpl();
      final first = (await processor.load('p1', photo))!;
      final cropped = await processor.refresh(first.withCorner(0, const ScanPoint(0.2, 0.1)).rotated());
      expect(img.decodeImage(cropped.preview)!.width, lessThan(400));

      final pdf = await processor.buildPdf([first, cropped], ScanColor.blackWhite, 'Scan du 6 octobre.pdf');
      expect(pdf.name, 'Scan du 6 octobre.pdf');
      expect(String.fromCharCodes(pdf.bytes.take(4)), '%PDF');
      expect(pdf.problem, isNull);
    });
  });

  group('ScanCubit', () {
    late FakePhotoSource source;
    late FakeScanProcessor processor;
    setUp(() {
      source = FakePhotoSource();
      processor = FakeScanProcessor();
    });

    test('photos one after another, from the camera and the gallery; a closed camera adds nothing', () async {
      final cubit = ScanCubit(source, processor);
      await cubit.takePhoto();
      await cubit.pickPhotos();
      expect(cubit.state.pages.map((p) => p.id), ['page-0', 'page-1', 'page-2']);

      source.nextPhoto = null;
      await cubit.takePhoto();
      expect(cubit.state.pages, hasLength(3));
      expect(cubit.state.adding, isFalse);

      source.nextPhoto = Uint8List(0);
      await cubit.takePhoto();
      expect(cubit.state.problem, ScanProblem.photo);
    });

    test('pages move, go, and change after a crop; the PDF keeps their order and colour', () async {
      final cubit = ScanCubit(source, processor);
      await cubit.pickPhotos();
      await cubit.takePhoto();
      cubit.move('page-2', 0);
      expect(cubit.state.pages.map((p) => p.id), ['page-2', 'page-0', 'page-1']);
      cubit.remove('page-0');
      await cubit.updatePage(cubit.state.pages.first.rotated());
      expect(cubit.state.pages.first.quarterTurns, 1);
      expect(processor.refreshed, 1);

      cubit.setColor(ScanColor.blackWhite);
      final file = await cubit.build('Scan.pdf');
      expect(file!.name, 'Scan.pdf');
      final (pages, color, _) = processor.built.single;
      expect(pages.map((p) => p.id), ['page-2', 'page-1']);
      expect(color, ScanColor.blackWhite);
    });

    test('no page, no PDF; a failed PDF says so', () async {
      final cubit = ScanCubit(source, processor);
      expect(await cubit.build('Scan.pdf'), isNull);

      await cubit.takePhoto();
      processor.failPdf = true;
      expect(await cubit.build('Scan.pdf'), isNull);
      expect(cubit.state.problem, ScanProblem.pdf);
      expect(cubit.state.building, isFalse);
    });
  });

  group('screens', () {
    setUp(() {
      registerTestServices(now);
      registerContentServices();
    });

    testWidgets('the import panel offers a file or a scan; a scan comes back as a PDF to import', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpSignedIn(
        tester,
        AdaptiveShell(destinations: teacherDestinations(), location: Routes.teacherContents, child: const ContentsScreen()),
        size: const Size(390, 1600),
      );
      await tester.tap(find.text(fr.importShort));
      await tester.pumpAndSettle();
      expect(find.text(fr.chooseFile), findsOneWidget);
      expect(find.text(fr.scanSheets), findsOneWidget);
      expectEveryFieldHasAHint(find.byType(DocumentFormPanel));

      await tester.tap(find.text(fr.scanSheets));
      await tester.pumpAndSettle();
      expect(find.text(fr.scanEmptyTitle), findsOneWidget);

      await tester.tap(find.text(fr.takePhoto));
      await tester.pumpAndSettle();
      await tester.tap(find.text(fr.takePhoto).first);
      await tester.pumpAndSettle();
      expect(find.text(fr.pagesCount(2)), findsOneWidget);
      expect(find.bySemanticsLabel(fr.pageNumber(2)), findsOneWidget);

      await tester.tap(find.text(fr.createPdf));
      await tester.pumpAndSettle();
      expect(find.byType(ScanScreen), findsNothing);
      expect(find.text('Scan du 6 octobre.pdf'), findsOneWidget);
      expect(find.text('Scan du 6 octobre'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('on a computer: no camera, photos already taken', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      (sl.get<PhotoSource>() as FakePhotoSource).hasCamera = false;
      await pumpSignedIn(
        tester,
        BlocProvider(create: (_) => ScanCubit(sl.get(), sl.get()), child: const ScanScreen()),
        size: const Size(1440, 900),
      );

      expect(find.text(fr.takePhoto), findsNothing);
      await tester.tap(find.text(fr.addPhotos).last);
      await tester.pumpAndSettle();
      expect(find.text(fr.pagesCount(2)), findsOneWidget);
    });

    testWidgets('leaving with pages asks first', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      final cubit = ScanCubit(sl.get(), sl.get());
      await cubit.takePhoto();
      await pumpSignedIn(
        tester,
        BlocProvider.value(value: cubit, child: const ScanScreen()),
        size: const Size(390, 844),
      );

      await tester.tap(find.byTooltip(fr.cancel));
      await tester.pumpAndSettle();
      expect(find.text(fr.scanDiscardTitle), findsOneWidget);
    });

    testWidgets('crop in Arabic: turn, back to the photo, delete', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      final cubit = CropCubit(page('a').withCorner(0, const ScanPoint(0.2, 0.2)));
      await pumpSignedIn(
        tester,
        BlocProvider.value(value: cubit, child: const CropScreen(index: 1, count: 3)),
        language: AppLanguage.ar,
        size: const Size(390, 844),
      );

      expect(find.text(ar.pageOf(2, 3)), findsOneWidget);
      expect(find.bySemanticsLabel(ar.cropCorner), findsNWidgets(4));
      await tester.tap(find.text(ar.rotate));
      await tester.pump();
      expect(cubit.state.quarterTurns, 1);
      await tester.tap(find.text(ar.resetCrop));
      await tester.pump();
      expect(cubit.state.edited, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a corner follows the finger', (tester) async {
      final cubit = CropCubit(page('a'));
      await pumpSignedIn(
        tester,
        BlocProvider.value(value: cubit, child: const CropScreen(index: 0, count: 1)),
        size: const Size(390, 844),
      );

      final corner = find.bySemanticsLabel(l10nOf(AppLanguage.fr).cropCorner).first;
      await tester.drag(corner, const Offset(40, 30));
      await tester.pump();
      expect(cubit.state.corners.first.x, greaterThan(0));
      expect(cubit.state.corners.first.y, greaterThan(0));

      // Then another corner, and another: each drag moves its own corner.
      final corners = find.bySemanticsLabel(l10nOf(AppLanguage.fr).cropCorner);
      await tester.drag(corners.at(2), const Offset(-40, -30));
      await tester.pump();
      await tester.drag(corners.at(1), const Offset(-30, 20));
      await tester.pump();
      expect(cubit.state.corners[2].x, lessThan(1));
      expect(cubit.state.corners[1].x, lessThan(1));
      expect(cubit.state.corners[1].y, greaterThan(0));
    });
  });
}
