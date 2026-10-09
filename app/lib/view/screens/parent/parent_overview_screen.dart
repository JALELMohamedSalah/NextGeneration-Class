import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/di/injection.dart';
import '../../../core/l10n/formatting.dart';
import '../../../core/l10n/tunis_time.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/router/routes.dart';
import '../../../domain/model/app_user.dart';
import '../../../domain/model/homework.dart';
import '../../../l10n/app_localizations.dart';
import '../../stateManager/auth/auth_cubit.dart';
import '../../stateManager/comments/comments_cubit.dart';
import '../../stateManager/common/load_status.dart';
import '../../stateManager/homework/my_homework_cubit.dart';
import '../../stateManager/my_planning/my_planning_cubit.dart';
import '../../stateManager/results/results_cubit.dart';
import '../../stateManager/language/language_cubit.dart';
import '../../widgets/cards.dart';
import '../../widgets/classmates.dart';
import '../../widgets/hero_card.dart';
import '../../widgets/labels.dart';
import '../../widgets/page_frame.dart';
import '../../widgets/school_widgets.dart';

/// One-minute overview of a child (docs/02-specification/10-parent-space.md, design `ParentPhone.png`):
/// sessions and attendance (R1), the average, homework sent and the last grade (R2), which open the results.
class ParentOverviewScreen extends StatelessWidget {
  const ParentOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firstChild = context.read<AuthCubit>().user?.children.firstOrNull?.studentId;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MyPlanningCubit(sl.get(), sl.get<Now>())..load(studentId: firstChild)),
        BlocProvider(create: (_) => ResultsCubit(sl.get())..load(studentId: firstChild)),
        BlocProvider(create: (_) => MyHomeworkCubit(sl.get(), sl.get<Now>())..load(studentId: firstChild)),
        BlocProvider(create: (_) => CommentsCubit(sl.get())..load(studentId: firstChild)),
      ],
      child: const ParentOverviewView(),
    );
  }
}

class ParentOverviewView extends StatelessWidget {
  const ParentOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final user = context.select((AuthCubit cubit) => cubit.user);
    final planning = context.watch<MyPlanningCubit>().state;
    final results = context.watch<ResultsCubit>().state.results;
    final homework = context.watch<MyHomeworkCubit>().state;
    final word = context.watch<CommentsCubit>().state.latest;
    final children = user?.children ?? const <ChildSummary>[];
    if (children.isEmpty) {
      return PageScroll(
        maxWidth: familyPageWidth,
        children: [
          Text(l10n.greeting(user?.firstName ?? ''), style: text.pageTitle(phone: isPhone(context))),
          SectionCard(child: EmptyState(message: l10n.parentNoChild)),
        ],
      );
    }
    final child = children.where((c) => c.studentId == planning.studentId).firstOrNull ?? children.first;
    final next = planning.next;
    final rate = planning.monthAttendanceRate;
    final loading = planning.status == LoadStatus.loading;
    final average = results?.average;
    final last = results?.grades.where((g) => g.counted).firstOrNull;
    final missing = homework.items.where((h) => h.status == HomeworkStatus.missing).toList()
      ..sort((a, b) => b.deadlineAt.compareTo(a.deadlineAt));
    void openResults() => context.push(Uri(path: Routes.parentResults, queryParameters: {Routes.childParam: child.studentId}).toString());
    void select(String studentId) {
      context.read<MyPlanningCubit>().load(studentId: studentId);
      context.read<ResultsCubit>().load(studentId: studentId);
      context.read<MyHomeworkCubit>().load(studentId: studentId);
      context.read<CommentsCubit>().load(studentId: studentId);
    }

    return PageScroll(
      maxWidth: familyPageWidth,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.greeting(user?.firstName ?? ''), style: text.style(13, FontWeight.w600, color: BrandColors.slate)),
            const SizedBox(height: 2),
            Text(l10n.childThisWeek(child.firstName), style: text.style(22, FontWeight.w800, spacing: -0.5)),
            if (children.length > 1) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in children)
                    _ChildChip(child: c, selected: c.studentId == child.studentId, onTap: () => select(c.studentId)),
                ],
              ),
            ],
          ],
        ),
        // On a computer the average and the four tiles sit side by side; one under the other on phones.
        PairedBlocks(
          equalHeight: false,
          startFlex: 6,
          endFlex: 6,
          start: GestureDetector(
            onTap: average == null ? null : openResults,
            child: HeroCard(
              variant: HeroVariant.parent,
              phone: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.average, style: text.style(13, FontWeight.w700, color: Colors.white.withValues(alpha: 0.75))),
                  const SizedBox(height: 8),
                  // The hero number shrinks rather than run out of a narrow phone.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Row(
                      textDirection: TextDirection.ltr,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          average == null ? l10n.noValue : averageText(average),
                          textDirection: TextDirection.ltr,
                          style: text.heroNumber,
                        ),
                        if (average != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '/20',
                            textDirection: TextDirection.ltr,
                            style: text.style(18, FontWeight.w700, color: Colors.white.withValues(alpha: 0.75)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 90),
                    child: Text(
                      average == null ? l10n.parentNoDataYet : l10n.averageOfGrades(results!.grades.length),
                      style: text.style(14, FontWeight.w600, color: Colors.white.withValues(alpha: 0.85), height: 1.5),
                    ),
                  ),
                  if (average != null) ...[
                    const SizedBox(height: 10),
                    Text(l10n.seeResults, style: text.style(14, FontWeight.w800, color: Colors.white)),
                  ],
                ],
              ),
            ),
          ),
          end: _TileGrid(
            tiles: [
              _Tile(
                title: l10n.nextSession,
                value: next == null || loading ? null : '${weekdayShort(TunisTime.day(next.startsAt), language)} ${hm(next.startsAt)}',
                caption: next == null ? null : placeLabel(l10n, next.mode, next.location, family: true),
              ),
              _Tile(
                title: l10n.attendance,
                value: rate == null || loading ? null : l10n.percentValue(rate),
                caption: rate == null ? null : l10n.absencesThisMonth(planning.monthAbsences),
                captionColor: planning.monthAbsences > 0 ? Accent.red.onSoft : null,
              ),
              _Tile(
                title: l10n.assignments,
                value: results == null || results.due == 0 ? null : l10n.countOf(results.submitted, results.due),
                caption: missing.isNotEmpty
                    ? l10n.missingTitle(isolated(missing.first.title))
                    : (results == null || results.due == 0 ? null : l10n.homeworkSentLabel),
                captionColor: missing.isNotEmpty ? Accent.red.onSoft : null,
                onTap: results == null || results.due == 0 ? null : openResults,
              ),
              _Tile(
                title: l10n.lastGrade,
                value: last == null ? null : '${scoreText(last.score!)}/${last.maxScore}',
                caption: last == null ? null : isolated(last.title),
                onTap: last == null ? null : openResults,
              ),
            ],
          ),
        ),
        SectionCard(
          phone: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconBadge(icon: LucideIcons.messageCircle, size: IconBadgeSize.medium),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Mot de l'enseignante · hier" (design `ParentPhone.png`): the latest comment on the child.
                    Text(
                      word == null
                          ? l10n.teacherNote
                          : '${l10n.teacherNote}${l10n.dotSeparator}${timeAgo(l10n, language, word.createdAt, sl.get<Now>()()).toLowerCase()}',
                      style: text.style(13, FontWeight.w700, color: BrandColors.slate),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      word?.body ?? l10n.emptyComment,
                      textDirection: word == null ? null : writtenDirection(word.body),
                      style: text.style(14, FontWeight.w500, color: word == null ? BrandColors.body : BrandColors.ink, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChildChip extends StatelessWidget {
  const _ChildChip({required this.child, required this.selected, required this.onTap});

  final ChildSummary child;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageCubit>().state;
    final radius = BorderRadius.circular(AppRadii.pill);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? BrandColors.ink : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: selected ? BorderSide.none : const BorderSide(color: BrandColors.line),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Text(
              '${child.firstName} · ${child.level.of(language)}',
              style: AppText.of(context).style(13, FontWeight.w700, color: selected ? Colors.white : BrandColors.ink),
            ),
          ),
        ),
      ),
    );
  }
}

/// Two tiles per row.
class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < tiles.length; row += 2) ...[
          if (row > 0) const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: tiles[row]),
                const SizedBox(width: 10),
                Expanded(child: row + 1 < tiles.length ? tiles[row + 1] : const SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// A parent tile: title, value (or "—"), caption (or "Pas encore"); [onTap] opens the details.
class _Tile extends StatelessWidget {
  const _Tile({required this.title, this.value, this.caption, this.captionColor, this.onTap});

  final String title;
  final String? value;
  final String? caption;
  final Color? captionColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    return HoverCard(
      radius: AppRadii.row,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.style(13, FontWeight.w700, color: BrandColors.body)),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 220),
            child: Text(
              value ?? l10n.noValue,
              key: ValueKey(value),
              textDirection: TextDirection.ltr,
              style: text.style(20, FontWeight.w800, tabular: true),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption ?? l10n.notYet,
            style: text.style(12, caption == null ? FontWeight.w500 : FontWeight.w700, color: captionColor ?? BrandColors.slate),
          ),
        ],
      ),
    );
  }
}
