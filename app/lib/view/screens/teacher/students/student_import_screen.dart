import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_language.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/l10n/joined_names.dart';
import '../../../../core/platform/document_printer.dart';
import '../../../../core/platform/file_opener.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../data/files/credential_cards_pdf.dart';
import '../../../../domain/model/app_user.dart';
import '../../../../domain/model/student_import.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/groups/groups_cubit.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/reference/reference_cubit.dart';
import '../../../stateManager/student_import/student_import_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/controls.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/page_frame.dart';
import '../../../widgets/panels.dart';
import '../../../widgets/school_widgets.dart';

/// Importing pupils from Excel or CSV (spec 02 "CSV import", design `r2/ImportEleves*.png`): Fichier, Vérifier,
/// Identifiants. Nothing is created before "Importer".
class StudentImportScreen extends StatelessWidget {
  const StudentImportScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocProvider(create: (_) => StudentImportCubit(sl.get(), sl.get()), child: const StudentImportView());
}

class StudentImportView extends StatelessWidget {
  const StudentImportView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final phone = isPhone(context);
    final state = context.watch<StudentImportCubit>().state;
    final preview = state.preview;
    final subtitle = switch (state.step) {
      ImportStep.file => l10n.importSubtitle,
      ImportStep.check => l10n.importReadLines(isolated(preview?.fileName ?? ''), preview?.rows.length ?? 0),
      ImportStep.done => l10n.credentialsSubtitle,
    };
    final header = <Widget>[
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          onPressed: () => context.go(Routes.teacherStudents),
          icon: const Icon(LucideIcons.arrowLeftDir, size: 18, color: BrandColors.indigo),
          label: Text(l10n.navStudents, style: text.style(14, FontWeight.w700, color: BrandColors.indigo)),
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.importTitle, style: text.pageTitle(phone: phone)),
          const SizedBox(height: 6),
          Text(subtitle, style: text.style(15, FontWeight.w500, color: BrandColors.body, height: 1.5)),
        ],
      ),
      _Steps(step: state.step),
      if (state.failure != null) FailureBanner(state.failure!),
    ];
    final body = switch (state.step) {
      ImportStep.file => const <Widget>[_FileStep()],
      ImportStep.check => const <Widget>[_Tiles(), _Rows()],
      ImportStep.done => const <Widget>[_Done()],
    };
    if (state.step != ImportStep.check) return PageScroll(children: [...header, ...body]);
    // Checking: the action stays in sight at the bottom.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: PageScroll(
            children: [
              ...header,
              ...body,
              if (preview != null && preview.count(ImportState.error) > 0) InfoNote(text: l10n.importErrorsNote),
            ],
          ),
        ),
        const _ActionBar(),
      ],
    );
  }
}

/// 1 Fichier, 2 Vérifier, 3 Identifiants; on phones a bar and "Étape 2 sur 3 · Vérifier".
class _Steps extends StatelessWidget {
  const _Steps({required this.step});

  final ImportStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final names = [l10n.importStepFile, l10n.importStepCheck, l10n.importStepAccounts];
    final current = step.index;
    if (isPhone(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: i <= current ? BrandColors.indigo : BrandColors.line,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(l10n.importStepOf(current + 1, names[current]), style: text.style(13, FontWeight.w700, color: BrandColors.indigo)),
        ],
      );
    }
    Widget dot(int i) {
      final done = i < current;
      final on = i == current;
      return Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: done || on ? BrandColors.indigo : Colors.white,
          shape: BoxShape.circle,
          border: done || on ? null : Border.all(color: const Color(0xFFCDD0DE), width: 1.5),
        ),
        child: done
            ? const Icon(LucideIcons.check, size: 15, color: Colors.white)
            : Text('${i + 1}', style: text.style(13, FontWeight.w800, color: on ? Colors.white : BrandColors.slate)),
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        for (var i = 0; i < 3; i++) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              dot(i),
              const SizedBox(width: 10),
              Text(
                names[i],
                style: text.style(
                  14,
                  i == current ? FontWeight.w800 : FontWeight.w600,
                  color: i == current ? BrandColors.ink : BrandColors.slate,
                ),
              ),
            ],
          ),
          if (i < 2) Container(width: 48, height: 2, color: i < current ? BrandColors.indigo : BrandColors.line),
        ],
      ],
    );
  }
}

// ── 1. The file ──

class _FileStep extends StatelessWidget {
  const _FileStep();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < Breakpoints.pairedBlocks) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _DropCard(),
              const SizedBox(height: 12),
              SecondaryButton(label: l10n.importTemplate, icon: LucideIcons.download, onPressed: () => _downloadTemplate(context)),
              const SizedBox(height: 16),
              const _Options(),
              const SizedBox(height: 16),
              const _ColumnsCard(),
            ],
          );
        }
        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [_DropCard(), SizedBox(height: 24), _ColumnsCard(withTemplate: true)],
              ),
            ),
            SizedBox(width: 24),
            Expanded(flex: 5, child: _Options()),
          ],
        );
      },
    );
  }
}

Future<void> _downloadTemplate(BuildContext context) {
  final language = context.read<LanguageCubit>().state;
  return sl.get<FileOpener>().download(context.read<StudentImportCubit>().templateUrl(language.code));
}

class _DropCard extends StatelessWidget {
  const _DropCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final reading = context.select((StudentImportCubit c) => c.state.reading);
    return Container(
      padding: EdgeInsets.all(isPhone(context) ? 22 : 34),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5FC),
        border: Border.all(color: const Color(0xFF9AA3D9), width: 1.5),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        children: [
          const IconBadge(icon: LucideIcons.fileSpreadsheet, accent: Accent.green),
          const SizedBox(height: 12),
          Text(l10n.importChooseTitle, textAlign: TextAlign.center, style: text.style(18, FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            reading ? l10n.importReading : l10n.importChooseHint,
            textAlign: TextAlign.center,
            style: text.style(13, FontWeight.w500, color: BrandColors.slate, height: 1.5),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: l10n.chooseFile,
            icon: LucideIcons.folderOpen,
            height: 46,
            loading: reading,
            onPressed: context.read<StudentImportCubit>().chooseFile,
          ),
        ],
      ),
    );
  }
}

class _ColumnsCard extends StatelessWidget {
  const _ColumnsCard({this.withTemplate = false});

  final bool withTemplate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final columns = [
      ('${l10n.importColFirstName} *', 'Yassine'),
      ('${l10n.importColLastName} *', 'Ben Ali'),
      (l10n.level, '4ème année'),
      (l10n.group, '4ème année · Maths'),
      (l10n.importColParentFirstName, 'Sonia'),
      (l10n.importColParentLastName, 'Ben Ali'),
      (l10n.importColParentPhone, '22345678'),
    ];
    Widget tip(String value) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.check, size: 15, color: Accent.green.onSoft),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: text.style(13, FontWeight.w500, color: BrandColors.body, height: 1.45)),
          ),
        ],
      ),
    );
    return SectionCard(
      title: l10n.importColumnsTitle,
      trailing: withTemplate
          ? SecondaryButton(label: l10n.importTemplate, icon: LucideIcons.download, height: 38, onPressed: () => _downloadTemplate(context))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.importColumnsHint, style: text.style(13, FontWeight.w500, color: BrandColors.slate, height: 1.45)),
          const SizedBox(height: 12),
          // The example line: scrolls sideways on a narrow screen rather than squeezing seven columns.
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: BrandColors.line),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Each column as wide as its widest cell: the grey band of the headings runs unbroken.
                  for (final (head, example) in columns)
                    IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            color: BrandColors.chalk,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Text(head, style: text.style(12, FontWeight.w700, color: BrandColors.body)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Text(example, style: text.style(13, FontWeight.w500)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          tip(l10n.importTipSiblings),
          tip(l10n.importTipNoParent),
        ],
      ),
    );
  }
}

class _Options extends StatelessWidget {
  const _Options();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final cubit = context.read<StudentImportCubit>();
    final state = context.watch<StudentImportCubit>().state;
    final groups = context.watch<GroupsCubit>().state.groups;
    final levels = context.watch<ReferenceCubit>().state.reference?.levels ?? const [];
    return SectionCard(
      title: l10n.importForAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SelectField<String?>(
            label: '${l10n.importGroup}${l10n.dotSeparator}${l10n.optional}',
            hint: l10n.importNoGroup,
            value: state.groupId,
            onChanged: (id) => cubit.setGroup(id, levelOfGroup: groups.where((g) => g.id == id).firstOrNull?.levelId),
            options: [
              SelectOption(null, l10n.importNoGroup),
              for (final g in groups)
                SelectOption(
                  g.id,
                  '${g.name}${l10n.dotSeparator}${l10n.studentsCount(g.memberCount)}',
                  leading: GroupSquare(code: g.code, color: g.color),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(l10n.importGroupHelp, style: text.style(12, FontWeight.w500, color: BrandColors.slate)),
          const SizedBox(height: 16),
          SelectField<String?>(
            label: l10n.importLevel,
            hint: l10n.chooseLevel,
            value: state.levelId,
            onChanged: cubit.setLevel,
            options: [for (final level in levels) SelectOption(level.id, level.name.of(language))],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: BrandColors.line),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BrandSwitch(value: state.createLogins, onChanged: cubit.setCreateLogins, label: l10n.importCreateLogins),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.importCreateLogins, style: text.style(14, FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(l10n.importCreateLoginsHelp, style: text.style(13, FontWeight.w500, color: BrandColors.slate, height: 1.45)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2. Checking every line ──

(String, Accent) _stateLook(AppLocalizations l10n, ImportState state) => switch (state) {
  ImportState.ready => (l10n.importStateReady, Accent.green),
  ImportState.parentKnown => (l10n.importStateKnown, Accent.blue),
  ImportState.exists => (l10n.importStateExists, Accent.amber),
  ImportState.error => (l10n.importStateError, Accent.red),
};

/// What a line says under the pupil's name: its problems, or why it is linked, left out or shared.
String? importNote(AppLocalizations l10n, ImportRow row) {
  if (row.state == ImportState.error) {
    return [
      for (final p in row.problems)
        switch (p) {
          'first_name_missing' => l10n.importProblemFirstName,
          'last_name_missing' => l10n.importProblemLastName,
          'level_missing' => l10n.importProblemLevelMissing,
          'level_unknown' => l10n.importProblemLevelUnknown(isolated(row.levelText)),
          'group_unknown' => l10n.importProblemGroupUnknown(isolated(row.groupText)),
          'phone_invalid' => l10n.importProblemPhoneInvalid,
          'phone_taken' => l10n.importProblemPhoneTaken,
          'parent_phone_missing' => l10n.importProblemParentPhoneMissing,
          'parent_phone_invalid' => l10n.importProblemParentPhoneInvalid,
          'parent_phone_taken' => l10n.importProblemParentPhoneTaken,
          'parent_name_missing' => l10n.importProblemParentName,
          'duplicate_in_file' => l10n.importProblemDuplicate(row.sameAs ?? 0),
          _ => l10n.importStateError,
        },
    ].join(' ');
  }
  if (row.state == ImportState.parentKnown) return l10n.importKnownNote(isolated(row.knownParent ?? ''), isolated(row.firstName));
  if (row.state == ImportState.exists) return l10n.importExistsNote(isolated(row.fullName));
  if (row.sameParentAs != null) return l10n.importSameParentNote(row.sameParentAs!);
  return null;
}

class _Tiles extends StatelessWidget {
  const _Tiles();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final preview = context.select((StudentImportCubit c) => c.state.preview);
    if (preview == null) return const SizedBox.shrink();
    final tiles = [
      (preview.count(ImportState.ready), l10n.importReadyCount, Accent.green),
      (preview.count(ImportState.parentKnown), l10n.importKnownCount, Accent.blue),
      (preview.count(ImportState.exists), l10n.importExistsCount, Accent.amber),
      (preview.count(ImportState.error), l10n.importErrorCount, Accent.red),
    ];
    if (isPhone(context)) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [for (final (count, label, accent) in tiles) StatusChip(label: '$count${l10n.dotSeparator}$label', accent: accent)],
      );
    }
    Widget tile(int count, String label, Accent accent) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.tile),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 40,
            decoration: BoxDecoration(color: accent.strong, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count', style: text.style(26, FontWeight.w800, tabular: true)),
                Text(label, maxLines: 2, style: text.style(13, FontWeight.w600, color: BrandColors.slate)),
              ],
            ),
          ),
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget row(List<(int, String, Accent)> items) => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, (count, label, accent)) in items.indexed) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: tile(count, label, accent)),
              ],
            ],
          ),
        );
        if (constraints.maxWidth >= 760) return row(tiles);
        return Column(children: [row(tiles.sublist(0, 2)), const SizedBox(height: 12), row(tiles.sublist(2))]);
      },
    );
  }
}

class _Rows extends StatelessWidget {
  const _Rows();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final preview = context.select((StudentImportCubit c) => c.state.preview);
    if (preview == null) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= Breakpoints.pairedBlocks;
        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final row in preview.rows) ...[_RowCard(row: row), const SizedBox(height: 10)],
            ],
          );
        }
        final style = text.overline(size: 11);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: BrandColors.line),
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    const SizedBox(width: 40),
                    SizedBox(width: 52, child: Text(text.upper(l10n.importColumnLine), style: style)),
                    const SizedBox(width: 52),
                    Expanded(flex: 3, child: Text(text.upper(l10n.columnStudent), style: style)),
                    Expanded(flex: 2, child: Text(text.upper(l10n.group), style: style)),
                    Expanded(flex: 2, child: Text(text.upper(l10n.importColumnParent), style: style)),
                    SizedBox(width: 180, child: Text(text.upper(l10n.importColumnState), style: style)),
                  ],
                ),
              ),
              for (final (i, row) in preview.rows.indexed) _RowLine(row: row, first: i == 0),
            ],
          ),
        );
      },
    );
  }
}

/// The pieces of a line, shared by the table and the phone cards.
class _LineParts {
  _LineParts(BuildContext context, this.row) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final levels = context.watch<ReferenceCubit>().state.reference;
    final groups = context.watch<GroupsCubit>().state.groups;
    final kept = context.select((StudentImportCubit c) => c.state.kept.contains(row.line));
    final cubit = context.read<StudentImportCubit>();
    final levelUnknown = row.problems.contains('level_unknown') || row.problems.contains('level_missing');
    final level = row.levelId == null ? row.levelText : (levels?.level(row.levelId!)?.name.of(language) ?? row.levelText);
    final (label, accent) = _stateLook(l10n, row.state);
    final note = importNote(l10n, row);
    final noteColor = switch (row.state) {
      ImportState.error => Accent.red.onSoft,
      ImportState.parentKnown => Accent.blue.onSoft,
      ImportState.exists => Accent.amber.onSoft,
      ImportState.ready => BrandColors.body,
    };
    final phoneProblem = row.problems.any((p) => p.startsWith('parent_phone'));

    checkbox = Checkbox(value: kept, activeColor: BrandColors.indigo, onChanged: row.importable ? (_) => cubit.toggle(row) : null);
    name = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(row.fullName.isEmpty ? '—' : row.fullName, style: text.rowTitle),
        if (level.isNotEmpty)
          Text(
            level,
            style: text.style(
              13,
              levelUnknown ? FontWeight.w700 : FontWeight.w500,
              color: levelUnknown ? Accent.red.onSoft : BrandColors.slate,
            ),
          ),
        if (note != null) ...[const SizedBox(height: 4), Text(note, style: text.style(12, FontWeight.w600, color: noteColor, height: 1.4))],
      ],
    );
    final group = groups.where((g) => row.groupIds.contains(g.id)).firstOrNull;
    this.group = group != null
        ? GroupLabel(code: group.code, color: group.color, name: group.name)
        : Text(
            row.groupText.isEmpty ? l10n.importNoGroup : row.groupText,
            style: text.style(13, FontWeight.w500, color: row.groupText.isEmpty ? BrandColors.slate : Accent.red.onSoft),
          );
    parent = row.hasParent || row.parentName.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (row.parentName.isNotEmpty || row.knownParent != null)
                Text(isolated(row.knownParent ?? row.parentName), style: text.style(14, FontWeight.w600)),
              if (row.parentPhone.isNotEmpty)
                Text(
                  row.parentPhone,
                  textDirection: TextDirection.ltr,
                  style: text.style(
                    13,
                    phoneProblem ? FontWeight.w700 : FontWeight.w500,
                    color: phoneProblem ? Accent.red.onSoft : BrandColors.slate,
                  ),
                ),
            ],
          )
        : Text(l10n.noParent, style: text.style(13, FontWeight.w500, color: BrandColors.slate));
    chip = StatusChip(label: label, accent: accent);
    initials = '${row.firstName.isEmpty ? '' : row.firstName[0]}${row.lastName.isEmpty ? '' : row.lastName[0]}'.toUpperCase();
  }

  final ImportRow row;
  late final Widget checkbox;
  late final Widget name;
  late final Widget group;
  late final Widget parent;
  late final Widget chip;
  late final String initials;
}

class _RowLine extends StatelessWidget {
  const _RowLine({required this.row, required this.first});

  final ImportRow row;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final parts = _LineParts(context, row);
    final error = row.state == ImportState.error;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: error ? const Color(0xFFFFFAFA) : null,
        border: first ? null : const Border(top: BorderSide(color: BrandColors.rowDivider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 40, child: parts.checkbox),
          SizedBox(
            width: 52,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('${row.line}', style: text.style(13, FontWeight.w600, color: BrandColors.slate, tabular: true)),
            ),
          ),
          InitialsAvatar(initials: parts.initials),
          const SizedBox(width: 12),
          Expanded(flex: 3, child: parts.name),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Padding(padding: const EdgeInsets.only(top: 10), child: parts.group),
          ),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: parts.parent),
          SizedBox(
            width: 180,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Align(alignment: AlignmentDirectional.centerStart, child: parts.chip),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowCard extends StatelessWidget {
  const _RowCard({required this.row});

  final ImportRow row;

  @override
  Widget build(BuildContext context) {
    final parts = _LineParts(context, row);
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 10, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.tile),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          parts.checkbox,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [parts.chip, parts.group]),
                  const SizedBox(height: 8),
                  parts.name,
                  const SizedBox(height: 6),
                  parts.parent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final phone = isPhone(context);
    final cubit = context.read<StudentImportCubit>();
    final state = context.watch<StudentImportCubit>().state;
    final count = state.keptRows.length;
    final summary = count == 0 ? l10n.importSummary(0) : '${l10n.importSummary(count)}${l10n.importSummaryParents(state.newParents)}';
    final import = PrimaryButton(
      label: l10n.importAction(count),
      icon: LucideIcons.arrowRightDir,
      height: phone ? 50 : 44,
      loading: state.importing,
      onPressed: count == 0 ? null : cubit.importKept,
    );
    final again = SecondaryButton(label: l10n.importAnotherFile, icon: LucideIcons.folderOpen, onPressed: cubit.restart);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: phone ? 16 : 32, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: BrandColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: phone
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(summary, style: text.style(13, FontWeight.w600, color: BrandColors.body)),
                  const SizedBox(height: 10),
                  // On a phone "Choisir un autre fichier" is the icon beside the action: the list keeps the room.
                  Row(
                    children: [
                      IconSquareButton(icon: LucideIcons.folderOpen, tooltip: l10n.importAnotherFile, size: 50, onPressed: cubit.restart),
                      const SizedBox(width: 10),
                      Expanded(child: import),
                    ],
                  ),
                ],
              )
            : Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Text(summary, style: text.style(14, FontWeight.w600, color: BrandColors.body)),
                  ),
                  again,
                  import,
                ],
              ),
      ),
    );
  }
}

// ── 3. The login details ──

class _Done extends StatelessWidget {
  const _Done();

  String _who(AppLocalizations l10n, ImportedAccount a) => a.account.role == UserRole.parent
      ? '${l10n.parentOf(joinedNames(l10n, a.children))}${l10n.dotSeparator}${l10n.parentLoginNote}'
      : l10n.roleStudent;

  Future<void> _copyAll(BuildContext context, List<ImportedAccount> accounts) async {
    final l10n = AppLocalizations.of(context);
    final message = [
      for (final a in accounts)
        l10n.credentialsMessage(a.account.firstName, l10n.appTitle, a.account.username, a.account.temporaryPassword),
    ].join('\n\n');
    await Clipboard.setData(ClipboardData(text: message));
    if (context.mounted) showNotice(context, l10n.copied);
  }

  Future<void> _print(BuildContext context, List<ImportedAccount> accounts) async {
    final l10n = AppLocalizations.of(context);
    final arabic = context.read<LanguageCubit>().state == AppLanguage.ar;
    final printer = sl.get<DocumentPrinter>();
    final cards = [
      for (final a in accounts)
        PrintedCard(
          title: l10n.printCardTitle(a.account.fullName),
          subtitle: _who(l10n, a),
          usernameLabel: l10n.credentialUsername,
          username: a.account.username,
          passwordLabel: l10n.credentialPassword,
          password: a.account.temporaryPassword,
          help: l10n.printCardHelp,
        ),
    ];
    try {
      final fonts = await printer.fonts(arabic: arabic);
      await printer.printPdf(
        l10n.printFileName,
        (format) => credentialCardsPdf(format: format, cards: cards, fonts: fonts, rtl: arabic, brand: l10n.appTitle),
      );
    } on Object {
      if (context.mounted) showNotice(context, l10n.errorUnknown);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final phone = isPhone(context);
    final state = context.watch<StudentImportCubit>().state;
    final result = state.result!;
    final group = context.watch<GroupsCubit>().state.groups.where((g) => g.id == state.groupId).firstOrNull;
    final title = group == null
        ? l10n.importDoneTitle(result.created)
        : l10n.importAddedTo(l10n.importDoneTitle(result.created), isolated(group.name));
    final parents = result.accounts.where((a) => a.account.role == UserRole.parent).length;
    final accounts = result.accounts;
    // "Tout copier" and "Imprimer" beside the title on a computer, under the list below that.
    final compact = MediaQuery.sizeOf(context).width < Breakpoints.desktop;

    Widget box(String label, String value, {bool mono = false}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: BrandColors.chalk, borderRadius: BorderRadius.circular(AppRadii.sm)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text.upper(label), style: text.overline(size: 10)),
          const SizedBox(height: 2),
          SelectableText(
            value,
            textDirection: TextDirection.ltr,
            style: mono
                ? text
                      .style(16, FontWeight.w800, spacing: 1)
                      .copyWith(fontFamily: 'monospace', fontFamilyFallback: const ['Menlo', 'Courier'])
                : text.style(16, FontWeight.w800),
          ),
        ],
      ),
    );

    Widget account(ImportedAccount a, bool first) {
      final initials =
          '${a.account.firstName.isEmpty ? '' : a.account.firstName[0]}${a.account.lastName.isEmpty ? '' : a.account.lastName[0]}'
              .toUpperCase();
      final copy = IconSquareButton(
        icon: LucideIcons.copy,
        tooltip: l10n.copy,
        size: 38,
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: '${a.account.username}\n${a.account.temporaryPassword}'));
          if (context.mounted) showNotice(context, l10n.copied);
        },
      );
      final who = Row(
        children: [
          InitialsAvatar(initials: initials),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.account.fullName, style: text.rowTitle),
                Text(_who(l10n, a), style: text.style(13, FontWeight.w500, color: BrandColors.slate)),
              ],
            ),
          ),
          if (phone) copy,
        ],
      );
      final login = box(l10n.credentialUsername, a.account.username);
      final password = box(l10n.credentialPassword, a.account.temporaryPassword, mono: true);
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: first ? null : const Border(top: BorderSide(color: BrandColors.rowDivider)),
        ),
        child: phone
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  who,
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: login),
                      const SizedBox(width: 8),
                      Expanded(child: password),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(flex: 5, child: who),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: login),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: password),
                  const SizedBox(width: 12),
                  copy,
                ],
              ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(phone ? 16 : 22),
          decoration: BoxDecoration(
            color: Accent.green.soft,
            border: Border.all(color: const Color(0xFFC7E9CF)),
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Row(
            children: [
              const IconBadge(icon: LucideIcons.circleCheck, accent: Accent.green),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.style(phone ? 16 : 20, FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.importDoneParents(parents)}${l10n.importDoneLinked(result.linked)}',
                      style: text.style(14, FontWeight.w600, color: Accent.green.onSoft),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (accounts.isEmpty)
          InfoNote(text: l10n.importNoAccounts)
        else ...[
          SectionCard(
            title: l10n.credentialsTitle,
            count: accounts.length,
            countAccent: Accent.indigo,
            trailing: compact
                ? null
                : Wrap(
                    spacing: 8,
                    children: [
                      SecondaryButton(
                        label: l10n.importCopyAll,
                        icon: LucideIcons.copy,
                        height: 38,
                        onPressed: () => _copyAll(context, accounts),
                      ),
                      SecondaryButton(
                        label: l10n.importPrint,
                        icon: LucideIcons.printer,
                        height: 38,
                        onPressed: () => _print(context, accounts),
                      ),
                    ],
                  ),
            child: Column(children: [for (final (i, a) in accounts.indexed) account(a, i == 0)]),
          ),
          if (compact) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(label: l10n.importCopyAll, icon: LucideIcons.copy, onPressed: () => _copyAll(context, accounts)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SecondaryButton(label: l10n.importPrint, icon: LucideIcons.printer, onPressed: () => _print(context, accounts)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          InfoNote(text: l10n.importPrintNote, icon: LucideIcons.lock),
        ],
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 10,
          runSpacing: 10,
          children: [
            SecondaryButton(label: l10n.importAgain, onPressed: context.read<StudentImportCubit>().restart),
            PrimaryButton(label: l10n.importSeeStudents, height: 44, onPressed: () => context.go(Routes.teacherStudents)),
          ],
        ),
      ],
    );
  }
}
