import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../view/screens/admin/admin_destinations.dart';
import '../../view/screens/parent/parent_destinations.dart';
import '../../view/screens/shared/choose_password_screen.dart';
import '../../view/screens/shared/document_screen.dart';
import '../../domain/repositories/homework_repository.dart';
import '../../view/screens/shared/login_screen.dart';
import '../../view/screens/shared/my_homework_detail_screen.dart';
import '../../view/screens/shared/my_results_screen.dart';
import '../../view/screens/shared/notifications_screen.dart';
import '../../view/screens/shared/splash_screen.dart';
import '../../view/screens/student/student_destinations.dart';
import '../../domain/model/evaluation.dart';
import '../../view/screens/teacher/contents/contents_screen.dart';
import '../../view/screens/teacher/homework/assignment_screen.dart';
import '../../view/screens/teacher/homework/evaluation_screen.dart';
import '../../view/screens/teacher/homework/correction_screen.dart';
import '../../view/screens/teacher/planning/session_mode_screen.dart';
import '../../view/screens/teacher/sidebar_groups.dart';
import '../../view/screens/teacher/students/group_screen.dart';
import '../../view/screens/teacher/students/student_profile_screen.dart';
import '../../view/screens/teacher/students/students_screen.dart';
import '../../view/screens/teacher/teacher_destinations.dart';
import '../../view/screens/teacher/search/teacher_search.dart';
import '../../view/screens/teacher/students/student_import_screen.dart';
import '../../view/screens/teacher/teacher_notifications_panel.dart';
import '../../view/screens/teacher/teacher_quick_actions.dart';
import '../../view/stateManager/auth/auth_cubit.dart';
import '../../view/stateManager/groups/groups_cubit.dart';
import '../../view/stateManager/library/library_cubit.dart';
import '../../view/stateManager/notifications/notifications_cubit.dart';
import '../../view/stateManager/reference/reference_cubit.dart';
import '../../view/widgets/adaptive_shell.dart';
import '../../view/widgets/app_destination.dart';
import '../../view/widgets/notification_bell.dart';
import '../di/injection.dart';
import 'routes.dart';

GoRouter buildRouter(AuthCubit auth) => GoRouter(
  initialLocation: Routes.splash,
  refreshListenable: _StreamListenable(auth.stream),
  redirect: (context, state) => authRedirect(auth.state, state.matchedLocation),
  routes: [
    GoRoute(path: Routes.splash, builder: (context, state) => const SplashScreen()),
    GoRoute(path: Routes.login, builder: (context, state) => const LoginScreen()),
    GoRoute(path: Routes.choosePassword, builder: (context, state) => const ChoosePasswordScreen()),
    // Session mode takes the whole screen, without the shell.
    GoRoute(
      path: Routes.sessionMode(':id'),
      builder: (context, state) => SessionModeScreen(sessionId: state.pathParameters['id']!),
    ),
    // A document takes the whole screen; the teacher's comes with her library, groups and lists
    // (details, sharing, editing).
    GoRoute(
      path: Routes.teacherDocument(':id'),
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl.get<GroupsCubit>()..load()),
          BlocProvider(create: (_) => sl.get<ReferenceCubit>()..load()),
          BlocProvider(create: (_) => sl.get<LibraryCubit>()..load()),
        ],
        child: DocumentScreen(documentId: state.pathParameters['id']!, backTo: Routes.teacherContents, teacher: true),
      ),
    ),
    GoRoute(
      path: Routes.studentDocument(':id'),
      builder: (context, state) => DocumentScreen(documentId: state.pathParameters['id']!, backTo: Routes.studentCourses),
    ),
    GoRoute(
      path: Routes.parentDocument(':id'),
      builder: (context, state) => DocumentScreen(documentId: state.pathParameters['id']!, backTo: Routes.parentCourses),
    ),
    // Homework (spec 06): a pupil's work in the viewer, and a homework for the pupil or the parent, full screen.
    GoRoute(
      path: Routes.teacherSubmission(':id'),
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DocumentScreen(
          documentId: id,
          backTo: Routes.teacherAssignments,
          loader: () => sl.get<HomeworkRepository>().submissionView(id),
        );
      },
    ),
    GoRoute(
      path: Routes.teacherCorrection(':id', ':studentId'),
      builder: (context, state) =>
          CorrectionScreen(assignmentId: state.pathParameters['id']!, studentId: state.pathParameters['studentId']!),
    ),
    GoRoute(
      path: Routes.teacherCorrectionFile(':id', ':studentId'),
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final studentId = state.pathParameters['studentId']!;
        return DocumentScreen(
          documentId: '$id/$studentId',
          backTo: Routes.teacherAssignments,
          loader: () => sl.get<HomeworkRepository>().correctionFileView(id, studentId),
        );
      },
    ),
    GoRoute(
      path: Routes.studentCorrection(':id'),
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DocumentScreen(
          documentId: id,
          backTo: Routes.studentHomework(id),
          loader: () => sl.get<HomeworkRepository>().myCorrectionView(id),
        );
      },
    ),
    GoRoute(
      path: Routes.parentCorrection(':id'),
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final child = state.uri.queryParameters[Routes.childParam];
        return DocumentScreen(
          documentId: id,
          backTo: Routes.parentAssignments,
          loader: () => sl.get<HomeworkRepository>().myCorrectionView(id, studentId: child),
        );
      },
    ),
    GoRoute(
      path: Routes.studentHomework(':id'),
      builder: (context, state) => MyHomeworkDetailScreen(assignmentId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: Routes.studentSubmission(':id'),
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DocumentScreen(
          documentId: id,
          backTo: Routes.studentHomework(id),
          loader: () => sl.get<HomeworkRepository>().mySubmissionView(id),
        );
      },
    ),
    GoRoute(
      path: Routes.parentHomework(':id'),
      builder: (context, state) =>
          MyHomeworkDetailScreen(assignmentId: state.pathParameters['id']!, studentId: state.uri.queryParameters[Routes.childParam]),
    ),
    GoRoute(
      path: Routes.parentSubmission(':id'),
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final child = state.uri.queryParameters[Routes.childParam];
        return DocumentScreen(
          documentId: id,
          backTo: Routes.parentAssignments,
          loader: () => sl.get<HomeworkRepository>().mySubmissionView(id, studentId: child),
        );
      },
    ),
    _teacherShell(),
    _roleShell(
      studentDestinations(),
      bell: const NotificationBell(),
      extra: [_page(Routes.studentNotifications, (_) => const NotificationsScreen(showBack: true))],
    ),
    _roleShell(
      parentDestinations(),
      extra: [_page(Routes.parentResults, (state) => MyResultsScreen(childId: state.uri.queryParameters[Routes.childParam]))],
    ),
    _adminShell(),
  ],
);

/// The owner of the platform: the teachers' accounts, nothing of what is inside their spaces.
ShellRoute _adminShell() {
  final destinations = adminDestinations();
  return ShellRoute(
    builder: (context, state, child) => AdaptiveShell(destinations: destinations, location: state.matchedLocation, child: child),
    routes: _pages(destinations),
  );
}

/// The teacher's shell keeps her groups, the reference lists and her notifications (the bell) for every screen and panel.
ShellRoute _teacherShell() {
  final destinations = teacherDestinations();
  return ShellRoute(
    builder: (context, state, child) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl.get<GroupsCubit>()..load()),
        BlocProvider(create: (_) => sl.get<ReferenceCubit>()..load()),
        BlocProvider(create: (_) => sl.get<NotificationsCubit>()..refreshCount()),
      ],
      child: AdaptiveShell(
        destinations: destinations,
        location: state.matchedLocation,
        topBarAction: const CreateMenuButton(),
        bell: const NotificationBell(onPressed: TeacherNotificationsPanel.open),
        search: const TeacherSearchField(),
        phoneSearch: const SearchButton(),
        sidebarExtra: SidebarGroups(location: state.matchedLocation),
        child: child,
      ),
    ),
    routes: [
      ..._pages(destinations),
      _page(Routes.teacherGroups, (_) => const StudentsScreen(initialTab: StudentsTab.groups)),
      _page(Routes.teacherPrivateLessons, (_) => const StudentsScreen(initialTab: StudentsTab.privateLessons)),
      _page(Routes.teacherArchived, (_) => const StudentsScreen(initialTab: StudentsTab.archived)),
      _page(Routes.teacherStudentImport, (_) => const StudentImportScreen()),
      _page(Routes.teacherChapter(':id'), (state) => ContentsScreen(chapterId: state.pathParameters['id'])),
      _page(Routes.teacherStudent(':id'), (state) => StudentProfileScreen(studentId: state.pathParameters['id']!)),
      _page(Routes.teacherGroup(':id'), (state) => GroupScreen(groupId: state.pathParameters['id']!)),
      _page(Routes.teacherHomework(':id'), (state) => AssignmentScreen(assignmentId: state.pathParameters['id']!)),
      _page(
        Routes.teacherEvaluation(':id'),
        (state) => EvaluationScreen(evaluationId: state.pathParameters['id']!, created: state.extra as EvaluationDetail?),
      ),
    ],
  );
}

/// A student's or parent's shell: their notifications live here, so the bell and the tab badge follow
/// them on every page (refreshed every minute).
ShellRoute _roleShell(List<AppDestination> destinations, {Widget? bell, List<GoRoute> extra = const []}) => ShellRoute(
  builder: (context, state, child) => BlocProvider(
    create: (_) => sl.get<NotificationsCubit>()..refreshCount(),
    child: AdaptiveShell(destinations: destinations, location: state.matchedLocation, bell: bell, child: child),
  ),
  routes: [..._pages(destinations), ...extra],
);

List<GoRoute> _pages(List<AppDestination> destinations) => [
  for (final destination in destinations) _page(destination.path, (_) => destination.screen()),
];

/// Pages inside a shell swap without a transition: the cards of the new page rise in on their own.
GoRoute _page(String path, Widget Function(GoRouterState state) screen) => GoRoute(
  path: path,
  pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: screen(state)),
);

class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
