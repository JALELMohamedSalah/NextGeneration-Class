import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/di/injection.dart';
import '../../../core/l10n/formatting.dart';
import '../../../core/l10n/tunis_time.dart';
import '../../../core/platform/link_opener.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../domain/model/app_notification.dart';
import '../../../domain/model/app_user.dart';
import '../../../domain/model/session.dart';
import '../../../l10n/app_localizations.dart';
import '../../stateManager/auth/auth_cubit.dart';
import '../../stateManager/common/load_status.dart';
import '../../stateManager/language/language_cubit.dart';
import '../../stateManager/my_planning/my_planning_cubit.dart';
import '../../stateManager/notifications/notifications_cubit.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';
import '../../widgets/classmates.dart';
import '../../widgets/labels.dart';
import '../../widgets/page_frame.dart';
import '../../widgets/school_widgets.dart';

/// Planning of a student (design `r1/EspaceEleve.png`), or of a parent's child (`r1/PlanningPhone.png`).
class MyPlanningScreen extends StatefulWidget {
  const MyPlanningScreen({super.key});

  @override
  State<MyPlanningScreen> createState() => _MyPlanningScreenState();
}

class _MyPlanningScreenState extends State<MyPlanningScreen> {
  @override
  void initState() {
    super.initState();
    // A pupil's moved sessions show their former time, kept in the notifications.
    if (context.read<AuthCubit>().user?.role == UserRole.student) context.read<NotificationsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().user;
    // A parent opens on the child named in the link (from a notification), else on the first one.
    final children = user?.role == UserRole.parent ? user!.children : const <ChildSummary>[];
    final requested = GoRouter.maybeOf(context)?.routerDelegate.currentConfiguration.uri.queryParameters[Routes.childParam];
    final child = (children.where((c) => c.studentId == requested).firstOrNull ?? children.firstOrNull)?.studentId;
    return BlocProvider(
      create: (_) => MyPlanningCubit(sl.get(), sl.get<Now>())..load(studentId: child),
      child: const MyPlanningView(),
    );
  }
}

class MyPlanningView extends StatelessWidget {
  const MyPlanningView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MyPlanningCubit>().state;
    return AsyncView(
      status: state.status,
      hasData: state.sessions.isNotEmpty || state.status == LoadStatus.ready,
      failure: state.failure,
      onRetry: () => context.read<MyPlanningCubit>().load(studentId: state.studentId),
      builder: (context) => const _Content(),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final user = context.select((AuthCubit c) => c.user);
    final state = context.watch<MyPlanningCubit>().state;
    final parent = user?.role == UserRole.parent;
    final child = parent ? user!.children.where((c) => c.studentId == state.studentId).firstOrNull : null;
    final phone = isPhone(context);

    final days = <DateTime, List<MySession>>{};
    for (final s in state.upcoming) {
      days.putIfAbsent(TunisTime.day(s.startsAt), () => []).add(s);
    }
    // A pupil reads the days by week: "Cette semaine", "Semaine prochaine", "Plus tard".
    final thisMonday = TunisTime.weekStart(state.today);
    int weekOf(DateTime day) => TunisTime.weekStart(day).difference(thisMonday).inDays ~/ 7;
    String weekLabel(int week) => switch (week) {
      0 => l10n.thisWeek,
      1 => l10n.nextWeek,
      _ => l10n.laterOn,
    };
    final moves = parent ? const <AppNotification>[] : context.select((NotificationsCubit c) => c.state.items);

    final week = state.thisWeek;
    final rate = state.monthAttendanceRate;
    // One day: its heading and its sessions. Days sit two by two on a wide screen, like a calendar.
    Widget dayBlock(MapEntry<DateTime, List<MySession>> entry) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(dayHeading(l10n, language, entry.key, state.today), style: text.style(parent ? 13 : 14, FontWeight.w800)),
        for (final s in entry.value) ...[
          const SizedBox(height: 10),
          _SessionCard(session: s, now: state.now, parent: parent, movedFrom: parent ? null : _movedFrom(s, moves)),
        ],
      ],
    );
    final weeks = <int, List<MapEntry<DateTime, List<MySession>>>>{};
    for (final entry in days.entries) {
      weeks.putIfAbsent(weekOf(entry.key), () => []).add(entry);
    }
    return PageScroll(
      maxWidth: familyPageWidth,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (parent) Text(l10n.navPlanning, style: text.style(13, FontWeight.w600, color: BrandColors.slate)),
            Text(
              parent && child != null ? l10n.childSessions(child.firstName) : l10n.navPlanning,
              style: text.pageTitle(phone: phone || parent),
            ),
            if (parent && user!.children.length > 1) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in user.children)
                    ChoiceChip(
                      label: Text('${c.firstName}${l10n.dotSeparator}${c.level.of(language)}'),
                      selected: c.studentId == state.studentId,
                      showCheckmark: false,
                      selectedColor: BrandColors.ink,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: c.studentId == state.studentId ? BrandColors.ink : BrandColors.line),
                      labelStyle: text.style(13, FontWeight.w700, color: c.studentId == state.studentId ? Colors.white : BrandColors.ink),
                      onSelected: (_) => context.read<MyPlanningCubit>().load(studentId: c.studentId),
                    ),
                ],
              ),
            ],
          ],
        ),
        if (parent)
          Row(
            children: [
              Expanded(
                child: _Tile(
                  title: l10n.attendance,
                  value: rate == null ? l10n.noValue : l10n.percentValue(rate),
                  caption: l10n.absencesThisMonth(state.monthAbsences),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Tile(
                  title: l10n.thisWeek,
                  value: l10n.sessionsCount(week.where((s) => !s.isCancelled).length),
                  caption: week.any((s) => s.isCancelled) ? l10n.cancelledCount(week.where((s) => s.isCancelled).length) : null,
                ),
              ),
            ],
          ),
        if (days.isEmpty)
          SectionCard(child: EmptyState(message: l10n.emptyMyPlanning, scale: 0.35))
        else if (parent)
          CardColumns(gap: 20, children: [for (final entry in days.entries) dayBlock(entry)])
        else
          // A pupil reads the days by week: "Cette semaine", "Semaine prochaine", "Plus tard".
          for (final week in weeks.entries)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(text.upper(weekLabel(week.key)), style: text.overline(color: BrandColors.indigo)),
                const SizedBox(height: 12),
                CardColumns(gap: 20, children: [for (final entry in week.value) dayBlock(entry)]),
              ],
            ),
      ],
    );
  }
}

/// The former time of a session the teacher moved, when its notification still says so.
DateTime? _movedFrom(MySession session, List<AppNotification> notifications) => notifications
    .where((n) => n.kind == NotificationKind.moved && n.sessionId == session.id && n.startsAt == session.startsAt)
    .firstOrNull
    ?.previousStartsAt;

class _Tile extends StatelessWidget {
  const _Tile({required this.title, required this.value, this.caption});

  final String title;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.row),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text.upper(title), style: text.overline(size: 11)),
          const SizedBox(height: 4),
          Text(value, textDirection: TextDirection.ltr, style: text.style(22, FontWeight.w800, tabular: true)),
          if (caption != null) Text(caption!, style: text.style(12, FontWeight.w500, color: BrandColors.slate)),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.now, required this.parent, this.movedFrom});

  final MySession session;
  final DateTime now;
  final bool parent;

  /// A pupil's session the teacher moved: its former time.
  final DateTime? movedFrom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final cancelled = session.isCancelled;
    final done = session.status == SessionStatus.done;
    final color = cancelled ? const Color(0xFFADB1C6) : colorFromHex(session.group.color);
    // A pupil reads a size up, and only what is out of the ordinary is marked.
    final pupil = !parent;
    final online = session.mode == SessionMode.online;
    final Widget? chip = session.attendance != null
        ? AttendanceChip(status: session.attendance!)
        : cancelled
        ? (pupil ? StatusChip(label: l10n.statusCancelled, accent: Accent.red) : null)
        : pupil && session.status == SessionStatus.planned
        ? (movedFrom != null ? StatusChip(label: l10n.newTime, accent: Accent.blue) : null)
        : SessionStatusChip(status: session.status);
    final waitingForLink =
        pupil && online && !cancelled && session.meetUrl != null && session.startsAt.isAfter(now) && !session.canJoin(now);
    final detail = text.style(pupil ? 14 : 13, FontWeight.w500, color: BrandColors.slate);
    return Opacity(
      opacity: done && session.attendance == null ? 0.6 : 1,
      child: Container(
        padding: EdgeInsets.all(pupil ? 16 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: BrandColors.line),
          borderRadius: BorderRadius.circular(AppRadii.tile),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: pupil ? 52 : 48,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(hm(session.startsAt), style: text.style(pupil ? 17 : 14, FontWeight.w800, tabular: true)),
                      Text(
                        hm(session.endsAt),
                        style: text.style(pupil ? 13 : 12, FontWeight.w500, color: BrandColors.slate, tabular: true),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 4,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.group.name,
                      style: (pupil ? text.style(16, FontWeight.w700) : text.rowTitle).copyWith(
                        decoration: cancelled ? TextDecoration.lineThrough : null,
                        color: cancelled ? BrandColors.slate : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (!(pupil && cancelled))
                      Row(
                        children: [
                          if (pupil && online && !cancelled) ...[
                            const Icon(LucideIcons.video, size: 15, color: BrandColors.slate),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              cancelled ? l10n.statusCancelled : placeLabel(l10n, session.mode, session.location, family: true),
                              style: detail,
                            ),
                          ),
                        ],
                      ),
                    if (chip != null) ...[const SizedBox(height: 8), chip],
                    if (cancelled && session.cancelReason != null) ...[
                      if (pupil) const SizedBox(height: 4),
                      Text(
                        l10n.cancelledBecause(isolated(session.cancelReason!)),
                        style: text.style(pupil ? 14 : 13, FontWeight.w600, color: Accent.red.onSoft),
                      ),
                    ],
                    if (movedFrom != null && !cancelled) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.previousTime(l10n.dayAtTime(dayInSentence(TunisTime.day(movedFrom!), language), hm(movedFrom!))),
                        style: text.style(13, FontWeight.w500, color: BrandColors.slate).copyWith(decoration: TextDecoration.lineThrough),
                      ),
                    ],
                    if (waitingForLink) ...[
                      const SizedBox(height: 6),
                      Text(l10n.joinOpensBefore, style: text.style(13, FontWeight.w500, color: BrandColors.slate)),
                    ],
                    if (pupil && session.canJoin(now)) ...[
                      const SizedBox(height: 10),
                      PrimaryButton(
                        label: l10n.joinSession,
                        icon: LucideIcons.video,
                        height: 44,
                        onPressed: () => sl.get<LinkOpener>().open(session.meetUrl!),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
