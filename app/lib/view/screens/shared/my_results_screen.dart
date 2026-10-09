import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/di/injection.dart';
import '../../../core/l10n/formatting.dart';
import '../../../core/l10n/tunis_time.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../domain/model/app_user.dart';
import '../../../domain/model/results.dart';
import '../../../l10n/app_localizations.dart';
import '../../stateManager/auth/auth_cubit.dart';
import '../../stateManager/common/load_status.dart';
import '../../stateManager/language/language_cubit.dart';
import '../../stateManager/results/results_cubit.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';
import '../../widgets/classmates.dart';
import '../../widgets/feedback.dart';
import '../../widgets/page_frame.dart';

/// "Résultats" (spec 07 and 09, design `r2/CorrectionPhone.png`): per subject the average on /20, the trend,
/// homework sent, attendance, and each grade with the teacher's word. A pupil's tab; a parent opens it from
/// Aperçu for one child ([childId] first).
class MyResultsScreen extends StatelessWidget {
  const MyResultsScreen({super.key, this.childId});

  final String? childId;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().user;
    final children = user?.role == UserRole.parent ? user!.children : const <ChildSummary>[];
    final first = children.where((c) => c.studentId == childId).firstOrNull ?? children.firstOrNull;
    return BlocProvider(
      create: (_) => ResultsCubit(sl.get())..load(studentId: first?.studentId),
      child: const MyResultsView(),
    );
  }
}

class MyResultsView extends StatelessWidget {
  const MyResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final phone = isPhone(context);
    final language = context.watch<LanguageCubit>().state;
    final user = context.watch<AuthCubit>().user;
    final parent = user?.role == UserRole.parent;
    final state = context.watch<ResultsCubit>().state;
    final cubit = context.read<ResultsCubit>();
    final child = parent ? user!.children.where((c) => c.studentId == state.studentId).firstOrNull : null;
    final name = isolated(child?.firstName ?? '');

    Widget pill(String label, bool selected, VoidCallback onTap) => Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: BrandColors.ink,
        backgroundColor: Colors.white,
        side: BorderSide(color: selected ? BrandColors.ink : BrandColors.line),
        labelStyle: text.style(14, FontWeight.w700, color: selected ? Colors.white : BrandColors.ink),
        onSelected: (_) => onTap(),
      ),
    );

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(parent ? l10n.parentResultsTitle(name) : l10n.myResultsTitle, style: text.pageTitle(phone: phone)),
        const SizedBox(height: 6),
        Text(
          parent ? l10n.parentResultsSubtitle(name) : l10n.myResultsSubtitle,
          style: text.style(15, FontWeight.w500, color: BrandColors.body, height: 1.5),
        ),
      ],
    );
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (parent)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconSquareButton(
                icon: LucideIcons.arrowLeftDir,
                tooltip: l10n.back,
                onPressed: () => context.canPop() ? context.pop() : context.go(Routes.parentOverview),
              ),
              const SizedBox(width: 12),
              Expanded(child: title),
            ],
          )
        else
          title,
        if (parent && user!.children.length > 1) ...[
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final c in user.children)
                  pill(
                    '${keptTogether(c.firstName)}${l10n.dotSeparator}${c.level.of(language)}',
                    c.studentId == state.studentId,
                    () => cubit.load(studentId: c.studentId),
                  ),
              ],
            ),
          ),
        ],
      ],
    );

    final results = state.results;
    final List<Widget> body;
    if (state.status == LoadStatus.failure && results == null) {
      body = [FailureBanner(state.failure!, onRetry: () => cubit.load(studentId: state.studentId))];
    } else if (results == null) {
      body = [const LinearProgressIndicator(minHeight: 3)];
    } else if (results.subjects.isEmpty) {
      body = [SectionCard(child: EmptyState(message: parent ? l10n.resultsEmptyParent(name) : l10n.resultsEmpty, scale: 0.45))];
    } else {
      body = [
        CardColumns(
          gap: 20,
          children: [
            for (final (i, subject) in results.subjects.indexed)
              FadeRise(
                index: i,
                child: SubjectCard(result: subject),
              ),
          ],
        ),
      ];
    }
    return PageScroll(maxWidth: familyPageWidth, gap: 20, children: [header, ...body]);
  }
}

/// One subject: the average and its trend, homework sent and attendance, then each grade.
class SubjectCard extends StatelessWidget {
  const SubjectCard({super.key, required this.result});

  final SubjectResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final r = result;
    final trend = switch (r.trend) {
      Trend.up => StatusChip(label: l10n.trendUp, accent: Accent.green),
      Trend.down => StatusChip(label: l10n.trendDown, accent: Accent.orange),
      Trend.stable => StatusChip(label: l10n.trendStable, accent: Accent.grey),
      null => null,
    };
    Widget stat(String value, String label) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: BrandColors.chalk, borderRadius: BorderRadius.circular(AppRadii.sm)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: text.style(16, FontWeight.w800)),
            Text(label, style: text.style(12, FontWeight.w500, color: BrandColors.slate)),
          ],
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.tile),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: colorFromHex(r.subject.color), borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(text.upper(r.subject.name.of(language)), style: text.overline(color: BrandColors.body)),
              ),
              ?trend,
            ],
          ),
          const SizedBox(height: 10),
          if (r.average == null) ...[
            Text(l10n.noGradeYet, style: text.style(17, FontWeight.w700)),
          ] else ...[
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              // "15,25 /20" reads left to right in Arabic too, like every score.
              child: Row(
                textDirection: TextDirection.ltr,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(averageText(r.average!), textDirection: TextDirection.ltr, style: text.style(40, FontWeight.w800, spacing: -1)),
                  const SizedBox(width: 6),
                  Text(
                    '/20',
                    textDirection: TextDirection.ltr,
                    style: text.style(16, FontWeight.w700, color: BrandColors.slate),
                  ),
                ],
              ),
            ),
            Text(l10n.averageOfGrades(r.gradeCount), style: text.style(13, FontWeight.w500, color: BrandColors.slate)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              stat(l10n.countOf(r.submitted, r.due), l10n.homeworkSentLabel),
              const SizedBox(width: 8),
              stat(r.attendanceRate == null ? l10n.noValue : l10n.percentValue(r.attendanceRate!), l10n.attendanceLabel),
            ],
          ),
          if (r.grades.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(text.upper(l10n.gradesTitle), style: text.overline(size: 11)),
            for (final (i, g) in r.grades.indexed) _GradeRow(grade: g, first: i == 0),
          ],
        ],
      ),
    );
  }
}

class _GradeRow extends StatelessWidget {
  const _GradeRow({required this.grade, required this.first});

  final GradeItem grade;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final g = grade;
    final comment = g.comment;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: first ? null : const Border(top: BorderSide(color: BrandColors.rowDivider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(g.title, style: text.style(15, FontWeight.w700)),
                const SizedBox(height: 4),
                // Where the grade comes from: a paper evaluation or a corrected homework.
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(
                      label: g.kind == GradeKind.evaluation ? l10n.gradeKindEvaluation : l10n.gradeKindHomework,
                      accent: g.kind == GradeKind.evaluation ? Accent.violet : Accent.blue,
                    ),
                    Text(dayInSentence(TunisTime.day(g.date), language), style: text.style(13, FontWeight.w500, color: BrandColors.slate)),
                  ],
                ),
                if (comment != null && comment.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    comment,
                    textDirection: writtenDirection(comment),
                    style: text.style(13, FontWeight.w500, color: BrandColors.body, height: 1.45),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // An absence is listed, never as 0.
          if (!g.counted)
            StatusChip(label: l10n.absentLabel, accent: Accent.grey)
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: scoreText(g.score!), style: text.style(17, FontWeight.w800)),
                      TextSpan(
                        text: ' /${g.maxScore}',
                        style: text.style(13, FontWeight.w600, color: BrandColors.slate),
                      ),
                    ],
                  ),
                  textDirection: TextDirection.ltr,
                ),
                // "7/10 (14,00/20)": another scale also shows on /20 (spec 07).
                if (g.maxScore != 20)
                  Text(
                    '${averageText(g.score20!)} /20',
                    textDirection: TextDirection.ltr,
                    style: text.style(12, FontWeight.w600, color: BrandColors.slate),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
