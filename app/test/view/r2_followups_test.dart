import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngclass/core/di/injection.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/formatting.dart';
import 'package:ngclass/domain/model/clock_time.dart';
import 'package:ngclass/domain/model/content.dart';
import 'package:ngclass/domain/model/results.dart';
import 'package:ngclass/domain/model/session.dart';
import 'package:ngclass/domain/model/student.dart';
import 'package:ngclass/domain/repositories/comment_repository.dart';
import 'package:ngclass/domain/repositories/planning_repository.dart';
import 'package:ngclass/domain/repositories/student_repository.dart';
import 'package:ngclass/view/screens/parent/parent_overview_screen.dart';
import 'package:ngclass/view/screens/teacher/contents/document_form_panel.dart';
import 'package:ngclass/view/screens/teacher/planning/session_mode_screen.dart';
import 'package:ngclass/view/screens/teacher/students/student_profile_screen.dart';
import 'package:ngclass/view/screens/teacher/teacher_quick_actions.dart';
import 'package:ngclass/view/stateManager/comments/comments_cubit.dart';
import 'package:ngclass/view/stateManager/day_content/day_content_cubit.dart';
import 'package:ngclass/view/stateManager/homework/my_homework_cubit.dart';
import 'package:ngclass/view/stateManager/my_planning/my_planning_cubit.dart';
import 'package:ngclass/view/stateManager/results/results_cubit.dart';
import 'package:ngclass/view/stateManager/session_mode/session_mode_cubit.dart';

import '../helpers/content_fixtures.dart';
import '../helpers/fakes.dart';
import '../helpers/homework_fixtures.dart';
import '../helpers/pump_app.dart';
import '../helpers/student_fixtures.dart';

void main() {
  setUpAll(initializeAppDates);

  group('Contenu du jour', () {
    test('a group sees the published documents shared with it, alone or through their chapter, last edited first', () {
      final library = Library(
        chapters: [fractions.copyWith(sharedGroupIds: const ['g9'])],
        documents: [
          doc('serie2', 'Série 2', updatedAt: DateTime.utc(2026, 10, 5)),
          doc('lecon', 'Leçon', shared: const [], updatedAt: DateTime.utc(2026, 10, 6)),
          doc('brouillon', 'Brouillon', status: ContentStatus.draft),
          doc('table', 'Table de 7', chapterId: 'ch-mul', updatedAt: DateTime.utc(2026, 9, 1)),
        ],
      );

      expect(library.sharedWith('g4a').map((d) => d.id), ['serie2', 'table']);
      expect(library.sharedWith('g9').map((d) => d.id), ['lecon', 'serie2']);
      expect(library.sharedWith('another'), isEmpty);
    });

    test('three documents at most, with the chapter of the latest', () async {
      final cubit = DayContentCubit(FakeContentRepository(), 'g4a');
      await cubit.load();

      expect(cubit.state.documents, hasLength(DayContentCubit.shown));
      expect(cubit.state.documents.last.id, 'lecon');
      expect(cubit.state.chapter, fractions);
    });

    group('in session mode', () {
      late FakePlanningRepository planning;
      setUp(() {
        registerTestServices(now);
        planning = FakePlanningRepository()
          ..detailResult = SessionDetail(
            session: session('s1', DateTime.utc(2026, 10, 6), const ClockTime(9, 30), status: SessionStatus.inProgress),
            roster: const [RosterEntry(studentId: 'a', firstName: 'Amine', lastName: 'Kefi')],
          );
        sl.registerSingleton<PlanningRepository>(planning);
      });

      Widget sessionMode() => BlocProvider(
        create: (_) => SessionModeCubit(planning, 's1', attendanceDelay: Duration.zero, noteDelay: Duration.zero)..open(),
        child: const SessionModeView(),
      );

      testWidgets('the group\'s documents open from the session, with their chapter', (tester) async {
        final fr = l10nOf(AppLanguage.fr);
        registerContentServices();
        await pumpSignedIn(tester, sessionMode());

        expect(find.text(fr.contentOfDay), findsOneWidget);
        expect(find.text('Leçon : les fractions simples'), findsOneWidget);
        expect(find.text(fr.actionOpen), findsNWidgets(3));
        expect(find.text('${fr.chapter}${fr.dotSeparator}${isolated('Les fractions')}'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('nothing shared with the group yet says so, in Arabic on a phone', (tester) async {
        final ar = l10nOf(AppLanguage.ar);
        registerContentServices(repository: FakeContentRepository(library: const Library()));
        await pumpSignedIn(tester, sessionMode(), language: AppLanguage.ar, size: const Size(390, 1400));

        expect(find.text(ar.dayContentEmpty), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });

  group('Fiche élève', () {
    late FakeResultsRepository results;
    setUp(() {
      registerTestServices(now);
      results = registerHomeworkServices().results;
      sl.registerSingleton<StudentRepository>(FakeStudentRepository()..students = [student('1', 'Amine', 'Kefi', rate: 94)]);
    });

    testWidgets('the Moyenne tile shows the average and opens each subject and grade', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpSignedIn(tester, const Scaffold(body: StudentProfileScreen(studentId: '1')), size: const Size(1440, 1400));

      expect(find.text('12,50 /20'), findsOneWidget);
      expect(find.text(fr.gradesCount(4)), findsOneWidget);
      await tester.tap(find.text(fr.average));
      await tester.pumpAndSettle();
      expect(find.text(fr.parentResultsTitle(isolated('Amine'))), findsOneWidget);
      expect(find.text('Série D'), findsOneWidget);
      expect(find.text(fr.trendUp), findsOneWidget);
    });

    testWidgets('no grade yet: "Pas encore de note", never 0', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      results.results = const MyResults(subjects: [SubjectResult(subject: mathRef, submitted: 0, due: 0)]);
      await pumpSignedIn(tester, const Scaffold(body: StudentProfileScreen(studentId: '1')), size: const Size(390, 1600));

      expect(find.text(fr.noGradeYet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Créer › Importer', () {
    setUp(() {
      registerTestServices(now);
      registerContentServices();
    });

    testWidgets('opens the import panel of Contenus from anywhere', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpSignedIn(tester, const Scaffold(body: Center(child: QuickActionsRow())));

      await tester.tap(find.text(fr.quickImport));
      await tester.pumpAndSettle();
      expect(find.byType(DocumentFormPanel), findsOneWidget);
      expect(find.text(fr.importDocument), findsOneWidget);
      expectEveryFieldHasAHint(find.byType(DocumentFormPanel));
    });
  });

  group('Mot de l\'enseignante', () {
    setUp(() => registerTestServices(now));

    Widget overview(CommentRepository comments) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MyPlanningCubit(FakePlanningRepository(), () => now)..load(studentId: 'me')),
        BlocProvider(create: (_) => ResultsCubit(FakeResultsRepository())..load(studentId: 'me')),
        BlocProvider(create: (_) => MyHomeworkCubit(FakeHomeworkRepository(), () => now)..load(studentId: 'me')),
        BlocProvider(create: (_) => CommentsCubit(comments)..load(studentId: 'me')),
      ],
      child: const Scaffold(body: ParentOverviewView()),
    );

    final comment = NoteEntry(
      id: 'c1',
      body: 'Adam participe bien. Il doit revoir la simplification des fractions avant vendredi.',
      createdAt: now.subtract(const Duration(hours: 2)),
      updatedAt: now.subtract(const Duration(hours: 2)),
    );

    testWidgets('the parent reads the teacher\'s latest comment, and when it was written', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      final comments = FakeCommentRepository(items: [comment]);
      await pumpSignedIn(tester, overview(comments), user: parent, size: const Size(390, 1400));

      expect(find.text(comment.body), findsOneWidget);
      expect(find.text('${fr.teacherNote}${fr.dotSeparator}${fr.hoursAgo(2).toLowerCase()}'), findsOneWidget);
      expect(comments.askedFor, ['me']);
    });

    testWidgets('in Arabic the French comment keeps its direction', (tester) async {
      await pumpSignedIn(tester, overview(FakeCommentRepository(items: [comment])), user: parent, language: AppLanguage.ar, size: const Size(390, 1400));
      expect(tester.widget<Text>(find.text(comment.body)).textDirection, TextDirection.ltr);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no comment yet says so', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      await pumpSignedIn(tester, overview(FakeCommentRepository()), user: parent, language: AppLanguage.ar, size: const Size(390, 1400));
      expect(find.text(ar.emptyComment), findsOneWidget);
    });
  });
}
