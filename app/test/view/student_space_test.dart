import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ngclass/core/di/injection.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/formatting.dart';
import 'package:ngclass/core/router/routes.dart';
import 'package:ngclass/domain/model/app_notification.dart';
import 'package:ngclass/domain/model/app_user.dart';
import 'package:ngclass/domain/model/session.dart';
import 'package:ngclass/domain/repositories/planning_repository.dart';
import 'package:ngclass/view/screens/shared/my_planning_screen.dart';
import 'package:ngclass/view/screens/shared/notifications_screen.dart';
import 'package:ngclass/view/screens/student/student_destinations.dart';
import 'package:ngclass/view/screens/student/student_home_screen.dart';
import 'package:ngclass/view/stateManager/notifications/notifications_cubit.dart';
import 'package:ngclass/view/widgets/adaptive_shell.dart';
import 'package:ngclass/view/widgets/labels.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';
import '../helpers/student_fixtures.dart';

void main() {
  setUpAll(initializeAppDates);

  late FakePlanningRepository planning;
  setUp(() {
    registerTestServices(now);
    planning = FakePlanningRepository()..mine = week();
    sl.registerSingleton<PlanningRepository>(planning);
  });

  Future<NotificationsCubit> pumpPupil(
    WidgetTester tester,
    Widget screen, {
    AppLanguage language = AppLanguage.fr,
    List<AppNotification>? notifications,
    AppUser user = pupil,
  }) async {
    final cubit = NotificationsCubit(FakeNotificationRepository(items: notifications ?? changes()));
    addTearDown(cubit.close);
    await pumpSignedIn(
      tester,
      Scaffold(body: screen),
      user: user,
      language: language,
      size: const Size(390, 2200),
      notifications: cubit,
    );
    return cubit;
  }

  group('whenLabel', () {
    test('the next session in a child\'s words', () {
      final fr = l10nOf(AppLanguage.fr);
      String when(DateTime start) => whenLabel(fr, AppLanguage.fr, mine('x', ref4A, start), now);
      expect(when(now.subtract(const Duration(minutes: 10))), fr.statusInProgress);
      expect(when(at(6, 12)), "Aujourd'hui, dans 2 h");
      expect(when(at(7, 14)), 'Demain, mercredi');
      expect(when(at(8, 10)), 'Jeudi');
      expect(when(at(12, 10)), 'Lundi');
      expect(when(at(13, 15)), 'Mardi 13 octobre');
    });

    test('in Arabic', () {
      final ar = l10nOf(AppLanguage.ar);
      expect(whenLabel(ar, AppLanguage.ar, mine('x', ref4A, at(7, 14)), now), 'غدًا، الأربعاء');
    });
  });

  group('home', () {
    testWidgets('what is new on top, the next session in plain words, the week at a glance', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      final notifications = await pumpPupil(tester, const StudentHomeScreen());

      expect(find.text('Cette semaine, il te reste 2 séances.'), findsOneWidget);

      // Du nouveau: the unread changes, until they are read.
      expect(find.text('DU NOUVEAU'), findsOneWidget);
      expect(find.text(fr.notificationMoved(1)), findsOneWidget);
      expect(find.text(fr.notificationCancelled(1)), findsOneWidget);
      expect(find.text(fr.seeAll), findsOneWidget);

      // The next session: tomorrow, with its end and the room in a child's words.
      expect(find.text('Demain, mercredi'), findsOneWidget);
      expect(find.text('14:00'), findsOneWidget);
      expect(find.text(fr.untilTime('15:30')), findsOneWidget);
      expect(find.text(lecture.name), findsOneWidget);
      expect(find.text('En classe · ${isolated('Salle 2')}'), findsOneWidget);

      // Ma semaine: Monday to Saturday, Thursday crossed out, then next week.
      expect(find.text(fr.myWeek), findsOneWidget);
      for (final label in ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('DIM'), findsNothing);
      expect(find.byIcon(LucideIcons.x), findsNWidgets(2), reason: 'Thursday and the legend');
      expect(find.text(fr.legendSession), findsOneWidget);
      expect(find.text('La semaine prochaine : 2 séances.'), findsOneWidget);

      // No empty cards for what comes with release 2.
      expect(find.text(fr.toDo), findsNothing);
      expect(find.text(fr.latestResults), findsNothing);

      notifications.markAllRead();
      await tester.pumpAndSettle();
      expect(find.text('DU NOUVEAU'), findsNothing);
    });

    testWidgets('nothing new: no card; a running online session offers to join', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      final links = registerTestServices(now);
      sl.registerSingleton<PlanningRepository>(planning..mine = [mine('live', lecture, at(6, 9, 50), mode: SessionMode.online)]);
      await pumpPupil(tester, const StudentHomeScreen(), notifications: const []);

      expect(find.text('DU NOUVEAU'), findsNothing);
      expect(find.text(fr.statusInProgress), findsOneWidget);
      await tester.tap(find.text(fr.joinSession));
      expect(links.opened, ['https://meet.google.com/abc']);
    });

    testWidgets('in Arabic: Tunisian words, right to left', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      await pumpPupil(tester, const StudentHomeScreen(), language: AppLanguage.ar);

      expect(find.text('بقيت لك حصتان هذا الأسبوع.'), findsOneWidget);
      expect(find.text(ar.whatsNew), findsOneWidget);
      expect(find.text('غدًا، الأربعاء'), findsOneWidget);
      expect(find.text('في القسم · ${isolated('Salle 2')}'), findsOneWidget);
      expect(find.text(ar.nextWeekSessions(2)), findsOneWidget);
      // Right to left: Monday is the rightmost day.
      final monday = tester.getCenter(find.text(weekdayShort(DateTime.utc(2026, 10, 5), AppLanguage.ar)));
      final saturday = tester.getCenter(find.text(weekdayShort(DateTime.utc(2026, 10, 10), AppLanguage.ar)));
      expect(monday.dx, greaterThan(saturday.dx));
      expect(tester.takeException(), isNull);
    });
  });

  group('planning', () {
    testWidgets('a pupil reads by week, and only what changes is marked', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpPupil(tester, const MyPlanningScreen());

      expect(find.text('CETTE SEMAINE'), findsOneWidget);
      expect(find.text('SEMAINE PROCHAINE'), findsOneWidget);
      expect(tester.getTopLeft(find.text('CETTE SEMAINE')).dy, lessThan(tester.getTopLeft(find.text('SEMAINE PROCHAINE')).dy));
      expect(find.text('Demain, mercredi 7 octobre'), findsOneWidget);

      // Planned sessions carry no "Prévue" chip any more.
      expect(find.text(fr.statusPlanned), findsNothing);

      // Cancelled: a chip and the reason.
      expect(find.text(fr.statusCancelled), findsOneWidget);
      expect(find.text(fr.cancelledBecause(isolated('sortie scolaire'))), findsOneWidget);

      // Moved: "Nouvel horaire" and the former time struck through.
      expect(find.text(fr.newTime), findsOneWidget);
      final before = tester.widget<Text>(find.text('Avant : lundi 12 octobre à 10:00'));
      expect(before.style?.decoration, TextDecoration.lineThrough);

      // Online, later: the link comes 15 minutes before.
      expect(find.text(fr.joinOpensBefore), findsOneWidget);
      expect(find.text(fr.modeOnline), findsOneWidget);
      expect(find.text('En classe · ${isolated('Salle 2')}'), findsNWidgets(3));

      // A size up for young readers.
      expect(tester.widget<Text>(find.text('15:00')).style?.fontSize, 17);
    });

    testWidgets('in Arabic on a phone', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      await pumpPupil(tester, const MyPlanningScreen(), language: AppLanguage.ar);

      expect(find.text(ar.thisWeek), findsOneWidget);
      expect(find.text(ar.nextWeek), findsOneWidget);
      expect(find.text(ar.newTime), findsOneWidget);
      expect(find.text(ar.cancelledBecause(isolated('sortie scolaire'))), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a parent keeps the approved planning, with "En classe"', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpPupil(tester, const MyPlanningScreen(), user: parent);

      // No week sections ("CETTE SEMAINE" is the title of the parent's own tile).
      expect(find.text('SEMAINE PROCHAINE'), findsNothing);
      expect(find.text(fr.statusPlanned), findsNWidgets(4));
      expect(find.text(fr.newTime), findsNothing);
      expect(find.text('En classe · ${isolated('Salle 2')}'), findsNWidgets(3));
    });
  });

  testWidgets('a pupil has Accueil, Cours, Devoirs, Planning and Résultats', (tester) async {
    final fr = l10nOf(AppLanguage.fr);
    await pumpSignedIn(
      tester,
      AdaptiveShell(destinations: studentDestinations(), location: Routes.studentHome, child: const SizedBox.expand()),
      user: pupil,
      size: const Size(390, 844),
    );

    expect(find.text(fr.navStudentHome), findsOneWidget);
    expect(find.text(fr.navCourses), findsOneWidget);
    expect(find.text(fr.navAssignments), findsOneWidget);
    expect(find.text(fr.navPlanning), findsOneWidget);
    expect(find.text(fr.navResults), findsOneWidget);
  });

  testWidgets('an empty notification list speaks to the pupil with "tu"', (tester) async {
    final fr = l10nOf(AppLanguage.fr);
    await pumpPupil(tester, const NotificationsScreen(showBack: true), notifications: const []);

    expect(find.text(fr.noNotificationsHintStudent), findsOneWidget);
    expect(find.text(fr.noNotificationsHint), findsNothing);
  });

  test('once the list is shown, a new count brings the new notifications', () async {
    final repository = FakeNotificationRepository(items: changes().sublist(1));
    final cubit = NotificationsCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.unread.length, 1);

    repository
      ..items = changes()
      ..unread = 2;
    await cubit.refreshCount();
    expect(cubit.state.unreadCount, 2);
    expect(cubit.unread.map((n) => n.id), ['n-move', 'n-cancel']);
  });
}
