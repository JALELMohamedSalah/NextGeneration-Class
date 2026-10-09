import '../model/student.dart';

/// The teacher's comments on a pupil, "visible par l'élève et ses parents": the pupil's own, or a parent's child's
/// ([studentId] required for a parent). Latest first.
abstract interface class CommentRepository {
  Future<List<NoteEntry>> mine({String? studentId});
}
