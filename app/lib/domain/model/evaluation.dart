import 'package:equatable/equatable.dart';

import 'session.dart';

/// A paper evaluation (spec 06 "Évaluations", design `r2/Evaluation.png`): a test done in class, its scores
/// typed by the teacher. [heldOn] is a calendar day (UTC midnight); [average] on its own scale.
class Evaluation extends Equatable {
  const Evaluation({
    required this.id,
    required this.title,
    required this.group,
    required this.heldOn,
    required this.maxScore,
    this.chapterId,
    this.chapterTitle,
    this.pupils = 0,
    this.graded = 0,
    this.absent = 0,
    this.average,
  });

  final String id;
  final String title;
  final GroupRef group;
  final DateTime heldOn;
  final int maxScore;
  final String? chapterId;
  final String? chapterTitle;

  /// The group's current pupils, and anyone graded who left since.
  final int pupils;

  /// Scores typed, and pupils marked absent.
  final int graded;
  final int absent;
  final double? average;

  /// Every pupil has a score or is absent.
  bool get complete => pupils > 0 && graded + absent >= pupils;

  @override
  List<Object?> get props => [id, title, group, heldOn, maxScore, chapterId, chapterTitle, pupils, graded, absent, average];
}

/// One pupil of the score table: nothing yet, a score, or absent.
class EvaluationGrade extends Equatable {
  const EvaluationGrade({
    required this.studentId,
    required this.firstName,
    required this.lastName,
    this.score,
    this.absent = false,
    this.comment,
  });

  final String studentId;
  final String firstName;
  final String lastName;
  final double? score;
  final bool absent;
  final String? comment;

  String get fullName => '$firstName $lastName'.trim();

  String get initials =>
      '${firstName.isEmpty ? '' : firstName.substring(0, 1)}${lastName.isEmpty ? '' : lastName.substring(0, 1)}'.toUpperCase();

  @override
  List<Object?> get props => [studentId, firstName, lastName, score, absent, comment];
}

class EvaluationDetail extends Equatable {
  const EvaluationDetail({required this.evaluation, required this.grades});

  final Evaluation evaluation;

  /// By first name, as the server sends them.
  final List<EvaluationGrade> grades;

  @override
  List<Object?> get props => [evaluation, grades];
}

/// "Nouvelle évaluation" or "Modifier": the group cannot change once created.
class EvaluationDraft extends Equatable {
  const EvaluationDraft({required this.groupId, required this.title, required this.heldOn, required this.maxScore, this.chapterId});

  final String groupId;
  final String title;
  final DateTime heldOn;
  final int maxScore;
  final String? chapterId;

  @override
  List<Object?> get props => [groupId, title, heldOn, maxScore, chapterId];
}

/// What the table sends for one pupil: a score, absent, or nothing (a typed score erased).
class GradeInput extends Equatable {
  const GradeInput({required this.studentId, this.score, this.absent = false, this.comment});

  final String studentId;
  final double? score;
  final bool absent;
  final String? comment;

  @override
  List<Object?> get props => [studentId, score, absent, comment];
}
