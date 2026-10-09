import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/brand_colors.dart';
import '../../l10n/app_localizations.dart';
import 'account_menu.dart';
import 'app_destination.dart';
import 'brand_wordmark.dart';
import 'cards.dart';
import 'language_toggle.dart';
import 'notification_bell.dart';

/// The frame of a role space. Tablet and desktop: sidebar (labels from 1024 px, icons only below) and
/// a top bar. Phone: a header and a bottom bar. Mirrors itself in Arabic like the rest of the app.
class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({
    super.key,
    required this.destinations,
    required this.location,
    required this.child,
    this.topBarAction,
    this.sidebarExtra,
    this.bell,
    this.search,
    this.phoneSearch,
  });

  final List<AppDestination> destinations;
  final String location;
  final Widget child;

  /// The role's main action at the end of the top bar (the teacher's "Créer").
  final Widget? topBarAction;

  /// Under the navigation of the full sidebar (the teacher's "Mes groupes").
  final Widget? sidebarExtra;

  /// The child's notification bell: in the phone header and in the top bar.
  final Widget? bell;

  /// The teacher's search: a field at the start of the top bar, a magnifier beside the bell on phones.
  final Widget? search;
  final Widget? phoneSearch;

  AppDestination? get _current {
    for (final destination in destinations) {
      if (location.startsWith(destination.path)) return destination;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < Breakpoints.tablet) return _phone(context);
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(destinations: destinations, current: _current, compact: width < Breakpoints.desktop, extra: sidebarExtra),
          Expanded(
            child: Column(
              children: [
                AppTopBar(action: topBarAction, bell: bell, search: search),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _phone(BuildContext context) {
    final bar = destinations.where((destination) => destination.inPhoneBar).toList();
    final more = destinations.where((destination) => !destination.inPhoneBar).toList();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PhoneHeader(bell: bell, search: phoneSearch),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: destinations.length > 1 ? PhoneBottomNav(destinations: bar, more: more, current: _current) : null,
    );
  }
}

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key, required this.destinations, required this.current, required this.compact, this.extra});

  final List<AppDestination> destinations;
  final AppDestination? current;
  final bool compact;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: compact ? 88 : 264,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: BorderDirectional(end: BorderSide(color: BrandColors.line)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(start: compact ? 0 : 8),
            child: Align(
              alignment: compact ? Alignment.center : AlignmentDirectional.centerStart,
              child: compact
                  ? const BrandSymbol(height: 34)
                  : const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: BrandWordmark(size: WordmarkSize.sidebar),
                    ),
            ),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final destination in destinations) ...[
                    SidebarNavItem(
                      icon: destination.icon,
                      label: destination.label(l10n),
                      selected: identical(destination, current),
                      compact: compact,
                      count: destination.badge?.call(context),
                      onTap: () => context.go(destination.path),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (!compact) ?extra,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AccountMenu(
            builder: (context, user) => compact
                ? Center(
                    child: InitialsAvatar(initials: user.initials, solid: BrandColors.indigo),
                  )
                : SidebarUserCard(name: user.fullName, role: roleLabel(l10n, user.role), initials: user.initials),
          ),
        ],
      ),
    );
  }
}

class SidebarNavItem extends StatelessWidget {
  const SidebarNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
    this.count,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool compact;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final color = selected ? BrandColors.indigo : BrandColors.body;
    final radius = BorderRadius.circular(AppRadii.sm);
    final item = Material(
      color: selected ? BrandColors.indigoSoft : Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: SizedBox(
          height: 44,
          child: compact
              ? Center(child: Icon(icon, size: 20, color: color))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: text.style(14, selected ? FontWeight.w700 : FontWeight.w600, color: color),
                        ),
                      ),
                      if (count != null && count! > 0)
                        Container(
                          constraints: const BoxConstraints(minWidth: 22),
                          height: 22,
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: BrandColors.amber, borderRadius: BorderRadius.circular(AppRadii.pill)),
                          child: Text('$count', style: text.style(12, FontWeight.w800, tabular: true)),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
    return Semantics(
      selected: selected,
      child: compact ? Tooltip(message: label, child: item) : item,
    );
  }
}

class SidebarUserCard extends StatelessWidget {
  const SidebarUserCard({super.key, required this.name, required this.role, required this.initials});

  final String name;
  final String role;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.row),
      ),
      child: Row(
        children: [
          InitialsAvatar(initials: initials, solid: BrandColors.indigo),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, overflow: TextOverflow.ellipsis, style: text.style(14, FontWeight.w700)),
                Text(role, style: text.style(12, FontWeight.w500, color: BrandColors.slate)),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronDown, size: 18, color: BrandColors.slate),
        ],
      ),
    );
  }
}

/// White bar over the content: the search (the teacher's), then language, the bell and the role's main action.
class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key, this.action, this.bell, this.search});

  final Widget? action;
  final Widget? bell;
  final Widget? search;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: BrandColors.line)),
      ),
      child: Row(
        children: [
          if (search == null)
            const Spacer()
          else ...[
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: search),
              ),
            ),
            const SizedBox(width: 16),
          ],
          const LanguageToggleCompact(),
          if (bell != null) ...[const SizedBox(width: 12), bell!],
          if (action != null) ...[const SizedBox(width: 12), action!],
        ],
      ),
    );
  }
}

/// Phone header: short wordmark at the start, then the bell (if any) and the account avatar at the end.
class PhoneHeader extends StatelessWidget {
  const PhoneHeader({super.key, this.bell, this.search});

  final Widget? bell;
  final Widget? search;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 4),
      child: Row(
        children: [
          const BrandWordmark(size: WordmarkSize.short),
          const Spacer(),
          if (search != null) ...[search!, const SizedBox(width: 10)],
          if (bell != null) ...[bell!, const SizedBox(width: 10)],
          AccountMenu(
            builder: (context, user) => InitialsAvatar(initials: user.initials, solid: BrandColors.indigo),
          ),
        ],
      ),
    );
  }
}

class PhoneBottomNav extends StatelessWidget {
  const PhoneBottomNav({super.key, required this.destinations, required this.more, required this.current});

  final List<AppDestination> destinations;
  final List<AppDestination> more;
  final AppDestination? current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final inMore = current != null && more.contains(current);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: BrandColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              for (final destination in destinations)
                Expanded(
                  child: _BottomItem(
                    icon: destination.icon,
                    label: destination.label(l10n),
                    selected: identical(destination, current),
                    count: destination.badge?.call(context) ?? 0,
                    onTap: () => context.go(destination.path),
                  ),
                ),
              if (more.isNotEmpty)
                Expanded(
                  child: _BottomItem(icon: LucideIcons.ellipsis, label: l10n.navMore, selected: inMore, onTap: () => _showMore(context)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMore(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final destination in more) ...[
                SidebarNavItem(
                  icon: destination.icon,
                  label: destination.label(l10n),
                  selected: identical(destination, current),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.go(destination.path);
                  },
                ),
                const SizedBox(height: 4),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({required this.icon, required this.label, required this.selected, required this.onTap, this.count = 0});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int count;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 54,
              height: 30,
              decoration: BoxDecoration(
                color: selected ? BrandColors.indigoSoft : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(icon, size: 20, color: selected ? BrandColors.indigo : BrandColors.slate),
                  if (count > 0) PositionedDirectional(top: -2, start: 30, child: CountBadge(count: count)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.style(11, selected ? FontWeight.w800 : FontWeight.w600, color: selected ? BrandColors.indigo : BrandColors.slate),
            ),
          ],
        ),
      ),
    );
  }
}
