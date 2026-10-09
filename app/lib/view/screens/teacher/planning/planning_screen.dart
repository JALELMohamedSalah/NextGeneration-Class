import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/l10n/tunis_time.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/clock_time.dart';
import '../../../../domain/model/group.dart';
import '../../../../domain/model/session.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/common/load_status.dart';
import '../../../stateManager/groups/groups_cubit.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/planning/planning_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/classmates.dart';
import '../../../widgets/controls.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/labels.dart';
import '../../../widgets/page_frame.dart';
import '../../../widgets/school_widgets.dart';
import 'session_form_panel.dart';
import 'session_panel.dart';

/// The teacher's calendar (spec 03, design `r1/Planning.png`).
class PlanningScreen extends StatelessWidget {
  const PlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phone = MediaQuery.sizeOf(context).width < Breakpoints.tablet;
    return BlocProvider(
      create: (_) => PlanningCubit(sl.get(), sl.get<Now>(), view: phone ? PlanningView.day : PlanningView.week)..load(),
      child: const PlanningBoard(),
    );
  }
}

class PlanningBoard extends StatefulWidget {
  const PlanningBoard({super.key});

  @override
  State<PlanningBoard> createState() => _PlanningBoardState();
}

class _PlanningBoardState extends State<PlanningBoard> {
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    // The "now" line moves with the clock.
    _clock = Timer.periodic(const Duration(minutes: 1), (_) => mounted ? setState(() {}) : null);
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _create({DateTime? day, ClockTime? start}) async {
    final cubit = context.read<PlanningCubit>();
    final groupId = cubit.state.groupId;
    final group = groupId == null ? null : context.read<GroupsCubit>().state.byId(groupId);
    final saved = await SessionFormPanel.create(context, date: day, start: start, group: group);
    if (saved) await cubit.load();
  }

  Future<void> _open(Session session) async {
    final cubit = context.read<PlanningCubit>();
    if (await SessionPanel.open(context, session.id)) await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final state = context.watch<PlanningCubit>().state;
    final cubit = context.read<PlanningCubit>();
    final groups = context.watch<GroupsCubit>().state.groups;
    final phone = isPhone(context);
    final selectedGroup = state.groupId == null ? null : groups.where((g) => g.id == state.groupId).firstOrNull;

    final header = Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 16,
      runSpacing: 14,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(monthYear(state.day, language), style: text.style(13, FontWeight.w700, color: BrandColors.slate)),
            const SizedBox(height: 6),
            Text(l10n.navPlanning, style: text.pageTitle(phone: phone)),
          ],
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PillTabs<PlanningView>(
              value: state.view,
              onChanged: cubit.setView,
              items: [TabItem(PlanningView.day, l10n.viewDay), TabItem(PlanningView.week, l10n.viewWeek)],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconSquareButton(icon: LucideIcons.chevronLeftDir, tooltip: l10n.previous, onPressed: cubit.previous),
                const SizedBox(width: 6),
                SecondaryButton(label: l10n.heroToday, onPressed: cubit.goToday),
                const SizedBox(width: 6),
                IconSquareButton(icon: LucideIcons.chevronRightDir, tooltip: l10n.next, onPressed: cubit.next),
              ],
            ),
            if (groups.isNotEmpty)
              FilterMenuButton<String?>(
                label: selectedGroup?.name ?? l10n.allGroups,
                value: state.groupId,
                onChanged: cubit.setGroup,
                options: [
                  SelectOption(null, l10n.allGroups),
                  for (final g in groups)
                    SelectOption(
                      g.id,
                      g.name,
                      leading: GroupSquare(code: g.code, color: g.color, size: 20),
                    ),
                ],
              ),
            PrimaryButton(
              label: l10n.newSession,
              icon: LucideIcons.plus,
              height: 44,
              onPressed: () => _create(day: state.day),
            ),
          ],
        ),
      ],
    );

    final Widget body;
    if (state.status == LoadStatus.failure && state.sessions.isEmpty) {
      body = FailureBanner(state.failure!, onRetry: cubit.load);
    } else if (state.view == PlanningView.week && !phone) {
      body = _WeekGrid(
        state: state,
        onOpen: _open,
        onSlot: (day, start) => _create(day: day, start: start),
      );
    } else {
      body = _DayList(
        state: state,
        onOpen: _open,
        onCreate: () => _create(day: state.day),
      );
    }

    final slide = MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 280);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return PageScroll(
      maxWidth: 1600,
      children: [
        header,
        Stack(
          children: [
            AnimatedSwitcher(
              duration: slide,
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (child, animation) {
                final dx = state.direction * (rtl ? -0.06 : 0.06);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(begin: Offset(dx, 0), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(key: ValueKey('${state.view}-${state.from}-${state.groupId}'), child: body),
            ),
            if (state.status == LoadStatus.loading)
              const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(minHeight: 3)),
          ],
        ),
        if (!phone && state.view == PlanningView.week) _Legend(groups: groups.where((g) => !g.privateLesson).toList()),
      ],
    );
  }
}

/// Session block colors: soft tint of the group color with a strong edge (ink text on amber).
(Color, Color, Color) _blockColors(String hex) {
  final strong = colorFromHex(hex);
  final soft = Color.alphaBlend(strong.withValues(alpha: 0.13), Colors.white);
  final label = strong.computeLuminance() > 0.45 ? Accent.amber.onSoft : strong;
  return (strong, soft, label);
}

class _WeekGrid extends StatelessWidget {
  const _WeekGrid({required this.state, required this.onOpen, required this.onSlot});

  final PlanningState state;
  final ValueChanged<Session> onOpen;
  final void Function(DateTime day, ClockTime start) onSlot;

  static const hourHeight = 64.0;
  static const headHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final now = sl.get<Now>()();
    // 08:00 to 20:00, stretched to fit early or late sessions.
    var first = 8;
    var last = 20;
    for (final s in state.sessions) {
      first = TunisTime.clock(s.startsAt).hour < first ? TunisTime.clock(s.startsAt).hour : first;
      final end = TunisTime.clock(s.endsAt);
      final endHour = end.minute > 0 ? end.hour + 1 : end.hour;
      last = endHour > last ? endHour.clamp(0, 24) : last;
    }
    final hours = last - first;
    final next = state.sessions.where((s) => !s.isCancelled && s.startsAt.isAfter(now)).firstOrNull;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Column(
              children: [
                const SizedBox(height: headHeight),
                for (var h = first; h < last; h++)
                  SizedBox(
                    height: hourHeight,
                    child: Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 10),
                        child: Transform.translate(
                          offset: const Offset(0, -8),
                          child: Text(
                            '${h.toString().padLeft(2, '0')}:00',
                            textDirection: TextDirection.ltr,
                            style: text.style(12, FontWeight.w700, color: BrandColors.slate, tabular: true),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          for (final day in state.days)
            Expanded(
              child: _DayColumn(
                day: day,
                today: TunisTime.sameDay(day, state.today),
                sessions: state.on(day),
                firstHour: first,
                hours: hours,
                now: now,
                nextId: next?.id,
                weekday: weekdayShort(day, language),
                onOpen: onOpen,
                onSlot: onSlot,
              ),
            ),
        ],
      ),
    );
  }
}

class _DayColumn extends StatefulWidget {
  const _DayColumn({
    required this.day,
    required this.today,
    required this.sessions,
    required this.firstHour,
    required this.hours,
    required this.now,
    required this.nextId,
    required this.weekday,
    required this.onOpen,
    required this.onSlot,
  });

  final DateTime day;
  final bool today;
  final List<Session> sessions;
  final int firstHour;
  final int hours;
  final DateTime now;
  final String? nextId;
  final String weekday;
  final ValueChanged<Session> onOpen;
  final void Function(DateTime day, ClockTime start) onSlot;

  @override
  State<_DayColumn> createState() => _DayColumnState();
}

class _DayColumnState extends State<_DayColumn> {
  /// The half hour under the mouse, in minutes from the first hour.
  int? _hover;

  static const _hourHeight = _WeekGrid.hourHeight;

  int _slotAt(double dy) => ((dy / _hourHeight) * 2).floor() * 30;

  bool _free(int minutes) {
    final start = TunisTime.instant(widget.day, ClockTime(widget.firstHour, 0)).add(Duration(minutes: minutes));
    final end = start.add(const Duration(minutes: 90));
    return !widget.sessions.any((s) => !s.isCancelled && s.startsAt.isBefore(end) && s.endsAt.isAfter(start));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final height = widget.hours * _hourHeight;
    double y(DateTime instant) {
      final c = TunisTime.clock(instant);
      return (c.minutes - widget.firstHour * 60) / 60 * _hourHeight;
    }

    final hover = _hover;
    return Container(
      decoration: BoxDecoration(
        color: widget.today ? const Color(0xFFFBFBFE) : null,
        border: const BorderDirectional(start: BorderSide(color: BrandColors.rowDivider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: _WeekGrid.headHeight,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: BrandColors.line)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text.upper(widget.weekday),
                  style: text.style(12, FontWeight.w700, color: widget.today ? BrandColors.indigo : BrandColors.slate),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: widget.today ? BrandColors.indigo : null, shape: BoxShape.circle),
                  child: Text(
                    '${widget.day.day}',
                    style: text.style(18, FontWeight.w800, color: widget.today ? Colors.white : BrandColors.ink, tabular: true),
                  ),
                ),
              ],
            ),
          ),
          MouseRegion(
            onHover: (e) => setState(() => _hover = _slotAt(e.localPosition.dy)),
            onExit: (_) => setState(() => _hover = null),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) {
                final minutes = _slotAt(d.localPosition.dy);
                if (!_free(minutes)) return;
                final total = widget.firstHour * 60 + minutes;
                widget.onSlot(widget.day, ClockTime(total ~/ 60, total % 60));
              },
              child: SizedBox(
                height: height,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        for (var i = 0; i < widget.hours; i++)
                          Container(
                            height: _hourHeight,
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: BrandColors.rowDivider)),
                            ),
                          ),
                      ],
                    ),
                    if (hover != null && _free(hover) && hover < widget.hours * 60)
                      PositionedDirectional(
                        top: hover / 60 * _hourHeight + 2,
                        start: 4,
                        end: 4,
                        height: _hourHeight * 1.5 - 4,
                        child: IgnorePointer(
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: BrandColors.indigoSoft.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(AppRadii.sm),
                              border: Border.all(color: BrandColors.indigo.withValues(alpha: 0.6), width: 1.2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.plus, size: 15, color: BrandColors.indigo),
                                const SizedBox(width: 4),
                                Text(l10n.quickSession, style: text.style(13, FontWeight.w700, color: BrandColors.indigo)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    for (final s in widget.sessions)
                      PositionedDirectional(
                        top: y(s.startsAt) + 2,
                        start: 4,
                        end: 4,
                        height: (y(s.endsAt) - y(s.startsAt) - 4).clamp(26, double.infinity),
                        child: _SessionBlock(session: s, next: s.id == widget.nextId, onTap: () => widget.onOpen(s)),
                      ),
                    if (widget.today && y(widget.now) >= 0 && y(widget.now) <= height)
                      PositionedDirectional(
                        top: y(widget.now) - 1,
                        start: 0,
                        end: 0,
                        child: IgnorePointer(
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(color: BrandColors.amber, shape: BoxShape.circle),
                              ),
                              Expanded(child: Container(height: 2, color: BrandColors.amber)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionBlock extends StatefulWidget {
  const _SessionBlock({required this.session, required this.next, required this.onTap});

  final Session session;
  final bool next;
  final VoidCallback onTap;

  @override
  State<_SessionBlock> createState() => _SessionBlockState();
}

class _SessionBlockState extends State<_SessionBlock> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final s = widget.session;
    final (strong, soft, label) = _blockColors(s.group.color);
    final cancelled = s.isCancelled;
    final radius = BorderRadius.circular(AppRadii.sm);
    final time = '${timeRangeLabel(l10n, s.startsAt, s.endsAt)}${widget.next ? '${l10n.dotSeparator}${l10n.statusNext}' : ''}';
    final status = switch (s.status) {
      SessionStatus.cancelled => l10n.statusCancelled,
      SessionStatus.done => l10n.statusDone,
      SessionStatus.inProgress => l10n.statusInProgress,
      SessionStatus.planned => widget.next ? l10n.statusNext : l10n.statusPlanned,
    };
    return Semantics(
      button: true,
      label: '${s.group.name}, ${timeRangeLabel(l10n, s.startsAt, s.endsAt)}, $status',
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 150),
            transform: Matrix4.translationValues(0, _hover ? -1.5 : 0, 0),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: cancelled ? BrandColors.chalk : soft,
              borderRadius: radius,
              border: widget.next ? Border.all(color: BrandColors.indigo, width: 2) : null,
              boxShadow: _hover ? const [BoxShadow(color: Color(0x1A1C2566), blurRadius: 14, offset: Offset(0, 6))] : null,
            ),
            child: Opacity(
              opacity: s.isDone ? 0.55 : 1,
              child: CustomPaint(
                painter: cancelled ? _HatchPainter() : null,
                child: Container(
                  decoration: BoxDecoration(
                    border: BorderDirectional(start: BorderSide(color: cancelled ? const Color(0xFFADB1C6) : strong, width: 4)),
                  ),
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 6, 6, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.style(12, FontWeight.w800, color: cancelled ? BrandColors.slate : label, tabular: true),
                      ),
                      Text(
                        s.group.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text
                            .style(13, FontWeight.w700, height: 1.25)
                            .copyWith(
                              decoration: cancelled ? TextDecoration.lineThrough : null,
                              color: cancelled ? BrandColors.slate : BrandColors.ink,
                            ),
                      ),
                      Row(
                        children: [
                          Icon(s.mode == SessionMode.online ? LucideIcons.video : LucideIcons.mapPin, size: 12, color: BrandColors.slate),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              cancelled ? l10n.statusCancelled : placeLabel(l10n, s.mode, s.location),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.style(12, FontWeight.w500, color: BrandColors.slate),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEEF0F5)
      ..strokeWidth = 6;
    for (var x = -size.height; x < size.width; x += 12) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_HatchPainter oldDelegate) => false;
}

/// Phone and day view: a strip of the week's days, then the sessions of the chosen day as rows.
class _DayList extends StatelessWidget {
  const _DayList({required this.state, required this.onOpen, required this.onCreate});

  final PlanningState state;
  final ValueChanged<Session> onOpen;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final cubit = context.read<PlanningCubit>();
    final now = sl.get<Now>()();
    final week = [for (var i = 0; i < 7; i++) TunisTime.addDays(TunisTime.weekStart(state.day), i)];
    final sessions = state.view == PlanningView.day ? state.on(state.day) : state.sessions;
    final next = sessions.where((s) => !s.isCancelled && s.startsAt.isAfter(now)).firstOrNull;

    Widget row(Session s) {
      final (strong, _, _) = _blockColors(s.group.color);
      return TimelineItem(
        start: hm(s.startsAt),
        end: hm(s.endsAt),
        color: s.isCancelled ? const Color(0xFFADB1C6) : strong,
        title: s.group.name,
        subtitle: s.isCancelled && s.cancelReason != null ? l10n.cancelledBecause(s.cancelReason!) : placeLabel(l10n, s.mode, s.location),
        current: s.id == next?.id || s.status == SessionStatus.inProgress,
        past: s.isDone,
        struck: s.isCancelled,
        trailing: SessionStatusChip(status: s.status, next: s.id == next?.id),
        onTap: () => onOpen(s),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.view == PlanningView.day) ...[
          Row(
            children: [
              for (final day in week) ...[
                Expanded(
                  child: _DayChip(
                    weekday: weekdayShort(day, language),
                    day: day.day,
                    selected: TunisTime.sameDay(day, state.day),
                    today: TunisTime.sameDay(day, state.today),
                    onTap: () => cubit.openDay(day),
                  ),
                ),
                if (day != week.last) const SizedBox(width: 6),
              ],
            ],
          ),
          const SizedBox(height: 16),
        ],
        SectionCard(
          title: state.view == PlanningView.day ? dayHeading(l10n, language, state.day, state.today) : null,
          child: sessions.isEmpty && state.status != LoadStatus.loading
              ? EmptyState(
                  message: state.view == PlanningView.day ? l10n.emptyDay : l10n.emptyWeek,
                  scale: 0.35,
                  action: SecondaryButton(label: l10n.newSession, icon: LucideIcons.plus, onPressed: onCreate),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.view == PlanningView.week)
                      for (final day in state.days)
                        if (state.on(day).isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 4),
                            child: Text(dayHeading(l10n, language, day, state.today), style: text.style(13, FontWeight.w800)),
                          ),
                          for (final s in state.on(day)) row(s),
                        ],
                    if (state.view == PlanningView.day)
                      for (var i = 0; i < sessions.length; i++) FadeRise(index: i, child: row(sessions[i])),
                  ],
                ),
        ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.weekday, required this.day, required this.selected, required this.today, required this.onTap});

  final String weekday;
  final int day;
  final bool selected;
  final bool today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final radius = BorderRadius.circular(AppRadii.row);
    return Semantics(
      selected: selected,
      button: true,
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? BrandColors.indigoDeep : Colors.white,
          borderRadius: radius,
          border: Border.all(color: selected ? BrandColors.indigoDeep : (today ? BrandColors.indigo : BrandColors.line)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Text(
                    weekday,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: text.style(11, FontWeight.w700, color: selected ? Colors.white70 : BrandColors.slate),
                  ),
                  Text('$day', style: text.style(18, FontWeight.w800, color: selected ? Colors.white : BrandColors.ink, tabular: true)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.groups});

  final List<Group> groups;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final style = text.style(13, FontWeight.w500, color: BrandColors.slate);
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final g in groups)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: colorFromHex(g.color), borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: 8),
              Text(g.name, style: style),
            ],
          ),
        Text(l10n.planningLegend, style: style),
      ],
    );
  }
}
