import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/router/routes.dart';
import '../../widgets/app_destination.dart';
import '../shared/my_contents_screen.dart';
import '../shared/my_homework_screen.dart';
import '../shared/my_planning_screen.dart';
import '../shared/my_results_screen.dart';
import 'student_home_screen.dart';

/// A pupil sees only what works today (user decision 2026-10-06): Cours since release 2 step 1, Devoirs since
/// step 3 (design `r2/DevoirsPhone.png`), Résultats since step 4 (design `r2/CorrectionPhone.png`).
List<AppDestination> studentDestinations() => [
  AppDestination(
    path: Routes.studentHome,
    icon: LucideIcons.house,
    label: (l10n) => l10n.navStudentHome,
    screen: () => const StudentHomeScreen(),
  ),
  AppDestination(
    path: Routes.studentCourses,
    icon: LucideIcons.bookOpen,
    label: (l10n) => l10n.navCourses,
    screen: () => const MyContentsScreen(),
  ),
  AppDestination(
    path: Routes.studentAssignments,
    icon: LucideIcons.clipboard,
    label: (l10n) => l10n.navAssignments,
    screen: () => const MyHomeworkScreen(),
  ),
  AppDestination(
    path: Routes.studentPlanning,
    icon: LucideIcons.calendar,
    label: (l10n) => l10n.navPlanning,
    screen: () => const MyPlanningScreen(),
  ),
  AppDestination(
    path: Routes.studentResults,
    icon: LucideIcons.chartColumn,
    label: (l10n) => l10n.navResults,
    screen: () => const MyResultsScreen(),
  ),
];
