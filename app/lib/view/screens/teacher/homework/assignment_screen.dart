import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_language.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/l10n/tunis_time.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/clock_time.dart';
import '../../../../domain/model/homework.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/homework/assignment_cubit.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/classmates.dart';
import '../../../widgets/content_widgets.dart';
import '../../../widgets/controls.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/homework_widgets.dart';
import '../../../widgets/page_frame.dart';
import '../../../widgets/panels.dart';
import '../../../widgets/school_widgets.dart';

/// One homework (design `r2/Devoir.png`): how many sent, each pupil's status and work, a new deadline, close it.
class AssignmentScreen extends StatelessWidget {
  const AssignmentScreen({super.key, required this.assignmentId});

  final String assignmentId;

  @override
  Widget build(BuildContext context) =>
      BlocProvider(create: (_) => AssignmentCubit(sl.get(), assignmentId)..load(), child: const AssignmentView());
}

class AssignmentView extends StatelessWidget {
  const AssignmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AssignmentCubit>().state;
    return AsyncView(
      status: state.status,
      hasData: state.detail != null,
      failure: state.failure,
      onRetry: context.read<AssignmentCubit>().load,
      builder: (context) => _Content(detail: state.detail!),
    );
  }
}

/// "Pour le vendredi 3 octobre à 18:00".
String _dueFor(AppLocalizations l10n, AppLanguage language, DateTime deadline) =>
    l10n.dueFor(l10n.dayAtTime(dayInSentence(TunisTime.day(deadline), language), hm(deadline)));

/// "Ven 3 oct., 17:12".
String _dayTime(AppLocalizations l10n, AppLanguage language, DateTime instant) {
  final day = TunisTime.day(instant);
  return l10n.dueOn('${weekdayShort(day, language)} ${shortDate(day, language)}', hm(instant));
}

class _Content extends StatelessWidget {
  const _Content({required this.detail});

  final AssignmentDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final a = detail.assignment;
    return PageScroll(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () => context.go(Routes.teacherAssignments),
            icon: const Icon(LucideIcons.arrowLeftDir, size: 18, color: BrandColors.indigo),
            label: Text(l10n.navAssignments, style: AppText.of(context).style(14, FontWeight.w700, color: BrandColors.indigo)),
          ),
        ),
        _Header(detail: detail),
        if (a.mode == SubmissionMode.file) _Tiles(counts: a.counts),
        if (a.instructions?.trim().isNotEmpty ?? false)
          SectionCard(
            title: l10n.instructionsLabel,
            child: Text(
              a.instructions!,
              textDirection: writtenDirection(a.instructions!),
              style: AppText.of(context).style(15, FontWeight.w500, color: BrandColors.body, height: 1.5),
            ),
          ),
        _Recipients(detail: detail),
        if (a.mode == SubmissionMode.file) InfoNote(text: l10n.gradeAnywayInfo),
      ],
    );
  }
}

/// Opens one pupil's copy on the correction screen, then reads the homework again.
Future<void> _correct(BuildContext context, String assignmentId, String studentId) async {
  final cubit = context.read<AssignmentCubit>();
  await context.push(Routes.teacherCorrection(assignmentId, studentId));
  if (!cubit.isClosed) cubit.load();
}

class _Header extends StatelessWidget {
  const _Header({required this.detail});

  final AssignmentDetail detail;

  Assignment get assignment => detail.assignment;

  Future<void> _changeDeadline(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<AssignmentCubit>();
    final picked = await showAppDialog<DateTime>(context, builder: (_) => _DeadlineDialog(current: assignment.deadlineAt));
    if (picked == null) return;
    final failure = await cubit.changeDeadline(picked);
    if (context.mounted) showNotice(context, failure == null ? l10n.deadlineChanged : failureText(l10n, failure));
  }

  Future<void> _close(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<AssignmentCubit>();
    final ok = await confirmAction(
      context,
      title: l10n.closeHomeworkTitle(isolated(assignment.title)),
      text: l10n.closeHomeworkText,
      confirmLabel: l10n.closeHomework,
      icon: LucideIcons.lock,
    );
    if (!ok) return;
    final failure = await cubit.closeHomework();
    if (context.mounted) showNotice(context, failure == null ? l10n.homeworkClosed : failureText(l10n, failure));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final phone = isPhone(context);
    final a = assignment;
    final quiet = text.style(14, FontWeight.w500, color: BrandColors.body);

    final facts = Wrap(
      spacing: 12,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        GroupLabel(code: a.group.code, color: a.group.color, name: a.group.name),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.calendarClock, size: 16, color: BrandColors.slate),
            const SizedBox(width: 6),
            Flexible(child: Text(_dueFor(l10n, language, a.deadlineAt), style: quiet)),
          ],
        ),
        if (a.mode == SubmissionMode.none) StatusChip(label: l10n.nothingToSubmit, accent: Accent.grey),
        if (a.allowLate && a.mode == SubmissionMode.file) Text(l10n.lateAccepted, style: quiet),
        if (a.closed) StatusChip(label: l10n.closedChip, accent: Accent.grey),
        if (a.average != null) Text(l10n.averageOutOf20(averageText(a.average!)), style: quiet),
      ],
    );
    final waiting = detail.recipients.where((r) => r.status == HomeworkStatus.submitted || r.status == HomeworkStatus.late).toList()
      ..sort((x, y) => (x.submittedAt ?? DateTime(0)).compareTo(y.submittedAt ?? DateTime(0)));
    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (waiting.isNotEmpty)
          PrimaryButton(
            label: l10n.correctCount(waiting.length),
            icon: LucideIcons.penLine,
            height: 44,
            onPressed: () => _correct(context, a.id, waiting.first.studentId),
          ),
        SecondaryButton(label: l10n.changeDeadline, icon: LucideIcons.calendar, onPressed: () => _changeDeadline(context)),
        if (!a.closed) SecondaryButton(label: l10n.closeHomework, icon: LucideIcons.lock, onPressed: () => _close(context)),
      ],
    );
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.start,
      spacing: 16,
      runSpacing: 16,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!phone) ...[KindBadge(kind: a.contentKind), const SizedBox(width: 16)],
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title, style: text.pageTitle(phone: phone)),
                    const SizedBox(height: 8),
                    facts,
                  ],
                ),
              ),
            ],
          ),
        ),
        actions,
      ],
    );
  }
}

/// Sent, sent late, missing, to do: a colored bar, the count, the word.
class _Tiles extends StatelessWidget {
  const _Tiles({required this.counts});

  final StatusCounts counts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tiles = [
      _Tile(value: counts.corrected, label: l10n.tileCorrected, accent: Accent.violet),
      _Tile(value: counts.submitted + counts.late, label: l10n.homeToCorrect, accent: Accent.green),
      _Tile(value: counts.missing, label: l10n.tileMissing, accent: Accent.red),
      _Tile(value: counts.todo, label: l10n.tileTodo, accent: Accent.blue),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget row(List<Widget> items) => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, tile) in items.indexed) ...[if (i > 0) const SizedBox(width: 12), Expanded(child: tile)],
            ],
          ),
        );
        if (constraints.maxWidth >= 700) return row(tiles);
        return Column(children: [row(tiles.sublist(0, 2)), const SizedBox(height: 12), row(tiles.sublist(2))]);
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.value, required this.label, required this.accent});

  final int value;
  final String label;
  final Accent accent;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.tile),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 40,
            decoration: BoxDecoration(color: accent.strong, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedCount(value: value, style: text.style(26, FontWeight.w800, tabular: true)),
                Text(label, maxLines: 2, style: text.style(13, FontWeight.w600, color: BrandColors.slate)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Each pupil: status, when the work came, and the button to open it.
class _Recipients extends StatelessWidget {
  const _Recipients({required this.detail});

  final AssignmentDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final phone = isPhone(context);
    final rows = detail.recipients;
    if (rows.isEmpty) return SectionCard(child: EmptyState(message: l10n.noMembers, scale: 0.35));
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final style = text.overline(size: 11);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: phone ? 12 : 24, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: BrandColors.line),
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Column(
            children: [
              if (wide)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: BrandColors.rowDivider)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 54),
                      Expanded(child: Text(text.upper(l10n.columnStudent), style: style)),
                      if (detail.assignment.mode == SubmissionMode.file) ...[
                        SizedBox(width: 170, child: Text(text.upper(l10n.columnStatus), style: style)),
                        SizedBox(width: 160, child: Text(text.upper(l10n.columnSentAt), style: style)),
                        SizedBox(width: 90, child: Text(text.upper(l10n.columnScore), style: style)),
                        const SizedBox(width: 130),
                      ],
                    ],
                  ),
                ),
              for (final (i, r) in rows.indexed)
                FadeRise(
                  index: i,
                  child: _RecipientLine(row: r, first: i == 0, wide: wide, assignment: detail.assignment),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RecipientLine extends StatelessWidget {
  const _RecipientLine({required this.row, required this.first, required this.wide, required this.assignment});

  final RecipientRow row;
  final bool first;
  final bool wide;
  final Assignment assignment;

  SubmissionMode get mode => assignment.mode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final r = row;
    final quiet = text.style(13, FontWeight.w500, color: BrandColors.slate);
    final initials = '${r.firstName.isEmpty ? '' : r.firstName[0]}${r.lastName.isEmpty ? '' : r.lastName[0]}'.toUpperCase();
    final name = Text(r.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.rowTitle);
    final sentAt = r.submittedAt == null ? null : _dayTime(l10n, language, r.submittedAt!);
    void open() => _correct(context, assignment.id, r.studentId);
    // Corrected: see it again (and change the grade); sent: correct it; missing: grade it anyway (a paper copy).
    final Widget? action = switch (r.status) {
      HomeworkStatus.corrected => SecondaryButton(label: l10n.viewCorrection, icon: LucideIcons.eye, height: 38, onPressed: open),
      HomeworkStatus.submitted || HomeworkStatus.late => TonalButton(label: l10n.correctAction, onPressed: open),
      HomeworkStatus.missing => GhostButton(label: l10n.gradeAnyway, icon: LucideIcons.pencil, height: 38, onPressed: open),
      _ => null,
    };
    final score = r.score == null
        ? Text(l10n.noValue, style: quiet)
        : Text.rich(
            TextSpan(
              children: [
                TextSpan(text: scoreText(r.score!), style: text.style(15, FontWeight.w800)),
                TextSpan(text: ' / ${assignment.maxScore}', style: quiet),
              ],
            ),
            textDirection: TextDirection.ltr,
          );

    final Widget body;
    if (mode == SubmissionMode.none) {
      body = Row(children: [Expanded(child: name)]);
    } else if (wide) {
      body = Row(
        children: [
          Expanded(child: name),
          SizedBox(
            width: 170,
            child: Align(alignment: AlignmentDirectional.centerStart, child: HomeworkStatusChip(r.status)),
          ),
          SizedBox(width: 160, child: Text(sentAt ?? '', style: quiet)),
          SizedBox(
            width: 90,
            child: Align(alignment: AlignmentDirectional.centerStart, child: score),
          ),
          SizedBox(
            width: 130,
            child: Align(alignment: AlignmentDirectional.centerEnd, child: action ?? const SizedBox.shrink()),
          ),
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          name,
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              HomeworkStatusChip(r.status),
              if (sentAt != null) Text(sentAt, style: quiet),
              if (r.score != null) score,
            ],
          ),
          if (action != null) ...[const SizedBox(height: 8), action],
        ],
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: first ? null : const Border(top: BorderSide(color: BrandColors.rowDivider)),
      ),
      child: Row(
        crossAxisAlignment: wide || mode == SubmissionMode.none ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          InitialsAvatar(initials: initials),
          const SizedBox(width: 14),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// "Changer la date": a new day and time, after now. Pupils marked missing may send again.
class _DeadlineDialog extends StatefulWidget {
  const _DeadlineDialog({required this.current});

  final DateTime current;

  @override
  State<_DeadlineDialog> createState() => _DeadlineDialogState();
}

class _DeadlineDialogState extends State<_DeadlineDialog> {
  late DateTime _date = TunisTime.day(widget.current);
  late ClockTime _time = TunisTime.clock(widget.current);
  bool _past = false;

  void _save() {
    final picked = TunisTime.instant(_date, _time);
    if (!picked.isAfter(sl.get<Now>()())) return setState(() => _past = true);
    Navigator.of(context).pop(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = TunisTime.day(sl.get<Now>()());
    return AppDialog(
      title: l10n.changeDeadline,
      icon: LucideIcons.calendarClock,
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: DateField(
              label: l10n.newDeadline,
              value: _date,
              firstDate: _date.isBefore(today) ? _date : today,
              lastDate: TunisTime.addDays(today, 365),
              errorText: _past ? l10n.deadlineInPast : null,
              onChanged: (d) => setState(() {
                _date = d;
                _past = false;
              }),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: TimeField(
              label: l10n.deadlineTime,
              value: _time,
              error: _past,
              onChanged: (t) => setState(() {
                _time = t;
                _past = false;
              }),
            ),
          ),
        ],
      ),
      actions: [
        GhostButton(label: l10n.cancel, onPressed: () => Navigator.of(context).pop()),
        PrimaryButton(label: l10n.save, height: 44, onPressed: _save),
      ],
    );
  }
}
