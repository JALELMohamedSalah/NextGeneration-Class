import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/results.dart';
import '../../../domain/repositories/results_repository.dart';
import '../common/load_status.dart';

class ResultsState extends Equatable {
  const ResultsState({this.status = LoadStatus.loading, this.results, this.studentId, this.failure});

  final LoadStatus status;
  final MyResults? results;
  final String? studentId;
  final ApiFailure? failure;

  ResultsState copyWith({
    LoadStatus? status,
    MyResults? Function()? results,
    String? Function()? studentId,
    ApiFailure? Function()? failure,
  }) => ResultsState(
    status: status ?? this.status,
    results: results != null ? results() : this.results,
    studentId: studentId != null ? studentId() : this.studentId,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, results, studentId, failure?.code];
}

/// "Résultats" (design `r2/CorrectionPhone.png`): a pupil's, or a parent's view of one child's.
class ResultsCubit extends Cubit<ResultsState> {
  ResultsCubit(this._repository) : _teacher = false, super(const ResultsState());

  /// The teacher's view of one of her pupils (the Fiche élève): [load] needs the pupil.
  ResultsCubit.forTeacher(this._repository) : _teacher = true, super(const ResultsState());

  final bool _teacher;

  final ResultsRepository _repository;

  Future<void> load({String? studentId}) async {
    final otherChild = studentId != state.studentId;
    emit(
      state.copyWith(status: LoadStatus.loading, studentId: () => studentId, results: otherChild ? () => null : null, failure: () => null),
    );
    try {
      final results = _teacher ? await _repository.forStudent(studentId!) : await _repository.mine(studentId: studentId);
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.ready, results: () => results));
    } on Object catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from(error)));
    }
  }
}
