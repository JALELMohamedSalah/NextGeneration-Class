import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/brand_colors.dart';
import '../../../domain/model/reference.dart';
import '../../../l10n/app_localizations.dart';
import '../../stateManager/reference/reference_cubit.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';
import '../../widgets/feedback.dart';
import '../../widgets/panels.dart';
import '../../widgets/text_field.dart';

/// "Nouvelle matière" or, with [editing], "Modifier la matière": the teacher names her subjects herself
/// (French, optional Arabic, color). Returns the saved subject, or null when cancelled.
Future<Subject?> showSubjectDialog(BuildContext context, {Subject? editing}) {
  final reference = context.read<ReferenceCubit>();
  return showAppDialog<Subject>(
    context,
    builder: (_) => BlocProvider.value(
      value: reference,
      child: _SubjectDialog(editing: editing),
    ),
  );
}

class _SubjectDialog extends StatefulWidget {
  const _SubjectDialog({this.editing});

  final Subject? editing;

  @override
  State<_SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<_SubjectDialog> {
  late String _nameFr = widget.editing?.name.fr ?? '';
  late String _nameAr = widget.editing?.name.ar ?? '';
  late String? _color = widget.editing?.color;
  bool _missingName = false;
  bool _saving = false;
  String? _error;

  Future<void> _save(String color) async {
    if (_nameFr.trim().isEmpty) {
      setState(() => _missingName = true);
      return;
    }
    setState(() {
      _color = color;
      _saving = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    final draft = SubjectDraft(nameFr: _nameFr, nameAr: _nameAr, color: color);
    final reference = context.read<ReferenceCubit>();
    final editing = widget.editing;
    final (subject, failure) = editing == null ? await reference.createSubject(draft) : await reference.updateSubject(editing.id, draft);
    if (!mounted) return;
    if (subject != null) {
      Navigator.of(context).pop(subject);
    } else {
      setState(() {
        _saving = false;
        _error = failureText(l10n, failure!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final used = context.select((ReferenceCubit c) => c.state.reference?.subjects.map((s) => s.color).toSet() ?? const {});
    final selected = _color ?? groupPalette.firstWhere((c) => !used.contains(c), orElse: () => groupPalette.first);
    return AppDialog(
      icon: widget.editing == null ? LucideIcons.bookOpen : LucideIcons.pencil,
      title: widget.editing == null ? l10n.newSubject : l10n.editSubject,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null) ...[ErrorBanner(message: _error!), const SizedBox(height: 16)],
          FormInput(
            label: l10n.subjectNameFr,
            hint: l10n.subjectNameHint,
            initialValue: _nameFr,
            autofocus: true,
            textDirection: TextDirection.ltr,
            onChanged: (v) => setState(() {
              _nameFr = v;
              _missingName = false;
            }),
            errorText: _missingName ? l10n.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          FormInput(
            label: l10n.subjectNameAr,
            labelSuffix: l10n.optional,
            hint: l10n.subjectNameArExample,
            helper: l10n.subjectNameArHint,
            initialValue: _nameAr,
            textDirection: TextDirection.rtl,
            onChanged: (v) => _nameAr = v,
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: l10n.color,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final hex in groupPalette)
                  Semantics(
                    selected: hex == selected,
                    button: true,
                    child: GestureDetector(
                      onTap: () => setState(() => _color = hex),
                      child: AnimatedContainer(
                        duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 160),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colorFromHex(hex),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: hex == selected ? BrandColors.ink : Colors.transparent, width: 2.5),
                        ),
                        child: hex == selected ? Icon(LucideIcons.check, size: 16, color: onGroupColor(colorFromHex(hex))) : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        GhostButton(label: l10n.cancel, onPressed: () => Navigator.of(context).pop()),
        PrimaryButton(label: l10n.save, height: 44, loading: _saving, onPressed: () => _save(selected)),
      ],
    );
  }
}
