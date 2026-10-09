import 'package:equatable/equatable.dart';

import 'content.dart';
import 'session.dart';

/// One pupil's state for one homework (spec 06). [corrected] arrives with the correction step.
enum HomeworkStatus { todo, submitted, late, missing, corrected }

/// Photos or a PDF to send, or something to read only (no status).
enum SubmissionMode { file, none }

class StatusCounts extends Equatable {
  const StatusCounts({this.todo = 0, this.submitted = 0, this.late = 0, this.missing = 0, this.corrected = 0});

  final int todo;
  final int submitted;
  final int late;
  final int missing;
  final int corrected;

  /// Sent, on time or late (corrected work was sent too).
  int get sent => submitted + late + corrected;

  @override
  List<Object?> get props => [todo, submitted, late, missing, corrected];
}

/// A homework as the teacher follows it. [done]: closed, or past its deadline ("Terminés"). [average]: the mean
/// of the scores given so far, on /20.
class Assignment extends Equatable {
  const Assignment({
    required this.id,
    required this.title,
    required this.contentItemId,
    required this.contentKind,
    required this.group,
    required this.deadlineAt,
    required this.mode,
    required this.recipients,
    required this.counts,
    this.wholeGroup = true,
    this.allowLate = false,
    this.instructions,
    this.closed = false,
    this.done = false,
    this.maxScore = 20,
    this.subjectId,
    this.average,
  });

  final String id;
  final String title;
  final String contentItemId;
  final FileKind contentKind;
  final GroupRef group;
  final bool wholeGroup;
  final DateTime deadlineAt;
  final SubmissionMode mode;
  final bool allowLate;
  final String? instructions;
  final bool closed;
  final bool done;
  final int recipients;
  final StatusCounts counts;
  final int maxScore;

  /// The document's subject (the "Matière" filter).
  final String? subjectId;
  final double? average;

  /// Sent and waiting for a correction.
  int get toCorrect => counts.submitted + counts.late;

  @override
  List<Object?> get props => [
    id,
    title,
    contentItemId,
    contentKind,
    group,
    wholeGroup,
    deadlineAt,
    mode,
    allowLate,
    instructions,
    closed,
    done,
    recipients,
    counts,
    maxScore,
    subjectId,
    average,
  ];
}

class RecipientRow extends Equatable {
  const RecipientRow({
    required this.studentId,
    required this.firstName,
    required this.lastName,
    this.status,
    this.submittedAt,
    this.submissionId,
    this.score,
  });

  final String studentId;
  final String firstName;
  final String lastName;

  /// Null for something to read only.
  final HomeworkStatus? status;
  final DateTime? submittedAt;
  final String? submissionId;

  /// Out of the homework's max score, once corrected.
  final double? score;

  String get fullName => '$firstName $lastName'.trim();

  String get initials => '${firstName.isEmpty ? '' : firstName[0]}${lastName.isEmpty ? '' : lastName[0]}'.toUpperCase();

  @override
  List<Object?> get props => [studentId, firstName, lastName, status, submittedAt, submissionId, score];
}

class AssignmentDetail extends Equatable {
  const AssignmentDetail({required this.assignment, required this.recipients});

  final Assignment assignment;
  final List<RecipientRow> recipients;

  @override
  List<Object?> get props => [assignment, recipients];
}

/// What the teacher sets in "Nouveau devoir". [studentIds] empty: the whole group.
class AssignmentDraft extends Equatable {
  const AssignmentDraft({
    required this.contentItemId,
    required this.title,
    required this.groupId,
    required this.deadlineAt,
    this.studentIds = const [],
    this.mode = SubmissionMode.file,
    this.allowLate = false,
    this.instructions = '',
  });

  final String contentItemId;
  final String title;
  final String groupId;
  final List<String> studentIds;
  final DateTime deadlineAt;
  final SubmissionMode mode;
  final bool allowLate;
  final String instructions;

  @override
  List<Object?> get props => [contentItemId, title, groupId, studentIds, deadlineAt, mode, allowLate, instructions];
}

/// A homework in a pupil's or parent's list. [status] is null for something to read only.
class MyHomework extends Equatable {
  const MyHomework({
    required this.id,
    required this.title,
    required this.subject,
    required this.groupName,
    required this.deadlineAt,
    required this.mode,
    this.allowLate = false,
    this.closed = false,
    this.status,
    this.submittedAt,
    this.score,
    this.maxScore = 20,
  });

  final String id;
  final String title;
  final SubjectRef subject;
  final String groupName;
  final DateTime deadlineAt;
  final SubmissionMode mode;
  final bool allowLate;
  final bool closed;
  final HomeworkStatus? status;
  final DateTime? submittedAt;

  /// Once corrected, out of [maxScore].
  final double? score;
  final int maxScore;

  /// Still to do: something to send, or to read before the deadline.
  bool isOpen(DateTime now) => status == HomeworkStatus.todo || (status == null && deadlineAt.isAfter(now));

  @override
  List<Object?> get props => [id, title, subject, groupName, deadlineAt, mode, allowLate, closed, status, submittedAt, score, maxScore];
}

class ContentRef extends Equatable {
  const ContentRef({required this.id, required this.title, required this.kind, required this.tag, this.pageCount});

  final String id;
  final String title;
  final FileKind kind;
  final ContentTag tag;
  final int? pageCount;

  @override
  List<Object?> get props => [id, title, kind, tag, pageCount];
}

class SubmissionInfo extends Equatable {
  const SubmissionInfo({required this.id, required this.submittedAt, required this.fileName, this.late = false, this.pageCount});

  final String id;
  final DateTime submittedAt;
  final bool late;
  final String fileName;
  final int? pageCount;

  @override
  List<Object?> get props => [id, submittedAt, late, fileName, pageCount];
}

/// One homework for the pupil (or the parent): what to do, the document, what was sent, whether one can send,
/// and the correction once there.
class MyHomeworkDetail extends Equatable {
  const MyHomeworkDetail({
    required this.homework,
    required this.content,
    this.instructions,
    this.submission,
    this.canSubmit = false,
    this.correction,
  });

  final MyHomework homework;
  final String? instructions;
  final ContentRef content;
  final SubmissionInfo? submission;
  final bool canSubmit;
  final Correction? correction;

  @override
  List<Object?> get props => [homework, instructions, content, submission, canSubmit, correction];
}

// ── Correction (step 4) ──

/// The teacher's corrected copy (a photo or a PDF).
class CorrectionFile extends Equatable {
  const CorrectionFile({required this.fileName, required this.kind, this.pageCount});

  final String fileName;
  final FileKind kind;
  final int? pageCount;

  @override
  List<Object?> get props => [fileName, kind, pageCount];
}

/// What the pupil and the parents see once a homework is corrected.
class Correction extends Equatable {
  const Correction({required this.score, required this.maxScore, required this.correctedAt, this.comment, this.file});

  final double score;
  final int maxScore;
  final String? comment;
  final DateTime correctedAt;
  final CorrectionFile? file;

  @override
  List<Object?> get props => [score, maxScore, comment, correctedAt, file];
}

/// One pupil's copy on the correction screen. [score] null until saved; [file] can be attached any time.
class CorrectionView extends Equatable {
  const CorrectionView({
    required this.assignmentId,
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.maxScore,
    this.status,
    this.submission,
    this.score,
    this.comment,
    this.correctedAt,
    this.file,
  });

  final String assignmentId;
  final String studentId;
  final String firstName;
  final String lastName;
  final HomeworkStatus? status;
  final int maxScore;
  final SubmissionInfo? submission;
  final double? score;
  final String? comment;
  final DateTime? correctedAt;
  final CorrectionFile? file;

  String get fullName => '$firstName $lastName'.trim();

  String get initials => '${firstName.isEmpty ? '' : firstName[0]}${lastName.isEmpty ? '' : lastName[0]}'.toUpperCase();

  @override
  List<Object?> get props => [
    assignmentId,
    studentId,
    firstName,
    lastName,
    status,
    maxScore,
    submission,
    score,
    comment,
    correctedAt,
    file,
  ];
}

/// A copy waiting in "À corriger".
class ToCorrectItem extends Equatable {
  const ToCorrectItem({
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.submittedAt,
    required this.submissionId,
    this.status,
  });

  final String studentId;
  final String firstName;
  final String lastName;
  final HomeworkStatus? status;
  final DateTime submittedAt;
  final String submissionId;

  String get fullName => '$firstName $lastName'.trim();

  String get initials => '${firstName.isEmpty ? '' : firstName[0]}${lastName.isEmpty ? '' : lastName[0]}'.toUpperCase();

  @override
  List<Object?> get props => [studentId, firstName, lastName, status, submittedAt, submissionId];
}

/// One homework of "À corriger" and its copies, oldest first.
class ToCorrectGroup extends Equatable {
  const ToCorrectGroup({required this.assignment, required this.items});

  final Assignment assignment;
  final List<ToCorrectItem> items;

  @override
  List<Object?> get props => [assignment, items];
}

class PupilName extends Equatable {
  const PupilName({required this.studentId, required this.firstName, required this.lastName});

  final String studentId;
  final String firstName;
  final String lastName;

  String get initials => '${firstName.isEmpty ? '' : firstName[0]}${lastName.isEmpty ? '' : lastName[0]}'.toUpperCase();

  @override
  List<Object?> get props => [studentId, firstName, lastName];
}

/// "Travail manquant" (Ma journée): a homework past its deadline and who sent nothing.
class MissingWork extends Equatable {
  const MissingWork({required this.assignment, required this.missing});

  final Assignment assignment;
  final List<PupilName> missing;

  @override
  List<Object?> get props => [assignment, missing];
}
