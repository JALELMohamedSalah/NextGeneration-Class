import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/groups/groups_cubit.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/reference/reference_cubit.dart';
import '../../../stateManager/share/share_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/panels.dart';
import '../../../widgets/school_widgets.dart';

/// "Partager": the groups that see a document or a whole chapter in their Cours. Returns the saved
/// document or chapter, or null when cancelled.
Future<Object?> showShareDialog(BuildContext context, ShareTarget target) {
  final groups = context.read<GroupsCubit>();
  final reference = context.read<ReferenceCubit>();
  return showAppDialog<Object>(
    context,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: groups),
        BlocProvider.value(value: reference),
        BlocProvider(create: (_) => ShareCubit(sl.get(), target)),
      ],
      child: const _ShareDialog(),
    ),
  );
}

class _ShareDialog extends StatelessWidget {
  const _ShareDialog();

  Future<void> _save(BuildContext context) async {
    final saved = await context.read<ShareCubit>().save();
    if (saved != null && context.mounted) Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final state = context.watch<ShareCubit>().state;
    final cubit = context.read<ShareCubit>();
    final groups = context.watch<GroupsCubit>().state.groups;
    final (title, subtitle, levelId) = switch (cubit.target) {
      DocumentTarget(:final document) => (l10n.shareDocumentTitle(document.title), l10n.shareSubtitle, document.levelId),
      ChapterTarget(:final chapter) => (l10n.shareChapterTitle(chapter.title), l10n.shareChapterSubtitle, chapter.levelId),
    };
    final level = context.watch<ReferenceCubit>().state.reference?.levels.where((l) => l.id == levelId).firstOrNull;
    final sameLevel = groups.where((g) => g.levelId == levelId).toList();
    final others = groups.where((g) => g.levelId != levelId).toList();
    Widget section(String label, List<Group> list) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Text(text.upper(label), style: text.overline(size: 11)),
        ),
        for (final g in list) ...[
          _GroupOption(group: g, selected: state.selected.contains(g.id), onTap: () => cubit.toggle(g.id)),
          const SizedBox(height: 8),
        ],
      ],
    );
    return AppDialog(
      icon: LucideIcons.share2,
      title: title,
      subtitle: subtitle,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.failure != null) ...[FailureBanner(state.failure!), const SizedBox(height: 16)],
          if (groups.isEmpty) InfoNote(text: l10n.noGroupsYet),
          if (sameLevel.isNotEmpty) section(level == null ? l10n.otherGroups : l10n.groupsOfLevel(level.name.of(language)), sameLevel),
          if (others.isNotEmpty) section(l10n.otherGroups, others),
          const SizedBox(height: 4),
          InfoNote(text: l10n.unshareNote),
        ],
      ),
      actions: [
        GhostButton(label: l10n.cancel, onPressed: () => Navigator.of(context).maybePop()),
        PrimaryButton(label: l10n.save, height: 44, loading: state.saving, onPressed: () => _save(context)),
      ],
    );
  }
}

/// A group with a box to tick: indigo frame and fill when chosen.
class _GroupOption extends StatelessWidget {
  const _GroupOption({required this.group, required this.selected, required this.onTap});

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
                  size: 22,
                  color: selected ? BrandColors.indigo : const Color(0xFFADB1C6),
                ),
                const SizedBox(width: 12),
                GroupSquare(code: group.code, color: group.color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.style(14, FontWeight.w700)),
                      Text(l10n.studentsCount(group.memberCount), style: text.style(12, FontWeight.w500, color: BrandColors.slate)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
