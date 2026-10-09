import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/formatting.dart';
import 'package:ngclass/core/router/routes.dart';
import 'package:ngclass/domain/model/evaluation.dart';
import 'package:ngclass/domain/model/results.dart';
import 'package:ngclass/view/screens/shared/my_results_screen.dart';
import 'package:ngclass/view/screens/teacher/homework/evaluation_panel.dart';
import 'package:ngclass/view/screens/teacher/homework/evaluation_screen.dart';
import 'package:ngclass/view/screens/teacher/homework/homework_screen.dart';
import 'package:ngclass/view/screens/teacher/students/group_screen.dart';
import 'package:ngclass/view/screens/teacher/teacher_quick_actions.dart';
import 'package:ngclass/view/stateManager/homework/evaluation_cubit.dart';
import 'package:ngclass/view/widgets/buttons.dart';

import '../helpers/homework_fixtures.dart';
import '../helpers/pump_app.dart';
import '../helpers/content_fixtures.dart' show mathRef;
import '../helpers/student_fixtures.dart' show now, parent;

/// Paper evaluations (design `r2/NouvelleEvaluation.png`, `Evaluation.png`, `EvaluationPhone.png`).
void main() {
  setUpAll(initializeAppDates);

  late FakeEvaluationRepository evaluations;
  setUp(() {
    registerTestServices(now);
    evaluations = FakeEvaluationRepository(items: [sampleEvaluation()], details: {'e1': sampleEvaluationDetail()});
    registerHomeworkServices(evaluations: evaluations);
  });

  group('EvaluationCubit', () {
    Future<EvaluationCubit> loaded() async {
      final cubit = EvaluationCubit(evaluations, 'e1');
      addTearDown(cubit.close);
      await cubit.load();
      return cubit;
    }

    test('reads the table: typed, absent, still to type, the average', () async {
      final cubit = await loaded();
      expect(cubit.state.pupils, 6);
      expect(cubit.state.typed, 3);
      expect(cubit.state.absent, 1);
      expect(cubit.state.toType, 2);
      expect(cubit.state.average, closeTo(14.5, 0.001));
      expect(cubit.state.entryOf('s-amine').text, '11,5');
      expect(cubit.state.dirty, isFalse);
    });

    test('a score above the scale or not in half points cannot be saved', () async {
      final cubit = await loaded();
      cubit.setScore('s-omar', '21');
      expect(cubit.state.problemOf('s-omar'), ScoreProblem.tooHigh);
      expect(cubit.state.valid, isFalse);
      expect(await cubit.save(), isNull);
      expect(evaluations.saves, isEmpty);

      cubit.setScore('s-omar', '12,3');
      expect(cubit.state.problemOf('s-omar'), ScoreProblem.halfPoints);
      cubit.setScore('s-omar', '12,5');
      expect(cubit.state.problemOf('s-omar'), isNull);
    });

    test('the tiles follow the keyboard, and only what changed is sent', () async {
      final cubit = await loaded();
      cubit.setScore('s-omar', '12,5');
      cubit.setAbsent('s-yasmine', true);
      expect(cubit.state.typed, 4);
      expect(cubit.state.absent, 2);
      expect(cubit.state.toType, 0);
      expect(cubit.state.average, closeTo(14, 0.001));
      expect(cubit.state.dirty, isTrue);

      expect(await cubit.save(), isNull);
      final (id, sent) = evaluations.saves.single;
      expect(id, 'e1');
      expect(sent, const [
        GradeInput(studentId: 's-omar', score: 12.5, comment: ''),
        GradeInput(studentId: 's-yasmine', absent: true, comment: ''),
      ]);
      expect(cubit.state.dirty, isFalse);
      expect(cubit.state.detail!.evaluation.graded, 4);
    });

    test('after "Modifier", what was typed and not saved stays', () async {
      final cubit = await loaded();
      cubit.setScore('s-omar', '9');
      cubit.replaced(sampleEvaluationDetail(maxScore: 10));
      expect(cubit.state.evaluation!.maxScore, 10);
      expect(cubit.state.entryOf('s-omar').text, '9');
      // On 10, Adam's 15 is now too high.
      expect(cubit.state.problemOf('s-adam'), ScoreProblem.tooHigh);
    });
  });

  group('the score table', () {
    Widget table() => const Scaffold(body: EvaluationScreen(evaluationId: 'e1'));

    testWidgets('in French on a computer: tiles, the keyboard table, a score too high refused on the spot', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpSignedIn(tester, table(), size: const Size(1440, 1100));

      expect(find.text('Évaluation : la multiplication'), findsOneWidget);
      expect(find.text('3 / 6', findRichText: true), findsOneWidget);
      expect(find.text('14,50 / 20', findRichText: true), findsOneWidget);
      expect(find.text(fr.columnComment.toUpperCase()), findsOneWidget);
      expect(find.text('Très bien, continue.'), findsOneWidget);
      expect(find.text(fr.keyboardHint), findsOneWidget);
      expect(find.text(fr.absentNeverZero), findsOneWidget);
      expectEveryFieldHasAHint(find.byType(EvaluationScreen));
      // Nothing typed yet: nothing to save.
      expect(tester.widget<PrimaryButton>(find.widgetWithText(PrimaryButton, fr.saveGrades)).onPressed, isNull);

      await tester.enterText(find.descendant(of: find.byKey(const ValueKey('score-s-omar')), matching: find.byType(TextField)), '21');
      await tester.pump();
      expect(find.text(fr.scoreTooHigh('20')), findsOneWidget);
      expect(tester.widget<PrimaryButton>(find.widgetWithText(PrimaryButton, fr.saveGrades)).onPressed, isNull);

      await tester.enterText(find.descendant(of: find.byKey(const ValueKey('score-s-omar')), matching: find.byType(TextField)), '12,5');
      await tester.pump();
      expect(find.text(fr.scoreTooHigh('20')), findsNothing);
      expect(find.text('4 / 6', findRichText: true), findsOneWidget);
      expect(find.text('14,00 / 20', findRichText: true), findsOneWidget);

      await tester.tap(find.widgetWithText(PrimaryButton, fr.saveGrades));
      await tester.pumpAndSettle();
      expect(evaluations.saves.single.$2.single, const GradeInput(studentId: 's-omar', score: 12.5, comment: ''));
      expect(find.text(fr.gradesSaved), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('"Absent" greys the score and counts apart', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpSignedIn(tester, table(), size: const Size(1440, 1100));

      final yasmine = find.bySemanticsLabel('Yasmine Ben Abdallah Trabelsi${fr.dotSeparator}${fr.absentLabel}');
      await tester.tap(find.descendant(of: yasmine, matching: find.byType(Checkbox)));
      await tester.pump();
      expect(find.byKey(const ValueKey('score-s-yasmine')), findsNothing);
      expect(find.text('2'), findsWidgets);
    });

    testWidgets('on a phone, in Arabic: one card per pupil, scores left to right', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      await pumpSignedIn(tester, table(), language: AppLanguage.ar, size: const Size(320, 1800));

      expect(find.text(ar.saveGrades), findsOneWidget);
      expect(find.text(ar.columnComment.toUpperCase()), findsNothing);
      expect(find.text(ar.keyboardHint), findsNothing);
      final score = tester.widget<TextField>(find.descendant(of: find.byKey(const ValueKey('score-s-adam')), matching: find.byType(TextField)));
      expect(score.textDirection, TextDirection.ltr);
      expect(tester.takeException(), isNull);
    });

    testWidgets('typed scores are not lost by going back: it asks first', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      final router = GoRouter(
        initialLocation: Routes.teacherAssignments,
        routes: [
          GoRoute(path: Routes.teacherAssignments, builder: (_, _) => const Scaffold(body: Text('devoirs'))),
          GoRoute(
            path: Routes.teacherEvaluation(':id'),
            builder: (_, state) => Scaffold(body: EvaluationScreen(evaluationId: state.pathParameters['id']!)),
          ),
        ],
      );
      addTearDown(router.dispose);
      await pumpSignedIn(tester, const SizedBox(), router: router, size: const Size(1440, 1100));
      router.push(Routes.teacherEvaluation('e1'));
      await tester.pumpAndSettle();

      await tester.enterText(find.descendant(of: find.byKey(const ValueKey('score-s-omar')), matching: find.byType(TextField)), '12');
      await tester.pump();
      await tester.tap(find.text(fr.navAssignments));
      await tester.pumpAndSettle();
      expect(find.text(fr.unsavedGradesTitle), findsOneWidget);

      await tester.tap(find.text(fr.leaveWithoutSaving));
      await tester.pumpAndSettle();
      expect(find.text('devoirs'), findsOneWidget);
      expect(evaluations.saves, isEmpty);
    });
  });

  group('Nouvelle évaluation', () {
    Future<GoRouter> pumpRouted(WidgetTester tester, Widget start, {Size size = const Size(1440, 1000)}) async {
      final router = GoRouter(
        initialLocation: Routes.teacherAssignments,
        routes: [
          GoRoute(path: Routes.teacherAssignments, builder: (_, _) => Scaffold(body: start)),
          GoRoute(
            path: Routes.teacherEvaluation(':id'),
            builder: (_, state) => Scaffold(
              body: EvaluationScreen(evaluationId: state.pathParameters['id']!, created: state.extra as EvaluationDetail?),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await pumpSignedIn(tester, const SizedBox(), router: router, size: size);
      return router;
    }

    testWidgets('from Devoirs: every field has a hint, the title is required, then straight to the table', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpRouted(tester, const HomeworkScreen());

      await tester.tap(find.text(fr.newEvaluation));
      await tester.pumpAndSettle();
      expect(find.byType(EvaluationPanel), findsOneWidget);
      expectEveryFieldHasAHint(find.byType(EvaluationPanel));

      await tester.tap(find.text(fr.createAndGrade));
      await tester.pump();
      expect(find.text(fr.fieldRequired), findsNWidgets(2));
      expect(evaluations.drafts, isEmpty);
    });

    testWidgets('from a group: that group first, "Autre" asks for the scale, then the table opens', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpRouted(
        tester,
        Builder(
          builder: (context) => TextButton(onPressed: () => EvaluationPanel.createAndGrade(context, groupId: 'g4a'), child: const Text('go')),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      expect(find.text('4ème année · Maths${fr.dotSeparator}${fr.studentsCount(2)}'), findsOneWidget);
      await tester.enterText(find.descendant(of: find.byType(EvaluationPanel), matching: find.byType(TextField)).first, 'Dictée n° 3');
      await tester.tap(find.text(fr.scaleOther));
      await tester.pump();
      await tester.tap(find.text(fr.createAndGrade));
      await tester.pump();
      expect(find.text(fr.scaleInvalid), findsOneWidget);

      await tester.enterText(find.descendant(of: find.byType(EvaluationPanel), matching: find.byType(TextField)).last, '40');
      await tester.tap(find.text(fr.createAndGrade));
      await tester.pumpAndSettle();

      final draft = evaluations.drafts.single;
      expect(draft.groupId, 'g4a');
      expect(draft.title, 'Dictée n° 3');
      expect(draft.maxScore, 40);
      expect(find.byType(EvaluationPanel), findsNothing);
      expect(find.byType(EvaluationScreen), findsOneWidget);
      expect(find.text('Dictée n° 3'), findsOneWidget);
      expect(find.text('0 / 6', findRichText: true), findsOneWidget);
    });

    testWidgets('in the "Créer" menu, not in the row of Ma journée', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpSignedIn(tester, const Scaffold(body: Center(child: QuickActionsRow())));
      expect(find.text(fr.quickEvaluation), findsNothing);
      expect(find.byType(QuickActionButton), findsNWidgets(5));

      await pumpSignedIn(tester, const Scaffold(appBar: _Bar(), body: SizedBox()));
      await tester.tap(find.text(fr.quickCreate));
      await tester.pumpAndSettle();
      expect(find.text(fr.quickEvaluation), findsOneWidget);
    });

    testWidgets('on the group\'s page', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpSignedIn(tester, const Scaffold(body: GroupScreen(groupId: 'g4a')), size: const Size(1440, 1000));
      expect(find.text(fr.newEvaluation), findsOneWidget);
    });
  });

  testWidgets('the Évaluations tab lists them, with the scores typed', (tester) async {
    final fr = l10nOf(AppLanguage.fr);
    await pumpSignedIn(tester, const Scaffold(body: HomeworkScreen()), size: const Size(1440, 1000));

    await tester.tap(find.text(fr.evaluationsTab));
    await tester.pumpAndSettle();
    expect(find.text('Évaluation : la multiplication'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('in Résultats each grade says where it comes from, and an absent reads "Absent", never 0', (tester) async {
    final fr = l10nOf(AppLanguage.fr);
    final result = SubjectResult(
      subject: mathRef,
      average: 15,
      gradeCount: 2,
      submitted: 1,
      due: 1,
      grades: [
        GradeItem(
          kind: GradeKind.evaluation,
          evaluationId: 'e1',
          title: 'Évaluation : la multiplication',
          date: DateTime.utc(2026, 10, 7),
          score: 15,
          maxScore: 20,
          score20: 15,
        ),
        GradeItem(assignmentId: 'a1', title: 'Série 1 : les fractions', date: DateTime.utc(2026, 10, 3), score: 7, maxScore: 10, score20: 14),
        GradeItem(kind: GradeKind.evaluation, evaluationId: 'e0', title: 'Dictée n° 1', date: DateTime.utc(2026, 9, 29), maxScore: 20, absent: true),
      ],
    );
    await pumpSignedIn(tester, Scaffold(body: SingleChildScrollView(child: SubjectCard(result: result))), user: parent);

    expect(find.text(fr.gradeKindEvaluation), findsNWidgets(2));
    expect(find.text(fr.gradeKindHomework), findsOneWidget);
    expect(find.text(fr.absentLabel), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });
}

/// The top bar's "Créer" button, alone.
class _Bar extends StatelessWidget implements PreferredSizeWidget {
  const _Bar();

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) => const Align(alignment: AlignmentDirectional.centerEnd, child: CreateMenuButton());
}
