import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/di/injection.dart';
import '../../../core/l10n/formatting.dart';
import '../../../core/l10n/tunis_time.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../domain/model/app_user.dart';
import '../../../domain/model/content.dart';
import '../../../domain/model/homework.dart';
import '../../../l10n/app_localizations.dart';
import '../../stateManager/auth/auth_cubit.dart';
import '../../stateManager/common/load_status.dart';
import '../../stateManager/homework/my_homework_detail_cubit.dart';
import '../../stateManager/language/language_cubit.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';
import '../../widgets/content_widgets.dart';
import '../../widgets/feedback.dart';
import '../../widgets/homework_widgets.dart';
import '../../widgets/page_frame.dart';
import '../../widgets/panels.dart';
import '../teacher/contents/scan_screen.dart';
import 'my_homework_screen.dart';

/// One homework, full screen (design `r2/DevoirsPhone.png`, screens 2 and 3): the deadline, what to do,
/// the document, and the work to send as photos (one PDF) or a file. A parent sends it for [studentId].
class MyHomeworkDetailScreen extends StatelessWidget {
  const MyHomeworkDetailScreen({super.key, required this.assignmentId, this.studentId});

  final String assignmentId;
  final String? studentId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => MyHomeworkDetailCubit(sl.get(), sl.get(), assignmentId, studentId: studentId)..load(),
    child: const MyHomeworkDetailView(),
  );
}

class MyHomeworkDetailView extends StatelessWidget {
  const MyHomeworkDetailView({super.key});

  bool _parent(BuildContext context) => context.read<AuthCubit>().user?.role == UserRole.parent;

  void _back(BuildContext context) =>
      context.canPop() ? context.pop() : context.go(_parent(context) ? Routes.parentAssignments : Routes.studentAssignments);

  Future<void> _scan(BuildContext context) async {
    final cubit = context.read<MyHomeworkDetailCubit>();
    final scanned = await ScanScreen.open(context);
    if (scanned == null) return;
    final sent = await cubit.send(scanned);
    if (sent && context.mounted) showNotice(context, AppLocalizations.of(context).workSentNotice);
  }

  Future<void> _choose(BuildContext context) async {
    final sent = await context.read<MyHomeworkDetailCubit>().chooseAndSend();
    if (sent && context.mounted) showNotice(context, AppLocalizations.of(context).workSentNotice);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final phone = isPhone(context);
    final language = context.watch<LanguageCubit>().state;
    final parent = context.read<AuthCubit>().user?.role == UserRole.parent;
    final state = context.watch<MyHomeworkDetailCubit>().state;
    final detail = state.detail;
    final homework = detail?.homework;

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
                Text(
                  homework?.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.style(phone ? 16 : 18, FontWeight.w800),
                ),
                if (homework != null)
                  Text(
                    '${homework.subject.name.of(language)}${l10n.dotSeparator}${isolated(homework.groupName)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                  ),
              ],
            ),
          ),
          if (homework != null) ...[const SizedBox(width: 8), HomeworkStatusChip(homework.status)],
        ],
      ),
    );

    final Widget body;
    if (state.status == LoadStatus.failure && detail == null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FailureBanner(state.failure!, onRetry: context.read<MyHomeworkDetailCubit>().load),
        ),
      );
    } else if (detail == null) {
      body = const Align(alignment: Alignment.topCenter, child: LinearProgressIndicator(minHeight: 3));
    } else {
      body = SingleChildScrollView(
        padding: EdgeInsets.all(phone ? 16 : 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: detail.correction != null
                  ? [_CorrectedArea(detail: detail, correction: detail.correction!, parent: parent)]
                  : [
                      _DeadlineCard(homework: detail.homework),
                      if (detail.instructions?.trim().isNotEmpty ?? false) ...[
                        const SizedBox(height: 12),
                        _Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(text.upper(l10n.instructionsLabel), style: text.overline(size: 11, color: BrandColors.body)),
                              const SizedBox(height: 6),
                              Text(
                                detail.instructions!,
                                textDirection: writtenDirection(detail.instructions!),
                                style: text.style(15, FontWeight.w500, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _DocumentCard(content: detail.content, parent: parent),
                      const SizedBox(height: 12),
                      _WorkArea(detail: detail, parent: parent, onScan: () => _scan(context)),
                    ],
            ),
          ),
        ),
      );
    }

    final canSend = detail != null && detail.canSubmit && !state.sending;
    final replacing = detail?.submission != null;
    return Scaffold(
      backgroundColor: BrandColors.chalk,
      body: SafeArea(
        child: Column(
          children: [
            topBar,
            Expanded(child: body),
            if (detail != null && detail.canSubmit)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: BrandColors.line)),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (replacing)
                          SecondaryButton(
                            label: parent ? l10n.replaceTheWork : l10n.replaceMyWork,
                            icon: LucideIcons.camera,
                            height: 52,
                            onPressed: canSend ? () => _scan(context) : null,
                          )
                        else
                          PrimaryButton(
                            label: parent ? l10n.takeTheWork : l10n.takeMyWork,
                            icon: LucideIcons.camera,
                            height: 52,
                            loading: state.sending,
                            onPressed: canSend ? () => _scan(context) : null,
                          ),
                        const SizedBox(height: 4),
                        Center(
                          child: GhostButton(
                            label: l10n.orChooseFile,
                            icon: LucideIcons.folderOpen,
                            height: 38,
                            onPressed: canSend ? () => _choose(context) : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.color = Colors.white, this.border = BrandColors.line});

  final Widget child;
  final Color color;
  final Color border;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: border),
      borderRadius: BorderRadius.circular(AppRadii.tile),
    ),
    child: child,
  );
}

/// "Pour le jeudi 9 octobre à 18:00", "dans 2 jours".
class _DeadlineCard extends StatelessWidget {
  const _DeadlineCard({required this.homework});

  final MyHomework homework;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final now = sl.get<Now>()();
    final h = homework;
    final near = h.status == HomeworkStatus.todo && deadlineIsNear(h.deadlineAt, now);
    return _Card(
      child: Row(
        children: [
          IconBadge(icon: LucideIcons.calendarClock, accent: near ? Accent.orange : Accent.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dueFor(l10n.dayAtTime(dayInSentence(TunisTime.day(h.deadlineAt), language), hm(h.deadlineAt))),
                  style: text.style(16, FontWeight.w800),
                ),
                Text(
                  h.closed ? l10n.closedChip : deadlineNote(l10n, h.deadlineAt, now),
                  style: text.style(13, FontWeight.w500, color: near ? Accent.orange.onSoft : BrandColors.slate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The document of the homework, opened in the viewer.
class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.content, required this.parent});

  final ContentRef content;
  final bool parent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final c = content;
    void open() => context.push(parent ? Routes.parentDocument(c.id) : Routes.studentDocument(c.id));
    return _Card(
      child: Row(
        children: [
          KindBadge(kind: c.kind),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.style(15, FontWeight.w700)),
                Text(
                  [
                    tagLabel(l10n, c.tag),
                    if (c.kind == FileKind.pdf && c.pageCount != null) l10n.pagesCount(c.pageCount!),
                    if (c.kind == FileKind.word) l10n.toDownload,
                  ].join(l10n.dotSeparator),
                  style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TonalButton(label: l10n.actionOpen, onPressed: open),
        ],
      ),
    );
  }
}

/// What was sent, or the place to send it; why nothing can be sent otherwise.
class _WorkArea extends StatelessWidget {
  const _WorkArea({required this.detail, required this.parent, required this.onScan});

  final MyHomeworkDetail detail;
  final bool parent;
  final VoidCallback onScan;

  String _childName(BuildContext context) {
    final user = context.read<AuthCubit>().user;
    final studentId = context.read<MyHomeworkDetailCubit>().studentId;
    return isolated(user?.children.where((c) => c.studentId == studentId).firstOrNull?.firstName ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final state = context.watch<MyHomeworkDetailCubit>().state;
    final now = sl.get<Now>()();
    final h = detail.homework;
    final submission = detail.submission;

    final problem = switch (state.problem) {
      FileProblem.unsupported => l10n.workFileUnsupported,
      FileProblem.tooLarge => l10n.fileTooLarge,
      FileProblem.empty => l10n.fileEmpty,
      null => null,
    };
    final feedback = [if (problem != null) ErrorBanner(message: problem), if (state.failure != null) FailureBanner(state.failure!)];

    final progress = state.progress;
    final sending = state.sending
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
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
              Text(l10n.uploadProgress(((progress ?? 0) * 100).round()), style: text.style(12, FontWeight.w600, color: BrandColors.slate)),
            ],
          )
        : const SizedBox.shrink();

    if (h.mode == SubmissionMode.none) return InfoNote(text: l10n.readOnlyNotice);

    final Widget area;
    if (submission != null) {
      final day = TunisTime.day(submission.submittedAt);
      final sentAt = l10n.dueOn(dayInSentence(day, language), hm(submission.submittedAt));
      final until = homeworkWhen(l10n, language, h.deadlineAt, now);
      area = _Card(
        color: Accent.green.soft,
        border: const Color(0xFFBFE5C8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(LucideIcons.circleCheck, size: 20, color: Accent.green.onSoft),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.workSent, style: text.style(16, FontWeight.w800, color: Accent.green.onSoft)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.row),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.row),
                onTap: () => context.push(
                  parent
                      ? Uri(
                          path: Routes.parentSubmission(h.id),
                          queryParameters: {Routes.childParam: ?context.read<MyHomeworkDetailCubit>().studentId},
                        ).toString()
                      : Routes.studentSubmission(h.id),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const KindBadge(kind: FileKind.pdf),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(parent ? l10n.sentWork : l10n.myWork, style: text.style(15, FontWeight.w700)),
                            Text(
                              [if (submission.pageCount != null) l10n.pagesCount(submission.pageCount!), sentAt].join(l10n.dotSeparator),
                              style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(l10n.actionOpen, style: text.style(14, FontWeight.w800, color: BrandColors.indigo)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (submission.late)
              Text(l10n.lateSentNotice, style: text.style(13, FontWeight.w600, color: Accent.amber.onSoft))
            else if (detail.canSubmit && h.deadlineAt.isAfter(now))
              Text(
                parent ? l10n.canReplaceUntil(until) : l10n.canReplaceUntilTu(until),
                style: text.style(13, FontWeight.w600, color: Accent.green.onSoft),
              ),
            sending,
          ],
        ),
      );
    } else if (detail.canSubmit) {
      area = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (h.status == HomeworkStatus.missing) ...[ErrorBanner(message: l10n.missingNotice), const SizedBox(height: 12)],
          Material(
            color: const Color(0xFFF4F5FC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.tile),
              side: const BorderSide(color: Color(0xFF9AA3D9), width: 1.5),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.tile),
              onTap: state.sending ? null : onScan,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const IconBadge(icon: LucideIcons.camera, accent: Accent.turquoise),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                parent ? l10n.childWork(_childName(context)) : l10n.yourWork,
                                style: text.style(16, FontWeight.w800, color: Accent.turquoise.onSoft),
                              ),
                              const SizedBox(height: 2),
                              Text(l10n.workPhotosHint, style: text.style(13, FontWeight.w500, color: BrandColors.slate)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    sending,
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      final notice = h.closed
          ? l10n.closedNotice
          : h.status == HomeworkStatus.missing
          ? l10n.missingNotice
          : l10n.deadlinePassedNotice;
      area = h.status == HomeworkStatus.missing ? ErrorBanner(message: notice) : InfoNote(text: notice, icon: LucideIcons.lock);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final f in feedback) ...[f, const SizedBox(height: 12)],
        area,
      ],
    );
  }
}

/// A corrected homework (design `r2/CorrectionPhone.png`, "Devoir corrigé"): the grade, the teacher's word, the
/// corrected copy, the work sent and the document.
class _CorrectedArea extends StatelessWidget {
  const _CorrectedArea({required this.detail, required this.correction, required this.parent});

  final MyHomeworkDetail detail;
  final Correction correction;
  final bool parent;

  String? _child(BuildContext context) => context.read<MyHomeworkDetailCubit>().studentId;

  String _withChild(BuildContext context, String path) {
    final child = _child(context);
    return parent && child != null ? Uri(path: path, queryParameters: {Routes.childParam: child}).toString() : path;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final c = correction;
    final h = detail.homework;
    final submission = detail.submission;
    final user = context.read<AuthCubit>().user;
    final childName = isolated(user?.children.where((x) => x.studentId == _child(context)).firstOrNull?.firstName ?? '');
    final comment = c.comment;

    Widget fileCard(Widget badge, String title, String subtitle, VoidCallback onOpen) => _Card(
      child: Row(
        children: [
          badge,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.style(15, FontWeight.w700)),
                Text(subtitle, style: text.style(13, FontWeight.w500, color: BrandColors.slate)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TonalButton(label: l10n.actionOpen, onPressed: onOpen),
        ],
      ),
    );

    final grade = _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Accent.violet.soft, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      scoreText(c.score),
                      textDirection: TextDirection.ltr,
                      style: text.style(34, FontWeight.w800, color: Accent.violet.onSoft, height: 1),
                    ),
                    Text(
                      '/ ${c.maxScore}',
                      textDirection: TextDirection.ltr,
                      style: text.style(14, FontWeight.w700, color: Accent.violet.onSoft),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(parent ? l10n.childGrade(childName) : l10n.yourGrade, style: text.style(18, FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                      l10n.correctedOn(dayInSentence(TunisTime.day(c.correctedAt), language)),
                      style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment != null && comment.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: BrandColors.chalk, borderRadius: BorderRadius.circular(AppRadii.md)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const IconBadge(icon: LucideIcons.messageCircle, accent: Accent.indigo, size: IconBadgeSize.small),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(text.upper(l10n.teacherNote), style: text.overline(size: 11)),
                        const SizedBox(height: 4),
                        Text(comment, textDirection: writtenDirection(comment), style: text.style(15, FontWeight.w500, height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    final file = c.file;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        grade,
        if (file != null) ...[
          const SizedBox(height: 12),
          fileCard(
            const IconBadge(icon: LucideIcons.penLine, accent: Accent.violet),
            l10n.correctedCopy,
            [kindLabel(l10n, file.kind), if (file.pageCount != null) l10n.pagesCount(file.pageCount!)].join(l10n.dotSeparator),
            () => context.push(_withChild(context, parent ? Routes.parentCorrection(h.id) : Routes.studentCorrection(h.id))),
          ),
        ],
        if (submission != null) ...[
          const SizedBox(height: 12),
          fileCard(
            const KindBadge(kind: FileKind.pdf),
            parent ? l10n.sentWork : l10n.myWork,
            [
              if (submission.pageCount != null) l10n.pagesCount(submission.pageCount!),
              l10n.dueOn(dayInSentence(TunisTime.day(submission.submittedAt), language), hm(submission.submittedAt)),
            ].join(l10n.dotSeparator),
            () => context.push(_withChild(context, parent ? Routes.parentSubmission(h.id) : Routes.studentSubmission(h.id))),
          ),
        ],
        const SizedBox(height: 12),
        _DocumentCard(content: detail.content, parent: parent),
      ],
    );
  }
}
