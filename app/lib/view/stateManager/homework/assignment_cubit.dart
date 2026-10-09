import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/homework.dart';
import '../../../domain/repositories/homework_repository.dart';
import '../common/load_status.dart';

class AssignmentState extends Equatable {
  const AssignmentState({this.status = LoadStatus.loading, this.detail, this.failure});

  final LoadStatus status;
  final AssignmentDetail? detail;
  final ApiFailure? failure;

  AssignmentState copyWith({LoadStatus? status, AssignmentDetail? detail, ApiFailure? Function()? failure}) =>
      AssignmentState(status: status ?? this.status, detail: detail ?? this.detail, failure: failure != null ? failure() : this.failure);

  @override
  List<Object?> get props => [status, detail, failure?.code];
}

/// One homework for the teacher (design `r2/Devoir.png`): each pupil's status, a new deadline, close it.
class AssignmentCubit extends Cubit<AssignmentState> {
  AssignmentCubit(this._repository, this.assignmentId) : super(const AssignmentState());

  final HomeworkRepository _repository;
  final String assignmentId;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, failure: () => null));
    try {
      final detail = await _repository.detail(assignmentId);
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.ready, detail: detail));
    } on Object catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from(error)));
    }
  }

  /// Pupils marked "Manquant" may send again; the rows are read again.
  Future<ApiFailure?> changeDeadline(DateTime deadlineAt) async {
    try {
      await _repository.changeDeadline(assignmentId, deadlineAt);
      await load();
      return null;
    } on Object catch (error) {
      return ApiFailure.from(error);
    }
  }

  Future<ApiFailure?> closeHomework() async {
    try {
      await _repository.close(assignmentId);
      await load();
      return null;
    } on Object catch (error) {
      return ApiFailure.from(error);
    }
  }
}
