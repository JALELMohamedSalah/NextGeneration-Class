import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/group.dart';
import '../../../domain/repositories/group_repository.dart';
import '../common/load_status.dart';

class GroupDetailState extends Equatable {
  const GroupDetailState({this.status = LoadStatus.loading, this.detail, this.failure});

  final LoadStatus status;
  final GroupDetail? detail;
  final ApiFailure? failure;

  @override
  List<Object?> get props => [status, detail, failure?.code];
}

class GroupDetailCubit extends Cubit<GroupDetailState> {
  GroupDetailCubit(this._repository, this.groupId) : super(const GroupDetailState());

  final GroupRepository _repository;
  final String groupId;

  Future<void> load() async {
    emit(GroupDetailState(detail: state.detail));
    try {
      final detail = await _repository.detail(groupId);
      if (!isClosed) emit(GroupDetailState(status: LoadStatus.ready, detail: detail));
    } on Object catch (error) {
      if (!isClosed) emit(GroupDetailState(status: LoadStatus.failure, detail: state.detail, failure: ApiFailure.from(error)));
    }
  }

  /// After the edit panel saved.
  void replaceGroup(Group group) {
    final detail = state.detail;
    if (detail == null) return;
    emit(
      GroupDetailState(
        status: LoadStatus.ready,
        detail: GroupDetail(group: group, members: detail.members),
      ),
    );
  }

  Future<ApiFailure?> setMembers(List<String> studentIds) async {
    try {
      final detail = await _repository.setMembers(groupId, studentIds);
      emit(GroupDetailState(status: LoadStatus.ready, detail: detail));
      return null;
    } on Object catch (error) {
      return ApiFailure.from(error);
    }
  }

  Future<ApiFailure?> archive() async {
    try {
      await _repository.archive(groupId);
      return null;
    } on Object catch (error) {
      return ApiFailure.from(error);
    }
  }
}
