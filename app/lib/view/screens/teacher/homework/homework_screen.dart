import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/tunis_time.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../domain/model/evaluation.dart';
import '../../../../domain/model/homework.dart';
import '../../../../domain/model/reference.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/common/load_status.dart';
import '../../../stateManager/groups/groups_cubit.dart';
import '../../../stateManager/homework/homework_list_cubit.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/reference/reference_cubit.dart';
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
import '../../shared/my_homework_screen.dart' show homeworkWhen;
import 'assign_panel.dart';
import 'evaluation_panel.dart';

/// Devoirs (designs `r2/Devoirs.png`, `r2/ACorriger.png`): the copies to correct, homework in progress or finished.
class HomeworkScreen extends StatelessWidget {
  const HomeworkScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => HomeworkListCubit(sl.get(), evaluations: sl.get())..load(),
    child: const HomeworkView(),
  );
}

class HomeworkView extends StatelessWidget {
  const HomeworkView({super.key});

  static Future<void> _assign(BuildContext context) async {
    final list = context.read<HomeworkListCubit>();
    final saved = await AssignPanel.open(context);
    if (saved == null) return;
    list.saved(saved);
    if (context.mounted) showNotice(context, AppLocalizations.of(context).homeworkGiven);
  }

  /// "Nouvelle évaluation", then straight to its score table (design `r2/Evaluation.png`).
  static Future<void> _newEvaluation(BuildContext context) async {
    final list = context.read<HomeworkListCubit>();
    final created = await EvaluationPanel.open(context, groupId: list.state.groupId);
    if (created == null || !context.mounted) return;
    list.evaluationSaved(created.evaluation);
    await context.push(Routes.teacherEvaluation(created.evaluation.id), extra: created);
    if (!list.isClosed) list.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final phone = isPhone(context);
    final language = context.watch<LanguageCubit>().state;
    final state = context.watch<HomeworkListCubit>().state;
    final cubit = context.read<HomeworkListCubit>();
    final groups = context.watch<GroupsCubit>().state.groups;
    final reference = context.watch<ReferenceCubit>().state.reference;
    final filtered = groups.where((g) => g.id == state.groupId).firstOrNull;
    final subjects = [
      for (final s in reference?.subjects ?? const <Subject>[])
        if (state.subjectIds.contains(s.id)) s,
    ];
    final subject = subjects.where((s) => s.id == state.subjectId).firstOrNull;

    final header = Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 16,
      runSpacing: 14,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.navAssignments, style: text.pageTitle(phone: phone)),
              const SizedBox(height: 6),
              Text(l10n.homeworkSubtitle, style: text.style(15, FontWeight.w500, color: BrandColors.body, height: 1.5)),
            ],
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SecondaryButton(label: l10n.newEvaluation, icon: LucideIcons.clipboardCheck, onPressed: () => _newEvaluation(context)),
            PrimaryButton(label: l10n.newHomework, icon: LucideIcons.plus, height: 44, onPressed: () => _assign(context)),
          ],
        ),
      ],
    );

    final filters = Wrap(
      spacing: 12,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        PillTabs<HomeworkTab>(
          value: state.tab,
          onChanged: cubit.setTab,
          items: [
            TabItem(HomeworkTab.toCorrect, l10n.homeToCorrect, count: state.countOf(HomeworkTab.toCorrect)),
            TabItem(HomeworkTab.open, l10n.homeworkOpen, count: state.countOf(HomeworkTab.open)),
            TabItem(HomeworkTab.done, l10n.homeworkDone, count: state.countOf(HomeworkTab.done)),
            TabItem(HomeworkTab.evaluations, l10n.evaluationsTab, count: state.countOf(HomeworkTab.evaluations)),
          ],
        ),
        if (groups.length > 1)
          FilterMenuButton<String?>(
            label: filtered == null ? l10n.groupAll : l10n.groupFilter(filtered.name),
            value: state.groupId,
            onChanged: cubit.filterGroup,
            options: [SelectOption(null, l10n.groupAll), for (final g in groups) SelectOption(g.id, g.name)],
          ),
        if (subjects.length > 1)
          FilterMenuButton<String?>(
            label: subject == null ? l10n.subjectAllFilter : l10n.subjectFilter(subject.name.of(language)),
            value: state.subjectId,
            onChanged: cubit.filterSubject,
            options: [SelectOption(null, l10n.subjectAllFilter), for (final s in subjects) SelectOption(s.id, s.name.of(language))],
          ),
      ],
    );

    final List<Widget> body;
    if (state.status == LoadStatus.failure && state.items.isEmpty) {
      body = [FailureBanner(state.failure!, onRetry: cubit.load)];
    } else if (state.status == LoadStatus.loading && state.items.isEmpty) {
      body = [const LinearProgressIndicator(minHeight: 3)];
    } else if (state.tab == HomeworkTab.toCorrect) {
      final queue = state.visibleQueue;
      body = [
        filters,
        if (queue.isEmpty)
          SectionCard(
            child: EmptyState(
              message: l10n.emptyToCorrect,
              scale: 0.45,
              action: Text(
                l10n.toCorrectEmptyHint,
                textAlign: TextAlign.center,
                style: text.style(13, FontWeight.w500, color: BrandColors.slate, height: 1.5),
              ),
            ),
          )
        else ...[
          for (final (i, group) in queue.indexed)
            FadeRise(
              index: i,
              child: _QueueGroup(group: group),
            ),
          InfoNote(text: l10n.toCorrectInfo),
        ],
      ];
    } else if (state.tab == HomeworkTab.evaluations) {
      final evaluations = state.visibleEvaluations;
      body = [
        filters,
        if (evaluations.isEmpty)
          SectionCard(
            child: EmptyState(
              message: l10n.noEvaluations,
              scale: 0.45,
              action: Column(
                children: [
                  Text(
                    l10n.noEvaluationsHint,
                    textAlign: TextAlign.center,
                    style: text.style(13, FontWeight.w500, color: BrandColors.slate, height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: l10n.newEvaluation,
                    icon: LucideIcons.clipboardCheck,
                    height: 44,
                    onPressed: () => _newEvaluation(context),
                  ),
                ],
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 860;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: wide ? 24 : 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: BrandColors.line),
                  borderRadius: BorderRadius.circular(AppRadii.card),
                ),
                child: Column(
                  children: [
                    for (final (i, e) in evaluations.indexed)
                      FadeRise(
                        index: i,
                        child: _EvaluationRow(evaluation: e, first: i == 0, wide: wide),
                      ),
                  ],
                ),
              );
            },
          ),
      ];
    } else if (state.visible.isEmpty) {
      body = [
        filters,
        SectionCard(
          child: EmptyState(
            message: state.tab == HomeworkTab.open ? l10n.homeworkEmpty : l10n.homeworkDoneEmpty,
            scale: 0.45,
            action: state.tab == HomeworkTab.open
                ? Column(
                    children: [
                      Text(
                        l10n.homeworkEmptyHint,
                        textAlign: TextAlign.center,
                        style: text.style(13, FontWeight.w500, color: BrandColors.slate, height: 1.5),
                      ),
                      const SizedBox(height: 14),
                      PrimaryButton(label: l10n.newHomework, icon: LucideIcons.plus, height: 44, onPressed: () => _assign(context)),
                    ],
                  )
                : null,
          ),
        ),
      ];
    } else {
      body = [
        filters,
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 860;
            final items = state.visible;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: wide ? 24 : 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: BrandColors.line),
                borderRadius: BorderRadius.circular(AppRadii.card),
              ),
              child: Column(
                children: [
                  if (wide) const _Header(),
                  for (final (i, a) in items.indexed)
                    FadeRise(
                      index: i,
                      child: _Row(assignment: a, first: i == 0, wide: wide),
                    ),
                ],
              ),
            );
          },
        ),
        InfoNote(text: l10n.homeworkInfo),
      ];
    }
    return PageScroll(children: [header, ...body]);
  }
}

/// Opens the correction of one copy, then reads the list again (design `r2/Corriger.png`).
Future<void> openCorrection(BuildContext context, String assignmentId, String studentId) async {
  final list = context.read<HomeworkListCubit>();
  await context.push(Routes.teacherCorrection(assignmentId, studentId));
  if (!list.isClosed) list.load();
}

/// One homework of "À corriger" (design `r2/ACorriger.png`): its copies, oldest first.
class _QueueGroup extends StatelessWidget {
  const _QueueGroup({required this.group});

  final ToCorrectGroup group;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final now = sl.get<Now>()();
    final a = group.assignment;
    final phone = isPhone(context);
    final title = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KindBadge(kind: a.contentKind),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a.title, style: text.style(17, FontWeight.w700)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  GroupLabel(code: a.group.code, color: a.group.color, name: a.group.name),
                  Text(
                    l10n.deadlineWas(homeworkWhen(l10n, language, a.deadlineAt, now)),
                    style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
    final actions = Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        CountPill(count: group.items.length, accent: Accent.amber),
        PrimaryButton(
          label: l10n.correctAction,
          icon: LucideIcons.penLine,
          height: 40,
          onPressed: () => openCorrection(context, a.id, group.items.first.studentId),
        ),
      ],
    );
    return Container(
      padding: EdgeInsets.fromLTRB(phone ? 14 : 24, phone ? 14 : 20, phone ? 14 : 24, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (phone) ...[
            title,
            const SizedBox(height: 10),
            actions,
          ] else
            Row(
              children: [
                Expanded(child: title),
                actions,
              ],
            ),
          const SizedBox(height: 10),
          for (final (i, item) in group.items.indexed) _QueueRow(assignmentId: a.id, item: item, first: i == 0),
        ],
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({required this.assignmentId, required this.item, required this.first});

  final String assignmentId;
  final ToCorrectItem item;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final now = sl.get<Now>()();
    final sent = Text(
      l10n.sentOn(homeworkWhen(l10n, language, item.submittedAt, now)),
      style: text.style(13, FontWeight.w500, color: BrandColors.slate),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 640;
        return InkWell(
          onTap: () => openCorrection(context, assignmentId, item.studentId),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: BrandColors.rowDivider)),
            ),
            child: Row(
              children: [
                InitialsAvatar(initials: item.initials),
                const SizedBox(width: 14),
                Expanded(
                  child: wide
                      ? Row(
                          children: [
                            Expanded(
                              child: Text(item.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.rowTitle),
                            ),
                            SizedBox(
                              width: 170,
                              child: Align(alignment: AlignmentDirectional.centerStart, child: HomeworkStatusChip(item.status)),
                            ),
                            SizedBox(width: 200, child: sent),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.rowTitle),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [HomeworkStatusChip(item.status), sent],
                            ),
                          ],
                        ),
                ),
                const SizedBox(width: 10),
                TonalButton(label: l10n.correctAction, onPressed: () => openCorrection(context, assignmentId, item.studentId)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final style = text.overline(size: 11);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: BrandColors.rowDivider)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 54),
          Expanded(child: Text(text.upper(l10n.columnHomework), style: style)),
          SizedBox(width: 190, child: Text(text.upper(l10n.columnDueFor), style: style)),
          SizedBox(width: 230, child: Text(text.upper(l10n.columnSent), style: style)),
        ],
      ),
    );
  }
}

/// One homework: wide as a line, narrow as a card. A tap opens its detail.
class _Row extends StatelessWidget {
  const _Row({required this.assignment, required this.first, required this.wide});

  final Assignment assignment;
  final bool first;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final now = sl.get<Now>()();
    final a = assignment;
    final near = !a.done && deadlineIsNear(a.deadlineAt, now);
    final due = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          deadlineLabel(l10n, language, a.deadlineAt, now),
          style: text.style(14, FontWeight.w700, color: near ? Accent.orange.onSoft : BrandColors.ink),
        ),
        Text(
          a.closed ? l10n.closedChip : deadlineNote(l10n, a.deadlineAt, now),
          style: text.style(13, FontWeight.w500, color: BrandColors.slate),
        ),
      ],
    );
    final sent = a.mode == SubmissionMode.none
        ? Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusChip(label: l10n.nothingToSubmit, accent: Accent.grey),
              Text(l10n.studentsCount(a.recipients), style: text.style(13, FontWeight.w500, color: BrandColors.slate)),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeworkProgress(counts: a.counts, total: a.recipients),
              const SizedBox(height: 6),
              Text(
                [
                  l10n.sentOf(a.counts.sent, a.recipients),
                  if (a.counts.late > 0) l10n.lateCount(a.counts.late),
                  if (a.counts.missing > 0) l10n.missingCount(a.counts.missing),
                ].join(l10n.dotSeparator),
                style: text.style(13, FontWeight.w500, color: BrandColors.slate),
              ),
            ],
          );
    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.rowTitle),
        const SizedBox(height: 4),
        Row(
          children: [
            GroupSquare(code: a.group.code, color: a.group.color, size: 22),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                a.group.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.style(13, FontWeight.w500, color: BrandColors.slate),
              ),
            ),
          ],
        ),
      ],
    );
    return InkWell(
      onTap: () => context.go(Routes.teacherHomework(a.id)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: first ? null : const Border(top: BorderSide(color: BrandColors.rowDivider)),
        ),
        child: wide
            ? Row(
                children: [
                  KindBadge(kind: a.contentKind),
                  const SizedBox(width: 14),
                  Expanded(child: identity),
                  SizedBox(width: 190, child: due),
                  SizedBox(width: 230, child: sent),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KindBadge(kind: a.contentKind),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [identity, const SizedBox(height: 10), due, const SizedBox(height: 10), sent],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// One evaluation of the "Évaluations" tab: what, for whom, when, how many scores, the average.
class _EvaluationRow extends StatelessWidget {
  const _EvaluationRow({required this.evaluation, required this.first, required this.wide});

  final Evaluation evaluation;
  final bool first;
  final bool wide;

  Future<void> _open(BuildContext context) async {
    final list = context.read<HomeworkListCubit>();
    await context.push(Routes.teacherEvaluation(evaluation.id));
    if (!list.isClosed) list.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final e = evaluation;
    final quiet = text.style(13, FontWeight.w500, color: BrandColors.slate);
    final status = e.complete
        ? StatusChip(label: l10n.gradesDone, accent: Accent.green)
        : StatusChip(label: l10n.gradesToType, accent: Accent.amber);
    final count = Text(l10n.gradesTyped(e.graded, e.pupils), style: text.style(13, FontWeight.w600, color: BrandColors.body));
    final average = e.average == null
        ? Text('—', style: quiet)
        : Text.rich(
            TextSpan(
              children: [
                TextSpan(text: averageText(e.average!), style: text.style(15, FontWeight.w800, tabular: true)),
                TextSpan(text: ' / ${e.maxScore}', style: quiet),
              ],
            ),
            textDirection: TextDirection.ltr,
          );
    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(e.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.rowTitle),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GroupLabel(code: e.group.code, color: e.group.color, name: e.group.name),
            Text(dayDate(e.heldOn, language), style: quiet),
          ],
        ),
      ],
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _open(context),
        hoverColor: BrandColors.chalk,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: first ? null : const Border(top: BorderSide(color: BrandColors.rowDivider)),
          ),
          child: Row(
            crossAxisAlignment: wide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              const IconBadge(icon: LucideIcons.clipboardCheck, accent: Accent.violet),
              const SizedBox(width: 14),
              if (wide) ...[
                Expanded(child: identity),
                SizedBox(width: 150, child: count),
                SizedBox(width: 130, child: average),
                SizedBox(
                  width: 170,
                  child: Align(alignment: AlignmentDirectional.centerStart, child: status),
                ),
              ] else
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      identity,
                      const SizedBox(height: 8),
                      Wrap(spacing: 10, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [status, count, average]),
                    ],
                  ),
                ),
              const Icon(LucideIcons.chevronRightDir, size: 18, color: BrandColors.slate),
            ],
          ),
        ),
      ),
    );
  }
}
