import '../../core/l10n/tunis_time.dart';
import '../../domain/model/homework.dart';
import '../../domain/model/teacher_dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/repositories/homework_repository.dart';
import '../../domain/repositories/planning_repository.dart';

/// Builds "Ma journée" from the sessions of the next five days, the copies to correct and the missing work.
/// A failed homework block does not hide the sessions (spec 01: each block has its own error).
class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._planning, this._homework, {Now? now}) : _now = now ?? DateTime.now;

  final PlanningRepository _planning;
  final HomeworkRepository _homework;
  final Now _now;

  static const _stripDays = 5;

  @override
  Future<TeacherDashboard> teacherDashboard() async {
    final now = _now();
    final today = TunisTime.day(now);
    Future<T?> orNull<T>(Future<T> future) async {
      try {
        return await future;
      } on Object {
        return null;
      }
    }

    final (sessions, toCorrect, missing) = await (
      _planning.sessions(from: TunisTime.instant(today), to: TunisTime.instant(TunisTime.addDays(today, _stripDays))),
      orNull<List<ToCorrectGroup>>(_homework.toCorrect()),
      orNull<List<MissingWork>>(_homework.missing()),
    ).wait;
    List<T> on<T>(DateTime day, Iterable<T> list, DateTime Function(T) start) =>
        list.where((s) => TunisTime.sameDay(TunisTime.day(start(s)), day)).toList();
    return TeacherDashboard(
      date: today,
      now: now,
      today: on(today, sessions, (s) => s.startsAt),
      tomorrow: on(TunisTime.addDays(today, 1), sessions, (s) => s.startsAt),
      toCorrect: toCorrect,
      missingWork: missing,
      nextDays: [
        for (var i = 0; i < _stripDays; i++)
          DayLoad(
            date: TunisTime.addDays(today, i),
            sessions: on(TunisTime.addDays(today, i), sessions.where((s) => !s.isCancelled), (s) => s.startsAt).length,
          ),
      ],
    );
  }
}
