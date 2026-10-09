import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ngclass/core/di/injection.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/formatting.dart';
import 'package:ngclass/core/l10n/tunis_time.dart';
import 'package:ngclass/core/network/api_failure.dart';
import 'package:ngclass/core/router/routes.dart';
import 'package:ngclass/domain/model/app_user.dart';
import 'package:ngclass/domain/model/clock_time.dart';
import 'package:ngclass/domain/model/teacher_account.dart';
import 'package:ngclass/view/screens/admin/admin_destinations.dart';
import 'package:ngclass/view/screens/admin/new_teacher_panel.dart';
import 'package:ngclass/view/screens/admin/teachers_screen.dart';
import 'package:ngclass/view/stateManager/admin/teachers_cubit.dart';
import 'package:ngclass/view/stateManager/common/load_status.dart';
import 'package:ngclass/view/widgets/adaptive_shell.dart';
import 'package:ngclass/view/widgets/cards.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

/// Tuesday 6 October 2026, 10:00 in Tunis.
final now = TunisTime.instant(DateTime.utc(2026, 10, 6), const ClockTime(10, 0));

const owner = AppUser(
  id: 'a',
  role: UserRole.admin,
  username: 'admin',
  firstName: 'Administrateur',
  lastName: 'NG Class',
  mustChangePassword: false,
);

/// Ines teaches for a while, Sonia has not signed in yet, Karim's access is closed.
List<TeacherAccount> accounts() => [
  TeacherAccount(
    id: 't1',
    firstName: 'Ines',
    lastName: 'Haddad',
    username: 'enseignante',
    active: true,
    awaitingFirstLogin: false,
    lastLoginAt: now.subtract(const Duration(hours: 2)),
    createdAt: DateTime.utc(2026, 9, 1),
    students: 24,
    parents: 31,
    groups: 4,
  ),
  TeacherAccount(
    id: 't2',
    firstName: 'Sonia',
    lastName: 'Ben Ali',
    username: 'sonia.benali',
    phone: '22345678',
    active: true,
    awaitingFirstLogin: true,
    createdAt: DateTime.utc(2026, 10, 5),
  ),
  TeacherAccount(
    id: 't3',
    firstName: 'Karim',
    lastName: 'Jaziri',
    username: 'karim.jaziri',
    active: false,
    awaitingFirstLogin: false,
    lastLoginAt: DateTime.utc(2026, 9, 20, 9),
    createdAt: DateTime.utc(2026, 9, 2),
    students: 8,
    parents: 10,
    groups: 2,
  ),
];

void main() {
  setUpAll(initializeAppDates);

  late FakeAdminRepository repository;
  setUp(() {
    registerTestServices(now);
    repository = FakeAdminRepository(accounts: accounts());
    sl.registerFactory<TeachersCubit>(() => TeachersCubit(repository));
  });

  group('TeachersCubit', () {
    blocTest<TeachersCubit, TeachersState>(
      'loads the teachers and the totals across their spaces',
      build: () => TeachersCubit(FakeAdminRepository(accounts: accounts())),
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.status, LoadStatus.ready);
        expect(cubit.state.teachers, hasLength(3));
        expect(cubit.state.totals, const TeachersTotals(teachers: 3, activeTeachers: 2, students: 32, parents: 41, groups: 6));
      },
    );

    blocTest<TeachersCubit, TeachersState>(
      'search ignores accents, case and word order',
      build: () => TeachersCubit(FakeAdminRepository()),
      seed: () => TeachersState(status: LoadStatus.ready, teachers: accounts()),
      act: (cubit) => cubit.search('ali SÔNIA'),
      verify: (cubit) => expect(cubit.state.visible.map((t) => t.id), ['t2']),
    );

    test('a new teacher goes last, active, waiting for her first login', () async {
      final cubit = TeachersCubit(repository);
      addTearDown(cubit.close);
      await cubit.load();
      final (credential, failure) = await cubit.create(
        const TeacherDraft(firstName: 'Leila', lastName: 'Trabelsi', username: 'leila.trabelsi'),
      );
      expect(failure, isNull);
      expect(credential?.temporaryPassword, 'kprate4827');
      expect(cubit.state.teachers.last.fullName, 'Leila Trabelsi');
      expect(cubit.state.teachers.last.awaitingFirstLogin, isTrue);
      expect(cubit.state.totals.teachers, 4);
      expect(cubit.state.totals.activeTeachers, 3);
    });

    test('closing and reopening an access follows on the list and the totals', () async {
      final cubit = TeachersCubit(repository);
      addTearDown(cubit.close);
      await cubit.load();
      expect(await cubit.setActive(cubit.state.teachers.first, active: false), isNull);
      expect(cubit.state.teachers.first.active, isFalse);
      expect(cubit.state.totals.activeTeachers, 1);
      await cubit.setActive(cubit.state.teachers.last, active: true);
      expect(cubit.state.totals.activeTeachers, 2);
      expect(repository.activations, [('t1', false), ('t3', true)]);
    });

    test('a reset gives a new temporary password', () async {
      final cubit = TeachersCubit(repository);
      addTearDown(cubit.close);
      await cubit.load();
      final (credential, _) = await cubit.resetPassword(cubit.state.teachers.first);
      expect(credential?.temporaryPassword, 'hjkmnp2345');
      expect(cubit.state.teachers.first.awaitingFirstLogin, isTrue);
    });
  });

  test('a username is made from the name, without accents or spaces', () {
    expect(usernameFrom('Sonia', 'Ben Ali'), 'sonia.benali');
    expect(usernameFrom('Éya', "Ben Salah-Khémiri"), 'eya.bensalahkhemiri');
    expect(usernameFrom('', ''), '');
  });

  group('dashboard', () {
    /// The panel's fields in order: first name, last name, username, phone, email.
    Finder field(int index) => find.descendant(of: find.byType(NewTeacherPanel), matching: find.byType(TextField)).at(index);

    Future<void> pumpDashboard(WidgetTester tester, {AppLanguage language = AppLanguage.fr, Size size = const Size(1440, 1100)}) =>
        pumpSignedIn(
          tester,
          AdaptiveShell(destinations: adminDestinations(), location: Routes.adminTeachers, child: const TeachersScreen()),
          user: owner,
          language: language,
          size: size,
        );

    testWidgets('desktop in French: totals, one line per teacher, the status of each account', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpDashboard(tester);

      expect(find.text('ADMINISTRATION'), findsOneWidget);
      expect(find.text(fr.teachersSubtitle), findsOneWidget);
      expect(find.text(fr.newTeacher), findsOneWidget);

      // Totals across the spaces.
      expect(find.text('3'), findsOneWidget);
      expect(find.text(fr.activeAccounts(2)), findsOneWidget);
      expect(find.text('32'), findsOneWidget);
      expect(find.text('41'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);

      // The table.
      for (final column in [fr.columnTeacher, fr.columnStatus, fr.columnStudents, fr.columnGroups, fr.columnLastLogin]) {
        expect(find.text(column.toUpperCase()), findsWidgets);
      }
      expect(find.text('Ines Haddad'), findsOneWidget);
      expect(find.text(isolated('enseignante')), findsOneWidget);
      expect(find.text('${isolated('sonia.benali')}${fr.dotSeparator}${isolated('22345678')}'), findsOneWidget);
      expect(find.text(fr.teacherActive), findsOneWidget);
      expect(find.text(fr.teacherTemporaryPassword), findsOneWidget);
      expect(find.text(fr.teacherDisabled), findsOneWidget);
      expect(find.text('Il y a 2 h'), findsOneWidget);
      expect(find.text(fr.lastLoginNever), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('search narrows the list', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpDashboard(tester);

      await tester.enterText(find.byType(TextField).first, 'karim');
      await tester.pumpAndSettle();
      expect(find.text('Karim Jaziri'), findsOneWidget);
      expect(find.text('Ines Haddad'), findsNothing);
      expect(find.text(fr.teachersCount(1)), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'personne');
      await tester.pumpAndSettle();
      expect(find.text(fr.noResults), findsOneWidget);
    });

    testWidgets('a new teacher: the username follows the name, then the login details are shown once', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpDashboard(tester);

      await tester.tap(find.text(fr.newTeacher));
      await tester.pumpAndSettle();
      expect(find.text(fr.newTeacherSubtitle), findsOneWidget);
      expectEveryFieldHasAHint(find.byType(NewTeacherPanel));

      // Nothing typed: both names are asked for.
      await tester.tap(find.text(fr.createTeacherAccount));
      await tester.pumpAndSettle();
      expect(find.text(fr.fieldRequired), findsNWidgets(2));

      await tester.enterText(field(0), 'Leïla');
      await tester.enterText(field(1), 'Ben Salah');
      await tester.pumpAndSettle();
      expect(find.text('leila.bensalah'), findsOneWidget);

      await tester.tap(find.text(fr.createTeacherAccount));
      await tester.pumpAndSettle();

      expect(repository.created.single.username, 'leila.bensalah');
      expect(find.text(fr.credentialsTitle), findsOneWidget);
      expect(find.text('kprate4827'), findsOneWidget);
      expect(find.text(fr.teacherCredentialsNote), findsOneWidget);
      await tester.tap(find.text(fr.credentialsDone));
      await tester.pumpAndSettle();
      expect(find.text('Leïla Ben Salah'), findsOneWidget);
    });

    testWidgets('a refusal from the server stays in the panel', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      repository.createFailure = const ApiFailure(code: 'username_taken', message: "L'identifiant enseignante est déjà utilisé.");
      await pumpDashboard(tester);

      await tester.tap(find.text(fr.newTeacher));
      await tester.pumpAndSettle();
      await tester.enterText(field(0), 'Ines');
      await tester.enterText(field(1), 'Haddad');
      await tester.tap(find.text(fr.createTeacherAccount));
      await tester.pumpAndSettle();

      expect(find.text("L'identifiant enseignante est déjà utilisé."), findsOneWidget);
      expect(find.text(fr.newTeacherSubtitle), findsOneWidget);
    });

    testWidgets('closing an access asks first, then the line shows it', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpDashboard(tester);

      await tester.tap(find.byIcon(LucideIcons.ellipsis).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(fr.disableAccess));
      await tester.pumpAndSettle();
      expect(find.text(fr.disableTeacherTitle('Ines Haddad')), findsOneWidget);
      expect(find.text(fr.disableTeacherText), findsOneWidget);

      await tester.tap(find.text(fr.disableAccess).last);
      await tester.pumpAndSettle();
      expect(repository.activations, [('t1', false)]);
      expect(find.text(fr.teacherDisabled), findsNWidgets(2));
      expect(find.text(fr.teacherDisabledNotice('Ines Haddad')), findsOneWidget);
    });

    testWidgets('a password reset shows the new temporary password', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpDashboard(tester);

      await tester.tap(find.byIcon(LucideIcons.ellipsis).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(fr.resetPassword));
      await tester.pumpAndSettle();

      expect(repository.resets, ['t1']);
      expect(find.text(fr.resetPasswordTitle), findsOneWidget);
      expect(find.text('hjkmnp2345'), findsOneWidget);
    });

    testWidgets('phone in Arabic: right to left, stacked lines, no bottom bar for one section', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      await pumpDashboard(tester, language: AppLanguage.ar, size: const Size(390, 1600));

      expect(find.text(ar.navTeachers), findsWidgets);
      expect(find.text(ar.teacherTemporaryPassword), findsOneWidget);
      expect(find.byType(PhoneBottomNav), findsNothing);
      // Right to left: the name sits at the right of its avatar.
      expect(tester.getCenter(find.text('Ines Haddad')).dx, lessThan(tester.getCenter(find.text('IH')).dx));
      expect(tester.takeException(), isNull);
    });

    testWidgets('desktop in Arabic: each count sits under its heading, on the reading side', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      await pumpDashboard(tester, language: AppLanguage.ar);

      final students = tester.getTopRight(find.text(ar.columnStudents)).dx;
      final groups = tester.getTopRight(find.text(ar.columnGroups)).dx;
      expect(tester.getTopRight(find.text('24')).dx, moreOrLessEquals(students, epsilon: 1));
      expect(tester.getTopRight(find.text('4').last).dx, moreOrLessEquals(groups, epsilon: 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('small phone: a narrow tile puts its label under the icon', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpDashboard(tester, size: const Size(320, 1600));

      final badge = find.byWidgetPredicate((w) => w is IconBadge && w.icon == LucideIcons.graduationCap);
      final label = find.text(fr.navTeachers.toUpperCase());
      expect(tester.getTopLeft(label).dy, greaterThanOrEqualTo(tester.getBottomLeft(badge).dy));
      expect(tester.takeException(), isNull);
    });

    testWidgets('no teacher yet: says how to start', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      repository.accounts = [];
      await pumpDashboard(tester);

      expect(find.text(fr.noTeachers), findsOneWidget);
      expect(find.text(fr.noTeachersHint), findsOneWidget);
      expect(find.text(fr.newTeacher), findsNWidgets(2));
    });

    testWidgets('a failed load offers a retry', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      repository.failure = const ApiFailure(code: ApiFailure.network);
      await pumpDashboard(tester);

      expect(find.text(fr.errorNetwork), findsOneWidget);
      repository.failure = null;
      await tester.tap(find.text(fr.retry));
      await tester.pumpAndSettle();
      expect(find.text('Ines Haddad'), findsOneWidget);
    });
  });
}
