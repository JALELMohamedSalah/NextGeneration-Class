import 'package:equatable/equatable.dart';

import 'content.dart';

/// Up, down or stable: the last 3 grades against those before them (from 4 grades).
enum Trend { up, down, stable }

/// Where a grade comes from: a corrected homework, or a paper evaluation.
enum GradeKind { homework, evaluation }

/// A grade as given ([score] out of [maxScore]) and on /20 ([score20]). [date]: when a homework was corrected,
/// or the day an evaluation was held. An evaluation can say [absent]: no score, never counted as 0.
class GradeItem extends Equatable {
  const GradeItem({
    required this.title,
    required this.date,
    required this.maxScore,
    this.kind = GradeKind.homework,
    this.assignmentId,
    this.evaluationId,
    this.score,
    this.score20,
    this.comment,
    this.absent = false,
  });

  final GradeKind kind;
  final String? assignmentId;
  final String? evaluationId;
  final String title;
  final DateTime date;
  final double? score;
  final int maxScore;
  final double? score20;
  final String? comment;
  final bool absent;

  /// A real grade (not an absence).
  bool get counted => !absent && score != null && score20 != null;

  @override
  List<Object?> get props => [kind, assignmentId, evaluationId, title, date, score, maxScore, score20, comment, absent];
}

/// One subject of "Résultats" (spec 07): the same numbers for the pupil and the parents.
class SubjectResult extends Equatable {
  const SubjectResult({
    required this.subject,
    required this.submitted,
    required this.due,
    this.average,
    this.gradeCount = 0,
    this.trend,
    this.attendanceRate,
    this.grades = const [],
  });

  final SubjectRef subject;

  /// On /20; null before the first grade ("Pas encore de note", never 0).
  final double? average;
  final int gradeCount;
  final Trend? trend;

  /// Homework sent out of homework due.
  final int submitted;
  final int due;

  /// In %, null before a counted session.
  final int? attendanceRate;

  /// Latest first.
  final List<GradeItem> grades;

  @override
  List<Object?> get props => [subject, average, gradeCount, trend, submitted, due, attendanceRate, grades];
}

class MyResults extends Equatable {
  const MyResults({this.subjects = const []});

  final List<SubjectResult> subjects;

  /// Every grade and absence, latest first.
  List<GradeItem> get grades => [for (final s in subjects) ...s.grades]..sort((a, b) => b.date.compareTo(a.date));

  /// The mean of every grade on /20 (no coefficients); an absence never counts; null without a grade.
  double? get average {
    final counted = grades.where((g) => g.counted).toList();
    if (counted.isEmpty) return null;
    return counted.fold<double>(0, (sum, g) => sum + g.score20!) / counted.length;
  }

  int get submitted => subjects.fold(0, (sum, s) => sum + s.submitted);

  int get due => subjects.fold(0, (sum, s) => sum + s.due);

  @override
  List<Object?> get props => [subjects];
}
