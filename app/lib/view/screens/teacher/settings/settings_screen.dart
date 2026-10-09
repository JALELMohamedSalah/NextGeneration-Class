import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_language.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/reference.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/common/load_status.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/reference/reference_cubit.dart';
import '../../../stateManager/settings/subjects_settings_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/classmates.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/labels.dart';
import '../../../widgets/page_frame.dart';
import '../../../widgets/panels.dart';
import '../subject_dialog.dart';

/// "Paramètres" (design `r1/Parametres.png`, approved without its tabs on 2026-10-06): the teacher's
/// subjects, the levels and the school year. Only the subjects can be changed here.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(create: (_) => sl.get<SubjectsSettingsCubit>()..load(), child: const SettingsView());
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    return PageScroll(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.navSettings, style: text.pageTitle(phone: isPhone(context))),
            const SizedBox(height: 6),
            Text(l10n.settingsSubtitle, style: text.style(15, FontWeight.w500, color: BrandColors.body)),
          ],
        ),
        const PairedBlocks(
          equalHeight: false,
          start: _SubjectsCard(),
          end: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [_LevelsCard(), SizedBox(height: 24), _SchoolYearCard()]),
        ),
      ],
    );
  }
}

class _SubjectsCard extends StatelessWidget {
  const _SubjectsCard();

  Future<void> _create(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final subject = await showSubjectDialog(context);
    if (subject == null || !context.mounted) return;
    context.read<SubjectsSettingsCubit>().saved(subject);
    showNotice(context, l10n.subjectCreated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<SubjectsSettingsCubit>().state;
    final Widget body;
    if (state.status == LoadStatus.failure && state.subjects.isEmpty) {
      body = FailureBanner(state.failure!, onRetry: context.read<SubjectsSettingsCubit>().load);
    } else if (state.status == LoadStatus.loading && state.subjects.isEmpty) {
      body = const LinearProgressIndicator(minHeight: 3);
    } else if (state.subjects.isEmpty) {
      body = EmptyState(
        message: l10n.noSubjectsYet,
        action: PrimaryButton(label: l10n.newSubject, icon: LucideIcons.plus, height: 44, onPressed: () => _create(context)),
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < state.subjects.length; i++) _SubjectRow(usage: state.subjects[i], first: i == 0),
          const SizedBox(height: 12),
          InfoNote(text: l10n.subjectDeleteRule),
        ],
      );
    }
    return SectionCard(
      title: l10n.yourSubjects,
      trailing: state.subjects.isEmpty
          ? null
          : PrimaryButton(label: l10n.newSubject, icon: LucideIcons.plus, height: 38, onPressed: () => _create(context)),
      child: body,
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.usage, required this.first});

  final SubjectUsage usage;
  final bool first;

  Future<void> _edit(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final subject = await showSubjectDialog(context, editing: usage.subject);
    if (subject == null || !context.mounted) return;
    context.read<SubjectsSettingsCubit>().saved(subject);
    showNotice(context, l10n.subjectUpdated);
  }

  Future<void> _delete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final language = context.read<LanguageCubit>().state;
    final confirmed = await confirmAction(
      context,
      title: l10n.deleteSubjectTitle(usage.subject.name.of(language)),
      text: l10n.deleteSubjectText,
      confirmLabel: l10n.delete,
      icon: LucideIcons.trash2,
    );
    if (!confirmed || !context.mounted) return;
    final failure = await context.read<ReferenceCubit>().deleteSubject(usage.subject.id);
    if (!context.mounted) return;
    final settings = context.read<SubjectsSettingsCubit>();
    if (failure == null) {
      settings.removed(usage.subject.id);
      showNotice(context, l10n.subjectDeleted);
    } else {
      showNotice(context, failureText(l10n, failure));
      // A group may have taken the subject meanwhile: show the real counts.
      if (failure.code == 'subject_in_use') settings.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phone = isPhone(context);
    final usagePill = _UsagePill(count: usage.groupCount);
    final delete = Opacity(
      opacity: usage.inUse ? 0.4 : 1,
      child: IconSquareButton(
        icon: LucideIcons.x,
        tooltip: usage.inUse ? l10n.subjectInUse : l10n.delete,
        danger: !usage.inUse,
        size: 38,
        onPressed: usage.inUse ? null : () => _delete(context),
      ),
    );
    return Container(
      padding: EdgeInsets.symmetric(vertical: phone ? 12 : 16),
      decoration: BoxDecoration(
        border: first ? null : const Border(top: BorderSide(color: BrandColors.rowDivider)),
      ),
      child: Row(
        children: [
          Container(
            width: phone ? 36 : 40,
            height: phone ? 36 : 40,
            decoration: BoxDecoration(color: colorFromHex(usage.subject.color), borderRadius: BorderRadius.circular(AppRadii.sm)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SubjectNames(subject: usage.subject),
                if (phone) ...[const SizedBox(height: 8), usagePill],
              ],
            ),
          ),
          if (!phone) ...[const SizedBox(width: 12), usagePill, const SizedBox(width: 12)],
          phone
              ? IconSquareButton(icon: LucideIcons.pencil, tooltip: l10n.edit, size: 38, onPressed: () => _edit(context))
              : SecondaryButton(label: l10n.edit, icon: LucideIcons.pencil, height: 38, onPressed: () => _edit(context)),
          const SizedBox(width: 8),
          delete,
        ],
      ),
    );
  }
}

/// The name in the interface language first, then the other one. Each name is set in its own script
/// and direction, whatever the interface language. A missing Arabic name says the French one is shown.
class _SubjectNames extends StatelessWidget {
  const _SubjectNames({required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final arabicUi = context.watch<LanguageCubit>().state == AppLanguage.ar;
    final hasArabic = subject.name.ar.trim().isNotEmpty;

    Widget name(String value, {required bool arabic, required bool primary}) => Text(
      value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
      style: text.inScript(primary ? text.rowTitle : text.style(14, FontWeight.w500, color: BrandColors.body), arabic: arabic),
    );

    final french = name(subject.name.fr, arabic: false, primary: !arabicUi || !hasArabic);
    final missing = Text(l10n.subjectNoArabicName, style: text.style(13, FontWeight.w500, color: BrandColors.slate));
    final lines = !hasArabic
        ? [french, missing]
        : arabicUi
        ? [name(subject.name.ar, arabic: true, primary: true), french]
        : [french, name(subject.name.ar, arabic: true, primary: false)];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [lines[0], const SizedBox(height: 2), lines[1]]);
  }
}

/// "2 groupes" on indigo soft, "Aucun groupe" on grey.
class _UsagePill extends StatelessWidget {
  const _UsagePill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = count > 0 ? Accent.indigo : Accent.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: accent.soft, borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Text(capitalized(l10n.groupsCount(count)), style: AppText.of(context).style(12, FontWeight.w700, color: accent.onSoft)),
    );
  }
}

class _LevelsCard extends StatelessWidget {
  const _LevelsCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final reference = context.watch<ReferenceCubit>().state.reference;
    return SectionCard(
      title: l10n.levelsTitle,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: Accent.turquoise.soft, borderRadius: BorderRadius.circular(AppRadii.pill)),
        child: Text(l10n.primarySchool, style: text.style(12, FontWeight.w700, color: Accent.turquoise.onSoft)),
      ),
      child: reference == null
          ? const LinearProgressIndicator(minHeight: 3)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final level in reference.levels)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: BrandColors.chalk, borderRadius: BorderRadius.circular(AppRadii.pill)),
                        child: Text(level.name.of(language), style: text.style(13, FontWeight.w700)),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                InfoNote(text: l10n.levelsNote),
              ],
            ),
    );
  }
}

class _SchoolYearCard extends StatelessWidget {
  const _SchoolYearCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final year = context.watch<ReferenceCubit>().state.reference?.currentYear;
    return SectionCard(
      title: l10n.schoolYearTitle,
      child: Row(
        children: [
          const IconBadge(icon: LucideIcons.calendar),
          const SizedBox(width: 12),
          Expanded(
            child: year == null
                ? Text(l10n.noValue, style: text.rowTitle)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(year.label, textDirection: TextDirection.ltr, style: text.style(15, FontWeight.w700, tabular: true)),
                      const SizedBox(height: 2),
                      Text(
                        l10n.schoolYearRange(fullDate(year.startsOn, language), fullDate(year.endsOn, language)),
                        style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
