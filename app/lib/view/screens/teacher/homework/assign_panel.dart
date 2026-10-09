import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/tunis_time.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/group.dart';
import '../../../../domain/model/homework.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/groups/groups_cubit.dart';
import '../../../stateManager/homework/assign_form_cubit.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/reference/reference_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/content_widgets.dart';
import '../../../widgets/controls.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/page_frame.dart';
import '../../../widgets/panels.dart';
import '../../../widgets/school_widgets.dart';
import '../../../widgets/text_field.dart';

/// "Nouveau devoir" (design `r2/NouveauDevoir.png`): a published document for a group or some of its
/// pupils, with a deadline. From Devoirs, or from a document of Contenus ([contentItemId]).
class AssignPanel extends StatelessWidget {
  const AssignPanel({super.key});

  static Future<Assignment?> open(BuildContext context, {String? contentItemId, String? groupId}) {
    final groups = context.read<GroupsCubit>();
    final reference = context.read<ReferenceCubit>();
    return showSidePanel<Assignment>(
      context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: groups),
          BlocProvider.value(value: reference),
          BlocProvider(
            create: (_) => AssignFormCubit(sl.get(), sl.get(), sl.get(), sl.get(), contentItemId: contentItemId, groupId: groupId)..load(),
          ),
        ],
        child: const AssignPanel(),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final saved = await context.read<AssignFormCubit>().submit();
    if (saved != null && context.mounted) Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final reference = context.watch<ReferenceCubit>().state.reference;
    final groups = context.watch<GroupsCubit>().state.groups;
    final state = context.watch<AssignFormCubit>().state;
    final cubit = context.read<AssignFormCubit>();
    final errors = state.errors;
    final document = state.document;
    final today = TunisTime.day(sl.get<Now>()());
    final quiet = text.style(12, FontWeight.w500, color: BrandColors.slate, height: 1.4);

    final deadlineError = errors.contains(AssignFormError.deadline);
    final date = DateField(
      label: l10n.deadlineDate,
      value: state.date,
      onChanged: cubit.setDate,
      firstDate: today,
      lastDate: TunisTime.addDays(today, 365),
      errorText: deadlineError ? l10n.deadlineInPast : null,
    );
    final time = TimeField(label: l10n.deadlineTime, value: state.time, onChanged: cubit.setTime, error: deadlineError);

    return SidePanel(
      icon: LucideIcons.clipboardList,
      title: l10n.newHomework,
      subtitle: l10n.newHomeworkSubtitle,
      actions: [
        GhostButton(label: l10n.cancel, onPressed: () => Navigator.of(context).maybePop()),
        PrimaryButton(
          label: l10n.giveHomework,
          icon: LucideIcons.send,
          height: 44,
          loading: state.submitting,
          onPressed: () => _submit(context),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.failure != null) ...[FailureBanner(state.failure!), const SizedBox(height: 20)],
          SelectField<String>(
            label: l10n.documentLabel,
            hint: l10n.chooseDocument,
            value: state.contentItemId,
            onChanged: cubit.setDocument,
            errorText: errors.contains(AssignFormError.document) ? l10n.fieldRequired : null,
            options: [
              for (final d in state.documents)
                SelectOption(
                  d.id,
                  d.title,
                  leading: KindBadge(kind: d.kind, size: IconBadgeSize.small),
                ),
            ],
          ),
          if (document != null) ...[
            const SizedBox(height: 6),
            Text(
              [
                ?reference?.subject(document.subjectId)?.name.of(language),
                ?reference?.level(document.levelId)?.name.of(language),
                documentDetail(l10n, document),
              ].join(l10n.dotSeparator),
              style: quiet,
            ),
          ] else if (state.loaded && state.documents.isEmpty) ...[
            const SizedBox(height: 6),
            Text(l10n.noPublishedDocuments, style: quiet),
          ],
          const SizedBox(height: 20),
          FormInput(
            label: l10n.documentTitle,
            hint: l10n.documentTitleHint,
            helper: l10n.homeworkTitleHelper,
            initialValue: state.title,
            onChanged: cubit.setTitle,
            errorText: errors.contains(AssignFormError.title) ? l10n.fieldRequired : null,
          ),
          const SizedBox(height: 20),
          LabeledField(
            label: l10n.forLabel,
            child: SegmentedChoice<bool>(
              value: state.someStudents,
              onChanged: cubit.setSomeStudents,
              options: [SelectOption(false, l10n.forGroup), SelectOption(true, l10n.forStudents)],
            ),
          ),
          const SizedBox(height: 12),
          SelectField<String>(
            hint: l10n.chooseGroup,
            value: state.groupId,
            onChanged: cubit.setGroup,
            errorText: errors.contains(AssignFormError.group) ? l10n.fieldRequired : null,
            options: [
              for (final g in groups)
                SelectOption(
                  g.id,
                  '${g.name}${l10n.dotSeparator}${l10n.studentsCount(g.memberCount)}',
                  leading: GroupSquare(code: g.code, color: g.color),
                ),
            ],
          ),
          if (state.someStudents && state.groupId != null) ...[
            const SizedBox(height: 12),
            _StudentTicks(members: state.members, selected: state.studentIds, onToggle: cubit.toggleStudent),
            if (errors.contains(AssignFormError.students)) ...[
              const SizedBox(height: 6),
              Text(l10n.pickStudentsRequired, style: text.style(12, FontWeight.w600, color: Accent.red.onSoft)),
            ],
          ],
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: date),
              const SizedBox(width: 12),
              SizedBox(width: isPhone(context) ? 120 : 140, child: time),
            ],
          ),
          const SizedBox(height: 20),
          LabeledField(
            label: l10n.submissionLabel,
            child: SegmentedChoice<SubmissionMode>(
              value: state.mode,
              onChanged: cubit.setMode,
              options: [SelectOption(SubmissionMode.file, l10n.modeFile), SelectOption(SubmissionMode.none, l10n.modeNone)],
            ),
          ),
          const SizedBox(height: 6),
          Text(state.mode == SubmissionMode.file ? l10n.modeFileHint : l10n.modeNoneHint, style: quiet),
          const SizedBox(height: 20),
          FormInput(
            label: l10n.instructionsLabel,
            labelSuffix: l10n.optional,
            hint: l10n.instructionsHint,
            initialValue: state.instructions,
            onChanged: cubit.setInstructions,
            maxLines: 5,
          ),
          if (state.mode == SubmissionMode.file) ...[
            const SizedBox(height: 20),
            _LateSwitch(value: state.allowLate, onChanged: cubit.setAllowLate),
          ],
        ],
      ),
    );
  }
}

/// "Des élèves": the pupils of the group, ticked one by one.
class _StudentTicks extends StatelessWidget {
  const _StudentTicks({required this.members, required this.selected, required this.onToggle});

  final List<GroupMember> members;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    if (members.isEmpty) {
      return Text(l10n.noMembers, style: text.style(13, FontWeight.w500, color: BrandColors.slate));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final m in members) ...[
          _StudentTick(member: m, selected: selected.contains(m.studentId), onTap: () => onToggle(m.studentId)),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _StudentTick extends StatelessWidget {
  const _StudentTick({required this.member, required this.selected, required this.onTap});

  final GroupMember member;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Semantics(
      checked: selected,
      button: true,
      child: Material(
        color: selected ? const Color(0xFFF4F5FC) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: selected ? BrandColors.indigo : BrandColors.line, width: selected ? 1.5 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 14, 8),
            child: Row(
              children: [
                Icon(
                  selected ? LucideIcons.squareCheck : LucideIcons.square,
                  size: 20,
                  color: selected ? BrandColors.indigo : const Color(0xFFADB1C6),
                ),
                const SizedBox(width: 12),
                InitialsAvatar(initials: member.initials, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(member.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.style(14, FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LateSwitch extends StatelessWidget {
  const _LateSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 12, 12),
      decoration: BoxDecoration(
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.allowLate, style: text.style(14, FontWeight.w700)),
                const SizedBox(height: 2),
                Text(l10n.allowLateHint, style: text.style(12, FontWeight.w500, color: BrandColors.slate)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          BrandSwitch(value: value, onChanged: onChanged, label: l10n.allowLate),
        ],
      ),
    );
  }
}
