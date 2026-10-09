import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/di/injection.dart';
import '../../../core/l10n/app_language.dart';
import '../../../core/l10n/formatting.dart';
import '../../../core/l10n/tunis_time.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../domain/model/app_user.dart';
import '../../../domain/model/homework.dart';
import '../../../l10n/app_localizations.dart';
import '../../stateManager/auth/auth_cubit.dart';
import '../../stateManager/common/load_status.dart';
import '../../stateManager/homework/my_homework_cubit.dart';
import '../../stateManager/language/language_cubit.dart';
import '../../widgets/cards.dart';
import '../../widgets/classmates.dart';
import '../../widgets/feedback.dart';
import '../../widgets/homework_widgets.dart';
import '../../widgets/page_frame.dart';
import '../../widgets/school_widgets.dart';

/// "Mes devoirs" (design `r2/DevoirsPhone.png`): a pupil's homework, or a parent's view of one child's
/// ([childId] first, from a notification). To do first, nearest deadline first.
class MyHomeworkScreen extends StatelessWidget {
  const MyHomeworkScreen({super.key, this.childId});

  final String? childId;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().user;
    final children = user?.role == UserRole.parent ? user!.children : const <ChildSummary>[];
    final first = children.where((c) => c.studentId == childId).firstOrNull ?? children.firstOrNull;
    return BlocProvider(
      create: (_) => MyHomeworkCubit(sl.get(), sl.get())..load(studentId: first?.studentId),
      child: const MyHomeworkView(),
    );
  }
}

/// "Pour demain, 18:00", "Pour jeudi, 18:00", "Pour jeudi 15 octobre, 18:00" (Tunisian time).
String homeworkWhen(AppLocalizations l10n, AppLanguage language, DateTime instant, DateTime now) {
  final day = TunisTime.day(instant);
  final today = TunisTime.day(now);
  final time = hm(instant);
  if (TunisTime.sameDay(day, today)) return l10n.dueToday(time).toLowerCase();
  if (TunisTime.sameDay(day, TunisTime.addDays(today, 1))) return l10n.dueTomorrow(time).toLowerCase();
  if (TunisTime.sameDay(day, TunisTime.addDays(today, -1))) return l10n.dueOn(l10n.yesterday.toLowerCase(), time);
  final near = day.difference(today).inDays.abs() < 7;
  return l10n.dueOn(near ? weekdayName(day, language) : dayInSentence(day, language), time);
}

class MyHomeworkView extends StatelessWidget {
  const MyHomeworkView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final phone = isPhone(context);
    final language = context.watch<LanguageCubit>().state;
    final user = context.watch<AuthCubit>().user;
    final parent = user?.role == UserRole.parent;
    final state = context.watch<MyHomeworkCubit>().state;
    final cubit = context.read<MyHomeworkCubit>();
    final child = parent ? user!.children.where((c) => c.studentId == state.studentId).firstOrNull : null;
    // A French first name inside an Arabic sentence keeps its place (core/l10n/formatting.dart).
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

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(parent ? l10n.parentHomeworkTitle(name) : l10n.myHomeworkTitle, style: text.pageTitle(phone: phone)),
        const SizedBox(height: 6),
        Text(
          parent ? l10n.parentHomeworkSubtitle(name) : l10n.myHomeworkSubtitle,
          style: text.style(15, FontWeight.w500, color: BrandColors.body, height: 1.5),
        ),
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

    final List<Widget> body;
    if (state.status == LoadStatus.failure && state.items.isEmpty) {
      body = [FailureBanner(state.failure!, onRetry: () => cubit.load(studentId: state.studentId))];
    } else if (state.status == LoadStatus.loading && state.items.isEmpty) {
      body = [const LinearProgressIndicator(minHeight: 3)];
    } else if (state.items.isEmpty) {
      body = [SectionCard(child: EmptyState(message: parent ? l10n.parentHomeworkEmpty(name) : l10n.myHomeworkEmpty, scale: 0.45))];
    } else {
      final open = cubit.open;
      final finished = cubit.finished;
      body = [
        if (open.isNotEmpty) _Section(title: l10n.sectionTodo, count: open.length, items: open),
        if (finished.isNotEmpty) _Section(title: l10n.sectionDone, items: finished),
        if (parent && open.any((h) => h.mode == SubmissionMode.file)) InfoNote(text: l10n.parentSendsNotice(name)),
      ];
    }
    return PageScroll(maxWidth: familyPageWidth, gap: 20, children: [header, ...body]);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items, this.count});

  final String title;
  final int? count;
  final List<MyHomework> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          text.upper(count == null ? title : '$title${l10n.dotSeparator}$count'),
          style: text.overline(color: count == null ? BrandColors.body : BrandColors.indigo),
        ),
        const SizedBox(height: 10),
        CardColumns(
          gap: 10,
          children: [
            for (final (i, h) in items.indexed)
              FadeRise(
                index: i,
                child: _HomeworkTile(homework: h),
              ),
          ],
        ),
      ],
    );
  }
}

/// A homework to open: title, subject, its status, and when (due, to read, or sent).
class _HomeworkTile extends StatelessWidget {
  const _HomeworkTile({required this.homework});

  final MyHomework homework;

  Future<void> _open(BuildContext context) async {
    final parent = context.read<AuthCubit>().user?.role == UserRole.parent;
    final cubit = context.read<MyHomeworkCubit>();
    final studentId = cubit.state.studentId;
    await context.push(
      parent
          ? Uri(path: Routes.parentHomework(homework.id), queryParameters: {Routes.childParam: ?studentId}).toString()
          : Routes.studentHomework(homework.id),
    );
    // The work may have been sent meanwhile.
    cubit.load(studentId: studentId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final now = sl.get<Now>()();
    final h = homework;
    final color = colorFromHex(h.subject.color);

    final (String dueText, Color whenColor) = switch (h.status) {
      HomeworkStatus.corrected when h.score != null => (
        '${l10n.scoreLabel}${l10n.dotSeparator}${scoreText(h.score!)}/${h.maxScore}',
        Accent.violet.onSoft,
      ),
      HomeworkStatus.submitted || HomeworkStatus.late || HomeworkStatus.corrected when h.submittedAt != null => (
        l10n.sentOn(homeworkWhen(l10n, language, h.submittedAt!, now)),
        BrandColors.body,
      ),
      HomeworkStatus.missing => (l10n.dueLabel(homeworkWhen(l10n, language, h.deadlineAt, now)), Accent.red.onSoft),
      null => (l10n.readBefore(homeworkWhen(l10n, language, h.deadlineAt, now)), BrandColors.body),
      _ => (
        l10n.dueLabel(homeworkWhen(l10n, language, h.deadlineAt, now)),
        deadlineIsNear(h.deadlineAt, now) ? Accent.orange.onSoft : BrandColors.body,
      ),
    };

    return HoverCard(
      radius: AppRadii.tile,
      padding: const EdgeInsets.all(14),
      onTap: () => _open(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
            child: Icon(LucideIcons.clipboardList, size: 20, color: color.computeLuminance() > 0.5 ? BrandColors.ink : color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(h.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.style(16, FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    HomeworkStatusChip(h.status),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    h.subject.name.of(language),
                    if (h.mode == SubmissionMode.none) l10n.nothingToSubmit.toLowerCase(),
                  ].join(l10n.dotSeparator),
                  style: text.style(14, FontWeight.w500, color: BrandColors.slate),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(LucideIcons.calendarClock, size: 16, color: whenColor),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(dueText, style: text.style(14, FontWeight.w700, color: whenColor)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
