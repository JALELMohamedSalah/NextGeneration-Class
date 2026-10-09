import '../../domain/model/app_user.dart';
import '../../domain/model/student.dart';
import '../../domain/model/teacher_account.dart';
import '../../domain/repositories/admin_repository.dart';
import '../dto/school_dto.dart';
import '../remote/admin_api.dart';
import 'api_guard.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._api);

  final AdminApi _api;

  @override
  Future<TeachersOverview> teachers() => guard(() async {
    final json = await _api.teachers();
    final totals = json['totals'] as Json? ?? const {};
    int count(String key) => (totals[key] as num? ?? 0).toInt();
    return TeachersOverview(
      totals: TeachersTotals(
        teachers: count('teachers'),
        activeTeachers: count('activeTeachers'),
        students: count('students'),
        parents: count('parents'),
        groups: count('groups'),
      ),
      teachers: [for (final item in jsonList(json['teachers'])) teacherOf(item)],
    );
  });

  @override
  Future<(TeacherAccount, NewAccount)> createTeacher(TeacherDraft draft) => guard(() async {
    final json = await _api.createTeacher(draft.toJson());
    return (teacherOf(json['teacher'] as Json), credentialOf(json['credential'] as Json));
  });

  @override
  Future<NewAccount> resetPassword(TeacherAccount teacher) => guard(() async => credentialOf(await _api.resetPassword(teacher.id)));

  @override
  Future<void> setActive(String teacherId, {required bool active}) => guard(() => _api.setActive(teacherId, active: active));
}

TeacherAccount teacherOf(Json json) => TeacherAccount(
  id: json['id'] as String,
  firstName: json['firstName'] as String? ?? '',
  lastName: json['lastName'] as String? ?? '',
  username: json['username'] as String? ?? '',
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  active: json['active'] as bool? ?? true,
  awaitingFirstLogin: json['awaitingFirstLogin'] as bool? ?? false,
  lastLoginAt: instant(json['lastLoginAt']),
  createdAt: instant(json['createdAt']) ?? DateTime.now().toUtc(),
  students: (json['students'] as num? ?? 0).toInt(),
  parents: (json['parents'] as num? ?? 0).toInt(),
  groups: (json['groups'] as num? ?? 0).toInt(),
);

NewAccount credentialOf(Json json) => NewAccount(
  userId: json['userId'] as String,
  role: UserRole.teacher,
  firstName: json['firstName'] as String? ?? '',
  lastName: json['lastName'] as String? ?? '',
  username: json['username'] as String? ?? '',
  temporaryPassword: json['temporaryPassword'] as String,
);
