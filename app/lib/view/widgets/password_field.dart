import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import 'text_field.dart';

/// A password field with a show/hide button.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.helper,
    this.validator,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
    this.autovalidateMode,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? helper;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final AutovalidateMode? autovalidateMode;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      helper: widget.helper,
      icon: LucideIcons.lock,
      obscureText: _obscured,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      suffix: IconButton(
        tooltip: _obscured ? l10n.showPassword : l10n.hidePassword,
        icon: Icon(_obscured ? LucideIcons.eye : LucideIcons.eyeOff, size: 20),
        onPressed: () => setState(() => _obscured = !_obscured),
      ),
    );
  }
}
