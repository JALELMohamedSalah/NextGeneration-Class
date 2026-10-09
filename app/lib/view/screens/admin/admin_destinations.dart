import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/router/routes.dart';
import '../../widgets/app_destination.dart';
import 'teachers_screen.dart';

/// The owner of the platform: one section, the teachers' accounts.
List<AppDestination> adminDestinations() => [
  AppDestination(
    path: Routes.adminTeachers,
    icon: LucideIcons.graduationCap,
    label: (l10n) => l10n.navTeachers,
    screen: () => const TeachersScreen(),
  ),
];
