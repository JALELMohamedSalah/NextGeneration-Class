import 'package:flutter_test/flutter_test.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/tunis_time.dart';
import 'package:ngclass/data/repository/dashboard_repository_impl.dart';
import 'package:ngclass/domain/model/clock_time.dart';
import 'package:ngclass/domain/model/reference.dart';
import 'package:ngclass/domain/model/session.dart';
import 'package:ngclass/domain/model/student.dart';
import 'package:ngclass/view/stateManager/common/load_status.dart';
import 'package:ngclass/view/stateManager/my_planning/my_planning_cubit.dart';
import 'package:ngclass/view/stateManager/planning/planning_cubit.dart';
import 'package:ngclass/view/stateManager/session_form/session_form_cubit.dart';
import 'package:ngclass/view/stateManager/session_mode/session_mode_cubit.dart';
import 'package:ngclass/view/stateManager/student_form/student_form_cubit.dart';
import 'package:ngclass/view/stateManager/reference/reference_cubit.dart';
import 'package:ngclass/view/stateManager/students/students_cubit.dart';

import '../helpers/fakes.dart';
import '../helpers/homework_fixtures.dart';

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 5));

/// Tuesday 6 October 2026, 12:40 in Tunis.
final now = TunisTime.instant(DateTime.utc(2026, 10, 6), const ClockTime(12, 40));
final tuesday = DateTime.utc(2026, 10, 6);

void main() {
  group('student form', () {
    late FakeStudentRepository repository;

    setUp(() => repository = FakeStudentRepository());

    test('a primary pupil has no login by default: no username is checked or sent', () async {
      final cubit = StudentFormCubit(repository, debounce: Duration.zero);
      cubit
        ..setFirstName('Adam')
        ..setLastName('Gharbi')
        ..setLevel('l4');
      await settle();
      expect(repository.usernameChecks, isEmpty);
      await cubit.submit();
      expect(repository.created.single.createLogin, isFalse);
      expect(repository.created.single.username, isNull);
      expect(cubit.state.saved!.accounts, isEmpty);
      await cubit.close();
    });

    test('with an access, the username follows the name until the teacher types her own', () async {
      final cubit = StudentFormCubit(repository, debounce: Duration.zero)..setCreateLogin(true);
      cubit.setFirstName('Éya');
      cubit.setLastName('Ben Salah');
      expect(cubit.state.usernameStatus, UsernameStatus.checking);
      await settle();
      expect(cubit.state.username, 'éya.ben salah');
      expect(cubit.state.usernameStatus, UsernameStatus.available);

      repository.takenUsernames = {'eya.b'};
      cubit.setUsername('eya.b');
      await settle();
      expect(cubit.state.usernameStatus, UsernameStatus.taken);
      expect(repository.usernameChecks.last['username'], 'eya.b');
      await cubit.close();
    });

    test('nothing is sent while required fields are missing or a phone is wrong', () async {
      final cubit = StudentFormCubit(repository, debounce: Duration.zero);
      cubit.setPhone('12 34');
      cubit.addParent(const ParentDraft(firstName: 'Nadia', lastName: '', phone: '22'));
      await cubit.submit();
      expect(
        cubit.state.errors,
        containsAll([
          StudentFormError.firstName,
          StudentFormError.lastName,
          StudentFormError.level,
          StudentFormError.phone,
          StudentFormError.parentName,
          StudentFormError.parentPhone,
        ]),
      );
      expect(repository.created, isEmpty);
      await cubit.close();
    });

    test('a valid student with a new parent is saved with clean phones and the login details come back', () async {
      final cubit = StudentFormCubit(repository, debounce: Duration.zero, initialGroupId: 'g4a');
      cubit
        ..setCreateLogin(true)
        ..setFirstName('Omar')
        ..setLastName('Saidi')
        ..setLevel('l4')
        ..setPhone('+216 22 111 222')
        ..addParent(const ParentDraft(firstName: 'Nadia', lastName: 'Saidi', phone: '22.345.678', relation: 'mother'));
      await settle();
      await cubit.submit();
      final draft = repository.created.single;
      expect(draft.phone, '22111222');
      expect(draft.parents.single.phone, '22345678');
      expect(draft.groupIds, ['g4a']);
      expect(draft.username, isNull, reason: 'the server generates it');
      expect(cubit.state.saved!.accounts.single.temporaryPassword, 'kprate4827');
      await cubit.close();
    });

    test('two parents at most', () async {
      final cubit = StudentFormCubit(repository, debounce: Duration.zero);
      for (var i = 0; i < 3; i++) {
        cubit.addParent(const ParentDraft(firstName: 'A', lastName: 'B', phone: '22345678'));
      }
      expect(cubit.state.newParents, hasLength(2));
      expect(cubit.state.canAddParent, isFalse);
      await cubit.close();
    });
  });

  test('a subject the teacher creates is offered right away', () async {
    final repository = FakeReferenceRepository();
    final cubit = ReferenceCubit(repository);
    await cubit.load();
    final (subject, failure) = await cubit.createSubject(const SubjectDraft(nameFr: 'Éveil scientifique'));
    expect(failure, isNull);
    expect(cubit.state.reference!.subjects.map((s) => s.name.fr), ['Mathématiques', 'Éveil scientifique']);
    expect(subject!.name.of(AppLanguage.ar), 'Éveil scientifique', reason: 'no Arabic name: the French one shows');
    await cubit.close();
  });

  test('the student list searches without accents and filters by level', () async {
    final repository = FakeStudentRepository()..students = [student('1', 'Éya', 'Ben Salah'), student('2', 'Omar', 'Saidi')];
    final cubit = StudentsCubit(repository);
    await cubit.load();
    cubit.search('eya');
    expect(cubit.state.visible.map((s) => s.firstName), ['Éya']);
    cubit
      ..search('')
      ..filterLevel('other');
    expect(cubit.state.visible, isEmpty);
    await cubit.close();
  });

  group('planning', () {
    test('the week goes from Monday to Monday and moves by seven days', () async {
      final repository = FakePlanningRepository();
      final cubit = PlanningCubit(repository, () => now);
      await cubit.load();
      expect(repository.ranges.last.from, TunisTime.instant(DateTime.utc(2026, 10, 5)));
      expect(repository.ranges.last.to, TunisTime.instant(DateTime.utc(2026, 10, 12)));

      await cubit.next();
      expect(cubit.state.direction, 1);
      expect(repository.ranges.last.from, TunisTime.instant(DateTime.utc(2026, 10, 12)));

      await cubit.goToday();
      expect(cubit.state.day, tuesday);
      await cubit.close();
    });

    test('Sunday shows only when it has a session', () async {
      final repository = FakePlanningRepository();
      final cubit = PlanningCubit(repository, () => now);
      await cubit.load();
      expect(cubit.state.days, hasLength(6));
      repository.all = [session('s', DateTime.utc(2026, 10, 11), const ClockTime(9, 0))];
      await cubit.load();
      expect(cubit.state.days, hasLength(7));
      await cubit.close();
    });

    test('a group filter is sent to the server', () async {
      final repository = FakePlanningRepository();
      final cubit = PlanningCubit(repository, () => now);
      await cubit.setGroup('g4a');
      expect(repository.ranges.last.groupId, 'g4a');
      await cubit.close();
    });
  });

  group('session form', () {
    test('a weekly series counts its sessions and moving the start keeps the length', () async {
      final repository = FakePlanningRepository();
      final cubit = SessionFormCubit.create(
        repository,
        date: tuesday,
        start: const ClockTime(10, 0),
        schoolYearEnd: DateTime.utc(2026, 11, 3),
        group: group4A,
      );
      expect(cubit.state.sessionCount, 1);
      cubit.setRepeatWeekly(true);
      expect(cubit.state.sessionCount, 5, reason: '6, 13, 20, 27 October and 3 November');
      cubit.setStart(const ClockTime(14, 0));
      expect(cubit.state.end, const ClockTime(15, 30));
      await cubit.submit();
      expect(repository.drafts.single.repeatWeekly, isTrue);
      expect(repository.drafts.single.repeatUntil, DateTime.utc(2026, 11, 3));
      expect(cubit.state.created!.count, 5);
      await cubit.close();
    });

    test('an end before the start is refused, an overlap is only a warning', () async {
      final repository = FakePlanningRepository()..overlapping = [session('other', tuesday, const ClockTime(10, 30))];
      final cubit = SessionFormCubit.create(
        repository,
        date: tuesday,
        start: const ClockTime(10, 0),
        schoolYearEnd: DateTime.utc(2027, 6, 30),
        group: group4A,
      )..checkOverlaps();
      await settle();
      expect(cubit.state.overlaps, hasLength(1));
      cubit.setEnd(const ClockTime(9, 0));
      await cubit.submit();
      expect(cubit.state.errors, contains(SessionFormError.time));
      expect(repository.drafts, isEmpty);
      await cubit.close();
    });
  });

  group('session mode', () {
    SessionDetail detail() => SessionDetail(
      session: session('s1', tuesday, const ClockTime(10, 0), status: SessionStatus.inProgress),
      roster: const [
        RosterEntry(studentId: 'a', firstName: 'Amine', lastName: 'Kefi'),
        RosterEntry(studentId: 'b', firstName: 'Omar', lastName: 'Saidi'),
      ],
    );

    test('everyone starts present; a tap cycles absent, late, present and saves on its own', () async {
      final repository = FakePlanningRepository()..detailResult = detail();
      final cubit = SessionModeCubit(repository, 's1', attendanceDelay: Duration.zero, noteDelay: Duration.zero);
      await cubit.open();
      expect(cubit.state.count(AttendanceStatus.present), 2);

      cubit.tap('b');
      expect(cubit.state.markOf('b'), AttendanceStatus.absent);
      await settle();
      expect(repository.attendanceSaves.last, {'a': AttendanceStatus.present, 'b': AttendanceStatus.absent});
      expect(cubit.state.attendanceSave, SaveStatus.saved);

      cubit
        ..tap('b')
        ..tap('b');
      expect(cubit.state.markOf('b'), AttendanceStatus.present);
      await cubit.close();
    });

    test('the quick note saves itself and ending flushes everything first', () async {
      final repository = FakePlanningRepository()..detailResult = detail();
      final cubit = SessionModeCubit(repository, 's1', attendanceDelay: const Duration(hours: 1), noteDelay: const Duration(hours: 1));
      await cubit.open();
      cubit
        ..tap('a')
        ..setQuickNote('Exercice 4 difficile');
      await cubit.end();
      expect(repository.quickNotes.last, 'Exercice 4 difficile');
      expect(repository.attendanceSaves.last['a'], AttendanceStatus.absent);
      expect(repository.ends, 1);
      expect(cubit.state.ended, isTrue);
      await cubit.close();
    });
  });

  test('a parent sees the next session and the attendance of the last 30 days', () async {
    MySession mine(String id, DateTime day, {SessionStatus status = SessionStatus.done, AttendanceStatus? mark}) => MySession(
      id: id,
      group: ref4A,
      startsAt: TunisTime.instant(day, const ClockTime(10, 0)),
      endsAt: TunisTime.instant(day, const ClockTime(11, 30)),
      mode: SessionMode.inPerson,
      status: status,
      attendance: mark,
    );
    final repository = FakePlanningRepository()
      ..mine = [
        mine('1', DateTime.utc(2026, 9, 29), mark: AttendanceStatus.present),
        mine('2', DateTime.utc(2026, 10, 1), mark: AttendanceStatus.absent),
        mine('3', DateTime.utc(2026, 10, 2), mark: AttendanceStatus.late),
        mine('4', DateTime.utc(2026, 10, 7), status: SessionStatus.cancelled),
        mine('5', DateTime.utc(2026, 10, 8), status: SessionStatus.planned),
      ];
    final cubit = MyPlanningCubit(repository, () => now);
    await cubit.load(studentId: 'adam');
    final state = cubit.state;
    expect(state.status, LoadStatus.ready);
    expect(state.next!.id, '5', reason: 'the cancelled one is skipped');
    expect(state.monthAttendanceRate, 67);
    expect(state.monthAbsences, 1);
    expect(state.thisWeek.map((s) => s.id), ['4', '5']);
    await cubit.close();
  });

  test('Ma journée splits sessions by Tunisian day, even late in the evening', () async {
    final repository = FakePlanningRepository()
      ..all = [
        session('today-late', tuesday, const ClockTime(23, 30), minutes: 20),
        session('tomorrow', DateTime.utc(2026, 10, 7), const ClockTime(0, 30)),
        session('cancelled', tuesday, const ClockTime(17, 0), status: SessionStatus.cancelled),
      ];
    final dashboard = await DashboardRepositoryImpl(repository, FakeHomeworkRepository(items: [], mine: []), now: () => now).teacherDashboard();
    expect(dashboard.today.map((s) => s.id), ['today-late', 'cancelled']);
    expect(dashboard.tomorrow.map((s) => s.id), ['tomorrow']);
    expect(dashboard.todayCount, 1);
    expect(dashboard.nextDays.first.sessions, 1, reason: 'cancelled sessions do not count');
    expect(dashboard.next!.id, 'today-late');
  });
}
