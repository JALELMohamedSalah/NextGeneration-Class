import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ngclass/core/di/injection.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/formatting.dart';
import 'package:ngclass/core/router/routes.dart';
import 'package:ngclass/data/repository/dashboard_repository_impl.dart';
import 'package:ngclass/domain/model/app_notification.dart';
import 'package:ngclass/domain/model/content.dart';
import 'package:ngclass/domain/model/homework.dart';
import 'package:ngclass/view/screens/parent/parent_overview_screen.dart';
import 'package:ngclass/view/screens/shared/my_homework_detail_screen.dart';
import 'package:ngclass/view/screens/shared/my_results_screen.dart';
import 'package:ngclass/view/screens/shared/notifications_screen.dart';
import 'package:ngclass/view/screens/student/student_destinations.dart';
import 'package:ngclass/view/screens/teacher/homework/correction_screen.dart';
import 'package:ngclass/view/screens/teacher/homework/homework_screen.dart';
import 'package:ngclass/view/screens/teacher/teacher_destinations.dart';
import 'package:ngclass/view/screens/teacher/teacher_home_screen.dart';
import 'package:ngclass/view/stateManager/homework/correction_cubit.dart';
import 'package:ngclass/view/stateManager/homework/homework_list_cubit.dart';
import 'package:ngclass/view/stateManager/comments/comments_cubit.dart';
import 'package:ngclass/view/stateManager/homework/my_homework_cubit.dart';
import 'package:ngclass/view/stateManager/my_planning/my_planning_cubit.dart';
import 'package:ngclass/view/stateManager/notifications/notifications_cubit.dart';
import 'package:ngclass/view/stateManager/results/results_cubit.dart';
import 'package:ngclass/view/stateManager/teacher_home/teacher_home_cubit.dart';
import 'package:ngclass/view/widgets/adaptive_shell.dart';

import '../helpers/content_fixtures.dart';
import '../helpers/fakes.dart';
import '../helpers/homework_fixtures.dart';
import '../helpers/pump_app.dart';
import '../helpers/student_fixtures.dart';

RecipientRow row(String id, String first, String last, HomeworkStatus status, {DateTime? sent, double? score}) => RecipientRow(
  studentId: id,
  firstName: first,
  lastName: last,
  status: status,
  submittedAt: sent,
  submissionId: sent == null ? null : 'sub-$id',
  score: score,
);

/// "Série 2 : les fractions": Yasmine and Adam sent (Yasmine first), Rayen missing, Omar corrected.
List<RecipientRow> fractionsRows() => [
  row('s1', 'Adam', 'Gharbi', HomeworkStatus.submitted, sent: at(3, 17, 12)),
  row('s2', 'Rayen', 'Mansour', HomeworkStatus.missing),
  row('s3', 'Yasmine', 'Trabelsi', HomeworkStatus.submitted, sent: at(3, 16, 58)),
  row('s4', 'Omar', 'Saidi', HomeworkStatus.corrected, sent: at(3, 15, 5), score: 16),
];

/// The queue the server sends for those rows.
List<ToCorrectGroup> fractionsQueue() => [
  ToCorrectGroup(
    assignment: sampleAssignments().first,
    items: [
      ToCorrectItem(studentId: 's3', firstName: 'Yasmine', lastName: 'Trabelsi', status: HomeworkStatus.submitted, submittedAt: at(3, 16, 58), submissionId: 'sub-s3'),
      ToCorrectItem(studentId: 's1', firstName: 'Adam', lastName: 'Gharbi', status: HomeworkStatus.late, submittedAt: at(3, 17, 12), submissionId: 'sub-s1'),
    ],
  ),
];

FakeHomeworkRepository withCopies() => FakeHomeworkRepository()
  ..rows['a-fr'] = fractionsRows()
  ..queue = fractionsQueue();

void main() {
  setUpAll(initializeAppDates);

  group('formatting', () {
    test('scores with a decimal comma, averages with two decimals; what the teacher types is read both ways', () {
      expect(scoreText(14), '14');
      expect(scoreText(14.5), '14,5');
      expect(scoreText(12.25), '12,25');
      expect(averageText(12.5), '12,50');
      expect(parseScore('14,5'), 14.5);
      expect(parseScore(' 14.5 '), 14.5);
      expect(parseScore('quatorze'), isNull);
    });
  });

  group('CorrectionCubit', () {
    test('the copy opened first, then those waiting, oldest first', () async {
      final repository = withCopies();
      final fromCorrected = CorrectionCubit(repository, FakeFileChooser(), 'a-fr', 's4');
      await fromCorrected.load();
      expect(fromCorrected.state.copies.map((r) => r.studentId), ['s4', 's3', 's1']);
      expect(fromCorrected.state.index, 0);

      final fromAdam = CorrectionCubit(repository, FakeFileChooser(), 'a-fr', 's1');
      await fromAdam.load();
      expect(fromAdam.state.copies.map((r) => r.studentId), ['s3', 's1']);
      expect(fromAdam.state.index, 1);
      expect(fromAdam.state.view!.studentId, 's1');
    });

    test('a wrong score is refused; "Enregistrer et suivant" saves and opens the next copy, then says it is done', () async {
      final repository = withCopies();
      final cubit = CorrectionCubit(repository, FakeFileChooser(), 'a-fr', 's3');
      await cubit.load();

      for (final wrong in ['21', '14,3', 'quatorze', '']) {
        cubit.setScore(wrong);
        expect(await cubit.save(andNext: true), SaveOutcome.refused);
        expect(cubit.state.scoreError, isTrue);
      }
      expect(repository.grades, isEmpty);

      cubit.setScore('14,5');
      cubit.addPhrase('Très bien !');
      cubit.addPhrase('Bon travail');
      expect(cubit.state.comment, 'Très bien ! Bon travail');
      expect(await cubit.save(andNext: true), SaveOutcome.saved);
      expect(repository.grades.single, ('a-fr', 's3', 14.5, 'Très bien ! Bon travail'));
      expect(cubit.state.view!.studentId, 's1');
      expect(cubit.state.score, isEmpty);
      expect(cubit.state.copies.first.status, HomeworkStatus.corrected);

      cubit.setScore('12');
      expect(await cubit.save(andNext: true), SaveOutcome.finished);
      expect(repository.grades.last.$3, 12);
    });

    test('a corrected copy: a Word file is refused, a PDF attached, then taken back', () async {
      final repository = withCopies();
      final chooser = FakeFileChooser();
      final cubit = CorrectionCubit(repository, chooser, 'a-fr', 's3');
      await cubit.load();

      await cubit.attach(pdfFile('correction.docx'));
      expect(cubit.state.problem, FileProblem.unsupported);
      chooser.next = pdfFile('correction.pdf');
      await cubit.chooseAndAttach();
      expect(cubit.state.view!.file!.fileName, 'correction.pdf');
      expect(cubit.state.problem, isNull);
      await cubit.removeFile();
      expect(cubit.state.view!.file, isNull);
    });
  });

  test('HomeworkListCubit: opens on "À corriger" when copies wait; a subject filter', () async {
    final cubit = HomeworkListCubit(withCopies());
    await cubit.load();
    expect(cubit.state.tab, HomeworkTab.toCorrect);
    expect(cubit.state.countOf(HomeworkTab.toCorrect), 2);

    cubit.filterSubject('another');
    expect(cubit.state.visibleQueue, isEmpty);
    expect(cubit.state.countOf(HomeworkTab.open), 0);

    final quiet = HomeworkListCubit(FakeHomeworkRepository());
    await quiet.load();
    expect(quiet.state.tab, HomeworkTab.open);
  });

  test('MyResults: the mean of every grade on /20, latest first; ResultsCubit asks for the child', () async {
    final results = sampleResults();
    expect(results.average, 12.5);
    expect(results.grades.first.title, 'Série D');
    expect(results.submitted, 5);
    expect(results.due, 6);

    final repository = FakeResultsRepository();
    final cubit = ResultsCubit(repository);
    await cubit.load(studentId: 'me');
    expect(repository.askedFor, ['me']);
    expect(cubit.state.results!.subjects, hasLength(2));
  });

  group('teacher screens', () {
    setUp(() => registerTestServices(now));

    testWidgets('À corriger: a homework and its copies; "Corriger" opens the first, "Enregistrer et suivant" goes through them', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      final services = registerHomeworkServices(homework: withCopies());
      final router = GoRouter(
        initialLocation: Routes.teacherAssignments,
        routes: [
          GoRoute(
            path: Routes.teacherAssignments,
            builder: (_, _) => AdaptiveShell(destinations: teacherDestinations(), location: Routes.teacherAssignments, child: const HomeworkScreen()),
          ),
          GoRoute(
            path: Routes.teacherCorrection(':id', ':studentId'),
            builder: (_, state) => CorrectionScreen(assignmentId: state.pathParameters['id']!, studentId: state.pathParameters['studentId']!),
          ),
        ],
      );
      addTearDown(router.dispose);
      await pumpSignedIn(tester, const SizedBox(), router: router);

      expect(find.text('Yasmine Trabelsi'), findsOneWidget);
      expect(find.text('Adam Gharbi'), findsOneWidget);
      expect(find.text(fr.toCorrectInfo), findsOneWidget);

      // The homework's "Corriger" opens Yasmine's copy (the oldest).
      await tester.tap(find.text(fr.correctAction).first);
      await tester.pumpAndSettle();
      expect(find.byType(CorrectionScreen), findsOneWidget);
      expect(find.text(fr.copyOf(1, 2)), findsOneWidget);
      expect(find.text(fr.nextCopyName('Adam Gharbi')), findsOneWidget);
      expectEveryFieldHasAHint(find.byType(CorrectionScreen));

      await tester.enterText(find.byType(TextField).first, '21');
      await tester.tap(find.text(fr.saveAndNext));
      await tester.pumpAndSettle();
      expect(find.text(fr.scoreInvalid(20)), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '15,5');
      await tester.tap(find.text(fr.phraseGoodWork));
      await tester.pumpAndSettle();
      await tester.tap(find.text(fr.saveAndNext));
      await tester.pumpAndSettle();
      expect(services.homework.grades.single, ('a-fr', 's3', 15.5, 'Bon travail'));
      expect(find.text(fr.copyOf(2, 2)), findsOneWidget);
      expect(find.text(fr.lastCopy), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '12');
      await tester.tap(find.text(fr.saveAndNext));
      await tester.pumpAndSettle();
      expect(find.byType(CorrectionScreen), findsNothing);
      expect(find.text(fr.allCorrected), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a pupil who sent nothing can be graded anyway; on a phone in Arabic, nothing runs out', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      registerHomeworkServices(homework: withCopies());
      await pumpSignedIn(
        tester,
        BlocProvider(
          create: (_) => CorrectionCubit(sl.get(), sl.get(), 'a-fr', 's2')..load(),
          child: const CorrectionBody(),
        ),
        language: AppLanguage.ar,
        size: const Size(390, 844),
      );

      expect(find.text(ar.noWorkPane), findsOneWidget);
      expect(find.text(ar.copyOf(1, 3)), findsOneWidget);
      expect(find.text(ar.takeCorrectedPhoto), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Ma journée: the oldest copies to correct and the homework with missing work', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      final homework = withCopies()
        ..missingWork = [
          MissingWork(
            assignment: assignment('a-old', 'Série 1 : les fractions', deadlineAt: at(5, 18), counts: const StatusCounts(submitted: 3, missing: 2), recipients: 5),
            missing: const [
              PupilName(studentId: 's2', firstName: 'Rayen', lastName: 'Mansour'),
              PupilName(studentId: 's5', firstName: 'Sami', lastName: 'Ben Salah'),
            ],
          ),
        ];
      await pumpSignedIn(
        tester,
        BlocProvider(
          create: (_) => TeacherHomeCubit(DashboardRepositoryImpl(FakePlanningRepository(), homework, now: () => now))..load(),
          child: const Scaffold(body: TeacherHomeView()),
        ),
        size: const Size(1440, 1800),
      );

      expect(find.text('Yasmine Trabelsi'), findsOneWidget);
      expect(find.text(fr.attendanceLate), findsOneWidget);
      expect(find.text(fr.correctAction), findsNWidgets(2));
      expect(find.text('Série 1 : les fractions'), findsOneWidget);
      expect(find.text(fr.countOf(3, 5)), findsOneWidget);
      expect(find.text('RM'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('pupil and parent screens', () {
    setUp(() => registerTestServices(now));

    MyHomeworkDetail corrected() {
      final h = mineOf('h-old', 'Série 1 : les fractions', deadlineAt: at(3, 18), status: HomeworkStatus.corrected, submittedAt: at(2, 17, 12));
      return MyHomeworkDetail(
        homework: h,
        content: const ContentRef(id: 'serie1', title: 'Série 1 : les fractions', kind: FileKind.pdf, tag: ContentTag.serie, pageCount: 2),
        submission: SubmissionInfo(id: 'sub', submittedAt: at(2, 17, 12), fileName: 'travail.pdf', pageCount: 2),
        correction: Correction(
          score: 14,
          maxScore: 20,
          comment: 'Bon travail ! Revois la simplification des fractions.',
          correctedAt: at(6, 9),
          file: const CorrectionFile(fileName: 'correction.pdf', kind: FileKind.pdf, pageCount: 1),
        ),
      );
    }

    testWidgets('a corrected homework: the grade, the teacher\'s word, the corrected copy; nothing to send', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      final services = registerHomeworkServices();
      services.homework.details['h-old'] = corrected();
      await pumpSignedIn(tester, const MyHomeworkDetailScreen(assignmentId: 'h-old'), user: pupil, size: const Size(390, 844));

      expect(find.text(fr.yourGrade), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('Bon travail ! Revois la simplification des fractions.'), findsOneWidget);
      expect(find.text(fr.correctedCopy), findsOneWidget);
      expect(find.text(fr.myWork), findsOneWidget);
      expect(find.text(fr.takeMyWork), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a parent in Arabic reads the child\'s grade', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      final services = registerHomeworkServices();
      services.homework.details['h-old'] = corrected();
      await pumpSignedIn(
        tester,
        const MyHomeworkDetailScreen(assignmentId: 'h-old', studentId: 'me'),
        user: parent,
        language: AppLanguage.ar,
        size: const Size(390, 844),
      );

      expect(find.text(ar.childGrade(isolated('Adam'))), findsOneWidget);
      expect(find.text(ar.sentWork), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Résultats: the average and its trend, homework sent, attendance, each grade; no 0 without grades', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      registerHomeworkServices();
      await pumpSignedIn(
        tester,
        AdaptiveShell(destinations: studentDestinations(), location: Routes.studentResults, child: const MyResultsScreen()),
        user: pupil,
        size: const Size(390, 1600),
      );

      expect(find.text(fr.myResultsTitle), findsOneWidget);
      expect(find.text('12,50'), findsOneWidget);
      expect(find.text(fr.trendUp), findsOneWidget);
      expect(find.text(fr.averageOfGrades(4)), findsOneWidget);
      expect(find.text(fr.countOf(4, 5)), findsOneWidget);
      expect(find.text(fr.percentValue(95)), findsOneWidget);
      expect(find.text('Très bien !'), findsOneWidget);
      // 5/10 also on /20.
      expect(find.text('10,00 /20'), findsOneWidget);
      expect(find.text(fr.noGradeYet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a parent in Arabic: the child\'s results, and the overview cards that open them', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      final services = registerHomeworkServices();
      services.homework.mineItems = [...sampleMine(), mineOf('h-miss', 'Série 0', deadlineAt: at(4, 18), status: HomeworkStatus.missing)];
      await pumpSignedIn(tester, const MyResultsScreen(childId: 'me'), user: parent, language: AppLanguage.ar, size: const Size(390, 1600));
      expect(find.text(ar.parentResultsTitle(isolated('Adam'))), findsOneWidget);
      expect(services.results.askedFor, ['me']);

      await pumpSignedIn(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => MyPlanningCubit(FakePlanningRepository(), () => now)..load(studentId: 'me')),
            BlocProvider(create: (_) => ResultsCubit(services.results)..load(studentId: 'me')),
            BlocProvider(create: (_) => MyHomeworkCubit(services.homework, () => now)..load(studentId: 'me')),
            BlocProvider(create: (_) => CommentsCubit(FakeCommentRepository())..load()),
          ],
          child: const Scaffold(body: ParentOverviewView()),
        ),
        user: parent,
        language: AppLanguage.ar,
        size: const Size(390, 1200),
      );
      expect(find.text('12,50'), findsOneWidget);
      expect(find.text(ar.countOf(5, 6)), findsOneWidget);
      expect(find.text(ar.missingTitle(isolated('Série 0'))), findsOneWidget);
      expect(find.text('16/20'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a "Devoir corrigé" notification names the homework', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      final cubit = NotificationsCubit(
        FakeNotificationRepository(
          items: [
            AppNotification(
              id: 'n-c',
              kind: NotificationKind.corrected,
              groupName: '4ème année · Maths',
              startsAt: at(3, 18),
              createdAt: now.subtract(const Duration(hours: 1)),
              studentId: 'me',
              assignmentId: 'h-old',
              title: 'Série 1 : les fractions',
            ),
          ],
        ),
      );
      addTearDown(cubit.close);
      await pumpSignedIn(tester, const Scaffold(body: NotificationsScreen()), user: pupil, notifications: cubit);

      expect(find.text(fr.notificationCorrected), findsOneWidget);
      expect(find.text(isolated('Série 1 : les fractions')), findsOneWidget);
    });
  });
}
