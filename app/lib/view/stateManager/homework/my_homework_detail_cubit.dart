import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../core/platform/file_chooser.dart';
import '../../../domain/model/content.dart';
import '../../../domain/model/homework.dart';
import '../../../domain/repositories/homework_repository.dart';
import '../common/load_status.dart';

class MyHomeworkDetailState extends Equatable {
  const MyHomeworkDetailState({
    this.status = LoadStatus.loading,
    this.detail,
    this.sending = false,
    this.progress,
    this.problem,
    this.failure,
  });

  final LoadStatus status;
  final MyHomeworkDetail? detail;
  final bool sending;

  /// 0 to 1 while the work is sent.
  final double? progress;

  /// A file refused before sending (type, size).
  final FileProblem? problem;
  final ApiFailure? failure;

  MyHomeworkDetailState copyWith({
    LoadStatus? status,
    MyHomeworkDetail? detail,
    bool? sending,
    double? Function()? progress,
    FileProblem? Function()? problem,
    ApiFailure? Function()? failure,
  }) => MyHomeworkDetailState(
    status: status ?? this.status,
    detail: detail ?? this.detail,
    sending: sending ?? this.sending,
    progress: progress != null ? progress() : this.progress,
    problem: problem != null ? problem() : this.problem,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, detail, sending, progress, problem, failure?.code];
}

/// One homework for the pupil, or the parent sending the child's work (user decision 2026-10-07).
class MyHomeworkDetailCubit extends Cubit<MyHomeworkDetailState> {
  MyHomeworkDetailCubit(this._repository, this._chooser, this.assignmentId, {this.studentId}) : super(const MyHomeworkDetailState());

  final HomeworkRepository _repository;
  final FileChooser _chooser;
  final String assignmentId;
  final String? studentId;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, failure: () => null));
    try {
      final detail = await _repository.myDetail(assignmentId, studentId: studentId);
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.ready, detail: detail));
    } on Object catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from(error)));
    }
  }

  /// A PDF or a photo already on the device, sent at once; true once sent.
  Future<bool> chooseAndSend() async {
    final PickedFile? picked;
    try {
      picked = await _chooser.pickDocument();
    } on Object catch (error) {
      if (!isClosed) emit(state.copyWith(failure: () => ApiFailure.from(error)));
      return false;
    }
    if (picked == null || isClosed) return false;
    return send(picked);
  }

  /// The scanned PDF or a chosen file; true once sent. A newer one replaces the last until the deadline.
  Future<bool> send(PickedFile file) async {
    if (state.sending) return false;
    final problem = file.problem ?? (file.extension == 'docx' ? FileProblem.unsupported : null);
    if (problem != null) {
      emit(state.copyWith(problem: () => problem));
      return false;
    }
    emit(state.copyWith(sending: true, progress: () => 0, problem: () => null, failure: () => null));
    try {
      final detail = await _repository.submit(
        assignmentId,
        file,
        studentId: studentId,
        onProgress: (p) {
          if (!isClosed) emit(state.copyWith(progress: () => p));
        },
      );
      if (!isClosed) emit(state.copyWith(sending: false, progress: () => null, detail: detail));
      return true;
    } on Object catch (error) {
      if (!isClosed) emit(state.copyWith(sending: false, progress: () => null, failure: () => ApiFailure.from(error)));
      return false;
    }
  }
}
