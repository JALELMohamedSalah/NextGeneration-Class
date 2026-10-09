import '../model/app_user.dart';
import '../model/student.dart';

/// Teacher-side students and parents. Every method throws an ApiFailure when the call fails.
abstract interface class StudentRepository {
  Future<List<StudentSummary>> list({bool archived = false});

  Future<StudentProfile> profile(String studentId);

  Future<SavedStudent> create(StudentDraft draft);

  Future<SavedStudent> update(String studentId, StudentDraft draft);

  Future<void> archive(String studentId);

  Future<void> restore(String studentId);

  /// The generated username for a name, or whether a chosen one is free.
  Future<UsernameCheck> checkUsername({String? firstName, String? lastName, String? username});

  /// A new temporary password for a student or parent account; every device of that account is signed out.
  Future<NewAccount> resetPassword({required String userId, required UserRole role, required String firstName, required String lastName});

  /// Gives a child their own login; the details come back once.
  Future<NewAccount> enableLogin(StudentSummary student);

  /// The child stops signing in; parents keep following.
  Future<void> disableLogin(String studentId);

  Future<List<ParentAccount>> parents();

  Future<List<NoteEntry>> privateNotes(String studentId);

  Future<NoteEntry> addPrivateNote(String studentId, String body);

  Future<NoteEntry> editPrivateNote(String studentId, String noteId, String body);

  Future<void> deletePrivateNote(String studentId, String noteId);

  Future<List<NoteEntry>> comments(String studentId);

  Future<NoteEntry> addComment(String studentId, String body);
}
