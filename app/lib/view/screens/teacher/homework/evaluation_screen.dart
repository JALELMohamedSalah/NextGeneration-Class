import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/evaluation.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/common/load_status.dart';
import '../../../stateManager/homework/evaluation_cubit.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/page_frame.dart';
import '../../../widgets/panels.dart';
import '../../../widgets/school_widgets.dart';
import '../../../widgets/text_field.dart';
import 'evaluation_panel.dart';

/// A paper evaluation's score table (design `r2/Evaluation.png`): a score per pupil, Tab to the next,
/// "Absent", a comment; the whole table saved at once.
class EvaluationScreen extends StatelessWidget {
  const EvaluationScreen({super.key, required this.evaluationId, this.created});

  final String evaluationId;

  /// Just created: shown at once, without reading it again.
  final EvaluationDetail? created;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) {
      final cubit = EvaluationCubit(sl.get(), evaluationId);
      created == null ? cubit.load() : cubit.replaced(created!);
      return cubit;
    },
    child: const EvaluationView(),
  );
}

class EvaluationView extends StatelessWidget {
  const EvaluationView({super.key});

  static Future<void> save(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<EvaluationCubit>();
    if (!cubit.state.dirty || !cubit.state.valid) return;
    final failure = await cubit.save();
    if (context.mounted) showNotice(context, failure == null ? l10n.gradesSaved : failureText(l10n, failure));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<EvaluationCubit>().state;
    final detail = state.detail;
    // Back to Devoirs: to the tab it came from when it can (typed scores are asked about first).
    final back = Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        onPressed: () => context.canPop() ? Navigator.of(context).maybePop() : context.go(Routes.teacherAssignments),
        icon: const Icon(LucideIcons.arrowLeftDir, size: 18, color: BrandColors.indigo),
        label: Text(l10n.navAssignments, style: AppText.of(context).style(14, FontWeight.w700, color: BrandColors.indigo)),
      ),
    );
    final Widget body;
    if (detail == null) {
      body = PageScroll(
        children: [
          back,
          if (state.status == LoadStatus.failure)
            FailureBanner(state.failure!, onRetry: context.read<EvaluationCubit>().load)
          else
            const LinearProgressIndicator(minHeight: 3),
        ],
      );
    } else {
      final wide = MediaQuery.sizeOf(context).width >= 1100;
      body = PageScroll(
        children: [
          back,
          _Header(evaluation: detail.evaluation),
          const _Tiles(),
          _Table(grades: detail.grades, wide: wide),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (!isPhone(context)) InfoNote(text: l10n.keyboardHint, icon: LucideIcons.keyboard),
              InfoNote(text: l10n.absentNeverZero),
            ],
          ),
        ],
      );
    }
    // Typed scores are not lost by going back.
    return PopScope(
      canPop: !state.dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final leave = await confirmAction(
          context,
          title: l10n.unsavedGradesTitle,
          text: l10n.unsavedGradesText,
          confirmLabel: l10n.leaveWithoutSaving,
        );
        if (leave) navigator.pop();
      },
      child: body,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.evaluation});

  final Evaluation evaluation;

  Future<void> _edit(BuildContext context) async {
    final cubit = context.read<EvaluationCubit>();
    final saved = await EvaluationPanel.open(context, editing: evaluation);
    if (saved != null && !cubit.isClosed) cubit.replaced(saved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final phone = isPhone(context);
    final state = context.watch<EvaluationCubit>().state;
    final e = evaluation;
    final quiet = text.style(14, FontWeight.w500, color: BrandColors.body);
    final facts = Wrap(
      spacing: 12,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        GroupLabel(code: e.group.code, color: e.group.color, name: e.group.name),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.calendar, size: 16, color: BrandColors.slate),
            const SizedBox(width: 6),
            Flexible(child: Text(dayDate(e.heldOn, language), style: quiet)),
          ],
        ),
        Text(l10n.outOf('${e.maxScore}'), style: quiet),
        if (e.chapterTitle != null) Text(isolated(e.chapterTitle!), style: quiet),
      ],
    );
    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        SecondaryButton(label: l10n.edit, icon: LucideIcons.pencil, onPressed: () => _edit(context)),
        PrimaryButton(
          label: l10n.saveGrades,
          icon: LucideIcons.check,
          height: 44,
          loading: state.saving,
          onPressed: state.dirty && state.valid ? () => EvaluationView.save(context) : null,
        ),
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
              if (!phone) ...[const IconBadge(icon: LucideIcons.clipboardCheck, accent: Accent.violet), const SizedBox(width: 16)],
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.title, style: text.pageTitle(phone: phone)),
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

/// Typed, average, absent, to type: they follow the keyboard.
class _Tiles extends StatelessWidget {
  const _Tiles();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<EvaluationCubit>().state;
    final max = state.evaluation?.maxScore ?? 20;
    final average = state.average;
    final tiles = [
      _Tile(value: '${state.typed}', suffix: ' / ${state.pupils}', label: l10n.gradesDone, accent: Accent.violet),
      _Tile(
        value: average == null ? '—' : averageText(average),
        suffix: average == null ? '' : ' / $max',
        label: l10n.groupAverage,
        accent: Accent.green,
      ),
      _Tile(value: '${state.absent}', label: l10n.absentLabel, accent: Accent.grey),
      _Tile(value: '${state.toType < 0 ? 0 : state.toType}', label: l10n.toType, accent: Accent.amber),
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
  const _Tile({required this.value, required this.label, required this.accent, this.suffix = ''});

  final String value;
  final String suffix;
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
                // "14,50 / 20" stays left to right, in Arabic too.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: value, style: text.style(26, FontWeight.w800, tabular: true)),
                        TextSpan(
                          text: suffix,
                          style: text.style(15, FontWeight.w700, color: BrandColors.slate),
                        ),
                      ],
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ),
                Text(label, maxLines: 2, style: text.style(13, FontWeight.w600, color: BrandColors.slate)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The pupils in order; Tab goes from one score to the next, then to the comments.
class _Table extends StatelessWidget {
  const _Table({required this.grades, required this.wide});

  final List<EvaluationGrade> grades;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final style = text.overline(size: 11);
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: wide ? 24 : 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: BrandColors.line),
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Column(
          children: [
            if (wide)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    const SizedBox(width: 54),
                    SizedBox(width: 220, child: Text(text.upper(l10n.columnStudent), style: style)),
                    SizedBox(width: 160, child: Text(text.upper(l10n.columnScore), style: style)),
                    SizedBox(
                      width: 90,
                      child: Center(child: Text(text.upper(l10n.columnAbsent), style: style)),
                    ),
                    Expanded(child: Text(text.upper(l10n.columnComment), style: style)),
                  ],
                ),
              ),
            for (final (i, g) in grades.indexed) _PupilRow(grade: g, index: i, wide: wide, first: i == 0),
          ],
        ),
      ),
    );
  }
}

class _PupilRow extends StatelessWidget {
  const _PupilRow({required this.grade, required this.index, required this.wide, required this.first});

  final EvaluationGrade grade;
  final int index;
  final bool wide;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final cubit = context.read<EvaluationCubit>();
    final entry = context.select((EvaluationCubit c) => c.state.entryOf(grade.studentId));
    final problem = context.select((EvaluationCubit c) => c.state.problemOf(grade.studentId));
    final max = context.select((EvaluationCubit c) => c.state.evaluation?.maxScore ?? 20);
    final error = switch (problem) {
      ScoreProblem.tooHigh => l10n.scoreTooHigh('$max'),
      ScoreProblem.halfPoints => l10n.scoreHalfPoints,
      null => null,
    };

    final score = SizedBox(
      width: wide ? 160 : 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: entry.absent
                ? Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Accent.grey.soft, borderRadius: BorderRadius.circular(AppRadii.md)),
                    child: Text(l10n.absentLabel, style: text.style(14, FontWeight.w700, color: Accent.grey.onSoft)),
                  )
                : FocusTraversalOrder(
                    order: NumericFocusOrder(index.toDouble()),
                    child: Semantics(
                      label: '${grade.fullName}${l10n.dotSeparator}${l10n.columnScore}',
                      child: FormInput(
                        key: ValueKey('score-${grade.studentId}'),
                        initialValue: entry.text,
                        hint: l10n.scoreHint,
                        dense: true,
                        fillColor: Colors.white,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textDirection: TextDirection.ltr,
                        textInputAction: TextInputAction.next,
                        errorText: error,
                        onChanged: (v) => cubit.setScore(grade.studentId, v),
                        onSubmitted: (_) => EvaluationView.save(context),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 8, top: 14),
            child: Text(
              '/ $max',
              textDirection: TextDirection.ltr,
              style: text.style(13, FontWeight.w700, color: BrandColors.slate),
            ),
          ),
        ],
      ),
    );
    final absent = FocusTraversalOrder(
      order: NumericFocusOrder(2000.0 + index),
      child: Semantics(
        label: '${grade.fullName}${l10n.dotSeparator}${l10n.absentLabel}',
        child: Checkbox(
          value: entry.absent,
          activeColor: BrandColors.indigo,
          onChanged: (v) => cubit.setAbsent(grade.studentId, v ?? false),
        ),
      ),
    );
    final comment = FocusTraversalOrder(
      order: NumericFocusOrder(1000.0 + index),
      child: FormInput(
        key: ValueKey('comment-${grade.studentId}'),
        initialValue: entry.comment,
        dense: true,
        fillColor: Colors.white,
        hint: l10n.commentForPupilHint,
        onChanged: (v) => cubit.setComment(grade.studentId, v),
      ),
    );
    final name = Text(grade.fullName, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.rowTitle);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: first ? null : const Border(top: BorderSide(color: BrandColors.rowDivider)),
      ),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InitialsAvatar(initials: grade.initials),
                const SizedBox(width: 14),
                SizedBox(
                  width: 220,
                  child: Padding(padding: const EdgeInsets.only(top: 10), child: name),
                ),
                score,
                SizedBox(width: 90, child: Center(child: absent)),
                Expanded(child: comment),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InitialsAvatar(initials: grade.initials, size: 36),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          name,
                          Row(
                            children: [
                              absent,
                              Flexible(
                                child: Text(l10n.absentLabel, style: text.style(13, FontWeight.w600, color: BrandColors.body)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    score,
                  ],
                ),
                const SizedBox(height: 4),
                comment,
              ],
            ),
    );
  }
}
