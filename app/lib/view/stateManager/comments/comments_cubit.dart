import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/student.dart';
import '../../../domain/repositories/comment_repository.dart';
import '../common/load_status.dart';

class CommentsState extends Equatable {
  const CommentsState({this.status = LoadStatus.loading, this.items = const [], this.failure});

  final LoadStatus status;

  /// Latest first.
  final List<NoteEntry> items;
  final ApiFailure? failure;

  NoteEntry? get latest => items.firstOrNull;

  @override
  List<Object?> get props => [status, items, failure?.code];
}

/// "Mot de l'enseignante" (design `ParentPhone.png`): the teacher's comments on the pupil or a parent's child.
class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit(this._repository) : super(const CommentsState());

  final CommentRepository _repository;

  Future<void> load({String? studentId}) async {
    emit(const CommentsState());
    try {
      final items = await _repository.mine(studentId: studentId);
      if (!isClosed) emit(CommentsState(status: LoadStatus.ready, items: items));
    } on Object catch (error) {
      if (!isClosed) emit(CommentsState(status: LoadStatus.failure, failure: ApiFailure.from(error)));
    }
  }
}
