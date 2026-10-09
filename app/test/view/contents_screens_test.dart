import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngclass/core/di/injection.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/formatting.dart';
import 'package:ngclass/core/network/api_failure.dart';
import 'package:ngclass/core/router/routes.dart';
import 'package:ngclass/domain/model/app_user.dart';
import 'package:ngclass/domain/model/content.dart';
import 'package:ngclass/view/screens/shared/document_screen.dart';
import 'package:ngclass/view/screens/shared/my_contents_screen.dart';
import 'package:ngclass/view/screens/teacher/contents/contents_screen.dart';
import 'package:ngclass/view/screens/teacher/contents/document_form_panel.dart';
import 'package:ngclass/view/screens/teacher/teacher_destinations.dart';
import 'package:ngclass/view/stateManager/library/library_cubit.dart';
import 'package:ngclass/view/widgets/adaptive_shell.dart';
import 'package:ngclass/view/widgets/panels.dart';

import '../helpers/content_fixtures.dart';
import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';
import '../helpers/student_fixtures.dart' show now, parent, pupil;

void main() {
  setUpAll(initializeAppDates);

  late FakeContentRepository repository;
  late FakeFileChooser chooser;
  late RecordingFileOpener opener;
  setUp(() {
    registerTestServices(now);
    final services = registerContentServices();
    repository = services.repository;
    chooser = services.chooser;
    opener = services.opener;
  });

  Future<void> pumpLibrary(WidgetTester tester, {AppLanguage language = AppLanguage.fr, Size size = const Size(1440, 1200)}) =>
      pumpSignedIn(
        tester,
        AdaptiveShell(destinations: teacherDestinations(), location: Routes.teacherContents, child: const ContentsScreen()),
        language: language,
        size: size,
      );

  group('Contenus', () {
    testWidgets('desktop in French: the tree, the chapter and one line per document', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpLibrary(tester);

      expect(find.text(fr.contentsSubtitle), findsOneWidget);
      expect(find.text('Mathématiques'), findsOneWidget);
      expect(find.text('Les fractions'), findsNWidgets(2));
      expect(find.text('La multiplication'), findsOneWidget);
      expect(find.text('MATHÉMATIQUES · 4ÈME ANNÉE'), findsOneWidget);
      expect(find.text(fr.columnDocument.toUpperCase()), findsOneWidget);
      expect(find.text('Série 2 : les fractions'), findsOneWidget);
      expect(find.text('PDF · 3 pages · 1,2 Mo'), findsWidgets);
      expect(find.text('Word · 1,2 Mo · à télécharger'), findsOneWidget);
      expect(find.text(fr.statusDraft), findsOneWidget);
      expect(find.text(fr.notShared), findsNWidgets(2));
      expect(find.text(fr.documentsCount(5)), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Another chapter from the tree.
      await tester.tap(find.text('La multiplication'));
      await tester.pumpAndSettle();
      expect(find.text('Table de 7'), findsOneWidget);
      expect(find.text('Série 2 : les fractions'), findsNothing);
    });

    testWidgets('phone in Arabic: subject and level in one menu, chapters as chips, documents as cards', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      await pumpLibrary(tester, language: AppLanguage.ar, size: const Size(390, 1800));

      // In the menu and above the chapter (Arabic has no capitals).
      expect(find.text('الرياضيات · السنة الرابعة ابتدائي'), findsNWidgets(2));
      expect(find.text('Les fractions  5'), findsOneWidget);
      expect(find.text(ar.columnDocument), findsNothing);
      expect(find.text('Série 2 : les fractions'), findsOneWidget);
      expect(find.text(ar.importShort), findsOneWidget);
      expect(Directionality.of(tester.element(find.text('Série 2 : les fractions'))), TextDirection.rtl);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty library says how to start', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      repository.library_ = const Library();
      await pumpLibrary(tester);

      expect(find.text(fr.libraryEmptyTitle), findsOneWidget);
      expect(find.text(fr.libraryEmptyHint), findsOneWidget);
    });

    testWidgets('import: a file, the title from its name, then the document is in the list', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpLibrary(tester);

      await tester.tap(find.text(fr.importDocument));
      await tester.pumpAndSettle();
      expect(find.byType(DocumentFormPanel), findsOneWidget);
      expectEveryFieldHasAHint(find.byType(DocumentFormPanel));
      // Placed where the teacher is.
      expect(find.descendant(of: find.byType(DocumentFormPanel), matching: find.text('Les fractions')), findsOneWidget);

      await tester.tap(find.text(fr.importShort));
      await tester.pumpAndSettle();
      expect(find.text(fr.fileRequired), findsOneWidget);
      expect(repository.uploads, isEmpty);

      chooser.next = pdfFile('serie3_fractions.pdf');
      await tester.tap(find.text(fr.chooseFile));
      await tester.pumpAndSettle();
      expect(find.text('serie3_fractions.pdf'), findsOneWidget);
      expect(find.text('Serie3 fractions'), findsOneWidget);
      await tester.tap(find.text(group4A.name).last);
      await tester.pumpAndSettle();

      await tester.tap(find.text(fr.importShort));
      await tester.pumpAndSettle();
      expect(repository.uploads.single.$1.groupIds, ['g4a']);
      expect(find.byType(DocumentFormPanel), findsNothing);
      expect(find.text(fr.documentUploaded), findsOneWidget);
      expect(find.text('Serie3 fractions'), findsOneWidget);
    });

    testWidgets('a file of another type is refused in the panel, before any upload', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpLibrary(tester);
      await tester.tap(find.text(fr.importDocument));
      await tester.pumpAndSettle();

      chooser.next = pdfFile('photo.heic');
      await tester.tap(find.text(fr.chooseFile));
      await tester.pumpAndSettle();
      expect(find.text(fr.fileUnsupported), findsOneWidget);
      await tester.tap(find.text(fr.importShort));
      await tester.pumpAndSettle();
      expect(repository.uploads, isEmpty);
    });

    testWidgets('sharing a document from its menu; a draft cannot be shared', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpLibrary(tester);

      await tester.tap(find.byTooltip(fr.documentActions).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(fr.actionShare));
      await tester.pumpAndSettle();
      expect(find.text(fr.shareDocumentTitle('Série 2 : les fractions')), findsOneWidget);
      expect(find.text(fr.groupsOfLevel('4ème année').toUpperCase()), findsOneWidget);
      await tester.tap(find.descendant(of: find.byType(AppDialog), matching: find.text(group4A.name)));
      await tester.pump();
      await tester.tap(find.text(fr.save));
      await tester.pumpAndSettle();
      expect(repository.shares.single.$1, 'serie2');
      expect(repository.shares.single.$2, isEmpty);
      expect(find.text(fr.shareSaved), findsOneWidget);
      expect(find.text(fr.notShared), findsNWidgets(3));

      // The draft (third line).
      await tester.tap(find.byTooltip(fr.documentActions).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text(fr.actionShare));
      await tester.pumpAndSettle();
      expect(find.byType(AppDialog), findsNothing);
      expect(find.text(fr.draftCannotShare), findsOneWidget);
    });

    testWidgets('a new chapter: every field shows a hint, and the chapter opens', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpLibrary(tester);

      await tester.tap(find.text(fr.newChapter).first);
      await tester.pumpAndSettle();
      expectEveryFieldHasAHint(find.byType(AppDialog));
      await tester.enterText(find.descendant(of: find.byType(AppDialog), matching: find.byType(TextField)), 'Les mesures');
      await tester.tap(find.text(fr.save));
      await tester.pumpAndSettle();

      expect(find.byType(AppDialog), findsNothing);
      expect(find.text('Les mesures'), findsNWidgets(2));
      expect(find.text(fr.chapterEmpty), findsOneWidget);
    });

    testWidgets('a failed load offers a retry', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      repository.failure = const ApiFailure(code: ApiFailure.network);
      await pumpLibrary(tester);

      expect(find.text(fr.errorNetwork), findsOneWidget);
      expect(find.text(fr.retry), findsOneWidget);
    });
  });

  group('Cours', () {
    testWidgets('a pupil in French: by subject and chapter, "Nouveau" until opened, a filter by subject', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpSignedIn(
        tester,
        const Scaffold(body: MyContentsScreen()),
        user: pupil,
        size: const Size(390, 1400),
      );

      expect(find.text(fr.myCoursesTitle), findsOneWidget);
      expect(find.text(fr.myCoursesSubtitle), findsOneWidget);
      expect(find.text('Les fractions'), findsOneWidget);
      expect(find.text('Contes et fables'), findsOneWidget);
      expect(find.text('Série · 3 pages'), findsOneWidget);
      expect(find.text(fr.kindImage), findsOneWidget);
      expect(find.text(fr.newBadge), findsOneWidget);

      await tester.ensureVisible(find.text('Lecture'));
      await tester.tap(find.text('Lecture'));
      await tester.pumpAndSettle();
      expect(find.text('Les fractions'), findsNothing);
      expect(find.text('Contes et fables'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a parent in Arabic: the child\'s Cours, right to left', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      await pumpSignedIn(
        tester,
        const Scaffold(body: MyContentsScreen()),
        user: parent,
        language: AppLanguage.ar,
        size: const Size(390, 1400),
      );

      expect(find.text(ar.parentCoursesTitle(isolated('Adam'))), findsOneWidget);
      expect(repository.mineAskedFor, ['me']);
      expect(find.text(ar.newBadge), findsOneWidget);
      expect(Directionality.of(tester.element(find.text('Contes et fables'))), TextDirection.rtl);
      expect(tester.takeException(), isNull);
    });

    testWidgets('nothing shared yet: said to the pupil with "tu"', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      repository.cours = const [];
      await pumpSignedIn(
        tester,
        const Scaffold(body: MyContentsScreen()),
        user: pupil,
        size: const Size(390, 1000),
      );

      expect(find.text(fr.coursEmpty), findsOneWidget);
    });
  });

  group('document', () {
    testWidgets('a pupil pages through a PDF and downloads it', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpSignedIn(
        tester,
        const DocumentScreen(documentId: 'serie2', backTo: Routes.studentCourses),
        user: pupil,
        size: const Size(390, 844),
      );

      expect(find.text('Série 2 : les fractions'), findsOneWidget);
      expect(find.text('Mathématiques · ${isolated('Les fractions')}'), findsOneWidget);
      expect(find.text(fr.pageOf(1, 3)), findsOneWidget);
      await tester.tap(find.byTooltip(fr.nextPage));
      await tester.pumpAndSettle();
      expect(find.text(fr.pageOf(2, 3)), findsOneWidget);
      // On a phone, a big button at the bottom (design ContenusPhone.png).
      await tester.tap(find.text(fr.download));
      await tester.pumpAndSettle();
      expect(opener.opened, ['http://localhost/files/serie2-download']);
    });

    testWidgets('a Word file says it only downloads', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      repository.views['fiche'] = viewOf('fiche', kind: FileKind.word);
      await pumpSignedIn(
        tester,
        const DocumentScreen(documentId: 'fiche', backTo: Routes.studentCourses),
        user: pupil,
        size: const Size(390, 844),
      );

      expect(find.text(fr.wordNoPreview), findsOneWidget);
      expect(find.text(fr.pageOf(1, 3)), findsNothing);
    });

    testWidgets('the teacher sees the details beside the pages, in Arabic', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      await pumpSignedIn(
        tester,
        BlocProvider(
          create: (_) => sl.get<LibraryCubit>()..load(),
          child: const DocumentScreen(documentId: 'serie2', backTo: Routes.teacherContents, teacher: true),
        ),
        user: const AppUser(
          id: 't',
          role: UserRole.teacher,
          username: 'ines',
          firstName: 'Ines',
          lastName: 'Haddad',
          mustChangePassword: false,
        ),
        language: AppLanguage.ar,
        size: const Size(1440, 900),
      );

      expect(find.text(ar.details), findsOneWidget);
      expect(find.text(ar.actionShare), findsOneWidget);
      expect(find.text(ar.actionEditDetails), findsOneWidget);
      expect(find.text(group4A.name), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
