import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/tunis_time.dart';
import '../../../../core/network/api_failure.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/content.dart';
import '../../../../domain/model/evaluation.dart';
import '../../../../domain/repositories/content_repository.dart';
import '../../../../domain/repositories/evaluation_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/groups/groups_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/controls.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/panels.dart';
import '../../../widgets/school_widgets.dart';
import '../../../widgets/text_field.dart';

/// "Nouvelle évaluation" (design `r2/NouvelleEvaluation.png`), or "Modifier" an existing one (the group stays).
/// Returns the saved evaluation, or null when cancelled.
class EvaluationPanel extends StatefulWidget {
  const EvaluationPanel({super.key, this.editing, this.groupId});

  final Evaluation? editing;

  /// Opened from a group: that group first.
  final String? groupId;

  static Future<EvaluationDetail?> open(BuildContext context, {Evaluation? editing, String? groupId}) {
    final groups = context.read<GroupsCubit>();
    return showSidePanel<EvaluationDetail>(
      context,
      builder: (_) => BlocProvider.value(
        value: groups,
        child: EvaluationPanel(editing: editing, groupId: groupId),
      ),
    );
  }

  /// "Nouvelle évaluation" from a group's page or the "Créer" menu, then straight to its score table.
  /// True when one was created.
  static Future<bool> createAndGrade(BuildContext context, {String? groupId}) async {
    final router = GoRouter.of(context);
    final created = await open(context, groupId: groupId);
    if (created == null) return false;
    unawaited(router.push(Routes.teacherEvaluation(created.evaluation.id), extra: created));
    return true;
  }

  @override
  State<EvaluationPanel> createState() => _EvaluationPanelState();
}

/// The usual scales, and "Autre".
const _scales = [10, 20];

class _EvaluationPanelState extends State<EvaluationPanel> {
  late String? _groupId = widget.editing?.group.id ?? widget.groupId;
  late String _title = widget.editing?.title ?? '';
  late DateTime _heldOn = widget.editing?.heldOn ?? TunisTime.day(sl.get<Now>()());
  late int? _scale = widget.editing == null ? 20 : (_scales.contains(widget.editing!.maxScore) ? widget.editing!.maxScore : null);
  late String _otherScale = widget.editing != null && !_scales.contains(widget.editing!.maxScore) ? '${widget.editing!.maxScore}' : '';
  late String? _chapterId = widget.editing?.chapterId;
  List<Chapter> _chapters = const [];
  bool _tried = false;
  bool _saving = false;
  ApiFailure? _failure;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    try {
      final library = await sl.get<ContentRepository>().library();
      if (mounted) setState(() => _chapters = library.chapters);
    } on Object {
      // The chapter is optional: without the library, the field stays empty.
    }
  }

  int? get _maxScore => _scale ?? int.tryParse(_otherScale.trim());

  bool get _scaleValid => _maxScore != null && _maxScore! >= 1 && _maxScore! <= 100;

  Future<void> _submit() async {
    setState(() => _tried = true);
    if (_groupId == null || _title.trim().isEmpty || !_scaleValid) return;
    setState(() {
      _saving = true;
      _failure = null;
    });
    final draft = EvaluationDraft(groupId: _groupId!, title: _title, heldOn: _heldOn, maxScore: _maxScore!, chapterId: _chapterId);
    try {
      final repository = sl.get<EvaluationRepository>();
      final saved = widget.editing == null ? await repository.create(draft) : await repository.update(widget.editing!.id, draft);
      if (mounted) Navigator.of(context).pop(saved);
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _failure = ApiFailure.from(error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groups = context.watch<GroupsCubit>().state.groups;
    final group = groups.where((g) => g.id == _groupId).firstOrNull;
    // The chapters of the group's subject and level.
    final chapters = group == null
        ? const <Chapter>[]
        : _chapters.where((c) => c.subjectId == group.subjectId && c.levelId == group.levelId).toList();
    final editing = widget.editing != null;
    return SidePanel(
      icon: LucideIcons.clipboardCheck,
      accent: Accent.violet,
      title: editing ? l10n.editEvaluation : l10n.newEvaluation,
      subtitle: editing ? null : l10n.newEvaluationSubtitle,
      actions: [
        GhostButton(label: l10n.cancel, onPressed: () => Navigator.of(context).maybePop()),
        PrimaryButton(
          label: editing ? l10n.save : l10n.createAndGrade,
          icon: editing ? null : LucideIcons.keyboard,
          height: 44,
          loading: _saving,
          onPressed: _submit,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_failure != null) ...[FailureBanner(_failure!), const SizedBox(height: 20)],
          if (groups.isEmpty)
            InfoNote(text: l10n.noGroupsYet)
          else if (editing)
            LabeledField(
              label: l10n.group,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: GroupLabel(code: widget.editing!.group.code, color: widget.editing!.group.color, name: widget.editing!.group.name),
              ),
            )
          else
            SelectField<String>(
              label: l10n.group,
              hint: l10n.chooseGroup,
              value: _groupId,
              errorText: _tried && _groupId == null ? l10n.fieldRequired : null,
              onChanged: (id) => setState(() {
                _groupId = id;
                _chapterId = null;
              }),
              options: [
                for (final g in groups)
                  SelectOption(
                    g.id,
                    '${g.name}${l10n.dotSeparator}${l10n.studentsCount(g.memberCount)}',
                    leading: GroupSquare(code: g.code, color: g.color),
                  ),
              ],
            ),
          const SizedBox(height: 16),
          FormInput(
            label: l10n.documentTitle,
            hint: l10n.evaluationTitleHint,
            helper: l10n.evaluationTitleHelp,
            initialValue: _title,
            autofocus: !editing,
            errorText: _tried && _title.trim().isEmpty ? l10n.fieldRequired : null,
            onChanged: (v) => setState(() => _title = v),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final date = DateField(
                label: l10n.date,
                value: _heldOn,
                onChanged: (d) => setState(() => _heldOn = d),
                firstDate: DateTime(_heldOn.year - 1),
                lastDate: DateTime(_heldOn.year + 1, 12, 31),
              );
              final scale = LabeledField(
                label: l10n.notedOn,
                child: SegmentedChoice<int?>(
                  value: _scale,
                  onChanged: (v) => setState(() => _scale = v),
                  options: [for (final s in _scales) SelectOption(s, '$s'), SelectOption(null, l10n.scaleOther)],
                ),
              );
              if (constraints.maxWidth < 420) return Column(children: [date, const SizedBox(height: 16), scale]);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: date),
                  const SizedBox(width: 12),
                  Expanded(child: scale),
                ],
              );
            },
          ),
          if (_scale == null) ...[
            const SizedBox(height: 16),
            FormInput(
              label: l10n.scaleOtherLabel,
              hint: l10n.scaleOtherHint,
              initialValue: _otherScale,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              errorText: _tried && !_scaleValid ? l10n.scaleInvalid : null,
              onChanged: (v) => setState(() => _otherScale = v),
            ),
          ],
          const SizedBox(height: 16),
          SelectField<String?>(
            label: '${l10n.chapter}${l10n.dotSeparator}${l10n.optional}',
            hint: l10n.noChapter,
            value: _chapterId,
            onChanged: (id) => setState(() => _chapterId = id),
            options: [SelectOption(null, l10n.noChapter), for (final c in chapters) SelectOption(c.id, c.title)],
          ),
          const SizedBox(height: 20),
          InfoNote(text: l10n.evaluationScaleNote),
        ],
      ),
    );
  }
}
