import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/di/injection.dart';
import '../../../core/l10n/formatting.dart';
import '../../../core/platform/link_opener.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../domain/model/homework.dart';
import '../../../domain/model/session.dart';
import '../../../domain/model/teacher_dashboard.dart';
import '../../../l10n/app_localizations.dart';
import '../../stateManager/auth/auth_cubit.dart';
import '../../stateManager/common/load_status.dart';
import '../../stateManager/groups/groups_cubit.dart';
import '../../stateManager/language/language_cubit.dart';
import '../../stateManager/teacher_home/teacher_home_cubit.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';
import '../../widgets/classmates.dart';
import '../../widgets/day_strip.dart';
import '../../widgets/hero_card.dart';
import '../../widgets/labels.dart';
import '../../widgets/page_frame.dart';
import '../../widgets/school_widgets.dart';
import 'planning/session_panel.dart';
import '../shared/my_homework_screen.dart' show homeworkWhen;
import 'teacher_quick_actions.dart';

/// "Ma journée" (docs/02-specification/01-teacher-home.md, design `TeacherHome.png`). Release 1 fills
/// the hero, today and the coming days, release 2 the copies to correct and the missing work; to watch comes
/// with release 4.
class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(create: (_) => sl.get<TeacherHomeCubit>()..load(), child: const TeacherHomeView());
}

class TeacherHomeView extends StatelessWidget {
  const TeacherHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TeacherHomeCubit>().state;
    return AsyncView(
      status: switch (state) {
        TeacherHomeLoading() => LoadStatus.loading,
        TeacherHomeFailed() => LoadStatus.failure,
        TeacherHomeLoaded() => LoadStatus.ready,
      },
      hasData: state is TeacherHomeLoaded,
      failure: state is TeacherHomeFailed ? state.failure : null,
      onRetry: context.read<TeacherHomeCubit>().load,
      builder: (context) => _Dashboard((state as TeacherHomeLoaded).dashboard),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard(this.dashboard);

  final TeacherDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final next = dashboard.next;
    return PageScroll(
      children: [
        _Header(dashboard),
        PairedBlocks(
          start: next == null ? const _FreeDayHero() : _NextSessionHero(session: next, now: dashboard.now),
          end: _Today(dashboard: dashboard),
        ),
        // "À surveiller" is gone (user decision 2026-10-09: no alerting for now): what to correct beside what comes,
        // then the missing work across the page.
        PairedBlocks(
          start: _ToCorrect(dashboard: dashboard),
          end: SectionCard(
            title: l10n.homeUpcoming,
            trailing: CardLink(label: l10n.navPlanning, onPressed: () => context.go(Routes.teacherPlanning)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DayStrip(days: dashboard.nextDays, selected: dashboard.date),
                if (dashboard.isEmpty) ...[const SizedBox(height: 8), EmptyState(message: l10n.emptyUpcoming, scale: 0.35)],
              ],
            ),
          ),
        ),
        _MissingWork(dashboard: dashboard),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.dashboard);

  final TeacherDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final phone = isPhone(context);
    final language = context.watch<LanguageCubit>().state;
    final firstName = context.select((AuthCubit cubit) => cubit.user?.firstName ?? '');
    final hasGroups = context.select((GroupsCubit c) => c.state.groups.isNotEmpty);
    final summary = !hasGroups && dashboard.isEmpty ? l10n.homeSummaryEmpty : l10n.homeSessionsToday(dashboard.todayCount);
    final greeting = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(dayDate(dashboard.date, language), style: text.style(13, FontWeight.w700, color: BrandColors.slate)),
        const SizedBox(height: 6),
        Text(l10n.greeting(firstName), style: text.pageTitle(phone: phone)),
        const SizedBox(height: 6),
        Text(summary, style: text.style(15, FontWeight.w500, color: BrandColors.body, height: 1.5)),
      ],
    );
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 20,
      runSpacing: 16,
      children: [
        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: greeting),
        QuickActionsRow(onChanged: context.read<TeacherHomeCubit>().load),
      ],
    );
  }
}

/// The session running now, or the next one today (design `TeacherHome.png`).
class _NextSessionHero extends StatelessWidget {
  const _NextSessionHero({required this.session, required this.now});

  final Session session;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final phone = isPhone(context);
    final running = session.status == SessionStatus.inProgress || !session.startsAt.isAfter(now);

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

    return HeroCard(
      variant: HeroVariant.teacher,
      phone: phone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              HeroPill(running ? l10n.statusInProgress : l10n.nextSession),
              if (!running)
                Text(
                  l10n.inDuration(durationLabel(l10n, session.startsAt.difference(now))),
                  style: text.style(14, FontWeight.w700, color: BrandColors.onDarkAmber),
                ),
            ],
          ),
          SizedBox(height: phone ? 14 : 20),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 14,
            runSpacing: 4,
            children: [
              Text(
                hm(session.startsAt),
                textDirection: TextDirection.ltr,
                style: text.heroTime(phone: phone),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  l10n.untilTime(hm(session.endsAt)),
                  style: text.style(15, FontWeight.w600, color: Colors.white.withValues(alpha: 0.75)),
                ),
              ),
            ],
          ),
          SizedBox(height: phone ? 12 : 18),
          // The group name as the teacher wrote it; the subject has its own chip.
          Text(session.group.name, style: text.heroSubject),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              chip(LucideIcons.bookOpen, session.group.subject.of(language)),
              chip(
                session.mode == SessionMode.online ? LucideIcons.video : LucideIcons.mapPin,
                placeLabel(l10n, session.mode, session.location),
              ),
              if (session.group.privateLesson) chip(null, l10n.privateLesson),
            ],
          ),
          SizedBox(height: phone ? 18 : 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              HeroButtonLight(
                label: running ? l10n.resumeSession : l10n.startSession,
                onPressed: () => context.go(Routes.sessionMode(session.id)),
              ),
              if (session.mode == SessionMode.online && session.meetUrl != null)
                HeroButtonGhost(
                  label: l10n.openMeet,
                  icon: LucideIcons.video,
                  onPressed: () => sl.get<LinkOpener>().open(session.meetUrl!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// No session left today: the hero still answers the question of the day, and offers to plan one.
class _FreeDayHero extends StatelessWidget {
  const _FreeDayHero();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final phone = isPhone(context);
    return HeroCard(
      variant: HeroVariant.teacher,
      phone: phone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeroPill(l10n.heroToday),
          SizedBox(height: phone ? 16 : 22),
          Text(
            l10n.heroFreeDayTitle,
            style: text.pageTitle(phone: phone).copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(l10n.heroFreeDayText, style: text.style(15, FontWeight.w600, color: Colors.white.withValues(alpha: 0.75))),
          SizedBox(height: phone ? 18 : 26),
          HeroButtonLight(
            label: l10n.planSession,
            icon: LucideIcons.calendarPlus,
            onPressed: () async {
              final cubit = context.read<TeacherHomeCubit>();
              if (await TeacherQuickAction.all.first.open(context)) await cubit.load();
            },
          ),
        ],
      ),
    );
  }
}

class _Today extends StatelessWidget {
  const _Today({required this.dashboard});

  final TeacherDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tomorrow = dashboard.tomorrowPlanned;
    final next = dashboard.next;
    return SectionCard(
      title: l10n.homeToday,
      trailing: CardLink(label: l10n.navPlanning, onPressed: () => context.go(Routes.teacherPlanning)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (dashboard.today.isEmpty)
            EmptyState(message: l10n.emptyToday)
          else
            for (var i = 0; i < dashboard.today.length; i++)
              FadeRise(
                index: i,
                child: _TodayRow(session: dashboard.today[i], next: dashboard.today[i].id == next?.id),
              ),
          const SizedBox(height: 12),
          InfoNote(
            icon: LucideIcons.clock,
            text: l10n.tomorrowSessions(tomorrow.length, tomorrow.isEmpty ? '' : hm(tomorrow.first.startsAt)),
          ),
        ],
      ),
    );
  }
}

class _TodayRow extends StatelessWidget {
  const _TodayRow({required this.session, required this.next});

  final Session session;
  final bool next;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = session;
    final subtitle = [
      if (s.isCancelled && s.cancelReason != null) l10n.cancelledBecause(s.cancelReason!) else placeLabel(l10n, s.mode, s.location),
      if (s.attendanceTaken) l10n.attendanceOf(s.present + s.late, s.present + s.late + s.absent),
    ].join(l10n.dotSeparator);
    return TimelineItem(
      start: hm(s.startsAt),
      end: hm(s.endsAt),
      color: s.isCancelled ? const Color(0xFFADB1C6) : colorFromHex(s.group.color),
      title: s.group.name,
      subtitle: subtitle,
      current: next || s.status == SessionStatus.inProgress,
      past: s.isDone,
      struck: s.isCancelled,
      trailing: SessionStatusChip(status: s.status, next: next && s.status == SessionStatus.planned),
      onTap: () async {
        final cubit = context.read<TeacherHomeCubit>();
        if (await SessionPanel.open(context, s.id)) await cubit.load();
      },
    );
  }
}

/// "À corriger" (design `TeacherHome.png`): how many copies wait, the five oldest, "Corriger" on each.
class _ToCorrect extends StatelessWidget {
  const _ToCorrect({required this.dashboard});

  final TeacherDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final copies = dashboard.copiesToCorrect;
    final Widget body;
    if (dashboard.toCorrect == null) {
      body = ErrorBanner(message: l10n.errorUnknown, onRetry: context.read<TeacherHomeCubit>().load, retryLabel: l10n.retry);
    } else if (copies.isEmpty) {
      body = EmptyState(message: l10n.emptyToCorrect);
    } else {
      // On a phone the "En retard" chip goes under the name, so the name keeps its room. (No LayoutBuilder: the
      // paired blocks measure their intrinsic height.)
      final narrow = isPhone(context);
      body = Column(
        children: [
          for (final (i, (assignment, item)) in copies.take(5).indexed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: i == 0 ? null : const Border(top: BorderSide(color: BrandColors.rowDivider)),
              ),
              child: Row(
                children: [
                  InitialsAvatar(initials: item.initials, size: narrow ? 34 : 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.rowTitle),
                        Text(
                          '${isolated(assignment.title)}${l10n.dotSeparator}${keptTogether(assignment.group.name)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                        ),
                        if (narrow && item.status == HomeworkStatus.late) ...[
                          const SizedBox(height: 4),
                          StatusChip(label: l10n.attendanceLate, accent: Accent.orange),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!narrow) ...[
                    if (item.status == HomeworkStatus.late)
                      StatusChip(label: l10n.attendanceLate, accent: Accent.orange)
                    else
                      Text(
                        timeAgo(l10n, language, item.submittedAt, dashboard.now),
                        style: text.style(12, FontWeight.w500, color: BrandColors.slate),
                      ),
                    const SizedBox(width: 8),
                  ],
                  TonalButton(
                    label: l10n.correctAction,
                    onPressed: () async {
                      final cubit = context.read<TeacherHomeCubit>();
                      await context.push(Routes.teacherCorrection(assignment.id, item.studentId));
                      if (!cubit.isClosed) cubit.load();
                    },
                  ),
                ],
              ),
            ),
        ],
      );
    }
    return SectionCard(
      title: l10n.homeToCorrect,
      count: copies.isEmpty ? null : copies.length,
      countAccent: Accent.amber,
      trailing: copies.isEmpty ? null : CardLink(label: l10n.seeAll, onPressed: () => context.go(Routes.teacherAssignments)),
      child: body,
    );
  }
}

/// "Travail manquant" (design `TeacherHome.png`): each homework past its deadline once, how many sent, and
/// who sent nothing.
class _MissingWork extends StatelessWidget {
  const _MissingWork({required this.dashboard});

  final TeacherDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final work = dashboard.missingWork;
    final total = (work ?? const <MissingWork>[]).fold(0, (sum, w) => sum + w.missing.length);
    final Widget body;
    if (work == null) {
      body = ErrorBanner(message: l10n.errorUnknown, onRetry: context.read<TeacherHomeCubit>().load, retryLabel: l10n.retry);
    } else if (work.isEmpty) {
      body = EmptyState(message: l10n.emptyMissing);
    } else {
      body = Column(
        children: [
          for (final (i, w) in work.take(3).indexed) ...[
            if (i > 0) const SizedBox(height: 10),
            HoverCard(
              radius: AppRadii.row,
              padding: const EdgeInsets.all(14),
              onTap: () => context.go(Routes.teacherHomework(w.assignment.id)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(w.assignment.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.rowTitle),
                            Text(
                              '${keptTogether(w.assignment.group.name)}${l10n.dotSeparator}'
                              '${l10n.deadlineWas(homeworkWhen(l10n, language, w.assignment.deadlineAt, dashboard.now))}',
                              style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      AvatarStack(initials: [for (final p in w.missing) p.initials], size: 30, max: 3),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: MiniBar(
                          value: w.assignment.recipients == 0 ? 0 : (w.assignment.counts.sent * 100 / w.assignment.recipients).round(),
                          color: BrandColors.turquoise,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.countOf(w.assignment.counts.sent, w.assignment.recipients),
                        style: text.style(12, FontWeight.w700, color: BrandColors.body),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }
    return SectionCard(title: l10n.homeMissing, count: total == 0 ? null : total, countAccent: Accent.red, child: body);
  }
}
