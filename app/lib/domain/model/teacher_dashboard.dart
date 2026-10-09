import 'package:equatable/equatable.dart';

import 'homework.dart';
import 'session.dart';

/// Everything "Ma journée" shows, in one piece (docs/02-specification/01-teacher-home.md).
/// Release 1 fills today, tomorrow and the coming days; release 2 the copies to correct and the missing work;
/// to watch comes with release 4.
class TeacherDashboard extends Equatable {
  const TeacherDashboard({
    required this.date,
    required this.now,
    required this.nextDays,
    this.today = const [],
    this.tomorrow = const [],
    this.toCorrect = const [],
    this.missingWork = const [],
  });

  /// The teacher's "today" (Tunisian calendar day).
  final DateTime date;
  final DateTime now;

  /// The coming days of the "À venir" strip, today first.
  final List<DayLoad> nextDays;

  /// Today's sessions, cancelled ones included (the timeline shows them struck through).
  final List<Session> today;
  final List<Session> tomorrow;

  /// "À corriger", grouped by homework, oldest first; null when it could not be read (the block says so).
  final List<ToCorrectGroup>? toCorrect;

  /// "Travail manquant": homework past its deadline with who sent nothing; null when it could not be read.
  final List<MissingWork>? missingWork;

  /// Every copy waiting, the oldest first, with its homework.
  List<(Assignment, ToCorrectItem)> get copiesToCorrect => [
    for (final g in toCorrect ?? const <ToCorrectGroup>[])
      for (final item in g.items) (g.assignment, item),
  ]..sort((a, b) => a.$2.submittedAt.compareTo(b.$2.submittedAt));

  /// The session the hero shows: the one running, or the next one today.
  Session? get next => today.where((s) => !s.isCancelled && !s.isDone && s.endsAt.isAfter(now)).firstOrNull;

  List<Session> get tomorrowPlanned => tomorrow.where((s) => !s.isCancelled).toList();

  int get todayCount => today.where((s) => !s.isCancelled).length;

  /// Nothing planned at all yet: the header says so.
  bool get isEmpty => nextDays.every((day) => day.sessions == 0);

  @override
  List<Object?> get props => [date, now, nextDays, today, tomorrow, toCorrect, missingWork];
}

/// How busy one day is.
class DayLoad extends Equatable {
  const DayLoad({required this.date, required this.sessions, this.restDay = false});

  final DateTime date;
  final int sessions;

  /// A day the teacher does not work (shown hatched).
  final bool restDay;

  @override
  List<Object?> get props => [date, sessions, restDay];
}
