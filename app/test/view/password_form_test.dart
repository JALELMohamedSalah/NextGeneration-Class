import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/l10n/app_localizations.dart';
import 'package:ngclass/view/widgets/password_form.dart';

import '../helpers/pump_app.dart';

void main() {
  for (final language in AppLanguage.values) {
    testWidgets('first login in ${language.name}: each field says what to type', (tester) async {
      final l10n = l10nOf(language);
      await tester.pumpWidget(
        MaterialApp(
          locale: language.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: SingleChildScrollView(
              child: PasswordForm(
                currentLabel: l10n.temporaryPassword,
                currentHint: l10n.temporaryPasswordHint,
                submitting: false,
                onSubmit: (_, _) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expectEveryFieldHasAHint(find.byType(PasswordForm));
      for (final hint in [l10n.temporaryPasswordHint, l10n.newPasswordHint, l10n.confirmPasswordHint]) {
        expect(find.text(hint), findsOneWidget);
      }
    });
  }
}
