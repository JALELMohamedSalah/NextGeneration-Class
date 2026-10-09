import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/di/injection.dart';
import '../../../core/l10n/formatting.dart';
import '../../../core/l10n/tunis_time.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../domain/model/teacher_account.dart';
import '../../../l10n/app_localizations.dart';
import '../../stateManager/admin/teachers_cubit.dart';
import '../../stateManager/common/load_status.dart';
import '../../stateManager/language/language_cubit.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';
import '../../widgets/classmates.dart';
import '../../widgets/controls.dart';
import '../../widgets/feedback.dart';
import '../../widgets/labels.dart';
import '../../widgets/page_frame.dart';
import '../../widgets/panels.dart';
import '../teacher/students/credentials_dialog.dart';
import 'new_teacher_panel.dart';

/// The owner's dashboard: every teacher using the platform, the size of their spaces, and the account
/// actions (add, reset the password, close or reopen the access). The owner never sees inside a space.
class TeachersScreen extends StatelessWidget {
  const TeachersScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(create: (_) => sl.get<TeachersCubit>()..load(), child: const TeachersView());
}

class TeachersView extends StatelessWidget {
  const TeachersView({super.key});

  Future<void> _add(BuildContext context) async {
    final credential = await NewTeacherPanel.open(context);
    if (credential == null || !context.mounted) return;
    await CredentialsDialog.show(context, [credential], note: AppLocalizations.of(context).teacherCredentialsNote);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final phone = isPhone(context);
    final state = context.watch<TeachersCubit>().state;

    final header = Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 20,
      runSpacing: 16,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text.upper(l10n.adminArea), style: text.overline(color: BrandColors.indigo)),
              const SizedBox(height: 6),
              Text(l10n.navTeachers, style: text.pageTitle(phone: phone)),
              const SizedBox(height: 6),
              Text(l10n.teachersSubtitle, style: text.style(15, FontWeight.w500, color: BrandColors.body, height: 1.5)),
            ],
          ),
        ),
        PrimaryButton(label: l10n.newTeacher, icon: LucideIcons.userPlus, height: 44, onPressed: () => _add(context)),
      ],
    );

    final List<Widget> body;
    if (state.status == LoadStatus.failure && state.teachers.isEmpty) {
      body = [FailureBanner(state.failure!, onRetry: context.read<TeachersCubit>().load)];
    } else if (state.status == LoadStatus.loading && state.teachers.isEmpty) {
      body = [const LinearProgressIndicator(minHeight: 3)];
    } else if (state.teachers.isEmpty) {
      body = [
        SectionCard(
          child: EmptyState(
            message: l10n.noTeachers,
            scale: 0.5,
            action: Column(
              children: [
                Text(
                  l10n.noTeachersHint,
                  textAlign: TextAlign.center,
                  style: text.style(13, FontWeight.w500, color: BrandColors.slate, height: 1.5),
                ),
                const SizedBox(height: 16),
                PrimaryButton(label: l10n.newTeacher, icon: LucideIcons.userPlus, height: 44, onPressed: () => _add(context)),
              ],
            ),
          ),
        ),
      ];
    } else {
      body = [
        _Totals(totals: state.totals),
        Wrap(
          spacing: 16,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SearchBox(
              hint: l10n.searchTeachers,
              initialValue: state.query,
              width: phone ? double.infinity : 320,
              onChanged: context.read<TeachersCubit>().search,
            ),
            Text(l10n.teachersCount(state.visible.length), style: text.style(13, FontWeight.w600, color: BrandColors.slate)),
          ],
        ),
        if (state.visible.isEmpty) SectionCard(child: EmptyState(message: l10n.noResults)) else _TeachersTable(teachers: state.visible),
      ];
    }
    return PageScroll(children: [header, ...body]);
  }
}

/// Four figures across every space.
class _Totals extends StatelessWidget {
  const _Totals({required this.totals});

  final TeachersTotals totals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tiles = [
      _StatTile(
        icon: LucideIcons.graduationCap,
        accent: Accent.indigo,
        label: l10n.navTeachers,
        value: totals.teachers,
        caption: l10n.activeAccounts(totals.activeTeachers),
      ),
      _StatTile(
        icon: LucideIcons.usersRound,
        accent: Accent.turquoise,
        label: l10n.statStudents,
        value: totals.students,
        caption: l10n.allSpaces,
      ),
      _StatTile(
        icon: LucideIcons.contactRound,
        accent: Accent.amber,
        label: l10n.statParents,
        value: totals.parents,
        caption: l10n.allSpaces,
      ),
      _StatTile(icon: LucideIcons.layers, accent: Accent.violet, label: l10n.statGroups, value: totals.groups, caption: l10n.allSpaces),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        // Four in a row when there is room, two by two otherwise.
        final perRow = constraints.maxWidth >= 860 ? 4 : 2;
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (perRow - 1)) / perRow;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final tile in tiles) SizedBox(width: width, child: tile)],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.accent, required this.label, required this.value, required this.caption});

  final IconData icon;
  final Accent accent;
  final String label;
  final int value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final phone = isPhone(context);
    final badge = IconBadge(icon: icon, accent: accent, size: phone ? IconBadgeSize.small : IconBadgeSize.medium);
    final title = Text(text.upper(label), maxLines: 2, overflow: TextOverflow.ellipsis, style: text.overline(size: 11));
    return Container(
      padding: EdgeInsets.all(phone ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.tile),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A narrow tile (two per row on a small phone) puts the label under the icon, so a word never breaks.
          LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth < 170
                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [badge, const SizedBox(height: 10), title])
                : Row(
                    children: [
                      badge,
                      const SizedBox(width: 10),
                      Expanded(child: title),
                    ],
                  ),
          ),
          SizedBox(height: phone ? 10 : 14),
          Text(
            '$value',
            textDirection: TextDirection.ltr,
            style: text.style(phone ? 24 : 30, FontWeight.w800, spacing: -0.5, tabular: true),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.style(12, FontWeight.w600, color: BrandColors.slate),
          ),
        ],
      ),
    );
  }
}

/// A count in a table column, on the reading side whatever the direction of the digits.
class _Count extends StatelessWidget {
  const _Count(this.value, {required this.style});

  final int value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Text('$value', textDirection: TextDirection.ltr, style: style),
  );
}

class _TeachersTable extends StatelessWidget {
  const _TeachersTable({required this.teachers});

  final List<TeacherAccount> teachers;

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);
    final wide = MediaQuery.sizeOf(context).width >= 1100;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: phone ? 12 : 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(phone ? AppRadii.tile : AppRadii.card),
      ),
      child: Column(
        children: [
          if (!phone) _HeaderRow(wide: wide),
          for (var i = 0; i < teachers.length; i++)
            FadeRise(
              index: i,
              child: phone ? _TeacherCardRow(teacher: teachers[i], first: i == 0) : _TeacherRow(teacher: teachers[i], wide: wide),
            ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final style = text.overline(size: 11);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 54),
          Expanded(flex: 4, child: Text(text.upper(l10n.columnTeacher), style: style)),
          Expanded(flex: 3, child: Text(text.upper(l10n.columnStatus), style: style)),
          SizedBox(width: 80, child: Text(text.upper(l10n.columnStudents), style: style)),
          SizedBox(width: 80, child: Text(text.upper(l10n.columnGroups), style: style)),
          if (wide) Expanded(flex: 2, child: Text(text.upper(l10n.columnLastLogin), style: style)),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

/// Tablet and desktop: one line per teacher.
class _TeacherRow extends StatelessWidget {
  const _TeacherRow({required this.teacher, required this.wide});

  final TeacherAccount teacher;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final number = text.style(15, FontWeight.w700, tabular: true);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: BrandColors.rowDivider)),
      ),
      child: Opacity(
        opacity: teacher.active ? 1 : 0.65,
        child: Row(
          children: [
            InitialsAvatar(initials: teacher.initials),
            const SizedBox(width: 14),
            Expanded(flex: 4, child: _Identity(teacher: teacher)),
            Expanded(
              flex: 3,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: _StatusChip(teacher: teacher),
              ),
            ),
            // Under its heading on the reading side: a left-to-right number must not align to the left in Arabic.
            SizedBox(width: 80, child: _Count(teacher.students, style: number)),
            SizedBox(width: 80, child: _Count(teacher.groups, style: number)),
            if (wide) Expanded(flex: 2, child: _LastLogin(teacher: teacher)),
            SizedBox(width: 48, child: _Actions(teacher: teacher)),
          ],
        ),
      ),
    );
  }
}

/// Phones: the same facts, stacked.
class _TeacherCardRow extends StatelessWidget {
  const _TeacherCardRow({required this.teacher, required this.first});

  final TeacherAccount teacher;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: first ? null : const Border(top: BorderSide(color: BrandColors.rowDivider)),
      ),
      child: Opacity(
        opacity: teacher.active ? 1 : 0.65,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InitialsAvatar(initials: teacher.initials),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Identity(teacher: teacher),
                  const SizedBox(height: 8),
                  _StatusChip(teacher: teacher),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.columnStudents} ${teacher.students}${l10n.dotSeparator}${l10n.columnGroups} ${teacher.groups}',
                    style: text.style(13, FontWeight.w600, color: BrandColors.body),
                  ),
                  const SizedBox(height: 2),
                  _LastLogin(teacher: teacher),
                ],
              ),
            ),
            _Actions(teacher: teacher),
          ],
        ),
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.teacher});

  final TeacherAccount teacher;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    // Username and phone are Latin: kept whole and left to right inside an Arabic line.
    final login = [isolated(teacher.username), if (teacher.phone != null) isolated(teacher.phone!)].join(l10n.dotSeparator);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(teacher.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.rowTitle),
        const SizedBox(height: 2),
        Text(
          login,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: text.style(13, FontWeight.w500, color: BrandColors.slate),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.teacher});

  final TeacherAccount teacher;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!teacher.active) return StatusChip(label: l10n.teacherDisabled, accent: Accent.grey);
    if (teacher.awaitingFirstLogin) return StatusChip(label: l10n.teacherTemporaryPassword, accent: Accent.amber);
    return StatusChip(label: l10n.teacherActive, accent: Accent.green);
  }
}

class _LastLogin extends StatelessWidget {
  const _LastLogin({required this.teacher});

  final TeacherAccount teacher;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final last = teacher.lastLoginAt;
    return Text(
      last == null ? l10n.lastLoginNever : timeAgo(l10n, language, last, sl.get<Now>()()),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: text.style(13, FontWeight.w500, color: last == null ? BrandColors.slate : BrandColors.body),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.teacher});

  final TeacherAccount teacher;

  Future<void> _reset(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final (credential, failure) = await context.read<TeachersCubit>().resetPassword(teacher);
    if (!context.mounted) return;
    if (failure != null) return showNotice(context, failureText(l10n, failure));
    await CredentialsDialog.show(context, [credential!], reset: true, note: l10n.teacherCredentialsNote);
  }

  Future<void> _setActive(BuildContext context, {required bool active}) async {
    final l10n = AppLocalizations.of(context);
    if (!active) {
      final ok = await confirmAction(
        context,
        title: l10n.disableTeacherTitle(teacher.fullName),
        text: l10n.disableTeacherText,
        confirmLabel: l10n.disableAccess,
        icon: LucideIcons.userX,
      );
      if (!ok || !context.mounted) return;
    }
    final failure = await context.read<TeachersCubit>().setActive(teacher, active: active);
    if (!context.mounted) return;
    showNotice(
      context,
      failure != null
          ? failureText(l10n, failure)
          : active
          ? l10n.teacherEnabledNotice(teacher.fullName)
          : l10n.teacherDisabledNotice(teacher.fullName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(LucideIcons.keyRound, size: 16),
          onPressed: () => _reset(context),
          child: Text(l10n.resetPassword),
        ),
        if (teacher.active)
          MenuItemButton(
            leadingIcon: Icon(LucideIcons.userX, size: 16, color: Accent.red.onSoft),
            onPressed: () => _setActive(context, active: false),
            child: Text(l10n.disableAccess, style: TextStyle(color: Accent.red.onSoft)),
          )
        else
          MenuItemButton(
            leadingIcon: Icon(LucideIcons.userCheck, size: 16, color: Accent.green.onSoft),
            onPressed: () => _setActive(context, active: true),
            child: Text(l10n.enableAccess),
          ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: l10n.teacherActions,
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
        icon: const Icon(LucideIcons.ellipsis, size: 20, color: BrandColors.slate),
      ),
    );
  }
}
