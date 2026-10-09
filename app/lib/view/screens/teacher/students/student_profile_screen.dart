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
import '../../../../domain/model/session.dart';
import '../../../../domain/model/student.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/reference/reference_cubit.dart';
import '../../../stateManager/results/results_cubit.dart';
import '../../../stateManager/student_profile/student_profile_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/classmates.dart';
import '../../../widgets/controls.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/labels.dart';
import '../../../widgets/page_frame.dart';
import '../../../widgets/panels.dart';
import '../../../widgets/school_widgets.dart';
import '../../../widgets/text_field.dart';
import '../../shared/my_results_screen.dart' show SubjectCard;
import 'credentials_dialog.dart';
import 'student_form_panel.dart';

/// "Fiche élève" (spec 02, design `r1/FicheEleve.png`).
class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => StudentProfileCubit(sl.get(), sl.get(), studentId)..load()),
      // The Moyenne tile and the results panel: the numbers the pupil and the parents see.
      BlocProvider(create: (_) => ResultsCubit.forTeacher(sl.get())..load(studentId: studentId)),
    ],
    child: const StudentProfileView(),
  );
}

class StudentProfileView extends StatelessWidget {
  const StudentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudentProfileCubit>().state;
    return AsyncView(
      status: state.status,
      hasData: state.profile != null,
      failure: state.failure,
      onRetry: context.read<StudentProfileCubit>().load,
      builder: (context) => const _Profile(),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<StudentProfileCubit>().state;
    final profile = state.profile!;
    final attendance = profile.attendance;
    final phone = isPhone(context);
    return PageScroll(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () => context.go(Routes.teacherStudents),
            icon: const Icon(LucideIcons.arrowLeftDir, size: 18, color: BrandColors.indigo),
            label: Text(l10n.navStudents, style: AppText.of(context).style(14, FontWeight.w700, color: BrandColors.indigo)),
          ),
        ),
        _Header(profile: profile),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900 ? 4 : 2;
            final gap = phone ? 10.0 : 16.0;
            final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
            final tiles = [
              StatTile(
                icon: LucideIcons.circleCheck,
                accent: Accent.green,
                value: attendance.rate,
                suffix: ' %',
                label: l10n.statAttendance,
                caption: l10n.absencesCount(attendance.absent),
                captionColor: attendance.absent > 0 ? Accent.red.onSoft : Accent.green.onSoft,
              ),
              StatTile(icon: LucideIcons.clock, accent: Accent.orange, value: attendance.late, label: l10n.statLate, caption: l10n.sinceSeptember),
              StatTile(
                icon: LucideIcons.calendar,
                accent: Accent.indigo,
                value: attendance.counted,
                label: l10n.statSessions,
                caption: l10n.sinceSeptember,
              ),
              _AverageTile(firstName: profile.student.firstName),
            ];
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [for (final tile in tiles) SizedBox(width: width, child: tile)],
            );
          },
        ),
        PairedBlocks(
          equalHeight: false,
          start: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _NextSessions(sessions: profile.nextSessions),
              SizedBox(height: phone ? 16 : 24),
              _Attendance(summary: attendance),
            ],
          ),
          end: const Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [_Comments(), SizedBox(height: 24), _PrivateNotes()]),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final student = profile.student;
    final phone = isPhone(context);
    final lastLogin = profile.lastLoginAt == null ? l10n.neverLoggedIn : l10n.lastLogin(shortDate(TunisTime.day(profile.lastLoginAt!), language));
    final meta = [
      student.level.of(language),
      if (student.loginEnabled) ...[l10n.usernameInline(student.username), lastLogin] else l10n.noChildAccess,
    ].join(l10n.dotSeparator);

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (student.loginEnabled)
          SecondaryButton(label: l10n.resetPassword, icon: LucideIcons.keyRound, onPressed: () => _reset(context))
        else
          SecondaryButton(label: l10n.createChildAccess, icon: LucideIcons.keyRound, onPressed: () => _enableLogin(context)),
        SecondaryButton(label: l10n.edit, icon: LucideIcons.pencil, onPressed: () => _edit(context)),
        SecondaryButton(label: l10n.privateLesson, icon: LucideIcons.plus, onPressed: () => _privateLesson(context)),
        if (student.loginEnabled) IconSquareButton(icon: LucideIcons.userX, tooltip: l10n.removeChildAccess, onPressed: () => _disableLogin(context)),
        IconSquareButton(icon: LucideIcons.archive, tooltip: l10n.archive, danger: true, onPressed: () => _archive(context)),
      ],
    );

    return SectionCard(
      child: Wrap(
        spacing: 20,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InitialsAvatar(initials: student.initials, size: phone ? 56 : 72),
              const SizedBox(width: 18),
              // On the narrowest phones the name and facts take what is left beside the avatar.
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: phone ? 230 : 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(student.fullName, style: text.style(phone ? 24 : 30, FontWeight.w800, spacing: -0.6)),
                          StatusChip(label: l10n.active, accent: Accent.green),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(meta, style: text.style(14, FontWeight.w500, color: BrandColors.slate)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          for (final g in student.groups) GroupLabel(code: g.code, color: g.color, name: g.name),
                          for (final p in student.parents)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.phone, size: 15, color: BrandColors.indigo),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    [
                                      capitalized(relationLabel(l10n, p.relation)),
                                      p.fullName,
                                      ?p.phone,
                                    ].where((s) => s.isNotEmpty).join(l10n.dotSeparator),
                                    style: text.style(13, FontWeight.w500, color: BrandColors.body),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions,
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final cubit = context.read<StudentProfileCubit>();
    final saved = await StudentFormPanel.open(context, editing: profile.student);
    if (saved != null) {
      await cubit.refreshProfile();
      if (context.mounted) showNotice(context, AppLocalizations.of(context).savedChanges);
    }
  }

  Future<void> _reset(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<StudentProfileCubit>();
    final ok = await confirmAction(
      context,
      title: l10n.resetPassword,
      text: l10n.resetPasswordConfirm(profile.student.fullName),
      confirmLabel: l10n.resetPassword,
      icon: LucideIcons.keyRound,
      danger: false,
    );
    if (!ok || !context.mounted) return;
    final (account, failure) = await cubit.resetPassword();
    if (!context.mounted) return;
    if (account != null) {
      await CredentialsDialog.show(context, [account], reset: true);
    } else if (failure != null) {
      showNotice(context, failureText(l10n, failure));
    }
  }

  Future<void> _enableLogin(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final (account, failure) = await context.read<StudentProfileCubit>().enableLogin();
    if (!context.mounted) return;
    if (account != null) {
      await CredentialsDialog.show(context, [account]);
    } else if (failure != null) {
      showNotice(context, failureText(l10n, failure));
    }
  }

  Future<void> _disableLogin(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<StudentProfileCubit>();
    final ok = await confirmAction(
      context,
      title: l10n.removeChildAccess,
      text: l10n.removeChildAccessText(profile.student.fullName),
      confirmLabel: l10n.removeChildAccess,
      icon: LucideIcons.userX,
    );
    if (!ok) return;
    final failure = await cubit.disableLogin();
    if (context.mounted) showNotice(context, failure == null ? l10n.childAccessRemoved : failureText(l10n, failure));
  }

  Future<void> _archive(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<StudentProfileCubit>();
    final name = profile.student.fullName;
    final ok = await confirmAction(
      context,
      title: l10n.archiveStudentTitle(name),
      text: l10n.archiveStudentText,
      confirmLabel: l10n.archive,
      icon: LucideIcons.archive,
    );
    if (!ok || !context.mounted) return;
    final failure = await cubit.archive();
    if (!context.mounted) return;
    showNotice(context, failure == null ? l10n.studentArchived(name) : failureText(l10n, failure));
    if (failure == null) context.go(Routes.teacherStudents);
  }

  Future<void> _privateLesson(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<StudentProfileCubit>();
    final reference = context.read<ReferenceCubit>().state.reference;
    final language = context.read<LanguageCubit>().state;
    final subjectId = await showAppDialog<String>(
      context,
      builder: (dialogContext) {
        String? chosen;
        return StatefulBuilder(
          builder: (context, setState) => AppDialog(
            icon: LucideIcons.userRound,
            accent: Accent.violet,
            title: l10n.createPrivateLesson,
            subtitle: l10n.privateLessonText(profile.student.fullName),
            content: SelectField<String>(
              label: l10n.subject,
              hint: l10n.chooseSubject,
              value: chosen,
              onChanged: (v) => setState(() => chosen = v),
              options: [for (final s in reference?.subjects ?? const []) SelectOption(s.id, s.name.of(language))],
            ),
            actions: [
              GhostButton(label: l10n.cancel, onPressed: () => Navigator.of(dialogContext).pop()),
              PrimaryButton(
                label: l10n.createPrivateLesson,
                height: 44,
                onPressed: chosen == null ? null : () => Navigator.of(dialogContext).pop(chosen),
              ),
            ],
          ),
        );
      },
    );
    if (subjectId == null || !context.mounted) return;
    final (group, failure) = await cubit.createPrivateLesson(subjectId);
    if (!context.mounted) return;
    showNotice(context, group != null ? l10n.privateLessonCreated : failureText(l10n, failure!));
    if (group != null) context.go(Routes.teacherGroup(group.id));
  }
}

class _NextSessions extends StatelessWidget {
  const _NextSessions({required this.sessions});

  final List<UpcomingSession> sessions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    return SectionCard(
      title: l10n.nextSessions,
      trailing: CardLink(label: l10n.navPlanning, onPressed: () => context.go(Routes.teacherPlanning)),
      child: sessions.isEmpty
          ? EmptyState(message: l10n.noUpcoming, scale: 0.3)
          : Column(
              children: [
                for (var i = 0; i < sessions.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: i == 0 ? null : const Border(top: BorderSide(color: BrandColors.rowDivider)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 52,
                          child: Column(
                            children: [
                              Text(text.upper(weekdayShort(TunisTime.day(sessions[i].startsAt), language)), style: text.caption),
                              Text('${TunisTime.wall(sessions[i].startsAt).day}', style: text.style(20, FontWeight.w800, tabular: true)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 4,
                          height: 38,
                          decoration: BoxDecoration(color: colorFromHex(sessions[i].groupColor), borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sessions[i].groupName, style: text.rowTitle),
                              Text(
                                '${timeRangeLabel(l10n, sessions[i].startsAt, sessions[i].endsAt)}${l10n.dotSeparator}${placeLabel(l10n, sessions[i].mode, sessions[i].location)}',
                                style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                              ),
                            ],
                          ),
                        ),
                        const SessionStatusChip(status: SessionStatus.planned),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _Attendance extends StatelessWidget {
  const _Attendance({required this.summary});

  final AttendanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    // Oldest on the start side, like reading a week.
    final marks = summary.recent.reversed.toList();
    return SectionCard(
      title: l10n.attendanceTitle,
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 140),
        child: Text(
          l10n.lastTenSessions,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.end,
          style: text.style(13, FontWeight.w500, color: BrandColors.slate),
        ),
      ),
      child: summary.counted == 0
          ? EmptyState(message: l10n.noAttendanceYet, scale: 0.3)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final mark in marks)
                      Tooltip(
                        message:
                            '${shortDate(TunisTime.day(mark.sessionStart), language)}${l10n.dotSeparator}${switch (mark.status) {
                              AttendanceStatus.present => l10n.attendancePresent,
                              AttendanceStatus.absent => l10n.attendanceAbsent,
                              AttendanceStatus.late => l10n.attendanceLate,
                            }}',
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: switch (mark.status) {
                              AttendanceStatus.present => const Color(0xFFF3FBF5),
                              AttendanceStatus.absent => const Color(0xFFFEF5F5),
                              AttendanceStatus.late => const Color(0xFFFEF7F2),
                            },
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              width: 1.5,
                              color: switch (mark.status) {
                                AttendanceStatus.present => const Color(0xFFCDEBD3),
                                AttendanceStatus.absent => const Color(0xFFF6C9C9),
                                AttendanceStatus.late => const Color(0xFFF7D3BE),
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    StatusChip(label: l10n.presentCount(summary.present), accent: Accent.green),
                    StatusChip(label: l10n.absentCount(summary.absent), accent: Accent.red),
                    StatusChip(label: l10n.lateCount(summary.late), accent: Accent.orange),
                  ],
                ),
              ],
            ),
    );
  }
}

/// Asks for a text (a note, a comment). Returns it, or null.
Future<String?> _compose(BuildContext context, {required String title, required String hint, String initial = '', required IconData icon}) {
  final l10n = AppLocalizations.of(context);
  var value = initial;
  return showAppDialog<String>(
    context,
    builder: (dialogContext) => AppDialog(
      icon: icon,
      title: title,
      content: FormInput(initialValue: initial, hint: hint, maxLines: 5, autofocus: true, onChanged: (v) => value = v),
      actions: [
        GhostButton(label: l10n.cancel, onPressed: () => Navigator.of(dialogContext).pop()),
        PrimaryButton(label: l10n.save, height: 44, onPressed: () => Navigator.of(dialogContext).pop(value.trim().isEmpty ? null : value.trim())),
      ],
    ),
  );
}

class _Comments extends StatelessWidget {
  const _Comments();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final comments = context.select((StudentProfileCubit c) => c.state.comments);
    return SectionCard(
      title: l10n.commentsTitle,
      trailing: TonalButton(
        label: l10n.add,
        icon: LucideIcons.plus,
        onPressed: () async {
          final cubit = context.read<StudentProfileCubit>();
          final body = await _compose(context, title: l10n.commentsTitle, hint: l10n.commentHint, icon: LucideIcons.messageCircle);
          if (body == null) return;
          final failure = await cubit.addComment(body);
          if (failure != null && context.mounted) showNotice(context, failureText(l10n, failure));
        },
      ),
      child: comments.isEmpty
          ? Text(l10n.emptyComment, style: text.style(14, FontWeight.w500, color: BrandColors.slate))
          : Column(
              children: [
                for (final c in comments)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: BrandColors.chalk, borderRadius: BorderRadius.circular(AppRadii.md)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            text.upper('${shortDate(TunisTime.day(c.createdAt), language)}${l10n.dotSeparator}${l10n.commentsVisibility}'),
                            style: text.overline(size: 11),
                          ),
                          const SizedBox(height: 4),
                          Text(c.body, style: text.style(14, FontWeight.w500, height: 1.5)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _PrivateNotes extends StatelessWidget {
  const _PrivateNotes();

  static const _cream = Color(0xFFFFF8E8);
  static const _creamLine = Color(0xFFF8E3B3);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final notes = context.select((StudentProfileCubit c) => c.state.privateNotes);
    final cubit = context.read<StudentProfileCubit>();
    return Container(
      padding: EdgeInsets.all(isPhone(context) ? 16 : 24),
      decoration: BoxDecoration(
        color: _cream,
        border: Border.all(color: _creamLine),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(LucideIcons.lock, size: 18, color: Accent.amber.onSoft),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.privateNotesTitle, style: text.sectionTitle())),
              SecondaryButton(
                label: l10n.add,
                icon: LucideIcons.plus,
                height: 38,
                onPressed: () async {
                  final body = await _compose(context, title: l10n.privateNotesTitle, hint: l10n.noteHint, icon: LucideIcons.lock);
                  if (body == null) return;
                  final failure = await cubit.addPrivateNote(body);
                  if (failure != null && context.mounted) showNotice(context, failureText(l10n, failure));
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(text.upper(l10n.privateNotesVisibility), style: text.overline(color: Accent.amber.onSoft, size: 11)),
          const SizedBox(height: 12),
          if (notes.isEmpty)
            Text(l10n.noPrivateNotes, style: text.style(14, FontWeight.w500, color: BrandColors.body))
          else
            for (final note in notes)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 4, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _creamLine),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(text.upper(fullDate(TunisTime.day(note.createdAt), language)), style: text.overline(size: 11)),
                            const SizedBox(height: 4),
                            Text(note.body, style: text.style(14, FontWeight.w500, height: 1.5)),
                          ],
                        ),
                      ),
                      MenuAnchor(
                        menuChildren: [
                          MenuItemButton(
                            leadingIcon: const Icon(LucideIcons.pencil, size: 16),
                            onPressed: () async {
                              final body = await _compose(
                                context,
                                title: l10n.privateNotesTitle,
                                hint: l10n.noteHint,
                                initial: note.body,
                                icon: LucideIcons.lock,
                              );
                              if (body == null) return;
                              final failure = await cubit.editPrivateNote(note.id, body);
                              if (failure != null && context.mounted) showNotice(context, failureText(l10n, failure));
                            },
                            child: Text(l10n.edit),
                          ),
                          MenuItemButton(
                            leadingIcon: Icon(LucideIcons.trash2, size: 16, color: Accent.red.onSoft),
                            onPressed: () async {
                              final ok = await confirmAction(
                                context,
                                title: l10n.deleteNoteTitle,
                                text: note.body,
                                confirmLabel: l10n.delete,
                                icon: LucideIcons.trash2,
                              );
                              if (!ok) return;
                              final failure = await cubit.deletePrivateNote(note.id);
                              if (failure != null && context.mounted) showNotice(context, failureText(l10n, failure));
                            },
                            child: Text(l10n.delete, style: TextStyle(color: Accent.red.onSoft)),
                          ),
                        ],
                        builder: (context, controller, _) => IconButton(
                          tooltip: l10n.edit,
                          onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                          icon: const Icon(LucideIcons.ellipsis, size: 18, color: BrandColors.slate),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

/// "Moyenne" (design `r1/FicheEleve.png`): the mean of the pupil's grades on /20; a tap shows each subject and
/// each grade, as the pupil and the parents see them.
class _AverageTile extends StatelessWidget {
  const _AverageTile({required this.firstName});

  final String firstName;

  Future<void> _open(BuildContext context) {
    final results = context.read<ResultsCubit>();
    return showSidePanel<void>(
      context,
      builder: (_) => BlocProvider.value(
        value: results,
        child: _ResultsPanel(firstName: firstName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final results = context.watch<ResultsCubit>().state.results;
    final average = results?.average;
    final count = results?.grades.where((g) => g.counted).length ?? 0;
    final tile = StatTile(
      icon: LucideIcons.chartColumn,
      accent: average == null ? Accent.grey : Accent.violet,
      label: l10n.average,
      valueText: average == null ? null : '${averageText(average)} /20',
      caption: results == null ? null : (average == null ? l10n.noGradeYet : l10n.gradesCount(count)),
    );
    if (results == null || results.subjects.isEmpty) return tile;
    return Semantics(
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: () => _open(context), child: tile),
      ),
    );
  }
}

class _ResultsPanel extends StatelessWidget {
  const _ResultsPanel({required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subjects = context.watch<ResultsCubit>().state.results?.subjects ?? const [];
    final name = isolated(firstName);
    return SidePanel(
      icon: LucideIcons.chartColumn,
      accent: Accent.violet,
      title: l10n.parentResultsTitle(name),
      subtitle: l10n.parentResultsSubtitle(name),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, subject) in subjects.indexed) ...[if (i > 0) const SizedBox(height: 14), SubjectCard(result: subject)],
        ],
      ),
    );
  }
}
