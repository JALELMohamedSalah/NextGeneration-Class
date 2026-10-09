import '../../domain/model/app_user.dart';
import '../../view/stateManager/auth/auth_state.dart';

/// Every path of the app. Each role has its own area; a user never sees another role's screens.
abstract final class Routes {
  static const splash = '/';
  static const login = '/connexion';
  static const choosePassword = '/mot-de-passe';

  static const teacherArea = '/enseignante';
  static const teacherHome = '$teacherArea/journee';
  static const teacherPlanning = '$teacherArea/planning';
  static const teacherStudents = '$teacherArea/eleves';
  static const teacherContents = '$teacherArea/contenus';
  static const teacherAssignments = '$teacherArea/devoirs';
  static const teacherAnnouncements = '$teacherArea/annonces';
  static const teacherSettings = '$teacherArea/parametres';

  /// Groups live under Élèves, so the sidebar keeps Élèves selected.
  static const teacherGroups = '$teacherStudents/groupes';
  static const teacherPrivateLessons = '$teacherStudents/cours-particuliers';
  static const teacherArchived = '$teacherStudents/archives';

  /// Importing a class from Excel or CSV.
  static const teacherStudentImport = '$teacherStudents/importer';
  static String teacherStudent(String id) => '$teacherStudents/fiche/$id';
  static String teacherGroup(String id) => '$teacherStudents/groupe/$id';

  /// A document of the library, full screen.
  static String teacherDocument(String id) => '$teacherContents/document/$id';

  /// Contenus opened on one chapter (from the search).
  static String teacherChapter(String id) => '$teacherContents/chapitre/$id';

  /// A homework of the teacher (inside the shell), and a pupil's work (full screen).
  static String teacherHomework(String id) => '$teacherAssignments/devoir/$id';

  /// A paper evaluation's score table (inside the shell).
  static String teacherEvaluation(String id) => '$teacherAssignments/evaluation/$id';
  static String teacherSubmission(String id) => '$teacherAssignments/rendu/$id';

  /// One pupil's copy to correct (full screen), and the teacher's corrected copy.
  static String teacherCorrection(String assignmentId, String studentId) => '$teacherAssignments/corriger/$assignmentId/$studentId';
  static String teacherCorrectionFile(String assignmentId, String studentId) => '$teacherAssignments/corrige/$assignmentId/$studentId';

  /// Session mode: full screen, outside the shell.
  static String sessionMode(String id) => '$teacherArea/seance/$id';

  /// The owner of the platform: teachers' accounts.
  static const adminArea = '/admin';
  static const adminTeachers = '$adminArea/enseignants';

  static const studentArea = '/eleve';
  static const studentHome = '$studentArea/accueil';
  static const studentCourses = '$studentArea/cours';
  static const studentAssignments = '$studentArea/devoirs';
  static const studentPlanning = '$studentArea/planning';
  static const studentResults = '$studentArea/resultats';

  static String studentDocument(String id) => '$studentCourses/document/$id';
  static String studentHomework(String id) => '$studentAssignments/devoir/$id';
  static String studentSubmission(String id) => '$studentAssignments/devoir/$id/rendu';
  static String studentCorrection(String id) => '$studentAssignments/devoir/$id/corrige';

  /// Opened from the bell of the student's header (not a tab).
  static const studentNotifications = '$studentArea/notifications';

  static const parentArea = '/parent';
  static const parentOverview = '$parentArea/apercu';
  static const parentCourses = '$parentArea/cours';
  static String parentDocument(String id) => '$parentCourses/document/$id';
  static const parentAssignments = '$parentArea/devoirs';
  static String parentHomework(String id) => '$parentAssignments/devoir/$id';
  static String parentSubmission(String id) => '$parentAssignments/devoir/$id/rendu';
  static String parentCorrection(String id) => '$parentAssignments/devoir/$id/corrige';

  /// A child's results, opened from the overview cards (inside the shell: Aperçu stays selected).
  static const parentResults = '$parentOverview/resultats';
  static const parentPlanning = '$parentArea/planning';
  static const parentNotifications = '$parentArea/notifications';

  /// Query parameter of the parent's planning: the child to show first.
  static const childParam = 'enfant';

  static String areaOf(UserRole role) => switch (role) {
    UserRole.admin => adminArea,
    UserRole.teacher => teacherArea,
    UserRole.student => studentArea,
    UserRole.parent => parentArea,
  };

  static String homeOf(UserRole role) => switch (role) {
    UserRole.admin => adminTeachers,
    UserRole.teacher => teacherHome,
    UserRole.student => studentHome,
    UserRole.parent => parentOverview,
  };
}

/// Where the app must go for this session state, or null to stay on [location].
String? authRedirect(AuthState auth, String location) {
  switch (auth) {
    case AuthUnknown():
      return location == Routes.splash ? null : Routes.splash;
    case AuthSignedOut():
      return location == Routes.login ? null : Routes.login;
    case AuthSignedIn(:final user):
      if (user.mustChangePassword) {
        return location == Routes.choosePassword ? null : Routes.choosePassword;
      }
      return location.startsWith('${Routes.areaOf(user.role)}/') ? null : Routes.homeOf(user.role);
  }
}
