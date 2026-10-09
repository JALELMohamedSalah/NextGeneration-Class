import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/l10n/tunis_time.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/clock_time.dart';
import '../../../../domain/model/group.dart';
import '../../../../domain/model/session.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/groups/groups_cubit.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/reference/reference_cubit.dart';
import '../../../stateManager/session_form/session_form_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/copy_link_button.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/controls.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/labels.dart';
import '../../../widgets/page_frame.dart';
import '../../../widgets/panels.dart';
import '../../../widgets/school_widgets.dart';
import '../../../widgets/text_field.dart';
import 'scope_dialog.dart';

/// "Nouvelle séance" / "Modifier la séance" (design `r1/NouvelleSeance.png`). Returns true once saved.
class SessionFormPanel extends StatelessWidget {
  const SessionFormPanel({super.key});

  static Future<bool> create(BuildContext context, {Group? group, DateTime? date, ClockTime? start}) async {
    final groups = context.read<GroupsCubit>();
    final reference = context.read<ReferenceCubit>();
    final now = sl.get<Now>()();
    final day = date ?? TunisTime.day(now);
    final clock = TunisTime.clock(now);
    final defaultStart = start ?? ClockTime((clock.hour + 1).clamp(8, 20), 0);
    final yearEnd = reference.state.reference?.currentYear?.endsOn ?? TunisTime.addDays(day, 7 * 30);
    final saved = await showSidePanel<bool>(
      context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: groups),
          BlocProvider(
            create: (_) =>
                SessionFormCubit.create(sl.get(), date: day, start: defaultStart, schoolYearEnd: yearEnd, group: group)..checkOverlaps(),
          ),
        ],
        child: const SessionFormPanel(),
      ),
    );
    if (saved ?? false) groups.load();
    return saved ?? false;
  }

  static Future<bool> edit(BuildContext context, Session session) async {
    final groups = context.read<GroupsCubit>();
    final saved = await showSidePanel<bool>(
      context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: groups),
          BlocProvider(
            create: (_) => SessionFormCubit.edit(sl.get(), session, groupMeetUrl: groups.state.byId(session.group.id)?.defaultMeetUrl),
          ),
        ],
        child: _EditScope(session: session, child: const SessionFormPanel()),
      ),
    );
    return saved ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = context.watch<LanguageCubit>().state;
    return BlocConsumer<SessionFormCubit, SessionFormState>(
      listenWhen: (previous, current) =>
          (previous.created == null && current.created != null) || (previous.updated == null && current.updated != null),
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop(true);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.created != null ? l10n.sessionsCreated(state.created!.count) : l10n.sessionUpdated)));
      },
      builder: (context, state) {
        final count = state.sessionCount;
        return SidePanel(
          icon: state.isEditing ? LucideIcons.pencil : LucideIcons.calendarPlus,
          title: state.isEditing ? l10n.editSession : l10n.newSession,
          subtitle: '${dayDate(state.date, language)}, ${state.start.hhmm}',
          actions: [
            GhostButton(label: l10n.cancel, onPressed: () => Navigator.of(context).maybePop()),
            PrimaryButton(
              label: state.isEditing ? l10n.save : l10n.createSessions(count),
              height: 44,
              loading: state.submitting,
              onPressed: () => _submit(context),
            ),
          ],
          body: const _Body(),
        );
      },
    );
  }

  static Future<void> _submit(BuildContext context) async {
    final cubit = context.read<SessionFormCubit>();
    final editing = _EditScope.of(context);
    if (editing != null && editing.recurring) {
      final scope = await askEditScope(context, editing);
      if (scope == null) return;
      await cubit.submit(scope: scope);
    } else {
      await cubit.submit();
    }
  }
}

/// Carries the edited session down to the submit button (for the scope question).
class _EditScope extends InheritedWidget {
  const _EditScope({required this.session, required super.child});

  final Session session;

  static Session? of(BuildContext context) => context.getInheritedWidgetOfExactType<_EditScope>()?.session;

  @override
  bool updateShouldNotify(_EditScope oldWidget) => session != oldWidget.session;
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final state = context.watch<SessionFormCubit>().state;
    final cubit = context.read<SessionFormCubit>();
    final groups = context.watch<GroupsCubit>().state.groups;
    final phone = isPhone(context);
    final timeError = state.errors.contains(SessionFormError.time);

    final date = DateField(
      label: l10n.date,
      value: state.date,
      onChanged: cubit.setDate,
      firstDate: DateTime(state.date.year - 1),
      lastDate: DateTime(state.date.year + 2),
    );
    final times = Row(
      children: [
        Expanded(
          child: TimeField(label: l10n.startTime, value: state.start, onChanged: cubit.setStart, error: timeError),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TimeField(label: l10n.endTime, value: state.end, onChanged: cubit.setEnd, error: timeError),
        ),
      ],
    );

    final overlap = state.overlaps.firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.failure != null) ...[FailureBanner(state.failure!), const SizedBox(height: 20)],
        if (groups.isEmpty)
          InfoNote(text: l10n.noGroupsYet)
        else
          SelectField<String>(
            label: l10n.group,
            hint: l10n.chooseGroup,
            value: state.groupId,
            errorText: state.errors.contains(SessionFormError.group) ? l10n.fieldRequired : null,
            onChanged: (id) {
              final group = groups.where((g) => g.id == id).firstOrNull;
              if (group != null) cubit.setGroup(group);
            },
            options: [
              for (final g in groups)
                SelectOption(
                  g.id,
                  g.name,
                  leading: GroupSquare(code: g.code, color: g.color, size: 22),
                ),
            ],
          ),
        const SizedBox(height: 20),
        if (phone) ...[
          date,
          const SizedBox(height: 20),
          times,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 13, child: date),
              const SizedBox(width: 12),
              Expanded(flex: 20, child: times),
            ],
          ),
        if (timeError)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 6, start: 4),
            child: Text(l10n.timeRangeInvalid, style: text.style(12, FontWeight.w600, color: Accent.red.onSoft)),
          ),
        const SizedBox(height: 20),
        LabeledField(
          label: l10n.mode,
          child: SegmentedChoice<SessionMode>(
            value: state.mode,
            onChanged: cubit.setMode,
            options: [
              SelectOption(SessionMode.inPerson, l10n.modeInPerson, leading: const Icon(LucideIcons.mapPin, size: 16)),
              SelectOption(SessionMode.online, l10n.modeOnline, leading: const Icon(LucideIcons.video, size: 16)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 200),
          child: state.mode == SessionMode.online
              ? FormInput(
                  key: const ValueKey('meet'),
                  label: l10n.meetLink,
                  icon: LucideIcons.link,
                  initialValue: state.meetUrl,
                  hint: state.groupMeetUrl ?? l10n.meetLinkHint,
                  keyboardType: TextInputType.url,
                  textDirection: TextDirection.ltr,
                  onChanged: cubit.setMeetUrl,
                  errorText: state.errors.contains(SessionFormError.meetUrl) ? l10n.meetLinkInvalid : null,
                  suffix: state.meetUrl.trim().isEmpty && state.groupMeetUrl != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusChip(label: l10n.fromGroup, accent: Accent.grey),
                            const SizedBox(width: 6),
                            CopyLinkButton(url: state.groupMeetUrl!, size: 32),
                          ],
                        )
                      : state.meetUrl.trim().isNotEmpty
                      ? CopyLinkButton(url: state.meetUrl, size: 32)
                      : null,
                )
              : FormInput(
                  key: const ValueKey('place'),
                  label: l10n.location,
                  labelSuffix: l10n.optional,
                  icon: LucideIcons.mapPin,
                  hint: l10n.locationHint,
                  initialValue: state.location,
                  onChanged: cubit.setLocation,
                ),
        ),
        if (state.isEditing) ...[
          const SizedBox(height: 20),
          InfoNote(text: l10n.familiesWillBeTold, icon: LucideIcons.bell),
        ] else ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: BrandColors.line),
              borderRadius: BorderRadius.circular(AppRadii.row),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const IconBadge(icon: LucideIcons.repeat, accent: Accent.turquoise, size: IconBadgeSize.medium),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.repeatWeekly, style: text.rowTitle),
                          Text(
                            l10n.repeatWeeklyHint(weekdayName(state.date, language), fullDate(state.repeatUntil, language)),
                            style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                          ),
                        ],
                      ),
                    ),
                    BrandSwitch(value: state.repeatWeekly, onChanged: cubit.setRepeatWeekly, label: l10n.repeatWeekly),
                  ],
                ),
                AnimatedSize(
                  duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: state.repeatWeekly
                      ? Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: DateField(
                                  label: l10n.repeatUntil,
                                  value: state.repeatUntil,
                                  onChanged: cubit.setRepeatUntil,
                                  firstDate: DateTime(state.date.year, state.date.month, state.date.day),
                                  lastDate: DateTime(state.date.year + 1, 12, 31),
                                  errorText: state.errors.contains(SessionFormError.repeatUntil) ? l10n.timeRangeInvalid : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: LabeledField(
                                  label: l10n.sessionsToCreate,
                                  child: Container(
                                    height: 48,
                                    alignment: AlignmentDirectional.centerStart,
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: BrandColors.line),
                                      borderRadius: BorderRadius.circular(AppRadii.md),
                                    ),
                                    child: AnimatedCount(value: state.sessionCount, style: text.style(15, FontWeight.w700, tabular: true)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ],
        AnimatedSize(
          duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 220),
          child: overlap == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(color: Accent.amber.soft, borderRadius: BorderRadius.circular(AppRadii.md)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.clock, size: 16, color: Accent.amber.onSoft),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.overlapWarning(
                              '${isolated(overlap.group.name)}, ${timeRangeLabel(l10n, overlap.startsAt, overlap.endsAt)}',
                            ),
                            style: text.style(13, FontWeight.w600, color: Accent.amber.onSoft, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 20),
        FormInput(
          label: l10n.prepNotes,
          labelSuffix: l10n.privateNotesVisibility.toLowerCase(),
          hint: l10n.prepNotesHint,
          initialValue: state.prepNote,
          maxLines: 4,
          onChanged: cubit.setPrepNote,
        ),
      ],
    );
  }
}
