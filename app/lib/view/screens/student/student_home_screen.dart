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
import '../../../domain/model/session.dart';
import '../../../l10n/app_localizations.dart';
import '../../stateManager/auth/auth_cubit.dart';
import '../../stateManager/common/load_status.dart';
import '../../stateManager/language/language_cubit.dart';
import '../../stateManager/my_planning/my_planning_cubit.dart';
import '../../stateManager/notifications/notifications_cubit.dart';
import '../../widgets/cards.dart';
import '../../widgets/feedback.dart';
import '../../widgets/hero_card.dart';
import '../../widgets/labels.dart';
import '../../widgets/page_frame.dart';
import '../shared/notifications_screen.dart';

/// Student home (docs/02-specification/09-student-space.md, design `r1/EspaceEleve.png`): what changed,
/// the next session in plain words, and the week at a glance. Work to do and results arrive with release 2.
class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    // "Du nouveau" lists the unread notifications of the shell.
    context.read<NotificationsCubit>().load();
  }

  @override
  Widget build(BuildContext context) =>
      BlocProvider(create: (_) => MyPlanningCubit(sl.get(), sl.get<Now>())..load(), child: const StudentHomeView());
}

class StudentHomeView extends StatelessWidget {
  const StudentHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final phone = isPhone(context);
    final firstName = context.select((AuthCubit cubit) => cubit.user?.firstName ?? '');
    final state = context.watch<MyPlanningCubit>().state;
    final unread = context.select((NotificationsCubit c) => c.unread);
    final whatsNew = unread.isEmpty ? null : _WhatsNew(items: unread, now: state.now);
    final hero = _NextSessionHero(session: state.next, now: state.now, loading: state.status == LoadStatus.loading);
    final week = state.status == LoadStatus.ready ? _MyWeek(state: state) : null;
    return PageScroll(
      maxWidth: familyPageWidth,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.greeting(firstName), style: text.pageTitle(phone: phone)),
            if (state.status == LoadStatus.ready) ...[
              const SizedBox(height: 2),
              Text(
                l10n.weekSummary(state.thisWeek.where((s) => !s.isCancelled && s.endsAt.isAfter(state.now)).length),
                style: text.style(15, FontWeight.w500, color: BrandColors.body),
              ),
            ],
          ],
        ),
        if (state.status == LoadStatus.failure) ...[
          ?whatsNew,
          FailureBanner(state.failure!, onRetry: () => context.read<MyPlanningCubit>().load()),
        ] else
          // On a computer: the next session and the week on the start side, what is new beside them (or the
          // week, when nothing is new). On phones, one under the other, what is new first.
          LayoutBuilder(
            builder: (context, constraints) {
              final gap = phone ? 16.0 : 24.0;
              Widget column(List<Widget?> blocks) {
                final shown = blocks.whereType<Widget>().toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < shown.length; i++) ...[if (i > 0) SizedBox(height: gap), shown[i]],
                  ],
                );
              }

              if (constraints.maxWidth < Breakpoints.pairedBlocks) return column([whatsNew, hero, week]);
              final (start, end) = whatsNew == null ? ([hero], [week]) : ([hero, week], [whatsNew]);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: column(start)),
                  const SizedBox(width: 24),
                  Expanded(flex: 5, child: column(end)),
                ],
              );
            },
          ),
      ],
    );
  }
}

/// Unread changes, on top: a child rarely opens the bell. Reading one (or all) removes the card.
class _WhatsNew extends StatelessWidget {
  const _WhatsNew({required this.items, required this.now});

  static const shown = 2;

  final List<AppNotification> items;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final visible = items.take(shown).toList();
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: NotificationTile.unreadTint,
        border: Border.all(color: NotificationTile.unreadLine),
        borderRadius: BorderRadius.circular(AppRadii.tile),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(text.upper(l10n.whatsNew), style: text.overline(color: BrandColors.indigo)),
              ),
              CardLink(label: l10n.seeAll, onPressed: () => context.push(Routes.studentNotifications)),
            ],
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0) const Divider(height: 14, color: NotificationTile.unreadLine),
            NotificationTile(notification: visible[i], now: now, embedded: true),
          ],
        ],
      ),
    );
  }
}

class _NextSessionHero extends StatelessWidget {
  const _NextSessionHero({required this.session, required this.now, required this.loading});

  final MySession? session;
  final DateTime now;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final s = session;
    final Widget content;
    if (s == null) {
      content = Column(
        key: const ValueKey('none'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeroPill(l10n.nextSession),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 90),
            child: loading ? const SizedBox(height: 28) : Text(l10n.noSessionPlanned, style: text.heroSubject),
          ),
          const SizedBox(height: 12),
        ],
      );
    } else {
      content = Column(
        key: ValueKey(s.id),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              HeroPill(l10n.nextSession),
              Text(whenLabel(l10n, language, s, now), style: text.style(15, FontWeight.w800, color: BrandColors.onDarkAmber)),
            ],
          ),
          const SizedBox(height: 14),
          Text(hm(s.startsAt), textDirection: TextDirection.ltr, style: text.heroTime(phone: true)),
          const SizedBox(height: 6),
          Text(l10n.untilTime(hm(s.endsAt)), style: text.style(14, FontWeight.w700, color: Colors.white.withValues(alpha: 0.8))),
          const SizedBox(height: 8),
          Text(s.group.name, style: text.heroSubject),
          const SizedBox(height: 10),
          if (s.canJoin(now))
            HeroButtonLight(label: l10n.joinSession, icon: LucideIcons.video, onPressed: () => sl.get<LinkOpener>().open(s.meetUrl!))
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(s.mode == SessionMode.online ? LucideIcons.video : LucideIcons.mapPin, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    placeLabel(l10n, s.mode, s.location, family: true),
                    style: text.style(14, FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
        ],
      );
    }
    return HeroCard(
      variant: HeroVariant.student,
      phone: true,
      child: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 260),
        layoutBuilder: (current, previous) => Stack(alignment: AlignmentDirectional.topStart, children: [...previous, ?current]),
        child: content,
      ),
    );
  }
}

/// "Ma semaine": Monday to Saturday (Sunday too when a session falls on it), a dot for a session, a cross
/// for a day whose sessions are all cancelled, today outlined. Any day opens the planning.
class _MyWeek extends StatelessWidget {
  const _MyWeek({required this.state});

  final MyPlanningState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final monday = TunisTime.weekStart(state.today);
    final week = state.thisWeek;
    List<MySession> on(DateTime day) => week.where((s) => TunisTime.sameDay(TunisTime.day(s.startsAt), day)).toList();
    final sunday = TunisTime.addDays(monday, 6);
    final days = [for (var i = 0; i < 6; i++) TunisTime.addDays(monday, i), if (on(sunday).isNotEmpty) sunday];
    final anyActive = week.any((s) => !s.isCancelled);
    final anyCancelled = days.any((d) => on(d).isNotEmpty && on(d).every((s) => s.isCancelled));
    void openPlanning() => context.go(Routes.studentPlanning);

    return SectionCard(
      title: l10n.myWeek,
      phone: true,
      trailing: CardLink(label: l10n.seePlanning, onPressed: openPlanning),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (var i = 0; i < days.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _DayTile(
                    label: text.upper(weekdayShort(days[i], language)),
                    day: days[i].day,
                    today: TunisTime.sameDay(days[i], state.today),
                    sessions: on(days[i]),
                    onTap: openPlanning,
                  ),
                ),
              ],
            ],
          ),
          if (anyActive || anyCancelled) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                if (anyActive)
                  _Legend(
                    mark: _Dot(color: colorFromHex(week.firstWhere((s) => !s.isCancelled).group.color)),
                    label: l10n.legendSession,
                  ),
                if (anyCancelled)
                  _Legend(
                    mark: Icon(LucideIcons.x, size: 13, color: Accent.red.strong),
                    label: l10n.statusCancelled,
                    color: Accent.red.onSoft,
                  ),
              ],
            ),
          ],
          const Divider(height: 28, color: BrandColors.rowDivider),
          Text(
            l10n.nextWeekSessions(state.nextWeek.where((s) => !s.isCancelled).length),
            style: text.style(14, FontWeight.w600, color: BrandColors.body),
          ),
        ],
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.label, required this.day, required this.today, required this.sessions, required this.onTap});

  final String label;
  final int day;
  final bool today;
  final List<MySession> sessions;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final active = sessions.where((s) => !s.isCancelled).toList();
    final allCancelled = sessions.isNotEmpty && active.isEmpty;
    final radius = BorderRadius.circular(14);
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: today ? const BorderSide(color: BrandColors.indigo, width: 2) : const BorderSide(color: BrandColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, maxLines: 1, style: text.style(11, FontWeight.w700, color: BrandColors.slate)),
              ),
              const SizedBox(height: 2),
              Text(
                '$day',
                textDirection: TextDirection.ltr,
                style: text.style(18, FontWeight.w800, color: today ? BrandColors.indigo : BrandColors.ink, tabular: true),
              ),
              const SizedBox(height: 3),
              SizedBox(
                height: 12,
                child: allCancelled
                    ? Icon(LucideIcons.x, size: 12, color: Accent.red.strong)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final s in active.take(3)) ...[
                            if (s != active.first) const SizedBox(width: 3),
                            _Dot(color: colorFromHex(s.group.color)),
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

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.mark, required this.label, this.color = BrandColors.slate});

  final Widget mark;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      mark,
      const SizedBox(width: 6),
      Text(label, style: AppText.of(context).style(13, FontWeight.w600, color: color)),
    ],
  );
}
