import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/tunis_time.dart';
import '../../../core/network/api_failure.dart';
import '../../../domain/model/session.dart';
import '../../../domain/repositories/planning_repository.dart';
import '../common/load_status.dart';

enum PlanningView { day, week }

class PlanningState extends Equatable {
  const PlanningState({
    required this.day,
    required this.today,
    this.view = PlanningView.week,
    this.status = LoadStatus.loading,
    this.groupId,
    this.sessions = const [],
    this.failure,
    this.direction = 0,
  });

  /// The Tunisian day the calendar is on (00:00, UTC-flagged).
  final DateTime day;
  final DateTime today;
  final PlanningView view;
  final LoadStatus status;

  /// Null: every group.
  final String? groupId;
  final List<Session> sessions;
  final ApiFailure? failure;

  /// -1 back, 1 forward, 0 in place: the calendar slides that way.
  final int direction;

  DateTime get from => view == PlanningView.week ? TunisTime.weekStart(day) : day;

  DateTime get to => TunisTime.addDays(from, view == PlanningView.week ? 7 : 1);

  /// The days to draw: Monday to Saturday, and Sunday only when it has sessions.
  List<DateTime> get days {
    if (view == PlanningView.day) return [day];
    final monday = from;
    final sunday = TunisTime.addDays(monday, 6);
    final sundayUsed = sessions.any((s) => TunisTime.sameDay(TunisTime.day(s.startsAt), sunday));
    return [for (var i = 0; i < (sundayUsed ? 7 : 6); i++) TunisTime.addDays(monday, i)];
  }

  List<Session> on(DateTime day) => sessions.where((s) => TunisTime.sameDay(TunisTime.day(s.startsAt), day)).toList();

  PlanningState copyWith({
    DateTime? day,
    PlanningView? view,
    LoadStatus? status,
    String? Function()? groupId,
    List<Session>? sessions,
    ApiFailure? Function()? failure,
    int? direction,
  }) => PlanningState(
    day: day ?? this.day,
    today: today,
    view: view ?? this.view,
    status: status ?? this.status,
    groupId: groupId != null ? groupId() : this.groupId,
    sessions: sessions ?? this.sessions,
    failure: failure != null ? failure() : this.failure,
    direction: direction ?? this.direction,
  );

  @override
  List<Object?> get props => [day, today, view, status, groupId, sessions, failure?.code, direction];
}

/// The teacher's calendar (spec 03): day and week views, filtered by group.
class PlanningCubit extends Cubit<PlanningState> {
  PlanningCubit(this._repository, Now now, {PlanningView view = PlanningView.week})
    : super(PlanningState(day: TunisTime.day(now()), today: TunisTime.day(now()), view: view));

  final PlanningRepository _repository;
  int _request = 0;

  Future<void> load() async {
    final ticket = ++_request;
    emit(state.copyWith(status: LoadStatus.loading, failure: () => null));
    try {
      final sessions = await _repository.sessions(
        from: TunisTime.instant(state.from),
        to: TunisTime.instant(state.to),
        groupId: state.groupId,
      );
      if (isClosed || ticket != _request) return;
      emit(state.copyWith(status: LoadStatus.ready, sessions: sessions));
    } on Object catch (error) {
      if (isClosed || ticket != _request) return;
      emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from(error)));
    }
  }

  Future<void> next() => _move(1);

  Future<void> previous() => _move(-1);

  Future<void> goToday() {
    final direction = state.today.isBefore(state.from) ? -1 : (state.today.isAfter(state.to) ? 1 : 0);
    emit(state.copyWith(day: state.today, direction: direction));
    return load();
  }

  /// A day picked in the strip of the phone view, or a column head of the week.
  Future<void> openDay(DateTime day) {
    final sameRange = !day.isBefore(state.from) && day.isBefore(state.to) && state.view == PlanningView.week;
    emit(state.copyWith(day: day, view: PlanningView.day, direction: day.isBefore(state.day) ? -1 : 1));
    return sameRange ? Future.value() : load();
  }

  Future<void> setView(PlanningView view) {
    if (view == state.view) return Future.value();
    emit(state.copyWith(view: view, direction: 0));
    return load();
  }

  Future<void> setGroup(String? groupId) {
    emit(state.copyWith(groupId: () => groupId, direction: 0));
    return load();
  }

  Future<void> _move(int step) {
    final days = state.view == PlanningView.week ? 7 : 1;
    emit(state.copyWith(day: TunisTime.addDays(state.day, step * days), direction: step));
    return load();
  }
}
