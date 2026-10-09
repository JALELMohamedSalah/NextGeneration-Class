import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/common/load_status.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/members/members_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/controls.dart';
import '../../../widgets/feedback.dart';
import '../../../widgets/panels.dart';

/// "Choisir les élèves" of a group. Returns the chosen student ids.
class MembersPanel extends StatelessWidget {
  const MembersPanel({super.key});

  static Future<List<String>?> open(BuildContext context, Iterable<String> current) => showSidePanel<List<String>>(
    context,
    builder: (_) => BlocProvider(create: (_) => MembersCubit(sl.get(), current)..load(), child: const MembersPanel()),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final state = context.watch<MembersCubit>().state;
    final cubit = context.read<MembersCubit>();
    return SidePanel(
      icon: LucideIcons.usersRound,
      title: l10n.chooseStudents,
      subtitle: l10n.selectedCount(state.selected.length),
      actions: [
        GhostButton(label: l10n.cancel, onPressed: () => Navigator.of(context).maybePop()),
        PrimaryButton(label: l10n.saveMembers, height: 44, onPressed: () => Navigator.of(context).pop(state.selected.toList())),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchBox(hint: l10n.searchStudents, onChanged: cubit.search),
          const SizedBox(height: 14),
          if (state.status == LoadStatus.loading)
            const LinearProgressIndicator(minHeight: 3)
          else if (state.status == LoadStatus.failure)
            FailureBanner(state.failure!, onRetry: cubit.load)
          else if (state.visible.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                state.students.isEmpty ? l10n.emptyStudents : l10n.noResults,
                style: text.style(14, FontWeight.w500, color: BrandColors.slate),
              ),
            )
          else
            for (final s in state.visible)
              CheckboxListTile(
                value: state.selected.contains(s.id),
                onChanged: (_) => cubit.toggle(s.id),
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: BrandColors.indigo,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
                secondary: InitialsAvatar(initials: s.initials, size: 36),
                title: Text(s.fullName, style: text.style(14, FontWeight.w700)),
                subtitle: Text(
                  [s.level.of(language), ...s.groups.map((g) => g.code)].join(l10n.dotSeparator),
                  style: text.style(13, FontWeight.w500, color: BrandColors.slate),
                ),
              ),
        ],
      ),
    );
  }
}
