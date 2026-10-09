import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n/app_language.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/brand_colors.dart';
import '../../domain/model/app_user.dart';
import '../../l10n/app_localizations.dart';
import '../screens/shared/change_password_dialog.dart';
import '../stateManager/auth/auth_cubit.dart';
import '../stateManager/language/language_cubit.dart';
import 'cards.dart';

enum _AccountAction { french, arabic, password, logout }

String roleLabel(AppLocalizations l10n, UserRole role) => switch (role) {
  UserRole.admin => l10n.roleAdmin,
  UserRole.teacher => l10n.roleTeacher,
  UserRole.student => l10n.roleStudent,
  UserRole.parent => l10n.roleParent,
};

/// Who is signed in, language, password, sign out. [builder] draws what opens it (the sidebar user
/// card, or an avatar on phones and in the compact sidebar).
class AccountMenu extends StatelessWidget {
  const AccountMenu({super.key, required this.builder});

  final Widget Function(BuildContext context, AppUser user) builder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final user = context.select((AuthCubit cubit) => cubit.user);
    final language = context.watch<LanguageCubit>().state;
    if (user == null) return const SizedBox.shrink();

    PopupMenuItem<_AccountAction> item(_AccountAction value, IconData icon, String label, {bool checked = false}) => PopupMenuItem(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon, size: 18, color: checked ? BrandColors.indigo : BrandColors.body),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: text.style(14, checked ? FontWeight.w700 : FontWeight.w600, color: checked ? BrandColors.indigo : BrandColors.ink),
            ),
          ),
          if (checked) const Icon(LucideIcons.check, size: 16, color: BrandColors.indigo),
        ],
      ),
    );

    return PopupMenuButton<_AccountAction>(
      tooltip: l10n.accountMenu,
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(minWidth: 240),
      onSelected: (action) => _onSelected(context, action),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Row(
            children: [
              InitialsAvatar(initials: user.initials, solid: BrandColors.indigo, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName, style: text.style(14, FontWeight.w700)),
                    Text(roleLabel(l10n, user.role), style: text.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        item(_AccountAction.french, LucideIcons.languages, l10n.languageFrench, checked: language == AppLanguage.fr),
        item(_AccountAction.arabic, LucideIcons.languages, l10n.languageArabic, checked: language == AppLanguage.ar),
        const PopupMenuDivider(),
        item(_AccountAction.password, LucideIcons.lock, l10n.changePassword),
        item(_AccountAction.logout, LucideIcons.logOutDir, l10n.logout),
      ],
      child: builder(context, user),
    );
  }

  void _onSelected(BuildContext context, _AccountAction action) {
    switch (action) {
      case _AccountAction.french:
        context.read<LanguageCubit>().change(AppLanguage.fr);
      case _AccountAction.arabic:
        context.read<LanguageCubit>().change(AppLanguage.ar);
      case _AccountAction.password:
        showChangePasswordDialog(context);
      case _AccountAction.logout:
        context.read<AuthCubit>().logout();
    }
  }
}
