import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/formatting.dart';
import 'package:ngclass/core/l10n/tunis_time.dart';
import 'package:ngclass/core/network/api_failure.dart';
import 'package:ngclass/data/repository/dashboard_repository_impl.dart';
import 'package:ngclass/domain/model/app_user.dart';
import 'package:ngclass/domain/model/clock_time.dart';
import 'package:ngclass/domain/model/localized_text.dart';
import 'package:ngclass/domain/model/session.dart';
import 'package:ngclass/domain/model/teacher_dashboard.dart';
import 'package:ngclass/domain/repositories/dashboard_repository.dart';
import 'package:ngclass/view/screens/parent/parent_overview_screen.dart';
import 'package:ngclass/view/screens/student/student_home_screen.dart';
import 'package:ngclass/view/screens/teacher/teacher_home_screen.dart';
import 'package:ngclass/domain/model/results.dart';
import 'package:ngclass/view/stateManager/comments/comments_cubit.dart';
import 'package:ngclass/view/stateManager/homework/my_homework_cubit.dart';
import 'package:ngclass/view/stateManager/my_planning/my_planning_cubit.dart';
import 'package:ngclass/view/stateManager/results/results_cubit.dart';
import 'package:ngclass/view/stateManager/teacher_home/teacher_home_cubit.dart';

import '../helpers/fakes.dart';
import '../helpers/homework_fixtures.dart';
import '../helpers/pump_app.dart';

class _FailingDashboard implements DashboardRepository {
  @override
  Future<TeacherDashboard> teacherDashboard() async => throw const ApiFailure(code: ApiFailure.network);
}

/// Tuesday 6 October 2026, 12:40 in Tunis.
final now = TunisTime.instant(DateTime.utc(2026, 10, 6), const ClockTime(12, 40));
final tuesday = DateTime.utc(2026, 10, 6);

void main() {
  setUpAll(initializeAppDates);
  setUp(() => registerTestServices(now));

  Widget teacherHome(DashboardRepository repository) => BlocProvider(
    create: (_) => TeacherHomeCubit(repository)..load(),
    child: const Scaffold(body: TeacherHomeView()),
  );

  /// The parent overview also reads the child's results and homework: none yet.
  Widget mine(FakePlanningRepository repository, Widget view, {String? studentId}) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => MyPlanningCubit(repository, () => now)..load(studentId: studentId)),
      BlocProvider(create: (_) => ResultsCubit(FakeResultsRepository(results: const MyResults()))..load(studentId: studentId)),
      BlocProvider(create: (_) => MyHomeworkCubit(FakeHomeworkRepository(items: [], mine: []), () => now)..load(studentId: studentId)),
      BlocProvider(create: (_) => CommentsCubit(FakeCommentRepository())..load()),
    ],
    child: Scaffold(body: view),
  );

  for (final language in AppLanguage.values) {
    for (final size in const [Size(1440, 1800), Size(390, 2400)]) {
      testWidgets('Ma journée before any data, ${language.name} ${size.width.toInt()} px', (tester) async {
        final l10n = l10nOf(language);
        await pumpSignedIn(
          tester,
          teacherHome(DashboardRepositoryImpl(FakePlanningRepository(), FakeHomeworkRepository(items: [], mine: []), now: () => now)),
          language: language,
          size: size,
          groups: FakeGroupRepository()..groups = [],
        );

        expect(find.text(l10n.greeting('Ines')), findsOneWidget);
        expect(find.text(l10n.homeSummaryEmpty), findsOneWidget);
        expect(find.text(l10n.heroFreeDayTitle), findsOneWidget);
        for (final message in [l10n.emptyToday, l10n.emptyToCorrect, l10n.emptyMissing, l10n.emptyUpcoming]) {
          expect(find.text(message), findsOneWidget);
        }
        expect(find.text(l10n.daySessions(0)), findsNWidgets(5));
        expect(find.text(l10n.tomorrowSessions(0, '')), findsOneWidget);
      });
    }
  }

  testWidgets('Ma journée with sessions: the next one in the hero, today in the timeline, tomorrow in a note', (tester) async {
    final fr = l10nOf(AppLanguage.fr);
    final planning = FakePlanningRepository()
      ..all = [
        session('done', tuesday, const ClockTime(10, 0), status: SessionStatus.done),
        session('next', tuesday, const ClockTime(14, 0), mode: SessionMode.online, meetUrl: 'https://meet.google.com/abc'),
        session('tomorrow', DateTime.utc(2026, 10, 7), const ClockTime(10, 0)),
      ];
    await pumpSignedIn(tester, teacherHome(DashboardRepositoryImpl(planning, FakeHomeworkRepository(items: [], mine: []), now: () => now)), size: const Size(1440, 1800));

    expect(find.text(fr.homeSessionsToday(2)), findsOneWidget);
    expect(find.text('14:00'), findsWidgets);
    expect(find.text(fr.inDuration('1 h 20')), findsOneWidget);
    expect(find.text(fr.startSession), findsOneWidget);
    expect(find.text(fr.openMeet), findsOneWidget);
    expect(find.text(fr.statusDone), findsOneWidget);
    expect(find.text(fr.statusNext), findsOneWidget);
    expect(find.text(fr.tomorrowSessions(1, '10:00')), findsOneWidget);
    expect(find.text(fr.daySessions(2)), findsOneWidget);
  });

  testWidgets('Ma journée that cannot load says why and offers to retry', (tester) async {
    final fr = l10nOf(AppLanguage.fr);
    await pumpSignedIn(tester, teacherHome(_FailingDashboard()));

    expect(find.text(fr.errorNetwork), findsOneWidget);
    expect(find.text(fr.retry), findsOneWidget);
  });

  const studentUser = AppUser(
    id: 's',
    role: UserRole.student,
    username: 'adam',
    firstName: 'Adam',
    lastName: 'Gharbi',
    mustChangePassword: false,
  );

  testWidgets('student home before any data', (tester) async {
    final ar = l10nOf(AppLanguage.ar);
    await pumpSignedIn(
      tester,
      mine(FakePlanningRepository(), const StudentHomeView()),
      user: studentUser,
      language: AppLanguage.ar,
      size: const Size(390, 1400),
    );

    expect(find.text(ar.noSessionPlanned), findsOneWidget);
    expect(find.text(ar.weekSummary(0)), findsOneWidget);
    expect(find.text(ar.myWeek), findsOneWidget);
    expect(find.text(ar.nextWeekSessions(0)), findsOneWidget);
    // Work to do and results come with release 2: no empty cards for a child until then.
    expect(find.text(ar.nothingToDo), findsNothing);
    expect(find.text(ar.noGradeYet), findsNothing);
  });

  testWidgets('student home: the next session, and the join button opens the link', (tester) async {
    final fr = l10nOf(AppLanguage.fr);
    final links = registerTestServices(now);
    final planning = FakePlanningRepository()
      ..mine = [
        MySession(
          id: 'm1',
          group: ref4A,
          startsAt: TunisTime.instant(tuesday, const ClockTime(12, 50)),
          endsAt: TunisTime.instant(tuesday, const ClockTime(14, 20)),
          mode: SessionMode.online,
          status: SessionStatus.planned,
          meetUrl: 'https://meet.google.com/abc',
        ),
      ];
    await pumpSignedIn(tester, mine(planning, const StudentHomeView()), user: studentUser, size: const Size(390, 1400));

    expect(find.text('12:50'), findsOneWidget);
    expect(find.text(fr.todayInDuration('10 min')), findsOneWidget);
    await tester.tap(find.text(fr.joinSession));
    expect(links.opened, ['https://meet.google.com/abc']);
  });

  const level = LocalizedText(fr: '4ème année', ar: 'السنة الرابعة ابتدائي');
  const parentUser = AppUser(
    id: 'p',
    role: UserRole.parent,
    username: 'mouna',
    firstName: 'Mouna',
    lastName: 'Gharbi',
    mustChangePassword: false,
    children: [
      ChildSummary(studentId: '1', firstName: 'Adam', lastName: 'Gharbi', level: level),
      ChildSummary(studentId: '2', firstName: 'Lina', lastName: 'Gharbi', level: level),
    ],
  );

  testWidgets('parent overview before any data, switching child', (tester) async {
    final fr = l10nOf(AppLanguage.fr);
    await pumpSignedIn(
      tester,
      mine(FakePlanningRepository(), const ParentOverviewView(), studentId: '1'),
      user: parentUser,
      size: const Size(390, 1400),
    );

    expect(find.text(fr.childThisWeek('Adam')), findsOneWidget);
    expect(find.text(fr.parentNoDataYet), findsOneWidget);
    expect(find.text(fr.notYet), findsNWidgets(4));
    expect(find.text(fr.emptyComment), findsOneWidget);

    await tester.tap(find.text('Lina · 4ème année'));
    await tester.pumpAndSettle();
    expect(find.text(fr.childThisWeek('Lina')), findsOneWidget);
  });

  testWidgets('parent overview shows the next session and the attendance of the month', (tester) async {
    final fr = l10nOf(AppLanguage.fr);
    MySession mark(String id, DateTime day, AttendanceStatus? status, SessionStatus s) => MySession(
      id: id,
      group: ref4A,
      startsAt: TunisTime.instant(day, const ClockTime(16, 30)),
      endsAt: TunisTime.instant(day, const ClockTime(18, 0)),
      mode: SessionMode.inPerson,
      location: 'Salle 2',
      status: s,
      attendance: status,
    );
    final planning = FakePlanningRepository()
      ..mine = [
        mark('a', DateTime.utc(2026, 10, 1), AttendanceStatus.present, SessionStatus.done),
        mark('b', DateTime.utc(2026, 10, 2), AttendanceStatus.absent, SessionStatus.done),
        mark('c', tuesday, null, SessionStatus.planned),
      ];
    await pumpSignedIn(
      tester,
      mine(planning, const ParentOverviewView(), studentId: '1'),
      user: parentUser,
      size: const Size(390, 1400),
    );

    expect(find.text('Mar 16:30'), findsOneWidget);
    expect(find.text(fr.percentValue(50)), findsOneWidget);
    expect(find.text(fr.absencesThisMonth(1)), findsOneWidget);
  });

  testWidgets('parent without a linked child is told what to do', (tester) async {
    final fr = l10nOf(AppLanguage.fr);
    const parent = AppUser(
      id: 'p',
      role: UserRole.parent,
      username: 'mouna',
      firstName: 'Mouna',
      lastName: 'Gharbi',
      mustChangePassword: false,
    );
    await pumpSignedIn(tester, mine(FakePlanningRepository(), const ParentOverviewView()), user: parent, size: const Size(390, 1000));

    expect(find.text(fr.parentNoChild), findsOneWidget);
  });
}
