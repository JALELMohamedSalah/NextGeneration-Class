import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/session.dart';
import '../../../domain/repositories/planning_repository.dart';
import '../common/load_status.dart';

class SessionDetailState extends Equatable {
  const SessionDetailState({this.status = LoadStatus.loading, this.detail, this.failure, this.busy = false});

  final LoadStatus status;
  final SessionDetail? detail;
  final ApiFailure? failure;

  /// An action (cancel, restore) is running.
  final bool busy;

  @override
  List<Object?> get props => [status, detail, failure?.code, busy];
}

/// The session side panel of the planning.
class SessionDetailCubit extends Cubit<SessionDetailState> {
  SessionDetailCubit(this._repository, this.sessionId) : super(const SessionDetailState());

  final PlanningRepository _repository;
  final String sessionId;

  Future<void> load() async {
    emit(SessionDetailState(detail: state.detail));
    try {
      final detail = await _repository.detail(sessionId);
      if (!isClosed) emit(SessionDetailState(status: LoadStatus.ready, detail: detail));
    } on Object catch (error) {
      if (!isClosed) emit(SessionDetailState(status: LoadStatus.failure, detail: state.detail, failure: ApiFailure.from(error)));
    }
  }

  Future<ApiFailure?> cancel(EditScope scope, String? reason) =>
      _act(() => _repository.cancel(sessionId, scope, reason: reason?.trim().isEmpty ?? true ? null : reason!.trim()));

  Future<ApiFailure?> restore() => _act(() => _repository.restore(sessionId));

  Future<ApiFailure?> _act(Future<Session> Function() action) async {
    emit(SessionDetailState(status: state.status, detail: state.detail, busy: true));
    try {
      await action();
      await load();
      return null;
    } on Object catch (error) {
      if (!isClosed) emit(SessionDetailState(status: state.status, detail: state.detail));
      return ApiFailure.from(error);
    }
  }
}
