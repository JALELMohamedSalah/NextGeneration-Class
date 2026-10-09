import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/tunis_time.dart';
import '../../../core/network/api_failure.dart';
import '../../../domain/model/session.dart';
import '../../../domain/repositories/planning_repository.dart';
import '../common/load_status.dart';

class MyPlanningState extends Equatable {
  const MyPlanningState({required this.now, this.status = LoadStatus.loading, this.studentId, this.sessions = const [], this.failure});

  final DateTime now;
  final LoadStatus status;

  /// The child a parent looks at; null for a student.
  final String? studentId;

  /// The last 30 days and the next 14.
  final List<MySession> sessions;
  final ApiFailure? failure;

  DateTime get today => TunisTime.day(now);

  /// From today on, cancelled ones included (they show struck through with their reason).
  List<MySession> get upcoming => sessions.where((s) => !s.startsAt.isBefore(TunisTime.instant(today))).toList();

  /// The session to show first: running or next, not cancelled.
  MySession? get next => sessions.where((s) => !s.isCancelled && s.endsAt.isAfter(now)).firstOrNull;

  List<MySession> get _lastMonth =>
      sessions.where((s) => s.status == SessionStatus.done && s.attendance != null && s.startsAt.isBefore(now)).toList();

  /// Attendance % over the last 30 days: (present + late) / sessions with a mark. Null without any.
  int? get monthAttendanceRate {
    final counted = _lastMonth;
    if (counted.isEmpty) return null;
    final attended = counted.where((s) => s.attendance != AttendanceStatus.absent).length;
    return (attended * 100 / counted.length).round();
  }

  int get monthAbsences => _lastMonth.where((s) => s.attendance == AttendanceStatus.absent).length;

  List<MySession> get thisWeek => _week(0);

  /// Monday to Sunday after this week (the next 15 days are loaded, so it is always complete).
  List<MySession> get nextWeek => _week(1);

  List<MySession> _week(int offset) {
    final monday = TunisTime.addDays(TunisTime.weekStart(today), 7 * offset);
    final from = TunisTime.instant(monday);
    final to = TunisTime.instant(TunisTime.addDays(monday, 7));
    return sessions.where((s) => !s.startsAt.isBefore(from) && s.startsAt.isBefore(to)).toList();
  }

  @override
  List<Object?> get props => [now, status, studentId, sessions, failure?.code];
}

/// A student's own sessions, or a parent's child's (spec 03, 09, 10).
class MyPlanningCubit extends Cubit<MyPlanningState> {
  MyPlanningCubit(this._repository, this._now) : super(MyPlanningState(now: _now()));

  final PlanningRepository _repository;
  final Now _now;
  int _request = 0;

  Future<void> load({String? studentId}) async {
    final ticket = ++_request;
    final now = _now();
    final switching = studentId != state.studentId;
    emit(MyPlanningState(now: now, studentId: studentId, sessions: switching ? const [] : state.sessions));
    final today = TunisTime.day(now);
    try {
      final sessions = await _repository.mySessions(
        from: TunisTime.instant(TunisTime.addDays(today, -30)),
        to: TunisTime.instant(TunisTime.addDays(today, 15)),
        studentId: studentId,
      );
      if (isClosed || ticket != _request) return;
      emit(MyPlanningState(now: now, status: LoadStatus.ready, studentId: studentId, sessions: sessions));
    } on Object catch (error) {
      if (isClosed || ticket != _request) return;
      emit(MyPlanningState(now: now, status: LoadStatus.failure, studentId: studentId, failure: ApiFailure.from(error)));
    }
  }
}
