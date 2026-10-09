import '../model/content.dart';
import '../model/homework.dart';

/// Homework (spec 06): the teacher's side, then the pupil's and parent's ([studentId] required for a parent).
abstract interface class HomeworkRepository {
  Future<List<Assignment>> list();

  Future<Assignment> assign(AssignmentDraft draft);

  Future<AssignmentDetail> detail(String id);

  Future<Assignment> changeDeadline(String id, DateTime deadlineAt);

  Future<void> close(String id);

  /// A pupil's work, for the teacher's viewer.
  Future<DocumentView> submissionView(String submissionId);

  Future<List<MyHomework>> mine({String? studentId});

  Future<MyHomeworkDetail> myDetail(String id, {String? studentId});

  /// [onProgress] goes from 0 to 1 while the file is sent.
  Future<MyHomeworkDetail> submit(String id, PickedFile file, {String? studentId, void Function(double progress)? onProgress});

  /// The work sent for the child, for the pupil's or parent's viewer.
  Future<DocumentView> mySubmissionView(String id, {String? studentId});

  /// The teacher's corrected copy, once corrected.
  Future<DocumentView> myCorrectionView(String id, {String? studentId});

  // ── Correction (step 4, teacher) ──

  /// "À corriger": copies waiting, grouped by homework, the oldest first.
  Future<List<ToCorrectGroup>> toCorrect();

  /// "Travail manquant": homework past its deadline in the last two weeks, with who sent nothing.
  Future<List<MissingWork>> missing();

  Future<CorrectionView> correction(String assignmentId, String studentId);

  /// [score] out of the homework's max score, half points allowed.
  Future<CorrectionView> correct(String assignmentId, String studentId, {required double score, String? comment});

  Future<CorrectionView> attachCorrection(
    String assignmentId,
    String studentId,
    PickedFile file, {
    void Function(double progress)? onProgress,
  });

  Future<CorrectionView> removeCorrectionFile(String assignmentId, String studentId);

  Future<DocumentView> correctionFileView(String assignmentId, String studentId);
}
