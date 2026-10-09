import '../../domain/model/app_user.dart';
import '../../domain/model/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../dto/student_dto.dart';
import '../remote/students_api.dart';
import 'api_guard.dart';

class StudentRepositoryImpl implements StudentRepository {
  StudentRepositoryImpl(this._api);

  final StudentsApi _api;

  @override
  Future<List<StudentSummary>> list({bool archived = false}) =>
      guard(() async => [for (final s in await _api.list(archived: archived)) StudentDto(s).toDomain()]);

  @override
  Future<StudentProfile> profile(String studentId) => guard(() async => StudentProfileDto(await _api.detail(studentId)).toDomain());

  @override
  Future<SavedStudent> create(StudentDraft draft) => guard(() async => savedStudent(await _api.create(studentDraftJson(draft))));

  @override
  Future<SavedStudent> update(String studentId, StudentDraft draft) =>
      guard(() async => savedStudent(await _api.update(studentId, studentDraftJson(draft))));

  @override
  Future<void> archive(String studentId) => guard(() => _api.archive(studentId));

  @override
  Future<void> restore(String studentId) => guard(() => _api.restore(studentId));

  @override
  Future<UsernameCheck> checkUsername({String? firstName, String? lastName, String? username}) => guard(() async {
    final json = await _api.usernameSuggestion({'firstName': ?firstName, 'lastName': ?lastName, 'username': ?username});
    return UsernameCheck(username: json['username'] as String? ?? '', available: json['available'] as bool? ?? false);
  });

  @override
  Future<NewAccount> resetPassword({required String userId, required UserRole role, required String firstName, required String lastName}) =>
      guard(() async {
        final json = await _api.resetPassword(userId);
        return NewAccount(
          userId: userId,
          role: role,
          firstName: firstName,
          lastName: lastName,
          username: json['username'] as String? ?? '',
          temporaryPassword: json['temporaryPassword'] as String? ?? '',
        );
      });

  @override
  Future<NewAccount> enableLogin(StudentSummary student) => guard(() async => newAccount(await _api.enableLogin(student.id)));

  @override
  Future<void> disableLogin(String studentId) => guard(() => _api.disableLogin(studentId));

  @override
  Future<List<ParentAccount>> parents() => guard(() async => [for (final p in await _api.parents()) parentAccount(p)]);

  @override
  Future<List<NoteEntry>> privateNotes(String studentId) =>
      guard(() async => [for (final n in await _api.privateNotes(studentId)) noteEntry(n)]);

  @override
  Future<NoteEntry> addPrivateNote(String studentId, String body) =>
      guard(() async => noteEntry(await _api.addPrivateNote(studentId, body)));

  @override
  Future<NoteEntry> editPrivateNote(String studentId, String noteId, String body) =>
      guard(() async => noteEntry(await _api.editPrivateNote(studentId, noteId, body)));

  @override
  Future<void> deletePrivateNote(String studentId, String noteId) => guard(() => _api.deletePrivateNote(studentId, noteId));

  @override
  Future<List<NoteEntry>> comments(String studentId) => guard(() async => [for (final n in await _api.comments(studentId)) noteEntry(n)]);

  @override
  Future<NoteEntry> addComment(String studentId, String body) => guard(() async => noteEntry(await _api.addComment(studentId, body)));
}
