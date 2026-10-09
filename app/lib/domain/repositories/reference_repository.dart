import '../model/reference.dart';

abstract interface class ReferenceRepository {
  Future<Reference> load();

  /// Paramètres > Matières: the teacher's subjects with how many groups use each one.
  Future<List<SubjectUsage>> subjectsWithUsage();

  /// The teacher's own subjects (none are predefined).
  Future<Subject> createSubject(SubjectDraft draft);

  Future<Subject> updateSubject(String id, SubjectDraft draft);

  /// Refused while a group uses the subject.
  Future<void> deleteSubject(String id);
}
