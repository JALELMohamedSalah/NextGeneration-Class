import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngclass/core/di/injection.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/formatting.dart';
import 'package:ngclass/core/l10n/tunis_time.dart';
import 'package:ngclass/domain/model/clock_time.dart';
import 'package:ngclass/domain/model/session.dart';
import 'package:ngclass/domain/model/results.dart';
import 'package:ngclass/domain/repositories/planning_repository.dart';
import 'package:ngclass/domain/repositories/results_repository.dart';
import 'package:ngclass/domain/repositories/student_repository.dart';
import 'package:ngclass/view/screens/teacher/planning/planning_screen.dart';
import 'package:ngclass/view/screens/teacher/planning/scope_dialog.dart';
import 'package:ngclass/view/screens/teacher/planning/session_form_panel.dart';
import 'package:ngclass/view/screens/teacher/planning/session_mode_screen.dart';
import 'package:ngclass/view/screens/teacher/students/students_screen.dart';
import 'package:ngclass/view/stateManager/planning/planning_cubit.dart';
import 'package:ngclass/view/stateManager/session_form/session_form_cubit.dart';
import 'package:ngclass/view/stateManager/session_mode/session_mode_cubit.dart';
import 'package:ngclass/view/stateManager/students/students_cubit.dart';
import 'package:ngclass/view/widgets/controls.dart';
import 'package:ngclass/view/widgets/panels.dart';
import 'package:ngclass/view/widgets/school_widgets.dart';

import '../helpers/content_fixtures.dart';
import '../helpers/fakes.dart';
import '../helpers/homework_fixtures.dart';
import '../helpers/pump_app.dart';

/// Tuesday 6 October 2026, 12:40 in Tunis.
final now = TunisTime.instant(DateTime.utc(2026, 10, 6), const ClockTime(12, 40));
final tuesday = DateTime.utc(2026, 10, 6);

void main() {
  setUpAll(initializeAppDates);

  late FakeStudentRepository students;
  late FakePlanningRepository planning;

  setUp(() {
    registerTestServices(now);
    students = FakeStudentRepository()
      ..students = [
        student('1', 'Amine', 'Kefi', rate: 94),
        student('2', 'Malek', 'Jaziri', rate: 71, absences: 2),
        student('3', 'Éya', 'Ben Salah'),
      ];
    planning = FakePlanningRepository();
    sl.registerSingleton<StudentRepository>(students);
    sl.registerSingleton<PlanningRepository>(planning);
    // Session mode lists the group's documents; the Fiche élève reads the pupil's results.
    registerContentServices();
    sl.registerSingleton<ResultsRepository>(FakeResultsRepository(results: const MyResults()));
  });

  Widget studentsScreen() => BlocProvider(
    create: (_) => StudentsCubit(students)..load(),
    child: const Scaffold(body: StudentsView()),
  );

  group('Élèves', () {
    testWidgets('rows show groups, attendance and a warning after two absences; the search narrows them', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpSignedIn(tester, studentsScreen());

      expect(find.text('Amine Kefi'), findsOneWidget);
      expect(find.text(fr.percentValue(94)), findsOneWidget);
      expect(find.text(fr.noValue), findsOneWidget, reason: 'Éya has no attendance yet');
      expect(find.text(fr.absencesCount(2)), findsOneWidget);
      expect(find.text(fr.studentsYearSummary(fr.studentsCount(3), fr.groupsCount(1), fr.privateLessonsCount(0))), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'eya');
      await tester.pumpAndSettle();
      expect(find.text('Éya Ben Salah'), findsOneWidget);
      expect(find.text('Amine Kefi'), findsNothing);
    });

    testWidgets('the Groupes tab shows the group cards', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpSignedIn(tester, studentsScreen());

      await tester.tap(find.text(fr.tabGroups));
      await tester.pumpAndSettle();
      expect(find.text('4ème année · Maths'), findsOneWidget);
      expect(find.text(fr.noSchedule), findsOneWidget);
      expect(find.text(fr.newGroup), findsOneWidget);
    });

    testWidgets('in Arabic the list reads right to left', (tester) async {
      await pumpSignedIn(tester, studentsScreen(), language: AppLanguage.ar);

      final avatar = tester.getCenter(find.text('AK'));
      final name = tester.getCenter(find.text('Amine Kefi'));
      expect(avatar.dx, greaterThan(name.dx));
    });

    testWidgets('a new student: required fields first, then the login details shown once', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpSignedIn(tester, studentsScreen());

      await tester.tap(find.text(fr.newStudent).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(fr.save));
      await tester.pumpAndSettle();
      expect(find.text(fr.fieldRequired), findsNWidgets(3));

      final fields = find.descendant(of: find.byType(SidePanel), matching: find.byType(TextField));
      await tester.enterText(fields.at(0), 'Omar');
      await tester.enterText(fields.at(1), 'Saidi');
      await tester.tap(find.text(fr.chooseLevel));
      await tester.pumpAndSettle();
      await tester.tap(find.text('4ème année').last);
      await tester.pumpAndSettle();
      // This child gets their own login (off by default in primary school).
      await tester.ensureVisible(find.byType(BrandSwitch));
      await tester.tap(find.byType(BrandSwitch));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      expectEveryFieldHasAHint(find.byType(SidePanel));
      await tester.tap(find.text(fr.save));
      await tester.pumpAndSettle();

      expect(students.created.single.firstName, 'Omar');
      expect(find.text(fr.credentialsTitle), findsOneWidget);
      expect(find.text('kprate4827'), findsOneWidget);
      await tester.tap(find.text(fr.credentialsDone));
      await tester.pumpAndSettle();
      expect(find.text('kprate4827'), findsNothing);
    });
  });

  group('session mode', () {
    SessionDetail detail() => SessionDetail(
      session: session('s1', tuesday, const ClockTime(12, 0), status: SessionStatus.inProgress),
      roster: const [
        RosterEntry(studentId: 'a', firstName: 'Amine', lastName: 'Kefi'),
        RosterEntry(studentId: 'b', firstName: 'Omar', lastName: 'Saidi'),
      ],
    );

    Widget sessionMode() => BlocProvider(
      create: (_) => SessionModeCubit(planning, 's1', attendanceDelay: Duration.zero, noteDelay: Duration.zero)..open(),
      child: const SessionModeView(),
    );

    testWidgets('everyone is present; one tap marks a student absent and the counts follow', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      planning.detailResult = detail();
      await pumpSignedIn(tester, sessionMode());

      expect(find.text(fr.inProgressFor(40)), findsOneWidget);
      expect(find.text(fr.presentCount(2)), findsOneWidget);
      await tester.tap(find.text('Omar Saidi'));
      await tester.pumpAndSettle();
      expect(find.text(fr.attendanceAbsent), findsOneWidget);
      expect(find.text(fr.absentCount(1)), findsOneWidget);
      expect(planning.attendanceSaves.last['b'], AttendanceStatus.absent);
    });

    testWidgets('in Arabic on a phone the tiles stack and still cycle', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      planning.detailResult = detail();
      await pumpSignedIn(tester, sessionMode(), language: AppLanguage.ar, size: const Size(390, 1400));

      await tester.tap(find.text('Amine Kefi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Amine Kefi'));
      await tester.pumpAndSettle();
      expect(find.text(ar.attendanceLate), findsOneWidget);
      expect(find.byType(AttendanceTile), findsNWidgets(2));
    });
  });

  group('planning', () {
    setUp(() {
      planning.all = [
        session('done', tuesday, const ClockTime(10, 0), status: SessionStatus.done),
        session('next', tuesday, const ClockTime(14, 0)),
        session('cancelled', DateTime.utc(2026, 10, 7), const ClockTime(15, 0), status: SessionStatus.cancelled),
      ];
    });

    testWidgets('the week shows each session as a block with its time and status', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpSignedIn(
        tester,
        BlocProvider(
          create: (_) => PlanningCubit(planning, () => now)..load(),
          child: const Scaffold(body: PlanningBoard()),
        ),
        size: const Size(1440, 1200),
      );

      expect(find.text('4ème année · Maths'), findsNWidgets(4), reason: 'three blocks and the legend');
      expect(find.text('${fr.timeRange('14:00', '15:30')}${fr.dotSeparator}${fr.statusNext}'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(fr.statusCancelled)), findsOneWidget);
      expect(find.text(fr.planningLegend), findsOneWidget);
    });

    testWidgets('on a phone the day is a list, and another day is one tap away', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpSignedIn(
        tester,
        BlocProvider(
          create: (_) => PlanningCubit(planning, () => now, view: PlanningView.day)..load(),
          child: const Scaffold(body: PlanningBoard()),
        ),
        size: const Size(390, 1400),
      );

      expect(find.text(fr.statusDone), findsOneWidget);
      expect(find.text(fr.statusNext), findsOneWidget);
      await tester.tap(find.text('7'));
      await tester.pumpAndSettle();
      expect(find.text(fr.statusCancelled), findsOneWidget);
    });

    testWidgets('editing a session says families hear of a new time; a new session does not', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      Widget form(SessionFormCubit cubit) => BlocProvider(
        key: UniqueKey(),
        create: (_) => cubit,
        child: const Scaffold(body: SessionFormPanel()),
      );

      await pumpSignedIn(tester, form(SessionFormCubit.edit(planning, planning.all[1])), size: const Size(1440, 1400));
      expect(find.text(fr.familiesWillBeTold), findsOneWidget);
      expect(find.text(fr.repeatWeekly), findsNothing);

      await pumpSignedIn(
        tester,
        form(SessionFormCubit.create(planning, date: tuesday, start: const ClockTime(16, 0), schoolYearEnd: DateTime.utc(2027, 6, 30))),
        size: const Size(1440, 1400),
      );
      expect(find.text(fr.familiesWillBeTold), findsNothing);
      expect(find.text(fr.repeatWeekly), findsOneWidget);
    });

    testWidgets('cancelling says families are told in the app and see the reason', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpSignedIn(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(onPressed: () => askCancel(context, planning.all[1]), child: const Text('open')),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text(fr.cancelVisibleNote), findsOneWidget);
    });
  });
}
