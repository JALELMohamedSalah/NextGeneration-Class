import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/group.dart';
import '../../../domain/repositories/group_repository.dart';
import '../common/load_status.dart';

class GroupsState extends Equatable {
  const GroupsState({this.status = LoadStatus.loading, this.groups = const [], this.failure});

  final LoadStatus status;
  final List<Group> groups;
  final ApiFailure? failure;

  List<Group> get regular => groups.where((g) => !g.privateLesson).toList();

  List<Group> get privateLessons => groups.where((g) => g.privateLesson).toList();

  Group? byId(String id) => groups.where((g) => g.id == id).firstOrNull;

  @override
  List<Object?> get props => [status, groups, failure?.code];
}

/// The teacher's groups and private lessons: sidebar "Mes groupes", the Groupes tab and every group picker.
class GroupsCubit extends Cubit<GroupsState> {
  GroupsCubit(this._repository) : super(const GroupsState());

  final GroupRepository _repository;

  Future<void> load() async {
    // A refresh keeps the current list on screen.
    if (state.groups.isEmpty) emit(const GroupsState());
    try {
      emit(GroupsState(status: LoadStatus.ready, groups: await _repository.list()));
    } on Object catch (error) {
      emit(GroupsState(status: LoadStatus.failure, groups: state.groups, failure: ApiFailure.from(error)));
    }
  }

  /// A group was created or edited elsewhere: show it right away, then confirm with the server.
  void upsert(Group group) {
    final list = [...state.groups.where((g) => g.id != group.id), group];
    emit(GroupsState(status: LoadStatus.ready, groups: list));
    unawaited(load());
  }

  void remove(String groupId) {
    emit(GroupsState(status: LoadStatus.ready, groups: state.groups.where((g) => g.id != groupId).toList()));
  }
}
