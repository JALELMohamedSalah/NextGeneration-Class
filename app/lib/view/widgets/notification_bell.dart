import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/brand_colors.dart';
import '../../l10n/app_localizations.dart';
import '../stateManager/notifications/notifications_cubit.dart';

/// The bell (header on phones, top bar on wider screens), with the number of unread notifications.
/// The child's opens its notifications page; the teacher's opens her panel ([onPressed]).
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key, this.size = 44, this.onPressed});

  final double size;
  final void Function(BuildContext context)? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = context.select((NotificationsCubit c) => c.state.unreadCount);
    final radius = BorderRadius.circular(AppRadii.sm);
    return Tooltip(
      message: l10n.navNotifications,
      child: Semantics(
        button: true,
        label: l10n.navNotifications,
        value: count > 0 ? l10n.notificationsUnread(count) : null,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: const BorderSide(color: BrandColors.line),
              ),
              child: InkWell(
                onTap: () => onPressed != null ? onPressed!(context) : context.push(Routes.studentNotifications),
                borderRadius: radius,
                child: SizedBox.square(
                  dimension: size,
                  child: const Icon(LucideIcons.bell, size: 20, color: BrandColors.body),
                ),
              ),
            ),
            if (count > 0) PositionedDirectional(top: -5, end: -5, child: CountBadge(count: count)),
          ],
        ),
      ),
    );
  }
}

/// Amber pill with a number: unread notifications on the bell and on the parent's tab.
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 18),
    height: 18,
    padding: const EdgeInsets.symmetric(horizontal: 5),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: BrandColors.amber,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: Text(
      count > 99 ? '99+' : '$count',
      textDirection: TextDirection.ltr,
      style: AppText.of(context).style(10, FontWeight.w800, height: 1, tabular: true),
    ),
  );
}
