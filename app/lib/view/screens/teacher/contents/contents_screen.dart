import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/tunis_time.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/content.dart';
import '../../../../domain/model/group.dart';
import '../../../../domain/model/reference.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/common/load_status.dart';
import '../../../stateManager/groups/groups_cubit.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/library/library_cubit.dart';
import '../../../stateManager/reference/reference_cubit.dart';
import '../../../stateManager/share/share_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/classmates.dart';
import '../../../widgets/content_widgets.dart';
import '../../../widgets/controls.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/page_frame.dart';
import '../../../widgets/panels.dart';
import '../../../widgets/school_widgets.dart';
import '../homework/assign_panel.dart';
import 'chapter_dialog.dart';
import 'document_form_panel.dart';
import 'share_dialog.dart';

/// Contenus (design `Contenus.png`, phones `ContenusPhone.png`): the tree subject > level > chapter,
/// and the documents of the chosen place.
class ContentsScreen extends StatelessWidget {
  const ContentsScreen({super.key, this.chapterId});

  /// Opened on this chapter (from the search).
  final String? chapterId;

  @override
  Widget build(BuildContext context) => BlocProvider(create: (_) => sl.get<LibraryCubit>()..load(chapterId: chapterId), child: const ContentsView());
}

/// Two columns from this content width; below, a place picker and cards.
const _wideFrom = 900.0;

class ContentsView extends StatelessWidget {
  const ContentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final phone = isPhone(context);
    final state = context.watch<LibraryCubit>().state;
    final place = state.place;

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
              Text(l10n.navContents, style: text.pageTitle(phone: phone)),
              const SizedBox(height: 6),
              Text(l10n.contentsSubtitle, style: text.style(15, FontWeight.w500, color: BrandColors.body, height: 1.5)),
            ],
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            TonalButton(
              label: l10n.newChapter,
              icon: LucideIcons.folderPlus,
              height: 44,
              onPressed: () => showChapterDialog(context, subjectId: place?.subjectId, levelId: place?.levelId),
            ),
            PrimaryButton(
              label: phone ? l10n.importShort : l10n.importDocument,
              icon: LucideIcons.upload,
              height: 44,
              onPressed: () => _upload(context),
            ),
          ],
        ),
      ],
    );

    final List<Widget> body;
    if (state.status == LoadStatus.failure && state.isEmpty) {
      body = [FailureBanner(state.failure!, onRetry: context.read<LibraryCubit>().load)];
    } else if (state.status == LoadStatus.loading && state.isEmpty) {
      body = [const LinearProgressIndicator(minHeight: 3)];
    } else if (state.isEmpty) {
      body = [
        SectionCard(
          child: EmptyState(
            message: l10n.libraryEmptyTitle,
            scale: 0.5,
            action: Column(
              children: [
                Text(
                  l10n.libraryEmptyHint,
                  textAlign: TextAlign.center,
                  style: text.style(13, FontWeight.w500, color: BrandColors.slate, height: 1.5),
                ),
                const SizedBox(height: 16),
                PrimaryButton(label: l10n.importDocument, icon: LucideIcons.upload, height: 44, onPressed: () => _upload(context)),
              ],
            ),
          ),
        ),
      ];
    } else {
      body = [
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= _wideFrom
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 300, child: _LibraryTree()),
                    const SizedBox(width: 24),
                    Expanded(child: _PlaceCard(wide: constraints.maxWidth >= 1100)),
                  ],
                )
              : const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [_PlacePicker(), SizedBox(height: 16), _PlaceCard(wide: false)],
                ),
        ),
      ];
    }
    return PageScroll(children: [header, ...body]);
  }

  static Future<void> _upload(BuildContext context) async {
    final saved = await DocumentFormPanel.upload(context);
    if (saved != null && context.mounted) showNotice(context, AppLocalizations.of(context).documentUploaded);
  }
}

/// Desktop: subjects, the levels that hold something, and the chapters of the open level.
class _LibraryTree extends StatelessWidget {
  const _LibraryTree();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = context.watch<LanguageCubit>().state;
    final reference = context.watch<ReferenceCubit>().state.reference;
    final state = context.watch<LibraryCubit>().state;
    final cubit = context.read<LibraryCubit>();
    final place = state.place;
    final levelOrder = [for (final l in reference?.levels ?? const <Level>[]) l.id];
    final subjects = reference?.subjects ?? const <Subject>[];

    final children = <Widget>[];
    for (final (i, subject) in subjects.indexed) {
      final open = place?.subjectId == subject.id;
      if (i > 0) children.add(const Divider(height: 12, color: BrandColors.rowDivider));
      children.add(
        _TreeRow(
          leading: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: colorFromHex(subject.color), borderRadius: BorderRadius.circular(4)),
          ),
          label: subject.name.of(language),
          count: state.countSubject(subject.id),
          strong: true,
          trailing: open ? LucideIcons.chevronDown : LucideIcons.chevronRightDir,
          onTap: () => cubit.selectSubject(subject.id, levelOrder),
        ),
      );
      if (!open) continue;
      final levels = state.levelsOf(subject.id);
      for (final level in reference!.levels.where((l) => levels.contains(l.id) || l.id == place?.levelId)) {
        final levelOpen = place?.levelId == level.id;
        children.add(
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6),
            child: _TreeRow(
              leading: Icon(levelOpen ? LucideIcons.chevronDown : LucideIcons.chevronRightDir, size: 16, color: BrandColors.body),
              label: level.name.of(language),
              count: state.countLevel(subject.id, level.id),
              onTap: () => cubit.selectLevel(subject.id, level.id),
            ),
          ),
        );
        if (!levelOpen) continue;
        final chapters = state.chaptersOf(subject.id, level.id);
        for (final chapter in chapters) {
          children.add(
            _ChapterRow(
              label: chapter.title,
              count: state.countChapter(chapter.id),
              selected: place?.chapterId == chapter.id,
              onTap: () => cubit.select(LibraryPlace(subjectId: subject.id, levelId: level.id, chapterId: chapter.id)),
            ),
          );
        }
        final unfiled = state.countUnfiled(subject.id, level.id);
        if (unfiled > 0 || chapters.isEmpty) {
          children.add(
            _ChapterRow(
              label: l10n.unfiled,
              count: unfiled,
              quiet: true,
              selected: place?.chapterId == null,
              onTap: () => cubit.select(LibraryPlace(subjectId: subject.id, levelId: level.id)),
            ),
          );
        }
      }
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...children,
          const Divider(height: 20, color: BrandColors.rowDivider),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: GhostButton(
              label: l10n.newChapter,
              icon: LucideIcons.folderPlus,
              height: 38,
              onPressed: () => showChapterDialog(context, subjectId: place?.subjectId, levelId: place?.levelId),
            ),
          ),
        ],
      ),
    );
  }
}

class _TreeRow extends StatelessWidget {
  const _TreeRow({
    required this.leading,
    required this.label,
    required this.count,
    required this.onTap,
    this.trailing,
    this.strong = false,
  });

  final Widget leading;
  final String label;
  final int count;
  final VoidCallback onTap;
  final IconData? trailing;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: strong ? 10 : 8),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: strong ? text.style(15, FontWeight.w800) : text.style(13, FontWeight.w700, color: BrandColors.body),
              ),
            ),
            Text('$count', textDirection: TextDirection.ltr, style: text.caption),
            if (trailing != null) ...[const SizedBox(width: 6), Icon(trailing, size: 16, color: BrandColors.slate)],
          ],
        ),
      ),
    );
  }
}

class _ChapterRow extends StatelessWidget {
  const _ChapterRow({required this.label, required this.count, required this.selected, required this.onTap, this.quiet = false});

  final String label;
  final int count;
  final bool selected;
  final bool quiet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 24, bottom: 2),
      child: Material(
        color: selected ? BrandColors.indigoSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 10, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.style(
                      14,
                      selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? BrandColors.indigo : (quiet ? BrandColors.slate : BrandColors.ink),
                    ),
                  ),
                ),
                Text('$count', textDirection: TextDirection.ltr, style: text.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Phones and narrow windows: subject and level in one menu, then the chapters as chips.
class _PlacePicker extends StatelessWidget {
  const _PlacePicker();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final reference = context.watch<ReferenceCubit>().state.reference;
    final state = context.watch<LibraryCubit>().state;
    final cubit = context.read<LibraryCubit>();
    final place = state.place;
    final levelOrder = [for (final l in reference?.levels ?? const <Level>[]) l.id];

    final options = <SelectOption<String>>[];
    for (final subject in reference?.subjects ?? const <Subject>[]) {
      final dot = Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: colorFromHex(subject.color), borderRadius: BorderRadius.circular(4)),
      );
      final levels = [
        for (final l in reference!.levels)
          if (state.levelsOf(subject.id).contains(l.id)) l,
      ];
      if (levels.isEmpty) options.add(SelectOption(subject.id, subject.name.of(language), leading: dot));
      for (final level in levels) {
        options.add(
          SelectOption(
            '${subject.id}|${level.id}',
            '${subject.name.of(language)}${l10n.dotSeparator}${level.name.of(language)}',
            leading: dot,
          ),
        );
      }
    }
    final value = place == null ? null : (place.levelId == null ? place.subjectId : '${place.subjectId}|${place.levelId}');
    final chips = <(String?, String, int)>[];
    if (place?.levelId != null) {
      for (final c in state.chaptersOf(place!.subjectId, place.levelId!)) {
        chips.add((c.id, c.title, state.countChapter(c.id)));
      }
      final unfiled = state.countUnfiled(place.subjectId, place.levelId!);
      if (unfiled > 0 || chips.isEmpty) chips.add((null, l10n.unfiled, unfiled));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SelectField<String>(
          hint: l10n.chooseSubject,
          value: options.any((o) => o.value == value) ? value : null,
          onChanged: (v) {
            final parts = v.split('|');
            if (parts.length == 2) return cubit.selectLevel(parts[0], parts[1]);
            cubit.selectSubject(parts[0], levelOrder);
          },
          options: options,
        ),
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (id, label, count) in chips)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text('$label  $count'),
                      selected: place?.chapterId == id,
                      showCheckmark: false,
                      selectedColor: BrandColors.ink,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: place?.chapterId == id ? BrandColors.ink : BrandColors.line),
                      labelStyle: text.style(13, FontWeight.w700, color: place?.chapterId == id ? Colors.white : BrandColors.ink),
                      onSelected: (_) => cubit.select(LibraryPlace(subjectId: place!.subjectId, levelId: place.levelId, chapterId: id)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// The chosen chapter (or "Sans chapitre"): its header, the filters, then the documents.
class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final phone = isPhone(context);
    final language = context.watch<LanguageCubit>().state;
    final reference = context.watch<ReferenceCubit>().state.reference;
    final state = context.watch<LibraryCubit>().state;
    final cubit = context.read<LibraryCubit>();
    final place = state.place;
    final subject = reference?.subjects.where((s) => s.id == place?.subjectId).firstOrNull;
    final level = reference?.levels.where((l) => l.id == place?.levelId).firstOrNull;
    final chapter = state.chapter;

    if (place == null || place.levelId == null) {
      return SectionCard(
        child: EmptyState(
          message: l10n.subjectEmpty,
          scale: 0.45,
          action: PrimaryButton(
            label: l10n.importDocument,
            icon: LucideIcons.upload,
            height: 44,
            onPressed: () => ContentsView._upload(context),
          ),
        ),
      );
    }

    final overline = [if (subject != null) subject.name.of(language), if (level != null) level.name.of(language)].join(l10n.dotSeparator);
    final heading = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text.upper(overline), style: text.overline(size: 11)),
              const SizedBox(height: 4),
              Text(chapter?.title ?? l10n.unfiled, style: text.style(phone ? 19 : 22, FontWeight.w800)),
              if (chapter != null && chapter.sharedGroupIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                _SharedSquares(groupIds: chapter.sharedGroupIds),
              ],
            ],
          ),
        ),
        if (chapter != null) ...[
          if (!phone) ...[
            TonalButton(label: l10n.shareChapter, icon: LucideIcons.share2, onPressed: () => _shareChapter(context, chapter)),
            const SizedBox(width: 8),
          ],
          _ChapterMenu(chapter: chapter, onShare: () => _shareChapter(context, chapter)),
        ],
      ],
    );

    final filters = Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SearchBox(hint: l10n.searchTitle, initialValue: state.query, width: phone ? double.infinity : 280, onChanged: cubit.search),
        FilterMenuButton<ContentTag?>(
          label: state.tag == null ? l10n.tagAll : l10n.tagFilter(tagLabel(l10n, state.tag!)),
          value: state.tag,
          onChanged: cubit.filterTag,
          options: [SelectOption(null, l10n.tagAll), for (final t in ContentTag.values) SelectOption(t, tagLabel(l10n, t))],
        ),
        FilterMenuButton<ContentStatus?>(
          label: state.documentStatus == null
              ? l10n.statusAll
              : l10n.statusFilter(state.documentStatus == ContentStatus.draft ? l10n.statusDraft : l10n.statusPublished),
          value: state.documentStatus,
          onChanged: cubit.filterStatus,
          options: [
            SelectOption(null, l10n.statusAll),
            SelectOption(ContentStatus.published, l10n.statusPublished),
            SelectOption(ContentStatus.draft, l10n.statusDraft),
          ],
        ),
        Text(l10n.documentsCount(state.visible.length), style: text.style(13, FontWeight.w600, color: BrandColors.slate)),
      ],
    );

    final documents = state.visible;
    final Widget list;
    if (state.placeCount == 0) {
      list = EmptyState(
        message: l10n.chapterEmpty,
        scale: 0.4,
        action: PrimaryButton(
          label: l10n.importDocument,
          icon: LucideIcons.upload,
          height: 44,
          onPressed: () => ContentsView._upload(context),
        ),
      );
    } else if (documents.isEmpty) {
      list = EmptyState(message: l10n.noResults, scale: 0.35);
    } else if (wide) {
      list = Column(
        children: [
          const _TableHeader(),
          for (final (i, d) in documents.indexed)
            FadeRise(
              index: i,
              child: _DocumentRow(document: d, first: i == 0),
            ),
        ],
      );
    } else {
      list = Column(
        children: [
          for (final (i, d) in documents.indexed)
            FadeRise(
              index: i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DocumentCard(document: d),
              ),
            ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.all(phone ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [heading, const SizedBox(height: 18), filters, const SizedBox(height: 12), list],
      ),
    );
  }

  static Future<void> _shareChapter(BuildContext context, Chapter chapter) async {
    final library = context.read<LibraryCubit>();
    final saved = await showShareDialog(context, ChapterTarget(chapter));
    if (saved is Chapter) {
      library.chapterSaved(saved);
      if (context.mounted) showNotice(context, AppLocalizations.of(context).shareSaved);
    }
  }
}

class _ChapterMenu extends StatelessWidget {
  const _ChapterMenu({required this.chapter, required this.onShare});

  final Chapter chapter;
  final VoidCallback onShare;

  Future<void> _delete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmAction(
      context,
      title: l10n.deleteChapterTitle(chapter.title),
      text: l10n.deleteChapterText,
      confirmLabel: l10n.delete,
      icon: LucideIcons.trash2,
    );
    if (!ok || !context.mounted) return;
    final failure = await context.read<LibraryCubit>().deleteChapter(chapter);
    if (context.mounted) showNotice(context, failure == null ? l10n.chapterDeleted : failureText(l10n, failure));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phone = isPhone(context);
    return MenuAnchor(
      menuChildren: [
        if (phone)
          MenuItemButton(leadingIcon: const Icon(LucideIcons.share2, size: 16), onPressed: onShare, child: Text(l10n.shareChapter)),
        MenuItemButton(
          leadingIcon: const Icon(LucideIcons.pencil, size: 16),
          onPressed: () => showChapterDialog(context, editing: chapter),
          child: Text(l10n.renameChapter),
        ),
        MenuItemButton(
          leadingIcon: Icon(LucideIcons.trash2, size: 16, color: Accent.red.onSoft),
          onPressed: () => _delete(context),
          child: Text(l10n.deleteChapter, style: TextStyle(color: Accent.red.onSoft)),
        ),
      ],
      builder: (context, controller, _) => IconSquareButton(
        icon: LucideIcons.ellipsis,
        tooltip: l10n.chapterActions,
        size: 40,
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final style = text.overline(size: 11);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: BrandColors.rowDivider)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 54),
          Expanded(child: Text(text.upper(l10n.columnDocument), style: style)),
          SizedBox(width: 100, child: Text(text.upper(l10n.columnTag), style: style)),
          SizedBox(width: 110, child: Text(text.upper(l10n.columnStatus), style: style)),
          SizedBox(width: 120, child: Text(text.upper(l10n.columnSharedWith), style: style)),
          SizedBox(width: 84, child: Text(text.upper(l10n.columnEdited), style: style)),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

/// Wide: one line per document; a tap opens it.
class _DocumentRow extends StatelessWidget {
  const _DocumentRow({required this.document, required this.first});

  final ContentDocument document;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    return InkWell(
      onTap: () => _open(context, document),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: first ? null : const Border(top: BorderSide(color: BrandColors.rowDivider)),
        ),
        child: Row(
          children: [
            KindBadge(kind: document.kind),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(document.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.rowTitle),
                  const SizedBox(height: 2),
                  Text(
                    documentDetail(l10n, document),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 100,
              child: Align(alignment: AlignmentDirectional.centerStart, child: TagChip(document.tag)),
            ),
            SizedBox(
              width: 110,
              child: Align(alignment: AlignmentDirectional.centerStart, child: DocumentStatusChip(document.status)),
            ),
            SizedBox(width: 120, child: _SharedSquares(groupIds: document.sharedGroupIds)),
            SizedBox(
              width: 84,
              child: Text(
                editedLabel(l10n, language, document.updatedAt, sl.get<Now>()()),
                style: text.style(13, FontWeight.w500, color: BrandColors.slate),
              ),
            ),
            SizedBox(width: 44, child: _DocumentMenu(document: document)),
          ],
        ),
      ),
    );
  }
}

/// Narrow: the same facts in a card.
class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document});

  final ContentDocument document;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    return HoverCard(
      radius: AppRadii.tile,
      padding: const EdgeInsets.all(14),
      onTap: () => _open(context, document),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KindBadge(kind: document.kind),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(document.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.style(15, FontWeight.w700)),
                const SizedBox(height: 2),
                Text(documentDetail(l10n, document), style: text.style(13, FontWeight.w500, color: BrandColors.slate)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TagChip(document.tag),
                    if (!document.published) DocumentStatusChip(document.status),
                    if (document.sharedGroupIds.isNotEmpty) _SharedSquares(groupIds: document.sharedGroupIds),
                  ],
                ),
              ],
            ),
          ),
          _DocumentMenu(document: document),
        ],
      ),
    );
  }
}

void _open(BuildContext context, ContentDocument document) => context.push(Routes.teacherDocument(document.id));

/// The groups a document or chapter is shared with, as their squares; "Non partagé" otherwise.
class _SharedSquares extends StatelessWidget {
  const _SharedSquares({required this.groupIds});

  final List<String> groupIds;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final groups = context.watch<GroupsCubit>().state.groups;
    final shared = [for (final id in groupIds) ?groups.where((g) => g.id == id).firstOrNull];
    if (shared.isEmpty) return Text(l10n.notShared, style: text.style(13, FontWeight.w500, color: BrandColors.slate));
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final Group g in shared)
          Tooltip(
            message: g.name,
            child: GroupSquare(code: g.code, color: g.color),
          ),
      ],
    );
  }
}

class _DocumentMenu extends StatelessWidget {
  const _DocumentMenu({required this.document});

  final ContentDocument document;

  Future<void> _share(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    if (!document.published) return showNotice(context, l10n.draftCannotShare);
    final library = context.read<LibraryCubit>();
    final saved = await showShareDialog(context, DocumentTarget(document));
    if (saved is ContentDocument) {
      library.documentSaved(saved);
      if (context.mounted) showNotice(context, l10n.shareSaved);
    }
  }

  Future<void> _assign(BuildContext context) async {
    final saved = await AssignPanel.open(context, contentItemId: document.id);
    if (saved != null && context.mounted) showNotice(context, AppLocalizations.of(context).homeworkGiven);
  }

  Future<void> _edit(BuildContext context) async {
    final saved = await DocumentFormPanel.edit(context, document);
    if (saved != null && context.mounted) showNotice(context, AppLocalizations.of(context).detailsSaved);
  }

  Future<void> _archive(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmAction(
      context,
      title: l10n.archiveDocumentTitle(document.title),
      text: l10n.archiveDocumentText,
      confirmLabel: l10n.archive,
      icon: LucideIcons.archive,
    );
    if (!ok || !context.mounted) return;
    final failure = await context.read<LibraryCubit>().archive(document);
    if (context.mounted) showNotice(context, failure == null ? l10n.documentArchived : failureText(l10n, failure));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(LucideIcons.eye, size: 16),
          onPressed: () => _open(context, document),
          child: Text(l10n.actionOpen),
        ),
        MenuItemButton(
          leadingIcon: const Icon(LucideIcons.share2, size: 16),
          onPressed: () => _share(context),
          child: Text(l10n.actionShare),
        ),
        // Only a published document can be given (the server refuses a draft too).
        if (document.published)
          MenuItemButton(
            leadingIcon: const Icon(LucideIcons.clipboardList, size: 16),
            onPressed: () => _assign(context),
            child: Text(l10n.giveAsHomework),
          ),
        MenuItemButton(
          leadingIcon: const Icon(LucideIcons.pencil, size: 16),
          onPressed: () => _edit(context),
          child: Text(l10n.actionEditDetails),
        ),
        MenuItemButton(
          leadingIcon: Icon(LucideIcons.archive, size: 16, color: Accent.red.onSoft),
          onPressed: () => _archive(context),
          child: Text(l10n.archive, style: TextStyle(color: Accent.red.onSoft)),
        ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: l10n.documentActions,
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
        icon: const Icon(LucideIcons.ellipsis, size: 20, color: BrandColors.slate),
      ),
    );
  }
}
