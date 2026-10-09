import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/router/routes.dart';
import '../../stateManager/notifications/notifications_cubit.dart';
import '../../widgets/app_destination.dart';
import '../shared/my_contents_screen.dart';
import '../shared/my_homework_screen.dart';
import '../shared/notifications_screen.dart';
import '../shared/my_planning_screen.dart';
import 'parent_overview_screen.dart';

List<AppDestination> parentDestinations() => [
  AppDestination(
    path: Routes.parentOverview,
    icon: LucideIcons.layoutDashboard,
    label: (l10n) => l10n.navParentOverview,
    screen: () => const ParentOverviewScreen(),
  ),
  AppDestination(
    path: Routes.parentCourses,
    icon: LucideIcons.bookOpen,
    label: (l10n) => l10n.navCourses,
    screen: () => const MyContentsScreen(),
  ),
  AppDestination(
    path: Routes.parentAssignments,
    icon: LucideIcons.clipboard,
    label: (l10n) => l10n.navAssignments,
    screen: () => const MyHomeworkScreen(),
  ),
  AppDestination(
    path: Routes.parentPlanning,
    icon: LucideIcons.calendar,
    label: (l10n) => l10n.navPlanning,
    screen: () => const MyPlanningScreen(),
  ),
  AppDestination(
    path: Routes.parentNotifications,
    icon: LucideIcons.bell,
    label: (l10n) => l10n.navNotifications,
    badge: (context) => context.select((NotificationsCubit c) => c.state.unreadCount),
    screen: () => const NotificationsScreen(),
  ),
];
