import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/group_form/group_form_cubit.dart';
import '../../../stateManager/groups/groups_cubit.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/reference/reference_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/copy_link_button.dart';
import '../../../widgets/controls.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/panels.dart';
import '../../../widgets/text_field.dart';
import '../subject_dialog.dart';

/// The "+ Nouvelle matière" entry of the subject menu.
const _newSubject = '__new_subject__';

/// "Nouveau groupe" / "Modifier le groupe".
class GroupFormPanel extends StatelessWidget {
  const GroupFormPanel({super.key});

  static Future<Group?> open(BuildContext context, {Group? editing}) async {
    final groups = context.read<GroupsCubit>();
    final reference = context.read<ReferenceCubit>();
    final saved = await showSidePanel<Group>(
      context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: reference),
          BlocProvider(create: (_) => GroupFormCubit(sl.get(), editing: editing)),
        ],
        child: const GroupFormPanel(),
      ),
    );
    if (saved != null) groups.upsert(saved);
    return saved;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = context.watch<LanguageCubit>().state;
    final reference = context.watch<ReferenceCubit>().state.reference;
    return BlocConsumer<GroupFormCubit, GroupFormState>(
      listenWhen: (previous, current) => previous.saved == null && current.saved != null,
      listener: (context, state) => Navigator.of(context).pop(state.saved),
      builder: (context, state) {
        final cubit = context.read<GroupFormCubit>();
        return SidePanel(
          icon: LucideIcons.users,
          title: state.isEditing ? l10n.editGroup : l10n.newGroup,
          subtitle: state.isEditing ? null : l10n.groupFormSubtitle,
          actions: [
            GhostButton(label: l10n.cancel, onPressed: () => Navigator.of(context).maybePop()),
            PrimaryButton(label: l10n.save, height: 44, loading: state.submitting, onPressed: cubit.submit),
          ],
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.failure != null) ...[FailureBanner(state.failure!), const SizedBox(height: 20)],
              FormInput(
                label: l10n.groupName,
                hint: l10n.groupNameHint,
                initialValue: state.name,
                autofocus: !state.isEditing,
                onChanged: cubit.setName,
                errorText: state.errors.contains(GroupFormError.name) ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 20),
              SelectField<String>(
                label: l10n.subject,
                hint: (reference?.subjects.isEmpty ?? true) ? l10n.noSubjectsYet : l10n.chooseSubject,
                value: state.subjectId,
                onChanged: (id) async {
                  if (id != _newSubject) return cubit.setSubject(id);
                  final subject = await showSubjectDialog(context);
                  if (subject != null) cubit.setSubject(subject.id);
                },
                errorText: state.errors.contains(GroupFormError.subject) ? l10n.fieldRequired : null,
                options: [
                  for (final s in reference?.subjects ?? const [])
                    SelectOption(
                      s.id,
                      s.name.of(language),
                      leading: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: colorFromHex(s.color), shape: BoxShape.circle),
                      ),
                    ),
                  SelectOption(_newSubject, l10n.newSubject, leading: const Icon(LucideIcons.plus, size: 16, color: BrandColors.indigo)),
                ],
              ),
              const SizedBox(height: 20),
              SelectField<String>(
                label: l10n.level,
                hint: l10n.chooseLevel,
                value: state.levelId,
                onChanged: cubit.setLevel,
                errorText: state.errors.contains(GroupFormError.level) ? l10n.fieldRequired : null,
                options: [for (final level in reference?.levels ?? const []) SelectOption(level.id, level.name.of(language))],
              ),
              const SizedBox(height: 20),
              FormInput(
                label: l10n.defaultMeetLink,
                labelSuffix: l10n.optional,
                hint: l10n.meetLinkHint,
                icon: LucideIcons.link,
                initialValue: state.meetUrl,
                keyboardType: TextInputType.url,
                textDirection: TextDirection.ltr,
                onChanged: cubit.setMeetUrl,
                errorText: state.errors.contains(GroupFormError.meetUrl) ? l10n.meetLinkInvalid : null,
                suffix: state.meetUrl.trim().isEmpty ? null : CopyLinkButton(url: state.meetUrl, size: 32),
              ),
              const SizedBox(height: 20),
              LabeledField(
                label: l10n.color,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final hex in groupPalette) _Swatch(color: hex, selected: state.color == hex, onTap: () => cubit.setColor(hex)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.selected, required this.onTap});

  final String color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = colorFromHex(color);
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 160),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? BrandColors.ink : Colors.transparent, width: 2.5),
              boxShadow: selected ? [BoxShadow(color: c.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))] : null,
            ),
            child: selected ? Icon(LucideIcons.check, size: 18, color: onGroupColor(c)) : null,
          ),
        ),
      ),
    );
  }
}
