import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/formatting.dart';
import 'package:ngclass/core/router/routes.dart';
import 'package:ngclass/data/repository/notification_repository_impl.dart';
import 'package:ngclass/domain/model/app_notification.dart';
import 'package:ngclass/view/screens/shared/notifications_screen.dart';
import 'package:ngclass/view/screens/teacher/teacher_destinations.dart';
import 'package:ngclass/view/screens/teacher/teacher_notifications_panel.dart';
import 'package:ngclass/view/stateManager/notifications/notifications_cubit.dart';
import 'package:ngclass/view/widgets/adaptive_shell.dart';
import 'package:ngclass/view/widgets/notification_bell.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';
import '../helpers/student_fixtures.dart' show now;

NamedPupil pupil(String id, String first, String last) => NamedPupil(id: id, firstName: first, lastName: last);

/// What the teacher finds on a Tuesday morning (design `r2/NotificationsEnseignante.png`): three unread today,
/// two read earlier. Long titles and names, to make rows wrap.
List<AppNotification> teacherSample(DateTime now) => [
  AppNotification(
    id: 't1',
    kind: NotificationKind.workSent,
    groupName: '4ème année · Maths',
    startsAt: now.add(const Duration(days: 2)),
    assignmentId: 'a1',
    title: 'Série 2 : les fractions',
    pupils: [pupil('p-adam', 'Adam', 'Gharbi'), pupil('p-sara', 'Sara', 'Ben Amor'), pupil('p-omar', 'Omar', 'Saidi')],
    createdAt: now.subtract(const Duration(minutes: 10)),
  ),
  AppNotification(
    id: 't2',
    kind: NotificationKind.workSent,
    groupName: 'Cours particulier · Mathématiques et lecture',
    startsAt: now.subtract(const Duration(days: 1)),
    assignmentId: 'a2',
    title: 'Série 1 : les fractions, exercices 1 à 3 et problème',
    pupils: [pupil('p-yas', 'Yasmine', 'Ben Abdallah Trabelsi')],
    late: true,
    createdAt: now.subtract(const Duration(hours: 1)),
  ),
  AppNotification(
    id: 't3',
    kind: NotificationKind.deadlinePassed,
    groupName: '4ème année · Lecture',
    startsAt: now.subtract(const Duration(hours: 2)),
    assignmentId: 'a3',
    title: 'Lecture : le corbeau et le renard',
    pupils: [pupil('p-rayen', 'Rayen', 'Mansour'), pupil('p-lina', 'Lina', 'Bouzid')],
    createdAt: now.subtract(const Duration(hours: 2)),
  ),
  AppNotification(
    id: 't4',
    kind: NotificationKind.deadlinePassed,
    groupName: '4ème année · Maths',
    startsAt: now.subtract(const Duration(days: 1)),
    assignmentId: 'a4',
    title: 'Table de 7',
    createdAt: now.subtract(const Duration(days: 1)),
    read: true,
  ),
  AppNotification(
    id: 't5',
    kind: NotificationKind.workSent,
    groupName: '4ème année · Maths',
    startsAt: now.subtract(const Duration(days: 3)),
    assignmentId: 'a5',
    title: 'Série 1 : les fractions',
    pupils: [
      pupil('1', 'Sami', 'Ben Salah'),
      pupil('2', 'Omar', 'Saidi'),
      pupil('3', 'Adam', 'Gharbi'),
      pupil('4', 'Amine', 'Kefi'),
      pupil('5', 'Lina', 'Bouzid'),
    ],
    createdAt: now.subtract(const Duration(days: 4)),
    read: true,
  ),
];

/// Without the isolate marks that keep a French name in order inside an Arabic line.
String plain(String text) => text.replaceAll(RegExp('[\u2066-\u2069]'), '');

void main() {
  setUpAll(initializeAppDates);
  setUp(() => registerTestServices(now));

  group('names', () {
    final pupils = teacherSample(now).last.pupils;

    test('one in full, then first names, three at most', () {
      final fr = l10nOf(AppLanguage.fr);
      expect(plain(pupilNames(fr, pupils.take(1).toList())), 'Sami Ben Salah');
      expect(plain(pupilNames(fr, pupils.take(2).toList())), 'Sami et Omar');
      expect(plain(pupilNames(fr, pupils.take(3).toList())), 'Sami, Omar et Adam');
      expect(plain(pupilNames(fr, pupils)), 'Sami, Omar, Adam et 2 autres');
      expect(plain(pupilNames(fr, pupils.take(2).toList(), full: true)), 'Sami Ben Salah et Omar Saidi');
      expect(pupilNames(fr, const []), isEmpty);
    });

    test('in Arabic', () {
      final ar = l10nOf(AppLanguage.ar);
      expect(plain(pupilNames(ar, pupils.take(3).toList())), 'Sami، Omar وAdam');
      expect(plain(pupilNames(ar, pupils)), 'Sami، Omar، Adam وآخران');
      expect(plain(pupilNames(ar, pupils.take(4).toList())), 'Sami، Omar، Adam وآخر');
      expect(plain(pupilNames(ar, [...pupils, ...pupils])), 'Sami، Omar، Adam و7 آخرين');
    });
  });

  test('the server\'s teacher notifications are read with their pupils', () {
    final sent = notificationOf({
      'id': 'n1',
      'type': 'WORK_SUBMITTED',
      'groupName': '4ème année · Maths',
      'startsAt': '2026-10-08T17:00:00Z',
      'assignmentId': 'a1',
      'title': 'Série 2 : les fractions',
      'pupils': [
        {'id': 's1', 'firstName': 'Adam', 'lastName': 'Gharbi'},
      ],
      'late': true,
      'createdAt': '2026-10-06T08:50:00Z',
      'read': false,
    });
    expect(sent.kind, NotificationKind.workSent);
    expect(sent.pupils, [pupil('s1', 'Adam', 'Gharbi')]);
    expect(sent.late, isTrue);
    expect(sent.markedRead().pupils, sent.pupils);

    final deadline = notificationOf({
      'id': 'n2',
      'type': 'DEADLINE_PASSED',
      'groupName': '4ème année · Maths',
      'startsAt': '2026-10-06T07:00:00Z',
      'createdAt': '2026-10-06T07:01:00Z',
    });
    expect(deadline.kind, NotificationKind.deadlinePassed);
    expect(deadline.pupils, isEmpty);
    expect(deadline.late, isFalse);
  });

  group('the teacher\'s bell and panel', () {
    Future<(NotificationsCubit, FakeNotificationRepository)> cubitWith(List<AppNotification> items) async {
      final repository = FakeNotificationRepository(items: items);
      final cubit = NotificationsCubit(repository);
      addTearDown(cubit.close);
      await cubit.refreshCount();
      return (cubit, repository);
    }

    Widget shell() => AdaptiveShell(
      destinations: teacherDestinations(),
      location: Routes.teacherHome,
      bell: const NotificationBell(onPressed: TeacherNotificationsPanel.open),
      child: const SizedBox.expand(),
    );

    testWidgets('in the top bar with the unread count; the panel words each event, in French', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      final (cubit, repository) = await cubitWith(teacherSample(now));
      await pumpSignedIn(tester, shell(), notifications: cubit);

      expect(find.descendant(of: find.byType(AppTopBar), matching: find.text('3')), findsOneWidget);
      await tester.tap(find.byType(NotificationBell));
      await tester.pumpAndSettle();

      expect(find.byType(TeacherNotificationsPanel), findsOneWidget);
      expect(find.text(fr.notificationsUnread(3)), findsOneWidget);
      expect(find.text(fr.notificationWorkSent(3)), findsOneWidget);
      expect(find.text(fr.notificationWorkSent(1)), findsOneWidget);
      expect(find.text(fr.notificationWorkSent(5)), findsOneWidget);
      expect(find.text(fr.workLate), findsOneWidget);
      expect(find.text(fr.notificationDeadlinePassed), findsNWidgets(2));
      expect(find.text(fr.everyoneSent), findsOneWidget);
      expect(find.textContaining('Rayen Mansour'), findsOneWidget);
      expect(find.text(fr.missingPupils(2, pupilNames(fr, teacherSample(now)[2].pupils, full: true))), findsOneWidget);
      expect(find.textContaining('Sami'), findsOneWidget);
      expect(find.text(fr.correctAction), findsNWidgets(3));
      expect(find.text(fr.actionSee), findsNWidgets(2));
      expect(find.text(fr.notificationsToday.toUpperCase()), findsOneWidget);
      expect(find.text(fr.notificationsEarlier.toUpperCase()), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text(fr.markAllRead));
      await tester.pumpAndSettle();
      expect(repository.readAll, 1);
      expect(cubit.state.unreadCount, 0);
      expect(find.text(fr.markAllRead), findsNothing);
    });

    Future<(FakeNotificationRepository, NotificationsCubit)> pumpRouted(WidgetTester tester) async {
      final (cubit, repository) = await cubitWith(teacherSample(now));
      final router = GoRouter(
        initialLocation: Routes.teacherHome,
        routes: [
          GoRoute(path: Routes.teacherHome, builder: (_, _) => shell()),
          GoRoute(
            path: Routes.teacherCorrection(':a', ':s'),
            builder: (_, state) => Scaffold(body: Text('copy ${state.pathParameters['a']} ${state.pathParameters['s']}')),
          ),
          GoRoute(path: Routes.teacherHomework(':id'), builder: (_, state) => Scaffold(body: Text('homework ${state.pathParameters['id']}'))),
        ],
      );
      addTearDown(router.dispose);
      await pumpSignedIn(tester, const SizedBox(), notifications: cubit, router: router);
      await tester.tap(find.byType(NotificationBell));
      await tester.pumpAndSettle();
      return (repository, cubit);
    }

    testWidgets('"Corriger" reads it, closes the panel and opens the first copy sent', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      final (repository, cubit) = await pumpRouted(tester);

      await tester.tap(find.text(fr.correctAction).first);
      await tester.pumpAndSettle();

      expect(find.text('copy a1 p-adam'), findsOneWidget);
      expect(find.byType(TeacherNotificationsPanel), findsNothing);
      expect(repository.readIds, ['t1']);
      expect(cubit.state.unreadCount, 2);
    });

    testWidgets('a deadline opens its homework, from the button or the row', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      final (repository, _) = await pumpRouted(tester);

      await tester.tap(find.text(fr.everyoneSent));
      await tester.pumpAndSettle();

      expect(find.text('homework a4'), findsOneWidget);
      expect(repository.readIds, isEmpty, reason: 'already read');
    });

    testWidgets('on a phone, in Arabic: the bell beside the avatar, the list over the whole screen', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      final (cubit, _) = await cubitWith(teacherSample(now));
      await pumpSignedIn(tester, shell(), notifications: cubit, language: AppLanguage.ar, size: const Size(320, 640));

      expect(find.descendant(of: find.byType(PhoneHeader), matching: find.byType(NotificationBell)), findsOneWidget);
      await tester.tap(find.byType(NotificationBell));
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(TeacherNotificationsPanel)).width, 320);
      expect(find.text(ar.navNotifications), findsWidgets);
      expect(find.text(ar.notificationWorkSent(3)), findsOneWidget);
      expect(find.text(ar.workLate), findsOneWidget);
      expect(find.text(ar.everyoneSent), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('nothing yet: says what will show up here', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      final (cubit, _) = await cubitWith(const []);
      await pumpSignedIn(tester, shell(), notifications: cubit);

      expect(find.byType(CountBadge), findsNothing);
      await tester.tap(find.byType(NotificationBell));
      await tester.pumpAndSettle();
      expect(find.text(fr.noNotificationsTeacher), findsOneWidget);
      expect(find.text(fr.noNotificationsHintTeacher), findsOneWidget);
      expect(find.text(fr.markAllRead), findsNothing);
    });
  });
}
