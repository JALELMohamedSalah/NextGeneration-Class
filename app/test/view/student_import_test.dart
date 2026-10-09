import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ngclass/core/di/injection.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/formatting.dart';
import 'package:ngclass/core/network/api_failure.dart';
import 'package:ngclass/core/platform/document_printer.dart';
import 'package:ngclass/core/router/routes.dart';
import 'package:ngclass/data/repository/student_import_repository_impl.dart';
import 'package:ngclass/domain/model/app_user.dart';
import 'package:ngclass/domain/model/content.dart';
import 'package:ngclass/domain/model/student.dart';
import 'package:ngclass/domain/model/student_import.dart';
import 'package:ngclass/domain/repositories/student_import_repository.dart';
import 'package:ngclass/view/screens/teacher/students/student_import_screen.dart';
import 'package:ngclass/view/screens/teacher/students/students_screen.dart';
import 'package:ngclass/view/stateManager/student_import/student_import_cubit.dart';
import 'package:ngclass/view/stateManager/students/students_cubit.dart';
import 'package:ngclass/view/widgets/buttons.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../helpers/content_fixtures.dart';
import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';
import '../helpers/student_fixtures.dart' show now;

/// The class list of the design (`r2/ImportElevesVerifier.png`): four ready, one with a known parent, one already a
/// pupil, two to fix.
ImportPreview sampleImport() => const ImportPreview(
  fileName: 'classe-4A.xlsx',
  rows: [
    ImportRow(
      line: 2,
      firstName: 'Yassine',
      lastName: 'Ben Ali',
      levelId: 'l4',
      groupIds: ['g4a'],
      parentFirstName: 'Sonia',
      parentLastName: 'Ben Ali',
      parentPhone: '22345678',
      state: ImportState.ready,
    ),
    ImportRow(
      line: 3,
      firstName: 'Eya',
      lastName: 'Trabelsi',
      levelId: 'l4',
      groupIds: ['g4a'],
      parentFirstName: 'Nabil',
      parentLastName: 'Trabelsi',
      parentPhone: '98123456',
      state: ImportState.ready,
    ),
    ImportRow(
      line: 4,
      firstName: 'Rania',
      lastName: 'Kefi',
      levelId: 'l4',
      groupIds: ['g4a'],
      parentPhone: '22111222',
      knownParent: 'Sonia Kefi',
      state: ImportState.parentKnown,
    ),
    ImportRow(line: 5, firstName: 'Amine', lastName: 'Kefi', levelId: 'l4', groupIds: ['g4a'], state: ImportState.exists),
    ImportRow(
      line: 6,
      firstName: 'Mohamed Aziz',
      lastName: 'Gharsalli',
      levelId: 'l4',
      parentFirstName: 'Hela',
      parentLastName: 'Gharsalli',
      parentPhone: '2234567',
      state: ImportState.error,
      problems: ['parent_phone_invalid'],
    ),
    ImportRow(line: 7, firstName: 'Firas', lastName: 'Jebali', levelText: '7ème', state: ImportState.error, problems: ['level_unknown']),
    ImportRow(line: 8, firstName: 'Ines', lastName: 'Mabrouk', levelId: 'l4', groupIds: ['g4a'], state: ImportState.ready),
    ImportRow(
      line: 9,
      firstName: 'Malek',
      lastName: 'Ben Ali',
      levelId: 'l4',
      groupIds: ['g4a'],
      parentPhone: '22345678',
      sameParentAs: 2,
      state: ImportState.ready,
    ),
  ],
);

class FakeStudentImportRepository implements StudentImportRepository {
  ImportPreview preview_ = sampleImport();
  ApiFailure? failure;
  PickedFile? file;
  String? groupId;
  String? levelId;
  List<ImportRow>? imported;
  bool? createLogins;

  @override
  Future<ImportPreview> preview(PickedFile file, {String? groupId, String? levelId}) async {
    if (failure != null) throw failure!;
    this.file = file;
    this.groupId = groupId;
    this.levelId = levelId;
    return preview_;
  }

  @override
  Future<ImportResult> importRows(List<ImportRow> rows, {required bool createLogins}) async {
    if (failure != null) throw failure!;
    imported = rows;
    this.createLogins = createLogins;
    return ImportResult(
      created: rows.length,
      linked: 1,
      accounts: const [
        ImportedAccount(
          account: NewAccount(
            userId: 'u1',
            role: UserRole.parent,
            firstName: 'Sonia',
            lastName: 'Ben Ali',
            username: '22345678',
            temporaryPassword: 'kpra4827',
          ),
          children: ['Yassine', 'Malek'],
        ),
        ImportedAccount(
          account: NewAccount(
            userId: 'u2',
            role: UserRole.parent,
            firstName: 'Nabil',
            lastName: 'Trabelsi',
            username: '98123456',
            temporaryPassword: 'mhwe5932',
          ),
          children: ['Eya'],
        ),
      ],
    );
  }

  @override
  String templateUrl(String languageCode) => 'http://api/students/import/template?lang=$languageCode';
}

/// Records what is printed and builds the PDF with the PDF package's own fonts (no download in tests).
class FakeDocumentPrinter implements DocumentPrinter {
  final printed = <String>[];
  Uint8List? pdf;

  @override
  Future<PdfFonts> fonts({required bool arabic}) async => PdfFonts(regular: pw.Font.helvetica(), bold: pw.Font.helveticaBold());

  @override
  Future<void> printPdf(String name, Future<Uint8List> Function(PdfPageFormat format) build) async {
    printed.add(name);
    pdf = await build(PdfPageFormat.a4);
  }
}

void main() {
  setUpAll(initializeAppDates);

  late FakeStudentImportRepository repository;
  late FakeFileChooser chooser;
  late RecordingFileOpener opener;
  late FakeDocumentPrinter printer;
  setUp(() {
    registerTestServices(now);
    final content = registerContentServices();
    chooser = content.chooser..next = PickedFile(name: 'classe-4A.xlsx', bytes: Uint8List.fromList([80, 75, 3, 4]));
    opener = content.opener;
    repository = FakeStudentImportRepository();
    printer = FakeDocumentPrinter();
    sl.registerSingleton<StudentImportRepository>(repository);
    sl.registerSingleton<DocumentPrinter>(printer);
  });

  group('StudentImportCubit', () {
    StudentImportCubit cubit() {
      final c = StudentImportCubit(repository, chooser);
      addTearDown(c.close);
      return c;
    }

    test('a group brings its level; the file is read with both, the ready lines and known parents ticked', () async {
      final c = cubit()..setGroup('g4a', levelOfGroup: 'l4');
      expect(c.state.levelId, 'l4');
      await c.chooseFile();

      expect(repository.groupId, 'g4a');
      expect(repository.levelId, 'l4');
      expect(repository.file!.name, 'classe-4A.xlsx');
      expect(c.state.step, ImportStep.check);
      expect(c.state.kept, {2, 3, 4, 8, 9});
      // Sonia Ben Ali for Yassine and Malek, Nabil for Eya; Sonia Kefi is known.
      expect(c.state.newParents, 2);
    });

    test('a line in error cannot be ticked; a pupil already registered can', () async {
      final c = cubit();
      await c.chooseFile();
      final rows = c.state.preview!.rows;
      c.toggle(rows.firstWhere((r) => r.line == 6));
      expect(c.state.kept.contains(6), isFalse);
      c.toggle(rows.firstWhere((r) => r.line == 5));
      expect(c.state.kept.contains(5), isTrue);
      c.toggle(rows.firstWhere((r) => r.line == 2));
      expect(c.state.kept.contains(2), isFalse);
    });

    test('the lines kept are imported, with the pupils\' logins when asked', () async {
      final c = cubit()..setCreateLogins(true);
      await c.chooseFile();
      await c.importKept();
      expect(repository.imported!.map((r) => r.line), [2, 3, 4, 8, 9]);
      expect(repository.createLogins, isTrue);
      expect(c.state.step, ImportStep.done);
      expect(c.state.result!.accounts, hasLength(2));
    });

    test('a file refused stays on the first step with the reason; closing the picker does nothing', () async {
      repository.failure = const ApiFailure(code: 'import_missing_columns', message: 'Il manque les colonnes.');
      final c = cubit();
      await c.chooseFile();
      expect(c.state.step, ImportStep.file);
      expect(c.state.failure!.code, 'import_missing_columns');

      chooser.next = null;
      repository.failure = null;
      await c.chooseFile();
      expect(c.state.step, ImportStep.file);
    });
  });

  test('a checked line is read with its problems and links', () {
    final row = importRow({
      'line': 7,
      'firstName': 'Firas',
      'lastName': 'Jebali',
      'levelText': '7ème',
      'groupIds': <String>[],
      'state': 'ERROR',
      'problems': ['level_unknown'],
      'sameParentAs': 2,
    });
    expect(row.state, ImportState.error);
    expect(row.problems, ['level_unknown']);
    expect(row.levelId, isNull);
    expect(row.sameParentAs, 2);
    expect(row.importable, isFalse);
  });

  group('the import page', () {
    Widget page() => const Scaffold(body: StudentImportScreen());

    testWidgets('in French on a computer: the file, then every line checked, then the login details', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
      await pumpSignedIn(tester, page(), size: const Size(1440, 1300));

      expect(find.text(fr.importTitle), findsOneWidget);
      expect(find.text(fr.importChooseTitle), findsOneWidget);
      expect(find.text(fr.importColumnsTitle), findsOneWidget);
      expect(find.text(fr.importCreateLogins), findsOneWidget);
      await tester.tap(find.text(fr.importTemplate));
      expect(opener.opened.single, 'http://api/students/import/template?lang=fr');

      await tester.tap(find.text(fr.chooseFile));
      await tester.pumpAndSettle();
      expect(find.text(fr.importReadLines(isolated('classe-4A.xlsx'), 8)), findsOneWidget);
      expect(find.text(fr.importReadyCount), findsOneWidget);
      expect(find.text(fr.importKnownNote(isolated('Sonia Kefi'), isolated('Rania'))), findsOneWidget);
      expect(find.text(fr.importExistsNote(isolated('Amine Kefi'))), findsOneWidget);
      expect(find.text(fr.importProblemParentPhoneInvalid), findsOneWidget);
      expect(find.text(fr.importProblemLevelUnknown(isolated('7ème'))), findsOneWidget);
      expect(find.text(fr.importSameParentNote(2)), findsOneWidget);
      expect(find.text(fr.importErrorsNote), findsOneWidget);
      expect(find.text('${fr.importSummary(5)}${fr.importSummaryParents(2)}'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text(fr.importAction(5)));
      await tester.pumpAndSettle();
      expect(find.text(fr.importDoneTitle(5)), findsOneWidget);
      expect(find.text('${fr.importDoneParents(2)}${fr.importDoneLinked(1)}'), findsOneWidget);
      expect(find.text('kpra4827'), findsOneWidget);
      expect(find.textContaining(fr.parentOf('')), findsNWidgets(2));

      await tester.tap(find.text(fr.importCopyAll));
      await tester.pump();
      expect(copied, contains('kpra4827'));
      expect(copied, contains('mhwe5932'));

      await tester.tap(find.text(fr.importPrint));
      await tester.pumpAndSettle();
      expect(printer.printed, [fr.printFileName]);
      expect(printer.pdf, isNotEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('on a phone, in Arabic: one card per line, the action at the bottom', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      await pumpSignedIn(tester, page(), language: AppLanguage.ar, size: const Size(360, 1600));
      await tester.tap(find.text(ar.chooseFile));
      await tester.pumpAndSettle();

      expect(find.text(ar.importStepOf(2, ar.importStepCheck)), findsOneWidget);
      expect(find.text(ar.importAction(5)), findsOneWidget);
      expect(find.text('22345678'), findsWidgets);
      expect(tester.widget<Text>(find.text('2234567')).textDirection, TextDirection.ltr);
      expect(tester.takeException(), isNull);
    });

    testWidgets('nothing ticked: nothing to import', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      repository.preview_ = ImportPreview(fileName: 'a.csv', rows: [sampleImport().rows[4]]);
      await pumpSignedIn(tester, page(), size: const Size(1440, 1000));
      await tester.tap(find.text(fr.chooseFile));
      await tester.pumpAndSettle();
      expect(find.text(fr.importSummary(0)), findsOneWidget);
      expect(tester.widget<PrimaryButton>(find.widgetWithText(PrimaryButton, fr.importAction(0))).onPressed, isNull);
    });

    testWidgets('"Importer" on Élèves opens it', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      sl.registerFactory<StudentsCubit>(() => StudentsCubit(FakeStudentRepository()));
      final router = GoRouter(
        initialLocation: Routes.teacherStudents,
        routes: [
          GoRoute(path: Routes.teacherStudents, builder: (_, _) => const Scaffold(body: StudentsScreen())),
          GoRoute(path: Routes.teacherStudentImport, builder: (_, _) => const Scaffold(body: Text('import'))),
        ],
      );
      addTearDown(router.dispose);
      await pumpSignedIn(tester, const SizedBox(), router: router, size: const Size(1440, 1000));
      await tester.tap(find.text(fr.quickImport));
      await tester.pumpAndSettle();
      expect(find.text('import'), findsOneWidget);
    });
  });
}
