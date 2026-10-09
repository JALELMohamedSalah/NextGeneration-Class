import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/tunis_time.dart';
import '../../../core/network/api_failure.dart';
import '../../../domain/model/homework.dart';
import '../../../domain/repositories/homework_repository.dart';
import '../common/load_status.dart';

class MyHomeworkState extends Equatable {
  const MyHomeworkState({this.status = LoadStatus.loading, this.items = const [], this.studentId, this.failure});

  final LoadStatus status;

  /// To do first (nearest deadline first), then the rest (latest first): the server's order.
  final List<MyHomework> items;
  final String? studentId;
  final ApiFailure? failure;

  MyHomeworkState copyWith({LoadStatus? status, List<MyHomework>? items, String? Function()? studentId, ApiFailure? Function()? failure}) =>
      MyHomeworkState(
        status: status ?? this.status,
        items: items ?? this.items,
        studentId: studentId != null ? studentId() : this.studentId,
        failure: failure != null ? failure() : this.failure,
      );

  @override
  List<Object?> get props => [status, items, studentId, failure?.code];
}

/// "Mes devoirs" (design `r2/DevoirsPhone.png`), or a parent's view of one child's.
class MyHomeworkCubit extends Cubit<MyHomeworkState> {
  MyHomeworkCubit(this._repository, this._now) : super(const MyHomeworkState());

  final HomeworkRepository _repository;
  final Now _now;

  List<MyHomework> get open => state.items.where((h) => h.isOpen(_now())).toList();

  List<MyHomework> get finished => state.items.where((h) => !h.isOpen(_now())).toList();

  Future<void> load({String? studentId}) async {
    final otherChild = studentId != state.studentId;
    emit(state.copyWith(status: LoadStatus.loading, studentId: () => studentId, items: otherChild ? const [] : null, failure: () => null));
    try {
      final items = await _repository.mine(studentId: studentId);
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.ready, items: items));
    } on Object catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from(error)));
    }
  }
}
