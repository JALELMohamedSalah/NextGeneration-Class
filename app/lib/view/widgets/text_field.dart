import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/brand_colors.dart';

/// The look of every input: chalk fill, 1 px line, indigo border when focused, red when wrong.
InputDecoration appInputDecoration(
  BuildContext context, {
  IconData? icon,
  String? hint,
  String? helper,
  String? errorText,
  Widget? suffix,
  bool dense = false,
  Color fillColor = BrandColors.chalk,
}) {
  final text = AppText.of(context);
  OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadii.md),
    borderSide: BorderSide(color: color, width: width),
  );
  final vertical = dense ? 13.0 : 15.0;
  return InputDecoration(
    filled: true,
    fillColor: fillColor,
    isDense: true,
    hintText: hint,
    hintStyle: text.style(15, FontWeight.w500, color: BrandColors.slate),
    contentPadding: EdgeInsetsDirectional.only(start: icon == null ? 14 : 16, end: 12, top: vertical, bottom: vertical),
    prefixIcon: icon == null ? null : Padding(padding: const EdgeInsetsDirectional.only(start: 14, end: 10), child: Icon(icon, size: 19)),
    prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 20),
    prefixIconColor: BrandColors.slate,
    suffixIcon: suffix == null ? null : Padding(padding: const EdgeInsetsDirectional.only(end: 8), child: suffix),
    suffixIconConstraints: const BoxConstraints(minHeight: 20),
    suffixIconColor: BrandColors.slate,
    helperText: helper,
    helperMaxLines: 3,
    helperStyle: text.style(12, FontWeight.w500, color: BrandColors.slate),
    errorText: errorText,
    errorMaxLines: 2,
    errorStyle: text.style(12, FontWeight.w600, color: Accent.red.onSoft),
    border: border(BrandColors.line),
    enabledBorder: border(BrandColors.line),
    focusedBorder: border(BrandColors.indigo, 1.5),
    errorBorder: border(Accent.red.strong),
    focusedErrorBorder: border(Accent.red.strong, 1.5),
  );
}

/// "Téléphone (facultatif)": a field label, with an optional quiet suffix.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key, this.suffix});

  final String label;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: label, style: text.label),
          if (suffix != null)
            TextSpan(
              text: ' · $suffix',
              style: text.style(13, FontWeight.w500, color: BrandColors.slate),
            ),
        ],
      ),
    );
  }
}

/// A label above a field of any kind.
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child, this.labelSuffix});

  final String label;
  final String? labelSuffix;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FieldLabel(label, suffix: labelSuffix),
      const SizedBox(height: 8),
      child,
    ],
  );
}

/// Label above, then a 54 px chalk field with a leading icon; indigo border when focused. For Forms.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
    this.helper,
    this.validator,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.textDirection,
    this.autovalidateMode,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;

  /// Placeholder shown while the field is empty: every field has one (an example or what to type).
  final String hint;
  final String? helper;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;

  /// [AutovalidateMode.always] after a refused submit: the field checks itself with its current
  /// validator, so the message follows the language.
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return LabeledField(
      label: label,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        autofillHints: autofillHints,
        textInputAction: textInputAction,
        onFieldSubmitted: onSubmitted,
        validator: validator,
        autovalidateMode: autovalidateMode,
        keyboardType: keyboardType,
        textDirection: textDirection,
        style: text.style(15, FontWeight.w500),
        decoration: appInputDecoration(
          context,
          icon: icon,
          hint: hint,
          helper: helper,
          suffix: suffix,
        ).copyWith(contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 12, top: 17, bottom: 17)),
      ),
    );
  }
}

/// A field that keeps its own text: the Cubit only hears [onChanged]. For side panels.
class FormInput extends StatefulWidget {
  const FormInput({
    super.key,
    this.label,
    this.labelSuffix,
    this.initialValue = '',
    this.onChanged,
    this.onSubmitted,
    required this.hint,
    this.helper,
    this.errorText,
    this.icon,
    this.suffix,
    this.maxLines = 1,
    this.keyboardType,
    this.textDirection,
    this.autofocus = false,
    this.textInputAction,
    this.dense = false,
    this.fillColor = BrandColors.chalk,
    this.focusNode,
  });

  final String? label;
  final String? labelSuffix;
  final String initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Placeholder shown while the field is empty: every field has one (an example or what to type).
  final String hint;
  final String? helper;
  final String? errorText;
  final IconData? icon;
  final Widget? suffix;
  final int maxLines;
  final TextInputType? keyboardType;

  /// Usernames, phones and links stay left to right in Arabic.
  final TextDirection? textDirection;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final bool dense;
  final Color fillColor;

  /// To focus it from outside (the search, Ctrl K).
  final FocusNode? focusNode;

  @override
  State<FormInput> createState() => _FormInputState();
}

class _FormInputState extends State<FormInput> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialValue);

  @override
  void didUpdateWidget(FormInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A value set from outside (a generated username) replaces the text, not while typing it.
    if (widget.initialValue != oldWidget.initialValue && widget.initialValue != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.initialValue,
        selection: TextSelection.collapsed(offset: widget.initialValue.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      maxLines: widget.maxLines,
      minLines: widget.maxLines > 1 ? 3 : 1,
      keyboardType: widget.maxLines > 1 ? TextInputType.multiline : widget.keyboardType,
      textDirection: widget.textDirection,
      autofocus: widget.autofocus,
      textInputAction: widget.textInputAction,
      style: AppText.of(context).style(15, FontWeight.w500),
      decoration: appInputDecoration(
        context,
        icon: widget.icon,
        hint: widget.hint,
        helper: widget.helper,
        errorText: widget.errorText,
        suffix: widget.suffix,
        dense: widget.dense,
        fillColor: widget.fillColor,
      ),
    );
    if (widget.label == null) return field;
    return LabeledField(label: widget.label!, labelSuffix: widget.labelSuffix, child: field);
  }
}
