import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/l10n/tunis_time.dart';
import '../../../../core/platform/link_opener.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/session.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/common/load_status.dart';
import '../../../stateManager/groups/groups_cubit.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/reference/reference_cubit.dart';
import '../../../stateManager/session_detail/session_detail_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/copy_link_button.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/labels.dart';
import '../../../widgets/panels.dart';
import '../../../widgets/school_widgets.dart';
import 'scope_dialog.dart';
import 'session_form_panel.dart';

/// A session of the planning (design `r1/Seance.png`). Returns true when something changed.
class SessionPanel extends StatelessWidget {
  const SessionPanel({super.key});

  static Future<bool> open(BuildContext context, String sessionId) async {
    final groups = context.read<GroupsCubit>();
    final reference = context.read<ReferenceCubit>();
    final changed = await showSidePanel<bool>(
      context,
      width: 480,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: groups),
          BlocProvider.value(value: reference),
          BlocProvider(create: (_) => SessionDetailCubit(sl.get(), sessionId)..load()),
        ],
        child: const SessionPanel(),
      ),
    );
    return changed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<SessionDetailCubit>().state;
    final session = state.detail?.session;
    if (session == null) {
      return SidePanel(
        icon: LucideIcons.calendar,
        title: l10n.navPlanning,
        body: state.status == LoadStatus.failure
            ? FailureBanner(state.failure!, onRetry: context.read<SessionDetailCubit>().load)
            : const LinearProgressIndicator(minHeight: 3),
      );
    }
    final color = colorFromHex(session.group.color);
    final language = context.watch<LanguageCubit>().state;
    return SidePanel(
      leading: GroupSquare(code: session.group.code, color: session.group.color, size: 40),
      headerColor: Color.alphaBlend(color.withValues(alpha: 0.10), Colors.white),
      title: session.group.name,
      subtitle: session.group.privateLesson
          ? '${l10n.privateLesson}${l10n.dotSeparator}${session.group.subject.of(language)}'
          : session.group.subject.of(language),
      body: _Body(session: session),
      actions: [
        if (session.isEditable) ...[
          SecondaryButton(
            label: l10n.edit,
            icon: LucideIcons.pencil,
            onPressed: state.busy
                ? null
                : () async {
                    final saved = await SessionFormPanel.edit(context, session);
                    if (saved && context.mounted) Navigator.of(context).pop(true);
                  },
          ),
          DangerButton(label: l10n.cancelSession, icon: LucideIcons.ban, onPressed: state.busy ? null : () => _cancel(context, session)),
        ],
        if (session.isCancelled)
          PrimaryButton(
            label: l10n.restoreSession,
            icon: LucideIcons.rotateCcw,
            height: 44,
            loading: state.busy,
            onPressed: () async {
              final failure = await context.read<SessionDetailCubit>().restore();
              if (!context.mounted) return;
              showNotice(context, failure == null ? l10n.sessionRestored : failureText(l10n, failure));
              if (failure == null) Navigator.of(context).pop(true);
            },
          ),
      ],
    );
  }

  Future<void> _cancel(BuildContext context, Session session) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SessionDetailCubit>();
    final answer = await askCancel(context, session);
    if (answer == null || !context.mounted) return;
    final failure = await cubit.cancel(answer.$1, answer.$2);
    if (!context.mounted) return;
    showNotice(context, failure == null ? l10n.sessionCancelled : failureText(l10n, failure));
    if (failure == null) Navigator.of(context).pop(true);
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final now = sl.get<Now>()();
    final day = TunisTime.day(session.startsAt);
    final startsIn = session.startsAt.difference(now);
    final soon = session.status == SessionStatus.planned && !startsIn.isNegative && startsIn.inHours < 12;

    Widget line(IconData icon, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: BrandColors.indigo),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
    final style = text.style(14, FontWeight.w500, color: BrandColors.ink);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SessionStatusChip(status: session.status, next: soon),
            if (soon) ...[
              const SizedBox(width: 12),
              Text(l10n.inDuration(durationLabel(l10n, startsIn)), style: text.style(14, FontWeight.w700, color: Accent.amber.onSoft)),
            ],
          ],
        ),
        const SizedBox(height: 18),
        line(
          LucideIcons.calendar,
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: dayDate(day, language),
                  style: style.copyWith(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: '${l10n.dotSeparator}${timeRangeLabel(l10n, session.startsAt, session.endsAt)}', style: style),
              ],
            ),
          ),
        ),
        if (session.recurring)
          line(
            LucideIcons.repeat,
            Text(
              session.seriesEndsOn == null
                  ? l10n.everyWeekday(weekdayName(day, language))
                  : l10n.everyWeekdayUntil(weekdayName(day, language), fullDate(session.seriesEndsOn!, language)),
              style: style,
            ),
          ),
        line(
          session.mode == SessionMode.online ? LucideIcons.video : LucideIcons.mapPin,
          session.mode == SessionMode.online && session.meetUrl != null
              ? Row(
                  children: [
                    Text('${l10n.modeOnline}${l10n.dotSeparator}', style: style),
                    Flexible(
                      child: Text(
                        session.meetUrl!.replaceFirst('https://', ''),
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                        style: text.style(14, FontWeight.w700, color: BrandColors.indigo),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CopyLinkButton(url: session.meetUrl!, size: 32),
                  ],
                )
              : Text(placeLabel(l10n, session.mode, session.location), style: style),
        ),
        const SizedBox(height: 6),
        if (session.isCancelled) ...[
          if (session.cancelReason != null) InfoNote(text: l10n.cancelledBecause(session.cancelReason!), icon: LucideIcons.ban),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: session.isDone
                      ? l10n.editAttendance
                      : (session.status == SessionStatus.inProgress ? l10n.resumeSession : l10n.startSession),
                  icon: session.isDone ? LucideIcons.circleCheck : LucideIcons.play,
                  height: 48,
                  onPressed: () {
                    final router = GoRouter.of(context);
                    Navigator.of(context).pop(false);
                    router.go(Routes.sessionMode(session.id));
                  },
                ),
              ),
              if (session.mode == SessionMode.online && session.meetUrl != null && !session.isDone) ...[
                const SizedBox(width: 10),
                SecondaryButton(
                  label: l10n.openMeet,
                  icon: LucideIcons.video,
                  height: 48,
                  onPressed: () => sl.get<LinkOpener>().open(session.meetUrl!),
                ),
              ],
            ],
          ),
          if (session.attendanceTaken) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusChip(label: l10n.presentCount(session.present), accent: Accent.green),
                StatusChip(label: l10n.absentCount(session.absent), accent: Accent.red),
                StatusChip(label: l10n.lateCount(session.late), accent: Accent.orange),
              ],
            ),
          ],
        ],
        if (session.prepNote != null) ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFFFF8E8), borderRadius: BorderRadius.circular(AppRadii.md)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text.upper(l10n.prepNotes), style: text.overline(color: Accent.amber.onSoft, size: 11)),
                const SizedBox(height: 4),
                Text(session.prepNote!, style: text.style(14, FontWeight.w500, height: 1.5)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
