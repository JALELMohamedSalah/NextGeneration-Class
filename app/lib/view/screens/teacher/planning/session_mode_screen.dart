import 'dart:async';

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
import '../../../stateManager/day_content/day_content_cubit.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/session_mode/session_mode_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/classmates.dart';
import '../../../widgets/content_widgets.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/labels.dart';
import '../../../widgets/page_frame.dart';
import '../../../widgets/panels.dart';
import '../../../widgets/school_widgets.dart';
import '../../../widgets/text_field.dart';

/// "Démarrer la séance" (spec 03, design `SessionMode.png`): attendance in a few taps, next to Meet.
class SessionModeScreen extends StatelessWidget {
  const SessionModeScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) => BlocProvider(create: (_) => SessionModeCubit(sl.get(), sessionId)..open(), child: const SessionModeView());
}

class SessionModeView extends StatelessWidget {
  const SessionModeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<SessionModeCubit>().state;
    final detail = state.detail;
    return BlocListener<SessionModeCubit, SessionModeState>(
      listenWhen: (previous, current) => !previous.ended && current.ended && previous.ending,
      listener: (context, state) {
        showNotice(context, l10n.sessionEnded);
        context.go(Routes.teacherHome);
      },
      child: Scaffold(
        backgroundColor: BrandColors.chalk,
        body: Column(
          children: [
            _Header(detail: detail),
            Expanded(
              child: AsyncView(
                status: state.status,
                hasData: detail != null,
                failure: state.failure,
                onRetry: context.read<SessionModeCubit>().open,
                builder: (context) => const _Body(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header({required this.detail});

  final SessionDetail? detail;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) => mounted ? setState(() {}) : null);
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _end(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SessionModeCubit>();
    final state = cubit.state;
    final summary = [
      l10n.presentCount(state.count(AttendanceStatus.present)),
      l10n.absentCount(state.count(AttendanceStatus.absent)),
      l10n.lateCount(state.count(AttendanceStatus.late)),
    ].join(l10n.listSeparator);
    final ok = await confirmAction(
      context,
      title: l10n.endSessionTitle,
      text: l10n.endSessionText(summary),
      confirmLabel: l10n.endSession,
      icon: LucideIcons.circleCheck,
      danger: false,
    );
    if (ok) await cubit.end();
    if (!context.mounted) return;
    final failure = cubit.state.failure;
    if (failure != null && !cubit.state.ended) showNotice(context, failureText(l10n, failure));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final session = widget.detail?.session;
    final state = context.watch<SessionModeCubit>().state;
    final phone = isPhone(context);
    // Below a desktop width (phones and tablets) the header keeps the essentials: icons, the title, the end button.
    final compact = MediaQuery.sizeOf(context).width < Breakpoints.desktop;
    final now = sl.get<Now>()();
    final minutes = session == null ? 0 : now.difference(session.startsAt).inMinutes.clamp(0, 999);
    final done = state.ended || (session?.isDone ?? false);

    final back = Material(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        onTap: () => context.go(Routes.teacherHome),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.arrowLeftDir, size: 16, color: Colors.white),
              if (!compact) ...[const SizedBox(width: 8), Text(l10n.navTeacherHome, style: text.style(13, FontWeight.w700, color: Colors.white))],
            ],
          ),
        ),
      ),
    );

    final live = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: BrandColors.onDarkTeal, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            done ? l10n.statusDone : (minutes > 0 ? l10n.inProgressFor(minutes) : l10n.statusInProgress),
            style: text.style(13, FontWeight.w700, color: BrandColors.onDarkTeal),
          ),
        ],
      ),
    );

    final endButton = Material(
      color: done ? Colors.white : BrandColors.amber,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: session == null || state.ending
            ? null
            : done
            ? () => context.go(Routes.teacherPlanning)
            : () => _end(context),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          child: state.ending
              ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: BrandColors.ink))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(done ? LucideIcons.x : LucideIcons.circleCheck, size: 18, color: BrandColors.ink),
                    if (!compact || done) ...[
                      const SizedBox(width: 8),
                      Text(done ? l10n.close : l10n.endSession, style: text.style(15, FontWeight.w800)),
                    ],
                  ],
                ),
        ),
      ),
    );

    return Container(
      color: BrandColors.indigoDeep,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: phone ? 14 : 32, vertical: 14),
          child: Row(
            children: [
              back,
              const SizedBox(width: 16),
              Expanded(
                child: session == null
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.group.name,
                            overflow: TextOverflow.ellipsis,
                            style: text.style(phone ? 17 : 20, FontWeight.w800, color: Colors.white),
                          ),
                          Text(
                            '${timeRangeLabel(l10n, session.startsAt, session.endsAt)}${l10n.dotSeparator}${placeLabel(l10n, session.mode, session.location)}',
                            overflow: TextOverflow.ellipsis,
                            style: text.style(13, FontWeight.w500, color: Colors.white.withValues(alpha: 0.75)),
                          ),
                        ],
                      ),
              ),
              if (session != null && !compact) ...[live, const SizedBox(width: 12)],
              if (session != null && session.mode == SessionMode.online && session.meetUrl != null && !done) ...[
                IconButton(
                  tooltip: l10n.openMeet,
                  onPressed: () => sl.get<LinkOpener>().open(session.meetUrl!),
                  icon: const Icon(LucideIcons.video, color: Colors.white),
                ),
                const SizedBox(width: 6),
              ],
              endButton,
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(phone ? 14 : 32),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: const PairedBlocks(
            equalHeight: false,
            startFlex: 6,
            endFlex: 7,
            start: FadeRise(child: _AttendanceCard()),
            end: FadeRise(index: 1, child: _SideColumn()),
          ),
        ),
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final state = context.watch<SessionModeCubit>().state;
    final cubit = context.read<SessionModeCubit>();
    final roster = state.detail!.roster;
    final saveLabel = switch (state.attendanceSave) {
      SaveStatus.saving => l10n.noteSaving,
      SaveStatus.saved => l10n.noteSaved,
      SaveStatus.failed => l10n.errorNetwork,
      SaveStatus.idle => l10n.tapToChange,
    };
    return SectionCard(
      title: l10n.attendanceTitle,
      // On a narrow card the hint wraps on two lines rather than push the title out.
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 230),
        child: Text(
          saveLabel,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.end,
          style: text.style(
            13,
            FontWeight.w600,
            color: state.attendanceSave == SaveStatus.saved
                ? Accent.green.onSoft
                : (state.attendanceSave == SaveStatus.failed ? Accent.red.onSoft : BrandColors.slate),
          ),
        ),
      ),
      child: roster.isEmpty
          ? EmptyState(message: l10n.noMembers, scale: 0.35)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusChip(label: l10n.presentCount(state.count(AttendanceStatus.present)), accent: Accent.green),
                    StatusChip(label: l10n.absentCount(state.count(AttendanceStatus.absent)), accent: Accent.red),
                    StatusChip(label: l10n.lateCount(state.count(AttendanceStatus.late)), accent: Accent.orange),
                  ],
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 460 ? 2 : 1;
                    final width = (constraints.maxWidth - 10 * (columns - 1)) / columns;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final r in roster)
                          SizedBox(
                            width: width,
                            child: AttendanceTile(
                              name: r.fullName,
                              initials: '${r.firstName.isEmpty ? '' : r.firstName[0]}${r.lastName.isEmpty ? '' : r.lastName[0]}'.toUpperCase(),
                              status: state.markOf(r.studentId),
                              onTap: () => cubit.tap(r.studentId),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class _SideColumn extends StatelessWidget {
  const _SideColumn();

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);
    final gap = phone ? 16.0 : 24.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _DayContent(),
        SizedBox(height: gap),
        LayoutBuilder(
          builder: (context, constraints) {
            const previous = _PreviousNote();
            const quick = _QuickNote();
            if (constraints.maxWidth < 560) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  previous,
                  SizedBox(height: gap),
                  quick,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: previous),
                SizedBox(width: gap),
                const Expanded(child: quick),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PreviousNote extends StatelessWidget {
  const _PreviousNote();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final previous = context.select((SessionModeCubit c) => c.state.detail?.previous);
    final note = previous?.note;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        border: Border.all(color: const Color(0xFFF8E3B3)),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text.upper(
              previous == null ? l10n.lastSessionOn(l10n.noValue) : l10n.lastSessionOn(weekdayName(TunisTime.day(previous.startsAt), language)),
            ),
            style: text.overline(color: Accent.amber.onSoft),
          ),
          const SizedBox(height: 10),
          Text(
            note ?? l10n.noPreviousNote,
            style: note == null ? text.style(15, FontWeight.w500, color: BrandColors.body) : text.style(16, FontWeight.w600, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _QuickNote extends StatelessWidget {
  const _QuickNote();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final state = context.watch<SessionModeCubit>().state;
    final cubit = context.read<SessionModeCubit>();
    final (label, color) = switch (state.noteSave) {
      SaveStatus.saving => (l10n.noteSaving, BrandColors.slate),
      SaveStatus.saved => (l10n.noteSaved, Accent.green.onSoft),
      SaveStatus.failed => (l10n.errorNetwork, Accent.red.onSoft),
      SaveStatus.idle => ('', BrandColors.slate),
    };
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(text.upper(l10n.quickNote), style: text.overline())),
              AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 200),
                child: Text(
                  label,
                  key: ValueKey(state.noteSave),
                  style: text.style(12, FontWeight.w700, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FormInput(initialValue: state.quickNote, hint: l10n.quickNoteHint, maxLines: 4, onChanged: cubit.setQuickNote),
        ],
      ),
    );
  }
}

/// "Contenu du jour" (design `SessionMode.png`): the group's latest documents from the library, to open in class.
class _DayContent extends StatelessWidget {
  const _DayContent();

  @override
  Widget build(BuildContext context) {
    final groupId = context.select((SessionModeCubit c) => c.state.detail?.session.group.id);
    if (groupId == null) return const SizedBox.shrink();
    return BlocProvider(key: ValueKey(groupId), create: (_) => DayContentCubit(sl.get(), groupId)..load(), child: const _DayContentCard());
  }
}

class _DayContentCard extends StatelessWidget {
  const _DayContentCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final state = context.watch<DayContentCubit>().state;
    final chapter = state.chapter;
    final Widget body;
    if (state.status == LoadStatus.failure) {
      body = FailureBanner(state.failure!, onRetry: context.read<DayContentCubit>().load);
    } else if (state.status == LoadStatus.loading) {
      body = const LinearProgressIndicator(minHeight: 3);
    } else if (state.documents.isEmpty) {
      body = Row(
        children: [
          const IconBadge(icon: LucideIcons.bookOpen, accent: Accent.blue),
          const SizedBox(width: 14),
          Expanded(
            child: Text(l10n.dayContentEmpty, style: text.style(14, FontWeight.w500, color: BrandColors.body, height: 1.5)),
          ),
        ],
      );
    } else {
      body = Column(
        children: [
          for (final (i, d) in state.documents.indexed) ...[
            if (i > 0) const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: BrandColors.line),
                borderRadius: BorderRadius.circular(AppRadii.row),
              ),
              child: Row(
                children: [
                  KindBadge(kind: d.kind),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.rowTitle),
                        Text(
                          documentDetail(l10n, d),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SecondaryButton(label: l10n.actionOpen, height: 38, onPressed: () => context.push(Routes.teacherDocument(d.id))),
                ],
              ),
            ),
          ],
        ],
      );
    }
    final chip = chapter == null ? null : StatusChip(label: '${l10n.chapter}${l10n.dotSeparator}${isolated(chapter.title)}', accent: Accent.indigo);
    // The chapter sits beside the title on a wide card (design `SessionMode.png`), under it on a narrow one.
    return LayoutBuilder(
      builder: (context, constraints) {
        final beside = constraints.maxWidth >= 480;
        return SectionCard(
          title: l10n.contentOfDay,
          trailing: beside && chip != null ? ConstrainedBox(constraints: const BoxConstraints(maxWidth: 220), child: chip) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!beside && chip != null) ...[Align(alignment: AlignmentDirectional.centerStart, child: chip), const SizedBox(height: 12)],
              body,
            ],
          ),
        );
      },
    );
  }
}
