import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/formatting.dart';
import 'package:ngclass/view/screens/shared/notifications_screen.dart';
import 'package:ngclass/view/stateManager/notifications/notifications_cubit.dart';
import 'package:ngclass/view/widgets/cards.dart';
import 'package:ngclass/view/widgets/page_frame.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';
import 'notifications_test.dart' show now, parentOfTwo, sample;

/// The pupil's and parent's pages use a computer screen: their cards go two by two, phones keep one column.
void main() {
  setUpAll(initializeAppDates);
  setUp(() => registerTestServices(now));

  group('CardColumns', () {
    Widget cards(double width) => Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          child: CardColumns(children: [for (final i in [0, 1, 2]) SizedBox(key: ValueKey(i), height: 50 + i * 10.0)]),
        ),
      ),
    );

    testWidgets('two columns filled row by row when there is room', (tester) async {
      await tester.pumpWidget(cards(780));
      final first = tester.getTopLeft(find.byKey(const ValueKey(0)));
      final second = tester.getTopLeft(find.byKey(const ValueKey(1)));
      final third = tester.getTopLeft(find.byKey(const ValueKey(2)));
      expect(second.dy, first.dy);
      expect(second.dx, greaterThan(first.dx));
      expect(third.dx, first.dx);
      expect(third.dy, greaterThan(first.dy));
      expect(tester.getSize(find.byKey(const ValueKey(0))).width, (780 - 12) / 2);
    });

    testWidgets('one column below two cards\' width', (tester) async {
      await tester.pumpWidget(cards(700));
      final first = tester.getTopLeft(find.byKey(const ValueKey(0)));
      final second = tester.getTopLeft(find.byKey(const ValueKey(1)));
      expect(second.dx, first.dx);
      expect(second.dy, first.dy + 50 + 12);
      expect(tester.getSize(find.byKey(const ValueKey(0))).width, 700);
    });
  });

  group('notifications page', () {
    Future<void> pumpPage(WidgetTester tester, {AppLanguage language = AppLanguage.fr, Size size = const Size(1440, 1000)}) async {
      final cubit = NotificationsCubit(FakeNotificationRepository(items: sample()));
      addTearDown(cubit.close);
      await pumpSignedIn(
        tester,
        const Scaffold(body: NotificationsScreen()),
        user: parentOfTwo,
        language: language,
        size: size,
        notifications: cubit,
      );
    }

    testWidgets('on a computer: two by two, the page as wide as the teacher\'s, "Tout marquer" at the end', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpPage(tester);

      final tiles = find.byType(NotificationTile);
      expect(tiles, findsNWidgets(4));
      // Today's two side by side, then the earlier two.
      expect(tester.getTopLeft(tiles.at(1)).dy, tester.getTopLeft(tiles.at(0)).dy);
      expect(tester.getTopLeft(tiles.at(1)).dx, greaterThan(tester.getTopLeft(tiles.at(0)).dx));
      expect(tester.getTopRight(tiles.at(1)).dx, closeTo(32 + familyPageWidth, 1));
      final link = find.ancestor(of: find.text(fr.markAllRead), matching: find.byType(CardLink));
      expect(tester.getTopRight(link).dx, closeTo(32 + familyPageWidth, 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('in Arabic the columns and the link follow the reading side', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      await pumpPage(tester, language: AppLanguage.ar);

      final tiles = find.byType(NotificationTile);
      expect(tester.getTopLeft(tiles.at(1)).dy, tester.getTopLeft(tiles.at(0)).dy);
      expect(tester.getTopLeft(tiles.at(1)).dx, lessThan(tester.getTopLeft(tiles.at(0)).dx));
      final link = find.ancestor(of: find.text(ar.markAllRead), matching: find.byType(CardLink));
      expect(tester.getTopLeft(link).dx, closeTo(1440 - 32 - familyPageWidth, 1));
    });

    testWidgets('on a phone: one column', (tester) async {
      await pumpPage(tester, size: const Size(390, 1600));

      final tiles = find.byType(NotificationTile);
      expect(tester.getTopLeft(tiles.at(1)).dx, tester.getTopLeft(tiles.at(0)).dx);
      expect(tester.getTopLeft(tiles.at(1)).dy, greaterThan(tester.getTopLeft(tiles.at(0)).dy));
      expect(tester.takeException(), isNull);
    });
  });
}
