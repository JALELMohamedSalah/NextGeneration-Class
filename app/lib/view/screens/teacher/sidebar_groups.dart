import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../stateManager/groups/groups_cubit.dart';
import '../../widgets/school_widgets.dart';

/// "MES GROUPES" in the sidebar: hidden while there is no group (UI design spec 2).
class SidebarGroups extends StatelessWidget {
  const SidebarGroups({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final groups = context.watch<GroupsCubit>().state.groups;
    if (groups.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 12, bottom: 6),
          child: Text(text.upper(l10n.myGroups), style: text.overline(size: 11)),
        ),
        for (final group in groups)
          Builder(
            builder: (context) {
              final selected = location == Routes.teacherGroup(group.id);
              final radius = BorderRadius.circular(AppRadii.sm);
              return Material(
                color: selected ? BrandColors.chalk : Colors.transparent,
                borderRadius: radius,
                child: InkWell(
                  onTap: () => context.go(Routes.teacherGroup(group.id)),
                  borderRadius: radius,
                  hoverColor: BrandColors.chalk,
                  child: SizedBox(
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          GroupSquare(code: group.code, color: group.color),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(group.name, overflow: TextOverflow.ellipsis, style: text.style(14, FontWeight.w600)),
                          ),
                          const SizedBox(width: 8),
                          Text('${group.memberCount}', style: text.style(12, FontWeight.w500, color: BrandColors.slate, tabular: true)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
