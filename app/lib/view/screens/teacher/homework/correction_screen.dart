import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/l10n/tunis_time.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/content.dart';
import '../../../../domain/model/homework.dart';
import '../../../../domain/repositories/homework_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/common/load_status.dart';
import '../../../stateManager/document/document_cubit.dart';
import '../../../stateManager/homework/correction_cubit.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/content_widgets.dart';
import '../../../widgets/document_pages.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/homework_widgets.dart';
import '../../../widgets/page_frame.dart';
import '../../../widgets/panels.dart';
import '../../../widgets/text_field.dart';
import '../../shared/my_homework_screen.dart' show homeworkWhen;
import '../contents/scan_screen.dart';

/// Correcting (design `r2/Corriger.png`): the copy beside the score, the comment and the corrected copy;
/// "Enregistrer et suivant" opens the next copy of the same homework.
class CorrectionScreen extends StatelessWidget {
  const CorrectionScreen({super.key, required this.assignmentId, required this.studentId});

  final String assignmentId;
  final String studentId;

  @override
  Widget build(BuildContext context) =>
      BlocProvider(create: (_) => CorrectionCubit(sl.get(), sl.get(), assignmentId, studentId)..load(), child: const CorrectionBody());
}

class CorrectionBody extends StatelessWidget {
  const CorrectionBody({super.key});

  /// Wide enough for the copy and the panel side by side.
  static const _sideBySide = 900.0;

  void _back(BuildContext context) => context.canPop() ? context.pop() : context.go(Routes.teacherAssignments);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final state = context.watch<CorrectionCubit>().state;
    final cubit = context.read<CorrectionCubit>();
    final a = state.assignment;
    final wide = MediaQuery.sizeOf(context).width >= _sideBySide;
    final phone = isPhone(context);
    final now = sl.get<Now>()();

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a?.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: text.style(phone ? 16 : 18, FontWeight.w800)),
                Text(
                  a == null
                      ? ''
                      : phone && state.copies.isNotEmpty
                      ? l10n.copyOf(state.index + 1, state.copies.length)
                      : '${isolated(a.group.name)}${l10n.dotSeparator}${l10n.deadlineWas(homeworkWhen(l10n, language, a.deadlineAt, now))}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                ),
              ],
            ),
          ),
          if (state.copies.length > 1) ...[
            const SizedBox(width: 8),
            IconSquareButton(
              icon: LucideIcons.chevronLeftDir,
              tooltip: l10n.previousCopy,
              size: phone ? 40 : 44,
              onPressed: state.index > 0 ? cubit.previous : null,
            ),
            if (!phone)
              SizedBox(
                width: 120,
                child: Text(
                  l10n.copyOf(state.index + 1, state.copies.length),
                  textAlign: TextAlign.center,
                  style: text.style(14, FontWeight.w700),
                ),
              )
            else
              const SizedBox(width: 6),
            IconSquareButton(
              icon: LucideIcons.chevronRightDir,
              tooltip: l10n.nextCopy,
              size: phone ? 40 : 44,
              onPressed: state.following != null ? cubit.next : null,
            ),
          ],
        ],
      ),
    );

    final Widget body;
    if (state.status == LoadStatus.failure && state.view == null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FailureBanner(state.failure!, onRetry: cubit.load),
        ),
      );
    } else if (state.view == null) {
      body = const Align(alignment: Alignment.topCenter, child: LinearProgressIndicator(minHeight: 3));
    } else {
      final view = state.view!;
      final pane = _CopyPane(key: ValueKey(view.submission?.id ?? view.studentId), view: view, compact: !wide);
      final form = _GradeForm(view: view);
      body = wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: pane),
                Container(
                  width: 460,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: BorderDirectional(start: BorderSide(color: BrandColors.line)),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: form),
                      ),
                      const _Footer(),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                SizedBox(height: (MediaQuery.sizeOf(context).height * 0.36).clamp(200.0, 360.0), child: pane),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), child: form),
                  ),
                ),
                const _Footer(),
              ],
            );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE9EBF3),
      body: SafeArea(
        child: Column(
          children: [
            topBar,
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

/// The pupil's work, page by page; nothing to show when nothing was sent.
class _CopyPane extends StatelessWidget {
  const _CopyPane({super.key, required this.view, required this.compact});

  final CorrectionView view;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final submission = view.submission;
    if (submission == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const IconBadge(icon: LucideIcons.fileX, accent: Accent.grey),
                const SizedBox(height: 12),
                Text(
                  l10n.noWorkPane,
                  textAlign: TextAlign.center,
                  style: text.style(14, FontWeight.w600, color: BrandColors.body, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final repository = sl.get<HomeworkRepository>();
    return BlocProvider(
      create: (_) => DocumentCubit(sl.get(), sl.get(), submission.id, loader: () => repository.submissionView(submission.id))..load(),
      child: Builder(
        builder: (context) {
          final document = context.watch<DocumentCubit>().state;
          if (document.status == LoadStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: FailureBanner(document.failure!, onRetry: context.read<DocumentCubit>().load),
              ),
            );
          }
          if (document.view == null || document.view!.pageUrls.isEmpty) {
            return const Align(alignment: Alignment.topCenter, child: LinearProgressIndicator(minHeight: 3));
          }
          return DocumentPages(compact: compact);
        },
      ),
    );
  }
}

/// The pupil, the score, the comment with quick phrases, and the corrected copy.
class _GradeForm extends StatelessWidget {
  const _GradeForm({required this.view});

  final CorrectionView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final state = context.watch<CorrectionCubit>().state;
    final cubit = context.read<CorrectionCubit>();
    final now = sl.get<Now>()();
    final submission = view.submission;
    final quiet = text.style(13, FontWeight.w500, color: BrandColors.slate);

    final pupil = Row(
      children: [
        InitialsAvatar(initials: view.initials, size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(view.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.style(17, FontWeight.w800)),
              Text(
                submission == null
                    ? l10n.nothingReceived
                    : [
                        l10n.sentOn(homeworkWhen(l10n, language, submission.submittedAt, now)),
                        if (submission.pageCount != null) l10n.pagesCount(submission.pageCount!),
                      ].join(l10n.dotSeparator),
                style: quiet,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        HomeworkStatusChip(view.status),
      ],
    );

    final phrases = [l10n.phraseVeryGood, l10n.phraseGoodWork, l10n.phraseReviewLesson, l10n.phraseHandwriting];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.failure != null) ...[FailureBanner(state.failure!), const SizedBox(height: 16)],
        pupil,
        const SizedBox(height: 20),
        LabeledField(
          label: l10n.scoreLabel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 124,
                    child: FormInput(
                      key: ValueKey('score-${view.studentId}'),
                      hint: l10n.scoreHint,
                      initialValue: state.score,
                      onChanged: cubit.setScore,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '/ ${view.maxScore}',
                    textDirection: TextDirection.ltr,
                    style: text.style(22, FontWeight.w800, color: BrandColors.slate),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                state.scoreError ? l10n.scoreInvalid(view.maxScore) : l10n.scoreHelper(view.maxScore),
                style: state.scoreError
                    ? text.style(12, FontWeight.w600, color: Accent.red.onSoft)
                    : text.style(12, FontWeight.w500, color: BrandColors.slate),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FormInput(
          key: ValueKey('comment-${view.studentId}'),
          label: l10n.commentLabel,
          labelSuffix: l10n.commentSuffix,
          hint: l10n.correctionCommentHint,
          initialValue: state.comment,
          onChanged: cubit.setComment,
          maxLines: 4,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final phrase in phrases)
              ActionChip(
                label: Text(phrase),
                labelStyle: text.style(13, FontWeight.w700, color: BrandColors.body),
                backgroundColor: Colors.white,
                side: const BorderSide(color: BrandColors.line),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
                onPressed: () => cubit.addPhrase(phrase),
              ),
          ],
        ),
        const SizedBox(height: 20),
        LabeledField(
          label: l10n.correctedCopy,
          labelSuffix: l10n.optional,
          child: _CorrectedCopy(view: view),
        ),
      ],
    );
  }
}

/// Attach the teacher's corrected copy (photos made into one PDF, or a file), open it, or take it back.
class _CorrectedCopy extends StatelessWidget {
  const _CorrectedCopy({required this.view});

  final CorrectionView view;

  Future<void> _scan(BuildContext context) async {
    final cubit = context.read<CorrectionCubit>();
    final scanned = await ScanScreen.open(context);
    if (scanned != null) await cubit.attach(scanned);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final state = context.watch<CorrectionCubit>().state;
    final cubit = context.read<CorrectionCubit>();
    final file = view.file;
    final problem = switch (state.problem) {
      FileProblem.unsupported => l10n.workFileUnsupported,
      FileProblem.tooLarge => l10n.fileTooLarge,
      FileProblem.empty => l10n.fileEmpty,
      null => null,
    };

    Widget choice(IconData icon, Accent accent, String label, VoidCallback onTap) => Expanded(
      child: Material(
        color: const Color(0xFFF4F5FC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: Color(0xFF9AA3D9), width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: state.attaching ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconBadge(icon: icon, accent: accent, size: IconBadgeSize.small),
                const SizedBox(width: 10),
                Expanded(child: Text(label, style: text.style(14, FontWeight.w700))),
              ],
            ),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (file != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: BrandColors.line),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              children: [
                const IconBadge(icon: LucideIcons.penLine, accent: Accent.violet, size: IconBadgeSize.medium),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.correctedCopy, style: text.style(14, FontWeight.w700)),
                      Text(
                        [kindLabel(l10n, file.kind), if (file.pageCount != null) l10n.pagesCount(file.pageCount!)].join(l10n.dotSeparator),
                        style: text.style(12, FontWeight.w500, color: BrandColors.slate),
                      ),
                    ],
                  ),
                ),
                GhostButton(
                  label: l10n.actionOpen,
                  height: 36,
                  onPressed: () => context.push(Routes.teacherCorrectionFile(view.assignmentId, view.studentId)),
                ),
                GhostButton(label: l10n.removeCopy, height: 36, onPressed: cubit.removeFile),
              ],
            ),
          )
        else
          Row(
            children: [
              choice(LucideIcons.camera, Accent.turquoise, l10n.takeCorrectedPhoto, () => _scan(context)),
              const SizedBox(width: 10),
              choice(LucideIcons.folderOpen, Accent.indigo, l10n.chooseFile, cubit.chooseAndAttach),
            ],
          ),
        if (state.progress != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFDCE0F5),
              color: Accent.green.strong,
            ),
          ),
          const SizedBox(height: 4),
          Text(l10n.uploadProgress((state.progress! * 100).round()), style: text.style(12, FontWeight.w600, color: BrandColors.slate)),
        ],
        if (problem != null) ...[
          const SizedBox(height: 6),
          Text(problem, style: text.style(12, FontWeight.w600, color: Accent.red.onSoft)),
        ],
      ],
    );
  }
}

/// "Copie suivante : Adam Gharbi", then "Enregistrer" and "Enregistrer et suivant".
class _Footer extends StatelessWidget {
  const _Footer();

  Future<void> _save(BuildContext context, {required bool andNext}) async {
    final l10n = AppLocalizations.of(context);
    final outcome = await context.read<CorrectionCubit>().save(andNext: andNext);
    if (!context.mounted) return;
    switch (outcome) {
      case SaveOutcome.finished:
        showNotice(context, l10n.allCorrected);
        context.canPop() ? context.pop() : context.go(Routes.teacherAssignments);
      case SaveOutcome.saved:
        if (!andNext) showNotice(context, l10n.correctionSaved);
      case SaveOutcome.refused:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final state = context.watch<CorrectionCubit>().state;
    final following = state.following;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: BrandColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            following == null ? l10n.lastCopy : l10n.nextCopyName(following.fullName),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.style(13, FontWeight.w500, color: BrandColors.slate),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 10,
            children: [
              SecondaryButton(label: l10n.save, height: 48, onPressed: state.saving ? null : () => _save(context, andNext: false)),
              PrimaryButton(
                label: l10n.saveAndNext,
                arrow: true,
                height: 48,
                loading: state.saving,
                onPressed: () => _save(context, andNext: true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
