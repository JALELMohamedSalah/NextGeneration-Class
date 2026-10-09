import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/l10n/formatting.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../domain/model/app_user.dart';
import '../../../domain/model/content.dart';
import '../../../l10n/app_localizations.dart';
import '../../stateManager/auth/auth_cubit.dart';
import '../../stateManager/common/load_status.dart';
import '../../stateManager/language/language_cubit.dart';
import '../../stateManager/my_contents/my_contents_cubit.dart';
import '../../widgets/cards.dart';
import '../../widgets/classmates.dart';
import '../../widgets/content_widgets.dart';
import '../../widgets/feedback.dart';
import '../../widgets/page_frame.dart';
import '../../widgets/school_widgets.dart';

/// Cours (design `r2/ContenusPhone.png`): a pupil's documents, or a parent's view of one child's, by
/// subject and chapter. "Nouveau" until opened.
class MyContentsScreen extends StatelessWidget {
  const MyContentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().user;
    final children = user?.role == UserRole.parent ? user!.children : const <ChildSummary>[];
    return BlocProvider(
      create: (_) => MyContentsCubit(sl.get())..load(studentId: children.firstOrNull?.studentId),
      child: const MyContentsView(),
    );
  }
}

class MyContentsView extends StatelessWidget {
  const MyContentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final phone = isPhone(context);
    final language = context.watch<LanguageCubit>().state;
    final user = context.watch<AuthCubit>().user;
    final parent = user?.role == UserRole.parent;
    final state = context.watch<MyContentsCubit>().state;
    final cubit = context.read<MyContentsCubit>();
    final child = parent ? user!.children.where((c) => c.studentId == state.studentId).firstOrNull : null;
    // A French first name inside an Arabic sentence keeps its place (core/l10n/formatting.dart).
    final name = isolated(child?.firstName ?? '');

    final chipStyle = text.style(14, FontWeight.w700);
    Widget pill(String label, bool selected, VoidCallback onTap) => Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: BrandColors.ink,
        backgroundColor: Colors.white,
        side: BorderSide(color: selected ? BrandColors.ink : BrandColors.line),
        labelStyle: chipStyle.copyWith(color: selected ? Colors.white : BrandColors.ink),
        onSelected: (_) => onTap(),
      ),
    );

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(parent ? l10n.parentCoursesTitle(name) : l10n.myCoursesTitle, style: text.pageTitle(phone: phone)),
        const SizedBox(height: 6),
        Text(
          parent ? l10n.parentCoursesSubtitle(name) : l10n.myCoursesSubtitle,
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
    if (state.status == LoadStatus.failure && state.documents.isEmpty) {
      body = [FailureBanner(state.failure!, onRetry: () => cubit.load(studentId: state.studentId))];
    } else if (state.status == LoadStatus.loading && state.documents.isEmpty) {
      body = [const LinearProgressIndicator(minHeight: 3)];
    } else if (state.documents.isEmpty) {
      body = [SectionCard(child: EmptyState(message: parent ? l10n.coursEmptyParent(name) : l10n.coursEmpty, scale: 0.45))];
    } else {
      final subjects = state.subjects;
      body = [
        if (subjects.length > 1)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                pill(l10n.allSubjects, state.subjectId == null, () => cubit.filterSubject(null)),
                for (final s in subjects) pill(s.name.of(language), state.subjectId == s.id, () => cubit.filterSubject(s.id)),
              ],
            ),
          ),
        for (final (i, section) in state.sections.indexed)
          FadeRise(
            index: i,
            child: _Section(section: section),
          ),
      ];
    }
    return PageScroll(maxWidth: familyPageWidth, gap: 20, children: [header, ...body]);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.section});

  final CoursSection section;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: colorFromHex(section.subject.color), borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text.upper(section.subject.name.of(language)), style: text.overline(color: BrandColors.body)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(section.chapter?.title ?? l10n.unfiled, style: text.style(19, FontWeight.w800)),
        const SizedBox(height: 10),
        CardColumns(gap: 10, children: [for (final document in section.documents) _DocumentTile(document: document)]),
        const SizedBox(height: 10),
      ],
    );
  }
}

/// A document to open: a size up for young readers, "Nouveau" until opened.
class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.document});

  final SharedDocument document;

  Future<void> _open(BuildContext context) async {
    final parent = context.read<AuthCubit>().user?.role == UserRole.parent;
    final cubit = context.read<MyContentsCubit>();
    await context.push(parent ? Routes.parentDocument(document.id) : Routes.studentDocument(document.id));
    cubit.opened(document.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    return HoverCard(
      radius: AppRadii.tile,
      padding: const EdgeInsets.all(14),
      onTap: () => _open(context),
      child: Row(
        children: [
          KindBadge(kind: document.kind),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(document.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.style(16, FontWeight.w700)),
                const SizedBox(height: 2),
                Text(sharedDetail(l10n, document), style: text.style(14, FontWeight.w500, color: BrandColors.slate)),
              ],
            ),
          ),
          if (document.isNew) ...[const SizedBox(width: 8), StatusChip(label: l10n.newBadge, accent: Accent.amber)],
        ],
      ),
    );
  }
}
