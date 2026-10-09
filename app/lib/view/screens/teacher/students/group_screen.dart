import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/group_detail/group_detail_cubit.dart';
import '../../../stateManager/groups/groups_cubit.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/reference/reference_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/copy_link_button.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/classmates.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/hero_card.dart';
import '../../../widgets/labels.dart';
import '../../../widgets/page_frame.dart';
import '../../../widgets/panels.dart';
import '../../../widgets/school_widgets.dart';
import '../homework/evaluation_panel.dart';
import '../planning/session_form_panel.dart';
import 'group_form_panel.dart';
import 'members_panel.dart';

/// A group or a private lesson (spec 02, design `r1/Groupe.png`).
class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) => BlocProvider(create: (_) => GroupDetailCubit(sl.get(), groupId)..load(), child: const GroupView());
}

class GroupView extends StatelessWidget {
  const GroupView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GroupDetailCubit>().state;
    return AsyncView(
      status: state.status,
      hasData: state.detail != null,
      failure: state.failure,
      onRetry: context.read<GroupDetailCubit>().load,
      builder: (context) => _Content(detail: state.detail!),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.detail});

  final GroupDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final group = detail.group;
    return PageScroll(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () => context.go(group.privateLesson ? Routes.teacherPrivateLessons : Routes.teacherGroups),
            icon: const Icon(LucideIcons.arrowLeftDir, size: 18, color: BrandColors.indigo),
            label: Text(
              group.privateLesson ? l10n.tabPrivateLessons : l10n.tabGroups,
              style: AppText.of(context).style(14, FontWeight.w700, color: BrandColors.indigo),
            ),
          ),
        ),
        _Hero(group: group),
        PairedBlocks(
          equalHeight: false,
          start: _Members(detail: detail),
          end: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Schedule(group: group),
              SizedBox(height: isPhone(context) ? 16 : 24),
              _MeetLink(group: group),
              const SizedBox(height: 16),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: DangerButton(label: l10n.archiveGroup, icon: LucideIcons.archive, onPressed: () => _archive(context, group)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _archive(BuildContext context, Group group) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<GroupDetailCubit>();
    final groups = context.read<GroupsCubit>();
    final ok = await confirmAction(
      context,
      title: '${l10n.archiveGroup} ${group.name}',
      text: l10n.archiveGroupText,
      confirmLabel: l10n.archive,
      icon: LucideIcons.archive,
    );
    if (!ok) return;
    final failure = await cubit.archive();
    if (!context.mounted) return;
    showNotice(context, failure == null ? l10n.groupArchived : failureText(l10n, failure));
    if (failure == null) {
      groups.remove(group.id);
      context.go(group.privateLesson ? Routes.teacherPrivateLessons : Routes.teacherGroups);
    }
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final phone = isPhone(context);
    final color = colorFromHex(group.color);

    Widget chip(IconData? icon, String label) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 15, color: Colors.white), const SizedBox(width: 6)],
          Text(label, style: text.style(13, FontWeight.w600, color: Colors.white)),
        ],
      ),
    );

    final slot = group.schedule.firstOrNull;
    return HeroCard(
      variant: HeroVariant.teacher,
      phone: phone,
      child: Wrap(
        spacing: 24,
        runSpacing: 18,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: phone ? 52 : 64,
                height: phone ? 52 : 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                child: Text(
                  group.code,
                  textDirection: TextDirection.ltr,
                  style: text.style(phone ? 18 : 22, FontWeight.w800, color: color.computeLuminance() > 0.45 ? BrandColors.ink : color),
                ),
              ),
              const SizedBox(width: 18),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: phone ? 220 : 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name, style: text.style(phone ? 22 : 30, FontWeight.w800, spacing: -0.6, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      '${group.subject.of(language)}${l10n.dotSeparator}${group.level.of(language)}',
                      style: text.style(14, FontWeight.w500, color: Colors.white.withValues(alpha: 0.75)),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (slot != null)
                          chip(
                            LucideIcons.repeat,
                            '${l10n.everyWeekday(weekdayOf(slot.weekday, language))}${l10n.dotSeparator}${l10n.timeRange(slot.start.hhmm, slot.end.hhmm)}',
                          ),
                        if (slot?.location != null) chip(LucideIcons.mapPin, slot!.location!),
                        chip(null, l10n.studentsCount(group.memberCount)),
                        if (group.privateLesson) chip(null, l10n.privateLesson),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              HeroButtonLight(
                label: l10n.planSession,
                icon: LucideIcons.calendarPlus,
                onPressed: () async {
                  final cubit = context.read<GroupDetailCubit>();
                  if (await SessionFormPanel.create(context, group: group)) await cubit.load();
                },
              ),
              HeroButtonGhost(
                label: l10n.newEvaluation,
                icon: LucideIcons.clipboardPen,
                onPressed: () => EvaluationPanel.createAndGrade(context, groupId: group.id),
              ),
              HeroButtonGhost(
                label: l10n.edit,
                icon: LucideIcons.pencil,
                onPressed: () async {
                  final cubit = context.read<GroupDetailCubit>();
                  final saved = await GroupFormPanel.open(context, editing: group);
                  if (saved != null) cubit.replaceGroup(saved);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Members extends StatelessWidget {
  const _Members({required this.detail});

  final GroupDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final cubit = context.read<GroupDetailCubit>();
    final members = detail.members;

    Future<void> editMembers() async {
      final groups = context.read<GroupsCubit>();
      final chosen = await MembersPanel.open(context, members.map((m) => m.studentId));
      if (chosen == null) return;
      final failure = await cubit.setMembers(chosen);
      if (!context.mounted) return;
      if (failure != null) {
        showNotice(context, failureText(l10n, failure));
      } else {
        groups.load();
      }
    }

    return SectionCard(
      title: l10n.navStudents,
      count: members.length,
      countAccent: Accent.indigo,
      trailing: TonalButton(label: l10n.addMembers, icon: LucideIcons.plus, onPressed: editMembers),
      child: members.isEmpty
          ? EmptyState(message: l10n.noMembers, scale: 0.35)
          : Column(
              children: [
                for (var i = 0; i < members.length; i++)
                  FadeRise(
                    index: i,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go(Routes.teacherStudent(members[i].studentId)),
                        hoverColor: BrandColors.chalk,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: i == 0 ? null : const Border(top: BorderSide(color: BrandColors.rowDivider)),
                          ),
                          child: Row(
                            children: [
                              InitialsAvatar(initials: members[i].initials),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(members[i].fullName, style: text.rowTitle),
                                    Text(
                                      members[i].username,
                                      textDirection: TextDirection.ltr,
                                      style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                members[i].attendanceRate == null ? l10n.noValue : l10n.percentValue(members[i].attendanceRate!),
                                textDirection: TextDirection.ltr,
                                style: text.style(13, FontWeight.w800, color: attendanceColor(members[i].attendanceRate), tabular: true),
                              ),
                              const SizedBox(width: 8),
                              const Icon(LucideIcons.chevronRightDir, size: 18, color: BrandColors.slate),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _Schedule extends StatelessWidget {
  const _Schedule({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final yearEnd = context.select((ReferenceCubit c) => c.state.reference?.currentYear?.endsOn);
    return SectionCard(
      title: l10n.usualSchedule,
      child: group.schedule.isEmpty
          ? InfoNote(text: l10n.noScheduleYet, icon: LucideIcons.calendar)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final slot in group.schedule)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const IconBadge(icon: LucideIcons.repeat, size: IconBadgeSize.medium),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.everyWeekday(weekdayOf(slot.weekday, language)), style: text.rowTitle),
                              Text(
                                '${l10n.timeRange(slot.start.hhmm, slot.end.hhmm)}${l10n.dotSeparator}${placeLabel(l10n, slot.mode, slot.location)}',
                                style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (yearEnd != null) ...[
                  const SizedBox(height: 4),
                  InfoNote(text: l10n.scheduleNote(fullDate(yearEnd, language)), icon: LucideIcons.calendar),
                ],
              ],
            ),
    );
  }
}

class _MeetLink extends StatelessWidget {
  const _MeetLink({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final link = group.defaultMeetUrl;
    return SectionCard(
      title: l10n.defaultMeetLink,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: BrandColors.chalk,
          border: Border.all(color: BrandColors.line),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.link, size: 18, color: BrandColors.slate),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                link ?? l10n.noMeetLink,
                overflow: TextOverflow.ellipsis,
                textDirection: link == null ? null : TextDirection.ltr,
                style: link == null
                    ? text.style(14, FontWeight.w500, color: BrandColors.slate)
                    : text.style(14, FontWeight.w700, color: BrandColors.indigo),
              ),
            ),
            if (link != null) ...[const SizedBox(width: 8), CopyLinkButton(url: link)],
          ],
        ),
      ),
    );
  }
}
