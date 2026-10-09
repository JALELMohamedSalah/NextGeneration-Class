import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/student.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/groups/groups_cubit.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/reference/reference_cubit.dart';
import '../../../stateManager/student_form/student_form_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/controls.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/labels.dart';
import '../../../widgets/page_frame.dart';
import '../../../widgets/panels.dart';
import '../../../widgets/school_widgets.dart';
import '../../../widgets/text_field.dart';
import 'credentials_dialog.dart';

/// "Nouvel élève" / "Modifier l'élève" (design `r1/NouvelEleve.png`).
class StudentFormPanel extends StatelessWidget {
  const StudentFormPanel({super.key});

  /// Opens the panel; when new accounts were created, shows their login details once.
  static Future<SavedStudent?> open(BuildContext context, {StudentSummary? editing, String? groupId}) async {
    final groups = context.read<GroupsCubit>();
    final reference = context.read<ReferenceCubit>();
    final saved = await showSidePanel<SavedStudent>(
      context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: groups),
          BlocProvider.value(value: reference),
          BlocProvider(
            create: (_) => StudentFormCubit(sl.get(), editing: editing, initialGroupId: groupId),
          ),
        ],
        child: const StudentFormPanel(),
      ),
    );
    if (saved == null) return null;
    groups.load();
    if (saved.accounts.isNotEmpty && context.mounted) await CredentialsDialog.show(context, saved.accounts);
    return saved;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<StudentFormCubit, StudentFormState>(
      listenWhen: (previous, current) => previous.saved == null && current.saved != null,
      listener: (context, state) => Navigator.of(context).pop(state.saved),
      child: BlocBuilder<StudentFormCubit, StudentFormState>(
        builder: (context, state) {
          final cubit = context.read<StudentFormCubit>();
          return SidePanel(
            icon: LucideIcons.userPlus,
            title: state.isEditing ? l10n.editStudent : l10n.newStudent,
            subtitle: state.isEditing ? null : l10n.studentFormSubtitle,
            body: const _Body(),
            actions: [
              GhostButton(label: l10n.cancel, onPressed: () => Navigator.of(context).maybePop()),
              PrimaryButton(label: l10n.save, height: 44, loading: state.submitting, onPressed: cubit.submit),
            ],
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = context.watch<LanguageCubit>().state;
    final state = context.watch<StudentFormCubit>().state;
    final cubit = context.read<StudentFormCubit>();
    final reference = context.watch<ReferenceCubit>().state.reference;
    final phone = isPhone(context);
    final errors = state.errors;

    Widget pair(Widget a, Widget b) => phone
        ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [a, const SizedBox(height: 20), b])
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              const SizedBox(width: 12),
              Expanded(child: b),
            ],
          );

    final usernameChip = switch (state.usernameStatus) {
      UsernameStatus.checking => const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)),
      UsernameStatus.available => StatusChip(label: l10n.usernameAvailable, accent: Accent.green),
      UsernameStatus.taken => StatusChip(label: l10n.usernameTaken, accent: Accent.red),
      UsernameStatus.idle => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.failure != null) ...[FailureBanner(state.failure!), const SizedBox(height: 20)],
        pair(
          FormInput(
            label: l10n.firstName,
            hint: l10n.studentFirstNameHint,
            initialValue: state.firstName,
            autofocus: !state.isEditing,
            onChanged: cubit.setFirstName,
            errorText: errors.contains(StudentFormError.firstName) ? l10n.fieldRequired : null,
          ),
          FormInput(
            label: l10n.lastName,
            hint: l10n.lastNameHint,
            initialValue: state.lastName,
            onChanged: cubit.setLastName,
            errorText: errors.contains(StudentFormError.lastName) ? l10n.fieldRequired : null,
          ),
        ),
        const SizedBox(height: 20),
        pair(
          SelectField<String>(
            label: l10n.level,
            hint: l10n.chooseLevel,
            value: state.levelId,
            onChanged: cubit.setLevel,
            errorText: errors.contains(StudentFormError.level) ? l10n.fieldRequired : null,
            options: [for (final level in reference?.levels ?? const []) SelectOption(level.id, level.name.of(language))],
          ),
          FormInput(
            label: l10n.phone,
            labelSuffix: l10n.optional,
            hint: l10n.phoneHint,
            initialValue: state.phone,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            onChanged: cubit.setPhone,
            errorText: errors.contains(StudentFormError.phone) ? l10n.phoneInvalid : null,
          ),
        ),
        const SizedBox(height: 20),
        const _GroupsField(),
        const SizedBox(height: 20),
        const _ParentsBox(),
        const SizedBox(height: 20),
        _AccessBox(usernameChip: usernameChip),
      ],
    );
  }
}

/// "Accès de l'élève": off by default, primary pupils are followed by their parents.
class _AccessBox extends StatelessWidget {
  const _AccessBox({required this.usernameChip});

  final Widget? usernameChip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final state = context.watch<StudentFormCubit>().state;
    final cubit = context.read<StudentFormCubit>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.row),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const IconBadge(icon: LucideIcons.keyRound, accent: Accent.turquoise, size: IconBadgeSize.medium),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.childAccess, style: text.rowTitle),
                    Text(l10n.childAccessHint, style: text.style(13, FontWeight.w500, color: BrandColors.slate, height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              BrandSwitch(value: state.createLogin, onChanged: cubit.setCreateLogin, label: l10n.childAccess),
            ],
          ),
          AnimatedSize(
            duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: state.createLogin
                ? Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: FormInput(
                      label: l10n.username,
                      hint: l10n.studentUsernameExample,
                      initialValue: state.username,
                      textDirection: TextDirection.ltr,
                      onChanged: cubit.setUsername,
                      helper: l10n.usernameHint,
                      suffix: usernameChip,
                      fillColor: Colors.white,
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _GroupsField extends StatelessWidget {
  const _GroupsField();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final groups = context.watch<GroupsCubit>().state.groups;
    final selected = context.select((StudentFormCubit c) => c.state.groupIds);
    final cubit = context.read<StudentFormCubit>();
    final available = groups.where((g) => !selected.contains(g.id)).toList();
    return LabeledField(
      label: l10n.groups,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: BrandColors.chalk,
          border: Border.all(color: BrandColors.line),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final id in selected)
              if (groups.where((g) => g.id == id).firstOrNull case final group?)
                InputChip(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: BrandColors.line),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
                  avatar: GroupSquare(code: group.code, color: group.color, size: 20),
                  label: Text(group.name, style: text.style(13, FontWeight.w600)),
                  deleteIcon: const Icon(LucideIcons.x, size: 14),
                  onDeleted: () => cubit.toggleGroup(group.id),
                ),
            if (available.isNotEmpty)
              MenuAnchor(
                menuChildren: [
                  for (final group in available)
                    MenuItemButton(
                      leadingIcon: GroupSquare(code: group.code, color: group.color, size: 22),
                      onPressed: () => cubit.toggleGroup(group.id),
                      child: Text(group.name, style: text.style(14, FontWeight.w600)),
                    ),
                ],
                builder: (context, controller, _) => TextButton.icon(
                  onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                  icon: const Icon(LucideIcons.plus, size: 16, color: BrandColors.indigo),
                  label: Text(l10n.addGroup, style: text.style(13, FontWeight.w700, color: BrandColors.indigo)),
                ),
              )
            else if (groups.isEmpty)
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(l10n.noGroupsYet, style: text.style(13, FontWeight.w500, color: BrandColors.slate)),
              ),
          ],
        ),
      ),
    );
  }
}

class _ParentsBox extends StatelessWidget {
  const _ParentsBox();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final state = context.watch<StudentFormCubit>().state;
    final cubit = context.read<StudentFormCubit>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.row),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.parents, style: text.style(15, FontWeight.w800))),
              Text(l10n.parentsCount(state.parentCount), style: text.style(13, FontWeight.w500, color: BrandColors.slate)),
            ],
          ),
          const SizedBox(height: 12),
          for (final parent in state.linkedParents) ...[
            _ParentRow(name: parent.fullName, detail: _detail(l10n, parent.relation, parent.phone)),
            const SizedBox(height: 10),
          ],
          for (var i = 0; i < state.newParents.length; i++) ...[
            state.newParents[i].isExisting
                ? _ParentRow(
                    name: state.newParents[i].fullName,
                    detail: _detail(l10n, state.newParents[i].relation, state.newParents[i].phone),
                    onRemove: () => cubit.removeParent(i),
                  )
                : _NewParentForm(index: i, parent: state.newParents[i]),
            const SizedBox(height: 10),
          ],
          if (state.canAddParent)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SecondaryButton(label: l10n.existingParent, icon: LucideIcons.search, height: 38, onPressed: () => _pickExisting(context)),
                SecondaryButton(
                  label: l10n.newParent,
                  icon: LucideIcons.plus,
                  height: 38,
                  onPressed: () => cubit.addParent(const ParentDraft(relation: 'mother')),
                ),
              ],
            ),
        ],
      ),
    );
  }

  static String _detail(AppLocalizations l10n, String? relation, String? phone) =>
      [relationLabel(l10n, relation), ?phone].where((s) => s.isNotEmpty).join(l10n.dotSeparator);

  Future<void> _pickExisting(BuildContext context) async {
    final cubit = context.read<StudentFormCubit>();
    final l10n = AppLocalizations.of(context);
    cubit.loadParentAccounts();
    final chosen = await showAppDialog<ParentDraft>(
      context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: AppDialog(icon: LucideIcons.search, title: l10n.existingParent, content: const _ParentPicker()),
      ),
    );
    if (chosen != null) cubit.addParent(chosen);
  }
}

class _ParentRow extends StatelessWidget {
  const _ParentRow({required this.name, required this.detail, this.onRemove});

  final String name;
  final String detail;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final l10n = AppLocalizations.of(context);
    final initials = name.split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0].toUpperCase()).join();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: BrandColors.chalk, borderRadius: BorderRadius.circular(AppRadii.md)),
      child: Row(
        children: [
          InitialsAvatar(initials: initials, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: text.style(14, FontWeight.w700)),
                if (detail.isNotEmpty) Text(detail, style: text.style(13, FontWeight.w500, color: BrandColors.slate)),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              tooltip: l10n.delete,
              onPressed: onRemove,
              icon: const Icon(LucideIcons.x, size: 18, color: BrandColors.slate),
            ),
        ],
      ),
    );
  }
}

/// A new parent account, typed in place.
class _NewParentForm extends StatelessWidget {
  const _NewParentForm({required this.index, required this.parent});

  final int index;
  final ParentDraft parent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final cubit = context.read<StudentFormCubit>();
    final errors = context.select((StudentFormCubit c) => c.state.errors);
    ParentDraft copy({String? firstName, String? lastName, String? phone, String? email, String? relation}) => ParentDraft(
      firstName: firstName ?? parent.firstName,
      lastName: lastName ?? parent.lastName,
      phone: phone ?? parent.phone,
      email: email ?? parent.email,
      relation: relation ?? parent.relation,
    );
    final nameMissing = errors.contains(StudentFormError.parentName);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: BrandColors.chalk, borderRadius: BorderRadius.circular(AppRadii.md)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StatusChip(label: l10n.newAccount, accent: Accent.blue),
              const Spacer(),
              IconButton(
                tooltip: l10n.delete,
                onPressed: () => cubit.removeParent(index),
                icon: const Icon(LucideIcons.x, size: 18, color: BrandColors.slate),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FormInput(
                  label: l10n.firstName,
                  hint: l10n.parentFirstNameHint,
                  initialValue: parent.firstName,
                  fillColor: Colors.white,
                  dense: true,
                  onChanged: (v) => cubit.updateParent(index, copy(firstName: v)),
                  errorText: nameMissing && parent.firstName.trim().isEmpty ? l10n.fieldRequired : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FormInput(
                  label: l10n.lastName,
                  hint: l10n.lastNameHint,
                  initialValue: parent.lastName,
                  fillColor: Colors.white,
                  dense: true,
                  onChanged: (v) => cubit.updateParent(index, copy(lastName: v)),
                  errorText: nameMissing && parent.lastName.trim().isEmpty ? l10n.fieldRequired : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FormInput(
                  label: l10n.phone,
                  hint: l10n.phoneHint,
                  initialValue: parent.phone,
                  fillColor: Colors.white,
                  dense: true,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  onChanged: (v) => cubit.updateParent(index, copy(phone: v)),
                  errorText: errors.contains(StudentFormError.parentPhone) ? l10n.phoneInvalid : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SelectField<String>(
                  label: l10n.relation,
                  hint: l10n.relationHint,
                  value: parent.relation,
                  onChanged: (v) => cubit.updateParent(index, copy(relation: v)),
                  options: [for (final code in relationCodes) SelectOption(code, relationLabel(l10n, code))],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FormInput(
            label: l10n.email,
            labelSuffix: l10n.optional,
            hint: l10n.emailHint,
            initialValue: parent.email ?? '',
            fillColor: Colors.white,
            dense: true,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            onChanged: (v) => cubit.updateParent(index, copy(email: v)),
          ),
          const SizedBox(height: 4),
          Text(l10n.parentLoginNote, style: text.style(12, FontWeight.w500, color: BrandColors.slate)),
        ],
      ),
    );
  }
}

class _ParentPicker extends StatefulWidget {
  const _ParentPicker();

  @override
  State<_ParentPicker> createState() => _ParentPickerState();
}

class _ParentPickerState extends State<_ParentPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final state = context.watch<StudentFormCubit>().state;
    final accounts = state.parentAccounts;
    final linked = {...state.linkedParents.map((p) => p.id), ...state.newParents.map((p) => p.existingParentId)};
    final visible = (accounts ?? const <ParentAccount>[])
        .where((p) => foldAccents('${p.fullName} ${p.phone ?? ''}'.toLowerCase()).contains(foldAccents(_query.toLowerCase())))
        .toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchBox(hint: l10n.searchParent, onChanged: (v) => setState(() => _query = v)),
        const SizedBox(height: 12),
        if (accounts == null)
          const LinearProgressIndicator(minHeight: 3)
        else if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              accounts.isEmpty ? l10n.noParentsYet : l10n.noResults,
              style: text.style(14, FontWeight.w500, color: BrandColors.slate),
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final p in visible)
                  ListTile(
                    enabled: !linked.contains(p.id),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
                    leading: InitialsAvatar(
                      initials: '${p.firstName.isEmpty ? '' : p.firstName[0]}${p.lastName.isEmpty ? '' : p.lastName[0]}'.toUpperCase(),
                      size: 36,
                    ),
                    title: Text(p.fullName, style: text.style(14, FontWeight.w700)),
                    subtitle: Text(
                      [?p.phone, if (p.children.isNotEmpty) l10n.parentOf(p.children.join(l10n.listSeparator))].join(l10n.dotSeparator),
                      style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                    ),
                    trailing: linked.contains(p.id) ? StatusChip(label: l10n.parentLinked, accent: Accent.grey) : null,
                    onTap: () => Navigator.of(
                      context,
                    ).pop(ParentDraft(existingParentId: p.id, firstName: p.firstName, lastName: p.lastName, phone: p.phone ?? '')),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
