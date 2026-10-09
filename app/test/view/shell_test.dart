import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/router/routes.dart';
import 'package:ngclass/view/screens/teacher/teacher_destinations.dart';
import 'package:ngclass/view/widgets/adaptive_shell.dart';

import '../helpers/pump_app.dart';

void main() {
  Widget shell() => AdaptiveShell(destinations: teacherDestinations(), location: Routes.teacherHome, child: const SizedBox.expand());

  testWidgets('desktop in Arabic: the sidebar sits on the right, labels in Arabic', (tester) async {
    final ar = l10nOf(AppLanguage.ar);
    await pumpSignedIn(tester, shell(), language: AppLanguage.ar);

    expect(find.byType(AppSidebar), findsOneWidget);
    expect(find.text(ar.navTeacherHome), findsOneWidget);
    expect(find.text(ar.navSettings), findsOneWidget);
    final sidebar = tester.getRect(find.byType(AppSidebar));
    expect(sidebar.right, 1440);
    expect(sidebar.width, 264);
  });

  testWidgets('desktop in French: the sidebar sits on the left', (tester) async {
    await pumpSignedIn(tester, shell());

    expect(tester.getRect(find.byType(AppSidebar)).left, 0);
  });

  testWidgets('tablet: the sidebar keeps only its icons', (tester) async {
    final fr = l10nOf(AppLanguage.fr);
    await pumpSignedIn(tester, shell(), size: const Size(800, 1000));

    expect(tester.getRect(find.byType(AppSidebar)).width, 88);
    expect(find.text(fr.navPlanning), findsNothing);
  });

  testWidgets('phone in Arabic: bottom bar with four sections and "more", right to left', (tester) async {
    final ar = l10nOf(AppLanguage.ar);
    await pumpSignedIn(tester, shell(), language: AppLanguage.ar, size: const Size(390, 844));

    expect(find.byType(AppSidebar), findsNothing);
    expect(find.byType(PhoneBottomNav), findsOneWidget);
    for (final label in [ar.navTeacherHome, ar.navPlanning, ar.navStudents, ar.navContents, ar.navMore]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text(ar.navAssignments), findsNothing);
    // Right to left: the first section (Ma journée) is the rightmost.
    expect(tester.getCenter(find.text(ar.navTeacherHome)).dx, greaterThan(tester.getCenter(find.text(ar.navMore)).dx));
  });

  testWidgets('phone: "more" opens the other sections', (tester) async {
    final fr = l10nOf(AppLanguage.fr);
    await pumpSignedIn(tester, shell(), size: const Size(390, 844));

    await tester.tap(find.text(fr.navMore));
    await tester.pumpAndSettle();

    expect(find.text(fr.navAssignments), findsOneWidget);
    expect(find.text(fr.navAnnouncements), findsOneWidget);
    expect(find.text(fr.navSettings), findsOneWidget);
  });
}
