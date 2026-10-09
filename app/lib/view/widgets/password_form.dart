import 'package:flutter/material.dart';

import '../../core/network/api_failure.dart';
import '../../domain/model/password_policy.dart';
import '../../l10n/app_localizations.dart';
import 'buttons.dart';
import 'feedback.dart';
import 'password_field.dart';

/// Current (or temporary) password, new password, confirmation. Used by the first-login screen
/// and the "change password" dialog.
class PasswordForm extends StatefulWidget {
  const PasswordForm({
    super.key,
    required this.currentLabel,
    required this.currentHint,
    required this.submitting,
    required this.onSubmit,
    this.failure,
    this.onCancel,
  });

  final String currentLabel;
  final String currentHint;
  final bool submitting;
  final ApiFailure? failure;
  final void Function(String currentPassword, String newPassword) onSubmit;
  final VoidCallback? onCancel;

  @override
  State<PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  /// After a refused submit, errors are checked on every build: they follow the language and clear as the user types.
  bool _submitted = false;

  AutovalidateMode get _check => _submitted ? AutovalidateMode.always : AutovalidateMode.disabled;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.submitting) return;
    if (!_submitted) setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSubmit(_current.text, _next.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PasswordField(
            controller: _current,
            label: widget.currentLabel,
            hint: widget.currentHint,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.next,
            autovalidateMode: _check,
            validator: (value) => (value == null || value.isEmpty) ? l10n.fieldRequired : null,
          ),
          const SizedBox(height: 20),
          PasswordField(
            controller: _next,
            label: l10n.newPassword,
            hint: l10n.newPasswordHint,
            helper: l10n.passwordRule,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.next,
            autovalidateMode: _check,
            validator: (value) => isAcceptablePassword(value) ? null : l10n.passwordRule,
          ),
          const SizedBox(height: 20),
          PasswordField(
            controller: _confirm,
            label: l10n.confirmPassword,
            hint: l10n.confirmPasswordHint,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            autovalidateMode: _check,
            validator: (value) => value == _next.text ? null : l10n.passwordsDoNotMatch,
          ),
          if (widget.failure != null) ...[const SizedBox(height: 16), FailureBanner(widget.failure!)],
          const SizedBox(height: 24),
          if (widget.onCancel == null)
            PrimaryButton(label: l10n.save, loading: widget.submitting, onPressed: _submit)
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(label: l10n.cancel, onPressed: widget.onCancel),
                const SizedBox(width: 10),
                PrimaryButton(label: l10n.save, height: 44, loading: widget.submitting, onPressed: _submit),
              ],
            ),
        ],
      ),
    );
  }
}
