import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/group.dart';
import '../../../../domain/model/student.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/common/load_status.dart';
import '../../../stateManager/groups/groups_cubit.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/reference/reference_cubit.dart';
import '../../../stateManager/students/students_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/classmates.dart';
import '../../../widgets/controls.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/labels.dart';
import '../../../widgets/page_frame.dart';
import '../../../widgets/panels.dart';
import '../../../widgets/school_widgets.dart';
import 'group_form_panel.dart';
import 'student_form_panel.dart';

enum StudentsTab { students, groups, privateLessons, archived }

/// "Élèves" (spec 02, design `r1/Eleves.png` and `r1/Groupes.png`).
class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key, this.initialTab = StudentsTab.students});

  final StudentsTab initialTab;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl.get<StudentsCubit>()..load(archived: initialTab == StudentsTab.archived),
    child: StudentsView(initialTab: initialTab),
  );
}

class StudentsView extends StatefulWidget {
  const StudentsView({super.key, this.initialTab = StudentsTab.students});

  final StudentsTab initialTab;

  @override
  State<StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> {
  late StudentsTab _tab = widget.initialTab;

  void _select(StudentsTab tab) {
    final cubit = context.read<StudentsCubit>();
    final archived = tab == StudentsTab.archived;
    if (archived != cubit.state.archived) cubit.load(archived: archived);
    setState(() => _tab = tab);
  }

  Future<void> _newStudent() async {
    final saved = await StudentFormPanel.open(context);
    if (saved != null && mounted) context.read<StudentsCubit>().load();
  }

  Future<void> _newGroup() async {
    final group = await GroupFormPanel.open(context);
    if (group != null && mounted) context.go(Routes.teacherGroup(group.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final phone = isPhone(context);
    final students = context.watch<StudentsCubit>().state;
    final groups = context.watch<GroupsCubit>().state;
    final groupTab = _tab == StudentsTab.groups || _tab == StudentsTab.privateLessons;

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        SecondaryButton(label: l10n.quickImport, icon: LucideIcons.upload, onPressed: () => context.go(Routes.teacherStudentImport)),
        if (groupTab) ...[
          SecondaryButton(label: l10n.newStudent, icon: LucideIcons.plus, onPressed: _newStudent),
          PrimaryButton(label: l10n.newGroup, icon: LucideIcons.plus, height: 44, onPressed: _newGroup),
        ] else ...[
          SecondaryButton(label: l10n.newGroup, icon: LucideIcons.users, onPressed: _newGroup),
          PrimaryButton(label: l10n.newStudent, icon: LucideIcons.plus, height: 44, onPressed: _newStudent),
        ],
      ],
    );

    final activeCount = students.archived ? null : students.students.length;
    final header = Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 20,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.navStudents, style: text.pageTitle(phone: phone)),
            if (activeCount != null && groups.status == LoadStatus.ready) ...[
              const SizedBox(height: 6),
              Text(
                l10n.studentsYearSummary(
                  l10n.studentsCount(activeCount),
                  l10n.groupsCount(groups.regular.length),
                  l10n.privateLessonsCount(groups.privateLessons.length),
                ),
                style: text.style(15, FontWeight.w500, color: BrandColors.body),
              ),
            ],
          ],
        ),
        actions,
      ],
    );

    final toolbar = Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        PillTabs<StudentsTab>(
          value: _tab,
          onChanged: _select,
          items: [
            TabItem(StudentsTab.students, l10n.navStudents, count: activeCount),
            TabItem(StudentsTab.groups, l10n.tabGroups, count: groups.status == LoadStatus.ready ? groups.regular.length : null),
            TabItem(
              StudentsTab.privateLessons,
              l10n.tabPrivateLessons,
              count: groups.status == LoadStatus.ready ? groups.privateLessons.length : null,
            ),
            TabItem(StudentsTab.archived, l10n.tabArchived),
          ],
        ),
        if (!groupTab) ...[
          SearchBox(
            hint: l10n.searchStudents,
            initialValue: students.query,
            width: phone ? double.infinity : 300,
            onChanged: context.read<StudentsCubit>().search,
          ),
          const _LevelFilter(),
        ],
      ],
    );

    final Widget content = switch (_tab) {
      StudentsTab.students || StudentsTab.archived => _StudentsList(archived: _tab == StudentsTab.archived),
      StudentsTab.groups => _GroupCards(groups: groups.regular, emptyMessage: l10n.emptyGroups, state: groups),
      StudentsTab.privateLessons => _GroupCards(groups: groups.privateLessons, emptyMessage: l10n.emptyPrivateLessons, state: groups),
    };

    return PageScroll(
      children: [
        header,
        toolbar,
        AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 220),
          child: KeyedSubtree(key: ValueKey(_tab), child: content),
        ),
      ],
    );
  }
}

class _LevelFilter extends StatelessWidget {
  const _LevelFilter();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = context.watch<LanguageCubit>().state;
    final reference = context.watch<ReferenceCubit>().state.reference;
    final levelId = context.select((StudentsCubit c) => c.state.levelId);
    if (reference == null) return const SizedBox.shrink();
    final current = levelId == null ? null : reference.level(levelId);
    return FilterMenuButton<String?>(
      label: current == null ? l10n.levelAll : l10n.levelFilter(current.name.of(language)),
      value: levelId,
      onChanged: context.read<StudentsCubit>().filterLevel,
      options: [SelectOption(null, l10n.levelAll), for (final level in reference.levels) SelectOption(level.id, level.name.of(language))],
    );
  }
}

class _StudentsList extends StatelessWidget {
  const _StudentsList({required this.archived});

  final bool archived;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<StudentsCubit>().state;
    if (state.status == LoadStatus.failure && state.students.isEmpty) {
      return FailureBanner(state.failure!, onRetry: () => context.read<StudentsCubit>().load());
    }
    if (state.status == LoadStatus.loading && state.students.isEmpty) {
      return const LinearProgressIndicator(minHeight: 3);
    }
    final visible = state.visible;
    if (visible.isEmpty) {
      return SectionCard(
        child: EmptyState(
          message: state.students.isEmpty ? (archived ? l10n.emptyArchived : l10n.emptyStudents) : l10n.noResults,
          action: state.students.isEmpty && !archived
              ? PrimaryButton(
                  label: l10n.newStudent,
                  icon: LucideIcons.plus,
                  height: 44,
                  onPressed: () async {
                    final saved = await StudentFormPanel.open(context);
                    if (saved != null && context.mounted) context.read<StudentsCubit>().load();
                  },
                )
              : null,
        ),
      );
    }
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
          for (var i = 0; i < visible.length; i++)
            FadeRise(
              index: i,
              child: _StudentRow(student: visible[i], wide: wide, phone: phone, first: phone && i == 0),
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
          Expanded(flex: 3, child: Text(text.upper(l10n.columnStudent), style: style)),
          Expanded(flex: 3, child: Text(text.upper(l10n.columnGroups), style: style)),
          if (wide) Expanded(flex: 3, child: Text(text.upper(l10n.columnParent), style: style)),
          SizedBox(width: 120, child: Text(text.upper(l10n.columnAttendance), style: style)),
          const SizedBox(width: 150),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({required this.student, required this.wide, required this.phone, required this.first});

  final StudentSummary student;
  final bool wide;
  final bool phone;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final rate = student.attendanceRate;
    final parent = student.parents.firstOrNull;
    String parentText(ParentTag p) {
      final relation = relationLabel(l10n, p.relation);
      return relation.isEmpty ? p.fullName : '${capitalized(relation)}${l10n.dotSeparator}${p.fullName}';
    }

    final attendance = SizedBox(
      width: phone ? 64 : 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rate == null ? l10n.noValue : l10n.percentValue(rate),
            textDirection: TextDirection.ltr,
            style: text.style(13, FontWeight.w800, color: attendanceColor(rate), tabular: true),
          ),
          if (rate != null) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: phone ? 56 : 110,
              child: MiniBar(value: rate, color: attendanceColor(rate)),
            ),
          ],
        ],
      ),
    );

    final Widget trailing = student.archived
        ? TonalButton(
            label: l10n.restore,
            icon: LucideIcons.archiveRestore,
            onPressed: () async {
              final failure = await context.read<StudentsCubit>().restore(student.id);
              if (!context.mounted) return;
              showNotice(context, failure == null ? l10n.studentRestored(student.fullName) : failureText(l10n, failure));
            },
          )
        : const Icon(LucideIcons.chevronRightDir, size: 18, color: BrandColors.slate);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: student.archived ? null : () => context.go(Routes.teacherStudent(student.id)),
        hoverColor: BrandColors.chalk,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: first ? null : const Border(top: BorderSide(color: BrandColors.rowDivider)),
          ),
          child: Row(
            children: [
              InitialsAvatar(initials: student.initials),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.fullName, overflow: TextOverflow.ellipsis, style: text.rowTitle),
                    Text(
                      phone && student.groups.isNotEmpty
                          ? '${student.level.of(language)}${l10n.dotSeparator}${student.groups.map((g) => g.code).join(' ')}'
                          : student.level.of(language),
                      overflow: TextOverflow.ellipsis,
                      style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                    ),
                  ],
                ),
              ),
              if (!phone)
                Expanded(
                  flex: 3,
                  child: student.groups.isEmpty
                      ? Text(l10n.noGroup, style: text.style(13, FontWeight.w500, color: BrandColors.slate))
                      : Wrap(
                          spacing: 10,
                          runSpacing: 6,
                          children: [for (final g in student.groups) GroupLabel(code: g.code, color: g.color, name: g.name)],
                        ),
                ),
              if (wide)
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Icon(parent == null ? LucideIcons.userX : LucideIcons.phone, size: 14, color: BrandColors.slate),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          parent == null ? l10n.noParent : parentText(parent),
                          overflow: TextOverflow.ellipsis,
                          style: text.style(13, FontWeight.w500, color: BrandColors.body),
                        ),
                      ),
                    ],
                  ),
                ),
              attendance,
              SizedBox(
                width: phone ? 32 : 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!phone && !student.archived && student.absences >= 2) ...[
                      Flexible(
                        child: StatusChip(label: l10n.absencesCount(student.absences), accent: Accent.red),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (!phone || !student.archived) trailing,
                  ],
                ),
              ),
              if (phone && student.archived) trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupCards extends StatelessWidget {
  const _GroupCards({required this.groups, required this.emptyMessage, required this.state});

  final List<Group> groups;
  final String emptyMessage;
  final GroupsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (state.status == LoadStatus.failure && state.groups.isEmpty) {
      return FailureBanner(state.failure!, onRetry: () => context.read<GroupsCubit>().load());
    }
    if (state.status == LoadStatus.loading && state.groups.isEmpty) return const LinearProgressIndicator(minHeight: 3);
    if (groups.isEmpty) {
      return SectionCard(
        child: EmptyState(
          message: emptyMessage,
          action: groups.isEmpty && emptyMessage == l10n.emptyGroups
              ? PrimaryButton(
                  label: l10n.newGroup,
                  icon: LucideIcons.plus,
                  height: 44,
                  onPressed: () async {
                    final group = await GroupFormPanel.open(context);
                    if (group != null && context.mounted) context.go(Routes.teacherGroup(group.id));
                  },
                )
              : null,
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 2 : 1;
        final width = (constraints.maxWidth - 24 * (columns - 1)) / columns;
        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            for (var i = 0; i < groups.length; i++)
              SizedBox(
                width: width,
                child: FadeRise(
                  index: i,
                  child: GroupCard(group: groups[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A group in the Groupes tab: square, name, schedule, place, members.
class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    return HoverCard(
      onTap: () => context.go(Routes.teacherGroup(group.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GroupSquare(code: group.code, color: group.color, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name, overflow: TextOverflow.ellipsis, style: text.style(17, FontWeight.w800)),
                    Text(
                      '${group.subject.of(language)}${l10n.dotSeparator}${group.level.of(language)}',
                      style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRightDir, size: 18, color: BrandColors.slate),
            ],
          ),
          const SizedBox(height: 16),
          ScheduleLines(group: group),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              if (group.memberCount == 0)
                Text(l10n.addStudentsHint, style: text.style(13, FontWeight.w500, color: BrandColors.slate))
              else
                Text(l10n.studentsCount(group.memberCount), style: text.style(13, FontWeight.w600, color: BrandColors.body)),
              const Spacer(),
              if (group.privateLesson) StatusChip(label: l10n.privateLesson, accent: Accent.violet),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Mardi et jeudi · 10:00 à 11:30" and the place, from the weekly rules of a group.
class ScheduleLines extends StatelessWidget {
  const ScheduleLines({super.key, required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    if (group.schedule.isEmpty) {
      return Row(
        children: [
          const Icon(LucideIcons.repeat, size: 16, color: BrandColors.indigo),
          const SizedBox(width: 8),
          Text(l10n.noSchedule, style: text.style(13, FontWeight.w600)),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final slot in group.schedule)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(LucideIcons.repeat, size: 16, color: BrandColors.indigo),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${l10n.everyWeekday(weekdayOf(slot.weekday, language))}${l10n.dotSeparator}${l10n.timeRange(slot.start.hhmm, slot.end.hhmm)}',
                    style: text.style(13, FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(slot.location == null ? LucideIcons.video : LucideIcons.mapPin, size: 15, color: BrandColors.slate),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    placeLabel(l10n, slot.mode, slot.location),
                    overflow: TextOverflow.ellipsis,
                    style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
