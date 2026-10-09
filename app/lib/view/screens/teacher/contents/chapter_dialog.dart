import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/content.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/library/library_cubit.dart';
import '../../../stateManager/reference/reference_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/controls.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/panels.dart';
import '../../../widgets/text_field.dart';

/// "Nouveau chapitre" in a subject and level (prefilled with where the teacher is), or, with
/// [editing], "Renommer le chapitre". Returns the saved chapter, or null when cancelled.
Future<Chapter?> showChapterDialog(BuildContext context, {Chapter? editing, String? subjectId, String? levelId}) {
  final library = context.read<LibraryCubit>();
  final reference = context.read<ReferenceCubit>();
  return showAppDialog<Chapter>(
    context,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: library),
        BlocProvider.value(value: reference),
      ],
      child: _ChapterDialog(editing: editing, subjectId: subjectId, levelId: levelId),
    ),
  );
}

class _ChapterDialog extends StatefulWidget {
  const _ChapterDialog({this.editing, this.subjectId, this.levelId});

  final Chapter? editing;
  final String? subjectId;
  final String? levelId;

  @override
  State<_ChapterDialog> createState() => _ChapterDialogState();
}

class _ChapterDialogState extends State<_ChapterDialog> {
  late String _title = widget.editing?.title ?? '';
  late String? _subjectId = widget.subjectId;
  late String? _levelId = widget.levelId;
  bool _showErrors = false;
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    if (_title.trim().isEmpty || (widget.editing == null && (_subjectId == null || _levelId == null))) {
      setState(() => _showErrors = true);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    final library = context.read<LibraryCubit>();
    final editing = widget.editing;
    if (editing != null) {
      final failure = await library.renameChapter(editing.id, _title);
      if (!mounted) return;
      if (failure == null) return Navigator.of(context).pop(editing.copyWith(title: _title.trim()));
      return setState(() {
        _saving = false;
        _error = failureText(l10n, failure);
      });
    }
    final (chapter, failure) = await library.createChapter(subjectId: _subjectId!, levelId: _levelId!, title: _title);
    if (!mounted) return;
    if (chapter != null) return Navigator.of(context).pop(chapter);
    setState(() {
      _saving = false;
      _error = failureText(l10n, failure!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = context.watch<LanguageCubit>().state;
    final reference = context.watch<ReferenceCubit>().state.reference;
    final editing = widget.editing;
    return AppDialog(
      icon: editing == null ? LucideIcons.folderPlus : LucideIcons.pencil,
      title: editing == null ? l10n.newChapter : l10n.renameChapter,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null) ...[ErrorBanner(message: _error!), const SizedBox(height: 16)],
          if (editing == null) ...[
            SelectField<String>(
              label: l10n.subject,
              hint: l10n.chooseSubject,
              value: _subjectId,
              onChanged: (id) => setState(() => _subjectId = id),
              errorText: _showErrors && _subjectId == null ? l10n.fieldRequired : null,
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
            ),
            const SizedBox(height: 16),
            SelectField<String>(
              label: l10n.level,
              hint: l10n.chooseLevel,
              value: _levelId,
              onChanged: (id) => setState(() => _levelId = id),
              errorText: _showErrors && _levelId == null ? l10n.fieldRequired : null,
              options: [for (final level in reference?.levels ?? const []) SelectOption(level.id, level.name.of(language))],
            ),
            const SizedBox(height: 16),
          ],
          FormInput(
            label: l10n.chapterTitle,
            hint: l10n.chapterTitleHint,
            initialValue: _title,
            autofocus: true,
            onChanged: (v) => setState(() {
              _title = v;
              _showErrors = false;
            }),
            onSubmitted: (_) => _save(),
            errorText: _showErrors && _title.trim().isEmpty ? l10n.fieldRequired : null,
          ),
        ],
      ),
      actions: [
        GhostButton(label: l10n.cancel, onPressed: () => Navigator.of(context).maybePop()),
        PrimaryButton(label: l10n.save, height: 44, loading: _saving, onPressed: _save),
      ],
    );
  }
}
