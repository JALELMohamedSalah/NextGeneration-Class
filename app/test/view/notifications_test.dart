import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/formatting.dart';
import 'package:ngclass/core/l10n/tunis_time.dart';
import 'package:ngclass/core/network/api_failure.dart';
import 'package:ngclass/core/router/routes.dart';
import 'package:ngclass/domain/model/app_notification.dart';
import 'package:ngclass/domain/model/app_user.dart';
import 'package:ngclass/domain/model/clock_time.dart';
import 'package:ngclass/domain/model/localized_text.dart';
import 'package:ngclass/view/screens/parent/parent_destinations.dart';
import 'package:ngclass/view/screens/shared/notifications_screen.dart';
import 'package:ngclass/view/screens/student/student_destinations.dart';
import 'package:ngclass/view/stateManager/common/load_status.dart';
import 'package:ngclass/view/stateManager/notifications/notifications_cubit.dart';
import 'package:ngclass/view/widgets/adaptive_shell.dart';
import 'package:ngclass/view/widgets/labels.dart';
import 'package:ngclass/view/widgets/feedback.dart';
import 'package:ngclass/view/widgets/notification_bell.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

/// Tuesday 6 October 2026, 10:00 in Tunis.
final now = TunisTime.instant(DateTime.utc(2026, 10, 6), const ClockTime(10, 0));

DateTime at(int day, int hour, [int minute = 0]) => TunisTime.instant(DateTime.utc(2026, 10, day), ClockTime(hour, minute));

const groupName = '4ème année · Maths';

/// Two today (unread), two earlier (read): what a parent of Yasmine and Adam finds after a busy week.
List<AppNotification> sample({bool forChild = false}) => [
  AppNotification(
    id: 'n1',
    kind: NotificationKind.cancelled,
    studentId: 's1',
    childFirstName: forChild ? null : 'Yasmine',
    groupName: groupName,
    startsAt: at(8, 16),
    reason: 'Examen blanc',
    createdAt: now.subtract(const Duration(minutes: 5)),
  ),
  AppNotification(
    id: 'n2',
    kind: NotificationKind.moved,
    studentId: 's2',
    childFirstName: forChild ? null : 'Adam',
    groupName: groupName,
    startsAt: at(9, 15, 30),
    previousStartsAt: at(7, 14),
    createdAt: now.subtract(const Duration(hours: 3)),
  ),
  AppNotification(
    id: 'n3',
    kind: NotificationKind.cancelled,
    studentId: 's1',
    childFirstName: forChild ? null : 'Yasmine',
    groupName: groupName,
    startsAt: at(12, 16),
    sessionCount: 3,
    createdAt: at(5, 18),
    read: true,
  ),
  AppNotification(
    id: 'n4',
    kind: NotificationKind.restored,
    studentId: 's2',
    childFirstName: forChild ? null : 'Adam',
    groupName: groupName,
    startsAt: at(14, 16),
    createdAt: at(3, 11),
    read: true,
  ),
];

const level = LocalizedText(fr: '4ème année', ar: 'السنة الرابعة ابتدائي');

const parentOfTwo = AppUser(
  id: 'p',
  role: UserRole.parent,
  username: 'mouna',
  firstName: 'Mouna',
  lastName: 'Ben Salah',
  mustChangePassword: false,
  children: [
    ChildSummary(studentId: 's1', firstName: 'Yasmine', lastName: 'Ben Salah', level: level),
    ChildSummary(studentId: 's2', firstName: 'Adam', lastName: 'Ben Salah', level: level),
  ],
);

const parentOfOne = AppUser(
  id: 'p1',
  role: UserRole.parent,
  username: 'sami',
  firstName: 'Sami',
  lastName: 'Trabelsi',
  mustChangePassword: false,
  children: [ChildSummary(studentId: 's1', firstName: 'Yasmine', lastName: 'Trabelsi', level: level)],
);

const pupil = AppUser(
  id: 'c',
  role: UserRole.student,
  username: 'yasmine',
  firstName: 'Yasmine',
  lastName: 'Ben Salah',
  mustChangePassword: false,
);

void main() {
  setUpAll(initializeAppDates);
  setUp(() => registerTestServices(now));

  group('NotificationsCubit', () {
    blocTest<NotificationsCubit, NotificationsState>(
      'the badge count alone does not load the list',
      build: () => NotificationsCubit(FakeNotificationRepository(unread: 3)),
      act: (cubit) => cubit.refreshCount(),
      expect: () => [const NotificationsState(unreadCount: 3)],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'a failed count keeps the last badge, silently',
      build: () => NotificationsCubit(FakeNotificationRepository()..failure = const ApiFailure(code: ApiFailure.network)),
      seed: () => const NotificationsState(unreadCount: 2),
      act: (cubit) => cubit.refreshCount(),
      expect: () => const <NotificationsState>[],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'loads the list with the unread count',
      build: () => NotificationsCubit(FakeNotificationRepository(items: sample())),
      act: (cubit) => cubit.load(),
      expect: () => [
        const NotificationsState(),
        NotificationsState(status: LoadStatus.ready, items: sample(), unreadCount: 2, loaded: true),
      ],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'a failed load keeps its failure for the retry banner',
      build: () => NotificationsCubit(FakeNotificationRepository()..failure = const ApiFailure(code: ApiFailure.network)),
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.status, LoadStatus.failure);
        expect(cubit.state.failure?.isNetwork, isTrue);
        expect(cubit.state.loaded, isFalse);
      },
    );

    final repository = FakeNotificationRepository(items: sample());
    blocTest<NotificationsCubit, NotificationsState>(
      'reading one lowers the badge at once and tells the server; reading it again does nothing',
      build: () => NotificationsCubit(repository),
      seed: () => NotificationsState(status: LoadStatus.ready, items: sample(), unreadCount: 2, loaded: true),
      act: (cubit) => cubit
        ..markRead(sample().first)
        ..markRead(sample()[2]),
      verify: (cubit) {
        expect(cubit.state.unreadCount, 1);
        expect(cubit.state.items.first.read, isTrue);
        expect(cubit.state.items[1].read, isFalse);
        expect(repository.readIds, ['n1']);
      },
    );

    final everything = FakeNotificationRepository(items: sample());
    blocTest<NotificationsCubit, NotificationsState>(
      'mark all as read',
      build: () => NotificationsCubit(everything),
      seed: () => NotificationsState(status: LoadStatus.ready, items: sample(), unreadCount: 2, loaded: true),
      act: (cubit) => cubit
        ..markAllRead()
        ..markAllRead(),
      verify: (cubit) {
        expect(cubit.state.unreadCount, 0);
        expect(cubit.state.items.every((n) => n.read), isTrue);
        expect(everything.readAll, 1);
      },
    );

    test('polls the count until closed', () async {
      final repository = FakeNotificationRepository(unread: 4);
      final cubit = NotificationsCubit(repository, poll: const Duration(milliseconds: 10));
      await Future<void>.delayed(const Duration(milliseconds: 45));
      expect(cubit.state.unreadCount, 4);
      await cubit.close();
      final calls = repository.countCalls;
      expect(calls, greaterThanOrEqualTo(2));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(repository.countCalls, calls);
    });
  });

  group('timeAgo', () {
    test('in French', () {
      final fr = l10nOf(AppLanguage.fr);
      String ago(DateTime instant) => timeAgo(fr, AppLanguage.fr, instant, now);
      expect(ago(now), "À l'instant");
      expect(ago(now.subtract(const Duration(minutes: 1))), 'Il y a 1 min');
      expect(ago(now.subtract(const Duration(minutes: 42))), 'Il y a 42 min');
      expect(ago(now.subtract(const Duration(hours: 3))), 'Il y a 3 h');
      expect(ago(at(5, 23, 30)), 'Hier');
      expect(ago(at(3, 11)), 'Samedi 3 octobre');
    });

    test('in Arabic, with Tunisian months and Latin digits', () {
      final ar = l10nOf(AppLanguage.ar);
      String ago(DateTime instant) => timeAgo(ar, AppLanguage.ar, instant, now);
      expect(ago(now), 'الآن');
      expect(ago(now.subtract(const Duration(hours: 2))), 'منذ ساعتين');
      expect(ago(now.subtract(const Duration(minutes: 5))), 'منذ 5 دقائق');
      expect(ago(at(5, 8)), 'أمس');
      expect(ago(at(3, 11)), contains('3'));
      expect(ago(at(3, 11)), contains('أكتوبر'));
    });
  });

  group('NotificationsView', () {
    Future<(NotificationsCubit, FakeNotificationRepository)> pumpList(
      WidgetTester tester, {
      List<AppNotification>? items,
      AppUser user = parentOfTwo,
      AppLanguage language = AppLanguage.fr,
      Size size = const Size(1440, 1200),
      bool showBack = false,
    }) async {
      final repository = FakeNotificationRepository(items: items ?? sample());
      final cubit = NotificationsCubit(repository);
      addTearDown(cubit.close);
      await pumpSignedIn(
        tester,
        Scaffold(body: NotificationsScreen(showBack: showBack)),
        user: user,
        language: language,
        size: size,
        notifications: cubit,
      );
      return (cubit, repository);
    }

    testWidgets('parent of two, in French: today and earlier, each change worded, the child named', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpList(tester);

      expect(find.text(fr.notificationsUnread(2)), findsOneWidget);
      expect(find.text(fr.markAllRead), findsOneWidget);
      expect(find.text("AUJOURD'HUI"), findsOneWidget);
      expect(find.text('PLUS TÔT'), findsOneWidget);
      expect(tester.getTopLeft(find.text("AUJOURD'HUI")).dy, lessThan(tester.getTopLeft(find.text('PLUS TÔT')).dy));

      // Cancelled, with the reason the teacher gave.
      expect(find.text(fr.notificationCancelled(1)), findsOneWidget);
      expect(find.text('Jeudi 8 octobre · 16:00 · ${keptTogether(groupName)}'), findsOneWidget);
      expect(find.text(fr.cancelledBecause(isolated('Examen blanc'))), findsOneWidget);
      expect(find.text('Il y a 5 min'), findsOneWidget);

      // Moved: the former time struck through, the new one in bold.
      expect(find.text(fr.notificationMoved(1)), findsOneWidget);
      final before = tester.widget<Text>(find.text('Mercredi 7 octobre · 14:00'));
      expect(before.style?.decoration, TextDecoration.lineThrough);
      final after = tester.widget<Text>(find.text('Vendredi 9 octobre · 15:30 · ${keptTogether(groupName)}'));
      expect(after.style?.fontWeight, FontWeight.w700);
      expect(find.text('Il y a 3 h'), findsOneWidget);

      // A whole series at once.
      expect(find.text('3 séances annulées'), findsOneWidget);
      expect(find.text('À partir du lundi 12 octobre · ${keptTogether(groupName)}'), findsOneWidget);
      expect(find.text('Hier'), findsOneWidget);

      expect(find.text(fr.notificationRestored), findsOneWidget);
      expect(find.text('Samedi 3 octobre'), findsOneWidget);

      // Two children: each line says which one.
      expect(find.text('Yasmine'), findsNWidgets(2));
      expect(find.text('Adam'), findsNWidgets(2));
    });

    testWidgets('parent of one: no first name on every line', (tester) async {
      await pumpList(tester, user: parentOfOne);

      expect(find.text('Yasmine'), findsNothing);
      expect(find.text('Adam'), findsNothing);
    });

    testWidgets('child on a phone, in Arabic: right to left, Arabic wording, Latin times', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      await pumpList(
        tester,
        items: sample(forChild: true),
        user: pupil,
        language: AppLanguage.ar,
        size: const Size(390, 1400),
        showBack: true,
      );

      expect(find.text(ar.navNotifications), findsOneWidget);
      expect(find.text(ar.notificationsUnread(2)), findsOneWidget);
      expect(find.text(ar.notificationsToday), findsOneWidget);
      expect(find.text(ar.notificationsEarlier), findsOneWidget);
      expect(find.text(ar.notificationCancelled(1)), findsOneWidget);
      expect(find.text(ar.notificationMoved(1)), findsOneWidget);
      expect(find.text(ar.notificationCancelled(3)), findsOneWidget);
      expect(find.text(ar.notificationRestored), findsOneWidget);
      expect(find.text(ar.cancelledBecause(isolated('Examen blanc'))), findsOneWidget);
      expect(find.text('${dayDate(DateTime.utc(2026, 10, 7), AppLanguage.ar)} · 14:00'), findsOneWidget);
      // The French group name stays whole inside the Arabic line.
      expect(find.text('${dayDate(DateTime.utc(2026, 10, 8), AppLanguage.ar)} · 16:00 · ${keptTogether(groupName)}'), findsOneWidget);
      expect(find.text(ar.back), findsNothing);
      expect(find.byTooltip(ar.back), findsOneWidget);

      // Right to left: the title starts at the right edge of its tile.
      final title = tester.getTopRight(find.text(ar.notificationCancelled(1)));
      final tile = tester.getTopRight(find.byType(NotificationTile).first);
      expect(tile.dx - title.dx, lessThan(80));
      expect(tester.takeException(), isNull);
    });

    testWidgets('mark all as read', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      final (cubit, repository) = await pumpList(tester);

      await tester.tap(find.text(fr.markAllRead));
      await tester.pumpAndSettle();

      expect(find.text(fr.notificationsUnread(0)), findsOneWidget);
      expect(find.text(fr.markAllRead), findsNothing);
      expect(cubit.state.unreadCount, 0);
      expect(repository.readAll, 1);
    });

    testWidgets('nothing yet: says what will show up here', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpList(tester, items: const []);

      expect(find.text(fr.noNotifications), findsOneWidget);
      expect(find.text(fr.noNotificationsHint), findsOneWidget);
      expect(find.text(fr.markAllRead), findsNothing);
    });

    testWidgets('a failed load offers a retry', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      final repository = FakeNotificationRepository()..failure = const ApiFailure(code: ApiFailure.network);
      final cubit = NotificationsCubit(repository);
      addTearDown(cubit.close);
      await pumpSignedIn(
        tester,
        const Scaffold(body: NotificationsScreen()),
        user: parentOfTwo,
        notifications: cubit,
      );

      expect(find.byType(FailureBanner), findsOneWidget);
      repository
        ..failure = null
        ..items = sample();
      await tester.tap(find.text(fr.retry));
      await tester.pumpAndSettle();
      expect(find.text(fr.notificationCancelled(1)), findsOneWidget);
    });

    testWidgets("a parent's tap reads it and opens that child's planning", (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      final repository = FakeNotificationRepository(items: sample());
      final cubit = NotificationsCubit(repository);
      addTearDown(cubit.close);
      final router = GoRouter(
        initialLocation: Routes.parentNotifications,
        routes: [
          GoRoute(
            path: Routes.parentNotifications,
            builder: (_, _) => const Scaffold(body: NotificationsScreen()),
          ),
          GoRoute(
            path: Routes.parentPlanning,
            builder: (_, state) => Scaffold(body: Text('planning ${state.uri.queryParameters[Routes.childParam]}')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await pumpSignedIn(tester, const SizedBox(), user: parentOfTwo, notifications: cubit, router: router);

      await tester.tap(find.text(fr.notificationMoved(1)));
      await tester.pumpAndSettle();

      expect(find.text('planning s2'), findsOneWidget);
      expect(repository.readIds, ['n2']);
      expect(cubit.state.unreadCount, 1);
    });
  });

  group('badges', () {
    Future<NotificationsCubit> withUnread(int count) async {
      final cubit = NotificationsCubit(FakeNotificationRepository(unread: count));
      addTearDown(cubit.close);
      await cubit.refreshCount();
      return cubit;
    }

    testWidgets("the child's bell shows the unread count, 99+ past 99, nothing at 0", (tester) async {
      final cubit = await withUnread(3);
      await pumpSignedIn(
        tester,
        const Scaffold(body: Center(child: NotificationBell())),
        user: pupil,
        notifications: cubit,
      );
      expect(find.descendant(of: find.byType(CountBadge), matching: find.text('3')), findsOneWidget);

      await pumpSignedIn(
        tester,
        const Scaffold(body: Center(child: NotificationBell())),
        user: pupil,
        notifications: await withUnread(120),
      );
      expect(find.text('99+'), findsOneWidget);

      await pumpSignedIn(
        tester,
        const Scaffold(body: Center(child: NotificationBell())),
        user: pupil,
        notifications: await withUnread(0),
      );
      expect(find.byType(CountBadge), findsNothing);
    });

    testWidgets("the child's phone header carries the bell", (tester) async {
      await pumpSignedIn(
        tester,
        AdaptiveShell(
          destinations: studentDestinations(),
          location: Routes.studentHome,
          bell: const NotificationBell(),
          child: const SizedBox.expand(),
        ),
        user: pupil,
        size: const Size(390, 844),
        notifications: await withUnread(2),
      );

      expect(find.descendant(of: find.byType(PhoneHeader), matching: find.byType(NotificationBell)), findsOneWidget);
      expect(find.descendant(of: find.byType(PhoneHeader), matching: find.text('2')), findsOneWidget);
    });

    testWidgets("the parent's Notifications tab carries the count, in the sidebar and the bottom bar", (tester) async {
      Widget shell() => AdaptiveShell(destinations: parentDestinations(), location: Routes.parentOverview, child: const SizedBox.expand());
      final cubit = await withUnread(2);

      await pumpSignedIn(tester, shell(), user: parentOfTwo, notifications: cubit);
      expect(find.descendant(of: find.byType(AppSidebar), matching: find.text('2')), findsOneWidget);

      await pumpSignedIn(tester, shell(), user: parentOfTwo, size: const Size(390, 844), notifications: cubit);
      expect(find.descendant(of: find.byType(PhoneBottomNav), matching: find.byType(CountBadge)), findsOneWidget);
      expect(find.byType(NotificationBell), findsNothing);
    });
  });
}
