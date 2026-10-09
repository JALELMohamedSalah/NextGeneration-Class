import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngclass/core/di/injection.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/formatting.dart';
import 'package:ngclass/domain/model/clock_time.dart';
import 'package:ngclass/domain/model/group.dart';
import 'package:ngclass/domain/repositories/group_repository.dart';
import 'package:ngclass/view/screens/teacher/planning/session_form_panel.dart';
import 'package:ngclass/view/screens/teacher/students/group_form_panel.dart';
import 'package:ngclass/view/screens/teacher/students/group_screen.dart';
import 'package:ngclass/view/stateManager/session_form/session_form_cubit.dart';
import 'package:ngclass/view/widgets/copy_link_button.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';
import '../helpers/student_fixtures.dart' show now;

const meet = 'https://meet.google.com/abc-defg-hij';

const withMeet = Group(
  id: 'g4a',
  name: '4ème année · Maths',
  code: '4A',
  subjectId: 'math',
  subject: math,
  levelId: 'l4',
  level: fourth,
  color: '#2B3990',
  defaultMeetUrl: meet,
  memberCount: 2,
);

/// "Copier le lien" beside a Meet link, wherever one is entered.
void main() {
  setUpAll(initializeAppDates);

  late String? copied;
  setUp(() {
    registerTestServices(now);
    copied = null;
  });

  void captureClipboard(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
  }

  testWidgets('the group\'s page copies its default link, and says so', (tester) async {
    final fr = l10nOf(AppLanguage.fr);
    captureClipboard(tester);
    sl.registerSingleton<GroupRepository>(FakeGroupRepository()..groups = [withMeet]);
    await pumpSignedIn(tester, const Scaffold(body: GroupScreen(groupId: 'g4a')), size: const Size(1440, 1200));

    await tester.tap(find.byType(CopyLinkButton));
    await tester.pump();
    expect(copied, meet);
    expect(find.text(fr.linkCopied), findsOneWidget);
  });

  testWidgets('no link, no button', (tester) async {
    sl.registerSingleton<GroupRepository>(FakeGroupRepository());
    await pumpSignedIn(tester, const Scaffold(body: GroupScreen(groupId: 'g4a')), size: const Size(1440, 1200));
    expect(find.byType(CopyLinkButton), findsNothing);
  });

  testWidgets('the group form shows it once a link is typed', (tester) async {
    captureClipboard(tester);
    sl.registerSingleton<GroupRepository>(FakeGroupRepository());
    await pumpSignedIn(
      tester,
      Scaffold(
        body: Builder(builder: (context) => TextButton(onPressed: () => GroupFormPanel.open(context), child: const Text('open'))),
      ),
      size: const Size(1440, 1200),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(CopyLinkButton), findsNothing);

    await tester.enterText(find.widgetWithText(TextField, l10nOf(AppLanguage.fr).meetLinkHint), 'meet.google.com/xyz-abcd-efg ');
    await tester.pump();
    await tester.tap(find.byType(CopyLinkButton));
    await tester.pump();
    expect(copied, 'meet.google.com/xyz-abcd-efg');
  });

  testWidgets('a session of a group with a link: "Du groupe" and the button, on the narrowest phone too', (tester) async {
    captureClipboard(tester);
    final cubit = SessionFormCubit.create(
      FakePlanningRepository(),
      date: DateTime.utc(2026, 10, 6),
      start: const ClockTime(16, 0),
      schoolYearEnd: DateTime.utc(2027, 6, 30),
      group: withMeet,
    );
    addTearDown(cubit.close);
    await pumpSignedIn(
      tester,
      BlocProvider.value(value: cubit, child: const Scaffold(body: SessionFormPanel())),
      language: AppLanguage.ar,
      size: const Size(320, 1600),
    );
    expect(find.byType(CopyLinkButton), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(CopyLinkButton));
    await tester.pump();
    expect(copied, meet);
  });
}
