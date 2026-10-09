import '../model/student.dart';
import '../model/teacher_account.dart';

/// The owner's dashboard (`/admin/teachers`). Every call throws an `ApiFailure` when refused.
abstract interface class AdminRepository {
  Future<TeachersOverview> teachers();

  /// The new account and its login details, shown once.
  Future<(TeacherAccount, NewAccount)> createTeacher(TeacherDraft draft);

  Future<NewAccount> resetPassword(TeacherAccount teacher);

  Future<void> setActive(String teacherId, {required bool active});
}
