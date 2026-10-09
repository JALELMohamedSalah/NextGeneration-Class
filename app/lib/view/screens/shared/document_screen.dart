import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/di/injection.dart';
import '../../../core/l10n/formatting.dart';
import '../../../core/l10n/tunis_time.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../domain/model/content.dart';
import '../../../domain/model/content.dart' as model show DocumentView;
import '../../../domain/model/group.dart';
import '../../../l10n/app_localizations.dart';
import '../../stateManager/common/load_status.dart';
import '../../stateManager/document/document_cubit.dart';
import '../../stateManager/groups/groups_cubit.dart';
import '../../stateManager/language/language_cubit.dart';
import '../../stateManager/library/library_cubit.dart';
import '../../stateManager/reference/reference_cubit.dart';
import '../../stateManager/share/share_cubit.dart';
import '../../widgets/buttons.dart';
import '../../widgets/content_widgets.dart';
import '../../widgets/document_pages.dart';
import '../../widgets/feedback.dart';
import '../../widgets/page_frame.dart';
import '../../widgets/panels.dart';
import '../../widgets/school_widgets.dart';
import '../teacher/contents/document_form_panel.dart';
import '../teacher/contents/share_dialog.dart';

/// A document, full screen (design `Document.png`, phones `ContenusPhone.png`): page by page for PDFs
/// and photos, a download for Word. The teacher also gets the details, sharing and editing; for her the
/// route provides the library, her groups and the reference lists.
class DocumentScreen extends StatelessWidget {
  const DocumentScreen({super.key, required this.documentId, required this.backTo, this.teacher = false, this.loader});

  final String documentId;

  /// Opens something else than a library document: a pupil's work (spec 06).
  final Future<model.DocumentView> Function()? loader;

  /// Where "back" goes when the page was opened directly (no page to return to).
  final String backTo;
  final bool teacher;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => DocumentCubit(sl.get(), sl.get(), documentId, loader: loader)..load(),
    child: DocumentView(backTo: backTo, teacher: teacher),
  );
}

class DocumentView extends StatelessWidget {
  const DocumentView({super.key, required this.backTo, this.teacher = false});

  final String backTo;
  final bool teacher;

  void _back(BuildContext context) => context.canPop() ? context.pop() : context.go(backTo);

  Future<void> _download(BuildContext context) async {
    final ok = await context.read<DocumentCubit>().download();
    if (!ok && context.mounted) showNotice(context, AppLocalizations.of(context).downloadFailed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final phone = isPhone(context);
    final language = context.watch<LanguageCubit>().state;
    final state = context.watch<DocumentCubit>().state;
    final view = state.view;
    final documentId = context.read<DocumentCubit>().documentId;
    final ContentDocument? document = teacher ? context.select((LibraryCubit c) => c.state.document(documentId)) : null;

    final chapterTitle = view?.chapterTitle;
    final subtitle = view == null
        ? ''
        : [view.subjectName.of(language), if (chapterTitle != null) isolated(chapterTitle)].join(l10n.dotSeparator);
    final topBar = Container(
      padding: EdgeInsetsDirectional.fromSTEB(phone ? 12 : 24, 12, phone ? 12 : 24, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: BrandColors.line)),
      ),
      child: Row(
        children: [
          IconSquareButton(icon: LucideIcons.arrowLeftDir, tooltip: l10n.back, onPressed: () => _back(context)),
          const SizedBox(width: 12),
          if (view != null && !phone) ...[KindBadge(kind: view.kind), const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(view?.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: text.style(phone ? 16 : 18, FontWeight.w800)),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                  ),
              ],
            ),
          ),
          if (view != null) ...[
            const SizedBox(width: 8),
            if (!phone) TonalButton(label: l10n.download, icon: LucideIcons.download, height: 44, onPressed: () => _download(context)),
            if (teacher && document != null) ...[
              const SizedBox(width: 8),
              if (phone)
                IconSquareButton(icon: LucideIcons.share2, tooltip: l10n.actionShare, onPressed: () => _share(context, document))
              else
                PrimaryButton(label: l10n.actionShare, icon: LucideIcons.share2, height: 44, onPressed: () => _share(context, document)),
            ],
          ],
        ],
      ),
    );

    final Widget body;
    if (state.status == LoadStatus.failure) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FailureBanner(state.failure!, onRetry: context.read<DocumentCubit>().load),
        ),
      );
    } else if (view == null) {
      body = const Align(alignment: Alignment.topCenter, child: LinearProgressIndicator(minHeight: 3));
    } else if (view.pageUrls.isEmpty) {
      body = _WordNotice(onDownload: () => _download(context));
    } else {
      body = const DocumentPages();
    }

    final wideAside = teacher && document != null && MediaQuery.sizeOf(context).width >= Breakpoints.desktop;
    return Scaffold(
      backgroundColor: const Color(0xFFE9EBF3),
      body: SafeArea(
        child: Column(
          children: [
            topBar,
            Expanded(
              child: wideAside
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: body),
                        _DetailsAside(document: document, onChanged: context.read<DocumentCubit>().load),
                      ],
                    )
                  : body,
            ),
            if (phone && view != null) _PhoneBar(onDownload: () => _download(context)),
          ],
        ),
      ),
    );
  }

  static Future<void> _share(BuildContext context, ContentDocument document) async {
    final l10n = AppLocalizations.of(context);
    if (!document.published) return showNotice(context, l10n.draftCannotShare);
    final library = context.read<LibraryCubit>();
    final saved = await showShareDialog(context, DocumentTarget(document));
    if (saved is ContentDocument) {
      library.documentSaved(saved);
      if (context.mounted) showNotice(context, l10n.shareSaved);
    }
  }
}

/// Phones (design `r2/ContenusPhone.png`): the page buttons, then a big download button a child finds.
class _PhoneBar extends StatelessWidget {
  const _PhoneBar({required this.onDownload});

  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final state = context.watch<DocumentCubit>().state;
    final cubit = context.read<DocumentCubit>();
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: BrandColors.line)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.pageCount > 0) ...[
            Row(
              children: [
                IconSquareButton(
                  icon: LucideIcons.chevronLeftDir,
                  tooltip: l10n.previousPage,
                  size: 48,
                  onPressed: state.page > 0 ? cubit.previous : null,
                ),
                Expanded(
                  child: Text(
                    l10n.pageOf(state.page + 1, state.pageCount),
                    textAlign: TextAlign.center,
                    style: text.style(15, FontWeight.w700),
                  ),
                ),
                IconSquareButton(
                  icon: LucideIcons.chevronRightDir,
                  tooltip: l10n.nextPage,
                  size: 48,
                  onPressed: state.page < state.pageCount - 1 ? cubit.next : null,
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          TonalButton(label: l10n.download, icon: LucideIcons.download, height: 50, onPressed: onDownload),
        ],
      ),
    );
  }
}

class _WordNotice extends StatelessWidget {
  const _WordNotice({required this.onDownload});

  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: BrandColors.line),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const KindBadge(kind: FileKind.word),
                const SizedBox(height: 16),
                Text(l10n.wordNoPreview, textAlign: TextAlign.center, style: text.style(15, FontWeight.w600, height: 1.5)),
                const SizedBox(height: 20),
                PrimaryButton(label: l10n.download, icon: LucideIcons.download, height: 48, onPressed: onDownload),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The teacher's details beside the pages (wide screens).
class _DetailsAside extends StatelessWidget {
  const _DetailsAside({required this.document, required this.onChanged});

  final ContentDocument document;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final reference = context.watch<ReferenceCubit>().state.reference;
    final groups = context.watch<GroupsCubit>().state.groups;
    final chapter = context.select((LibraryCubit c) => c.state.library.chapters.where((ch) => ch.id == document.chapterId).firstOrNull);
    final subject = reference?.subjects.where((s) => s.id == document.subjectId).firstOrNull;
    final level = reference?.levels.where((l) => l.id == document.levelId).firstOrNull;
    final shared = [for (final id in document.sharedGroupIds) ?groups.where((g) => g.id == id).firstOrNull];

    Widget row(String label, Widget value) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: BrandColors.rowDivider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.caption),
          const SizedBox(height: 4),
          value,
        ],
      ),
    );
    Text value(String v) => Text(v, style: text.style(14, FontWeight.w600));

    return Container(
      width: 320,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.details, style: text.style(16, FontWeight.w800)),
            const SizedBox(height: 8),
            row(l10n.subject, value(subject?.name.of(language) ?? '')),
            row(l10n.level, value(level?.name.of(language) ?? '')),
            row(l10n.chapter, value(chapter?.title ?? l10n.unfiled)),
            row(l10n.tag, Align(alignment: AlignmentDirectional.centerStart, child: TagChip(document.tag))),
            row(l10n.columnStatus, Align(alignment: AlignmentDirectional.centerStart, child: DocumentStatusChip(document.status))),
            row(
              l10n.columnSharedWith,
              shared.isEmpty
                  ? value(l10n.notShared)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final Group g in shared)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                GroupSquare(code: g.code, color: g.color),
                                const SizedBox(width: 8),
                                Expanded(child: Text(g.name, style: text.style(14, FontWeight.w600))),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            row(
              l10n.detailFile,
              Text(
                [document.fileName, fileSize(l10n, document.sizeBytes)].join(l10n.dotSeparator),
                textDirection: TextDirection.ltr,
                style: text.style(14, FontWeight.w600),
              ),
            ),
            row(l10n.columnEdited, value(editedLabel(l10n, language, document.updatedAt, sl.get<Now>()()))),
            const SizedBox(height: 16),
            TonalButton(
              label: l10n.actionEditDetails,
              icon: LucideIcons.pencil,
              onPressed: () async {
                final saved = await DocumentFormPanel.edit(context, document);
                if (saved != null) {
                  onChanged();
                  if (context.mounted) showNotice(context, l10n.detailsSaved);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
