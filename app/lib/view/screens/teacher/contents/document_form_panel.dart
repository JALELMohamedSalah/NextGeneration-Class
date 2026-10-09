import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/content.dart';
import '../../../../domain/model/group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/document_form/document_form_cubit.dart';
import '../../../stateManager/groups/groups_cubit.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/library/library_cubit.dart';
import '../../../stateManager/reference/reference_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/content_widgets.dart';
import '../../../widgets/controls.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/page_frame.dart';
import '../../../widgets/panels.dart';
import '../../../widgets/school_widgets.dart';
import '../../../widgets/text_field.dart';
import 'chapter_dialog.dart';
import 'scan_screen.dart';

/// The "Sans chapitre" and "+ Nouveau chapitre" entries of the chapter menu.
const _unfiled = '__unfiled__';
const _newChapter = '__new_chapter__';

/// "Importer un document" (design `Importer.png`) and "Modifier les détails". The saved document goes
/// to the library, which shows its place.
class DocumentFormPanel extends StatelessWidget {
  const DocumentFormPanel({super.key});

  /// From Contenus (its library and place), or from anywhere with a [library] of its own ("Créer › Importer").
  static Future<ContentDocument?> upload(BuildContext context, {LibraryCubit? library}) {
    final place = (library ?? context.read<LibraryCubit>()).state.place;
    return _open(
      context,
      (_) =>
          DocumentFormCubit.upload(sl.get(), sl.get(), subjectId: place?.subjectId, levelId: place?.levelId, chapterId: place?.chapterId),
      given: library,
    );
  }

  static Future<ContentDocument?> edit(BuildContext context, ContentDocument document) =>
      _open(context, (_) => DocumentFormCubit.edit(sl.get(), sl.get(), document));

  static Future<ContentDocument?> _open(BuildContext context, DocumentFormCubit Function(BuildContext) create, {LibraryCubit? given}) async {
    final library = given ?? context.read<LibraryCubit>();
    final reference = context.read<ReferenceCubit>();
    final groups = context.read<GroupsCubit>();
    final saved = await showSidePanel<ContentDocument>(
      context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: library),
          BlocProvider.value(value: reference),
          BlocProvider.value(value: groups),
          BlocProvider(create: create),
        ],
        child: const DocumentFormPanel(),
      ),
    );
    if (saved != null) library.documentSaved(saved);
    return saved;
  }

  Future<void> _submit(BuildContext context) async {
    final saved = await context.read<DocumentFormCubit>().submit();
    if (saved != null && context.mounted) Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = context.watch<LanguageCubit>().state;
    final reference = context.watch<ReferenceCubit>().state.reference;
    final library = context.watch<LibraryCubit>().state;
    final state = context.watch<DocumentFormCubit>().state;
    final cubit = context.read<DocumentFormCubit>();
    final errors = state.errors;
    final chapters = state.subjectId == null || state.levelId == null
        ? const <Chapter>[]
        : library.chaptersOf(state.subjectId!, state.levelId!);

    final subject = SelectField<String>(
      label: l10n.subject,
      hint: l10n.chooseSubject,
      value: state.subjectId,
      onChanged: cubit.setSubject,
      errorText: errors.contains(DocumentFormError.subject) ? l10n.fieldRequired : null,
      options: [
        for (final s in reference?.subjects ?? const [])
          SelectOption(
            s.id,
            s.name.of(language),
            leading: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: colorFromHex(s.color), shape: BoxShape.circle),
            ),
          ),
      ],
    );
    final level = SelectField<String>(
      label: l10n.level,
      hint: l10n.chooseLevel,
      value: state.levelId,
      onChanged: cubit.setLevel,
      errorText: errors.contains(DocumentFormError.level) ? l10n.fieldRequired : null,
      options: [for (final level in reference?.levels ?? const []) SelectOption(level.id, level.name.of(language))],
    );

    return SidePanel(
      icon: state.isEditing ? LucideIcons.pencil : LucideIcons.upload,
      title: state.isEditing ? l10n.actionEditDetails : l10n.importDocument,
      subtitle: state.isEditing ? l10n.editDetailsSubtitle : l10n.importSubtitle,
      actions: [
        GhostButton(label: l10n.cancel, onPressed: () => Navigator.of(context).maybePop()),
        PrimaryButton(
          label: state.isEditing ? l10n.save : l10n.importShort,
          icon: state.isEditing ? null : LucideIcons.upload,
          height: 44,
          loading: state.submitting,
          onPressed: () => _submit(context),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.failure != null) ...[FailureBanner(state.failure!), const SizedBox(height: 20)],
          if (!state.isEditing) ...[const _FileBox(), const SizedBox(height: 20)],
          FormInput(
            label: l10n.documentTitle,
            hint: l10n.documentTitleHint,
            helper: l10n.documentTitleHelper,
            initialValue: state.title,
            onChanged: cubit.setTitle,
            errorText: errors.contains(DocumentFormError.title) ? l10n.fieldRequired : null,
          ),
          const SizedBox(height: 20),
          if (isPhone(context)) ...[
            subject,
            const SizedBox(height: 20),
            level,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: subject),
                const SizedBox(width: 12),
                Expanded(child: level),
              ],
            ),
          const SizedBox(height: 20),
          SelectField<String>(
            label: l10n.chapter,
            hint: l10n.unfiled,
            value: state.chapterId,
            onChanged: (id) async {
              if (id == _unfiled) return cubit.setChapter(null);
              if (id != _newChapter) return cubit.setChapter(id);
              final chapter = await showChapterDialog(context, subjectId: state.subjectId, levelId: state.levelId);
              if (chapter == null) return;
              if (chapter.subjectId != state.subjectId) cubit.setSubject(chapter.subjectId);
              if (chapter.levelId != state.levelId) cubit.setLevel(chapter.levelId);
              cubit.setChapter(chapter.id);
            },
            options: [
              for (final c in chapters) SelectOption(c.id, c.title),
              SelectOption(_unfiled, l10n.unfiled),
              SelectOption(_newChapter, l10n.newChapter, leading: const Icon(LucideIcons.plus, size: 16, color: BrandColors.indigo)),
            ],
          ),
          const SizedBox(height: 20),
          LabeledField(
            label: l10n.tag,
            child: SegmentedChoice<ContentTag>(
              value: state.tag,
              onChanged: cubit.setTag,
              options: [for (final tag in ContentTag.values) SelectOption(tag, tagLabel(l10n, tag))],
            ),
          ),
          if (!state.isEditing && !state.draft) ...[const SizedBox(height: 20), _ShareChoices(levelId: state.levelId)],
          const SizedBox(height: 20),
          _DraftSwitch(value: state.draft, onChanged: cubit.setDraft),
        ],
      ),
    );
  }
}

/// The chosen file, or the button to choose one; its problem (type, size) is said before any upload.
class _FileBox extends StatelessWidget {
  const _FileBox();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final state = context.watch<DocumentFormCubit>().state;
    final cubit = context.read<DocumentFormCubit>();
    final file = state.file;
    final problem = switch (state.fileProblem) {
      FileProblem.unsupported => l10n.fileUnsupported,
      FileProblem.tooLarge => l10n.fileTooLarge,
      FileProblem.empty => l10n.fileEmpty,
      null => state.errors.contains(DocumentFormError.file) && file == null ? l10n.fileRequired : null,
    };
    final progress = state.progress;
    final box = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5FC),
        borderRadius: BorderRadius.circular(AppRadii.row),
        border: Border.all(color: problem != null ? Accent.red.strong : const Color(0xFF9AA3D9), width: 1.5),
      ),
      child: file == null
          ? const SizedBox.shrink()
          : Row(
              children: [
                KindBadge(kind: _kindOf(file)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr, style: text.rowTitle),
                      const SizedBox(height: 2),
                      Text(
                        [kindLabel(l10n, _kindOf(file)), fileSize(l10n, file.size)].join(l10n.dotSeparator),
                        style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                      ),
                      if (progress != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFDCE0F5),
                            color: Accent.green.strong,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.uploadProgress((progress * 100).round()),
                          style: text.style(12, FontWeight.w600, color: BrandColors.slate),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!state.submitting) GhostButton(label: l10n.changeFile, height: 38, onPressed: cubit.pickFile),
              ],
            ),
    );
    // No file yet: a file from the device, or sheets to scan (design `r2/Scanner.png`, screen 1).
    final choices = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _Choice(
              icon: LucideIcons.folderOpen,
              accent: Accent.indigo,
              title: l10n.chooseFile,
              subtitle: l10n.fileTypesShort,
              dashed: true,
              error: problem != null,
              onTap: cubit.pickFile,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Choice(
              icon: LucideIcons.camera,
              accent: Accent.turquoise,
              title: l10n.scanSheets,
              subtitle: l10n.scanSheetsHint,
              onTap: () async {
                final scanned = await ScanScreen.open(context);
                if (scanned != null) cubit.useFile(scanned);
              },
            ),
          ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (file == null) choices else box,
        if (problem != null) ...[
          const SizedBox(height: 6),
          Text(problem, style: text.style(12, FontWeight.w600, color: Accent.red.onSoft)),
        ],
      ],
    );
  }

  static FileKind _kindOf(PickedFile file) => switch (file.extension) {
    'pdf' => FileKind.pdf,
    'docx' => FileKind.word,
    _ => FileKind.image,
  };
}

/// One way to bring a document in: a tile with an icon, a title and what it takes.
class _Choice extends StatelessWidget {
  const _Choice({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.dashed = false,
    this.error = false,
  });

  final IconData icon;
  final Accent accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool dashed;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Material(
      color: dashed ? const Color(0xFFF4F5FC) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.row),
        side: BorderSide(color: error ? Accent.red.strong : (dashed ? const Color(0xFF9AA3D9) : BrandColors.indigo), width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.row),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Column(
            children: [
              IconBadge(icon: icon, accent: accent),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: text.style(14, FontWeight.w800, color: accent.onSoft),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: text.style(12, FontWeight.w500, color: BrandColors.slate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The groups to share with right away: those of the document's level first.
class _ShareChoices extends StatelessWidget {
  const _ShareChoices({required this.levelId});

  final String? levelId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final state = context.watch<DocumentFormCubit>().state;
    final cubit = context.read<DocumentFormCubit>();
    final groups = [...context.watch<GroupsCubit>().state.groups]
      ..sort((a, b) => (a.levelId == levelId ? 0 : 1).compareTo(b.levelId == levelId ? 0 : 1));
    return LabeledField(
      label: l10n.shareWith,
      labelSuffix: l10n.optional,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (groups.isEmpty)
            Text(l10n.noGroupsYet, style: text.style(13, FontWeight.w500, color: BrandColors.slate))
          else
            for (final g in groups) ...[
              _GroupTick(group: g, selected: state.groupIds.contains(g.id), onTap: () => cubit.toggleGroup(g.id)),
              const SizedBox(height: 8),
            ],
          Text(l10n.shareWithHint, style: text.style(12, FontWeight.w500, color: BrandColors.slate, height: 1.4)),
        ],
      ),
    );
  }
}

class _GroupTick extends StatelessWidget {
  const _GroupTick({required this.group, required this.selected, required this.onTap});

  final Group group;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    return Semantics(
      checked: selected,
      button: true,
      child: Material(
        color: selected ? const Color(0xFFF4F5FC) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: selected ? BrandColors.indigo : BrandColors.line, width: selected ? 1.5 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 14, 10),
            child: Row(
              children: [
                Icon(
                  selected ? LucideIcons.squareCheck : LucideIcons.square,
                  size: 20,
                  color: selected ? BrandColors.indigo : const Color(0xFFADB1C6),
                ),
                const SizedBox(width: 12),
                GroupSquare(code: group.code, color: group.color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(group.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.style(14, FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Text(l10n.studentsCount(group.memberCount), style: text.style(12, FontWeight.w500, color: BrandColors.slate)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DraftSwitch extends StatelessWidget {
  const _DraftSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 12, 12),
      decoration: BoxDecoration(
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.keepDraft, style: text.style(14, FontWeight.w700)),
                const SizedBox(height: 2),
                Text(l10n.keepDraftHint, style: text.style(12, FontWeight.w500, color: BrandColors.slate)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          BrandSwitch(value: value, onChanged: onChanged, label: l10n.keepDraft),
        ],
      ),
    );
  }
}
