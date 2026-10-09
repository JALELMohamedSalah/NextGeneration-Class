import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/group.dart';
import '../../../domain/repositories/group_repository.dart';

enum GroupFormError { name, subject, level, meetUrl }

class GroupFormState extends Equatable {
  const GroupFormState({
    this.groupId,
    this.name = '',
    this.subjectId,
    this.levelId,
    this.meetUrl = '',
    this.color,
    this.errors = const {},
    this.submitting = false,
    this.failure,
    this.saved,
  });

  final String? groupId;
  final String name;
  final String? subjectId;
  final String? levelId;
  final String meetUrl;

  /// Null: the server picks the next palette color.
  final String? color;
  final Set<GroupFormError> errors;
  final bool submitting;
  final ApiFailure? failure;
  final Group? saved;

  bool get isEditing => groupId != null;

  GroupFormState copyWith({
    String? name,
    String? Function()? subjectId,
    String? Function()? levelId,
    String? meetUrl,
    String? Function()? color,
    Set<GroupFormError>? errors,
    bool? submitting,
    ApiFailure? Function()? failure,
    Group? saved,
  }) => GroupFormState(
    groupId: groupId,
    name: name ?? this.name,
    subjectId: subjectId != null ? subjectId() : this.subjectId,
    levelId: levelId != null ? levelId() : this.levelId,
    meetUrl: meetUrl ?? this.meetUrl,
    color: color != null ? color() : this.color,
    errors: errors ?? this.errors,
    submitting: submitting ?? this.submitting,
    failure: failure != null ? failure() : this.failure,
    saved: saved ?? this.saved,
  );

  @override
  List<Object?> get props => [groupId, name, subjectId, levelId, meetUrl, color, errors, submitting, failure?.code, saved];
}

class GroupFormCubit extends Cubit<GroupFormState> {
  GroupFormCubit(this._repository, {Group? editing})
    : super(
        editing == null
            ? const GroupFormState()
            : GroupFormState(
                groupId: editing.id,
                name: editing.name,
                subjectId: editing.subjectId,
                levelId: editing.levelId,
                meetUrl: editing.defaultMeetUrl ?? '',
                color: editing.color,
              ),
      );

  final GroupRepository _repository;

  void setName(String value) => emit(state.copyWith(name: value, errors: state.errors.difference({GroupFormError.name})));

  void setSubject(String? id) => emit(state.copyWith(subjectId: () => id, errors: state.errors.difference({GroupFormError.subject})));

  void setLevel(String? id) => emit(state.copyWith(levelId: () => id, errors: state.errors.difference({GroupFormError.level})));

  void setMeetUrl(String value) => emit(state.copyWith(meetUrl: value, errors: state.errors.difference({GroupFormError.meetUrl})));

  void setColor(String? color) => emit(state.copyWith(color: () => color));

  Future<void> submit() async {
    if (state.submitting) return;
    final url = state.meetUrl.trim();
    final errors = {
      if (state.name.trim().isEmpty) GroupFormError.name,
      if (state.subjectId == null) GroupFormError.subject,
      if (state.levelId == null) GroupFormError.level,
      if (url.isNotEmpty && !url.startsWith('https://')) GroupFormError.meetUrl,
    };
    if (errors.isNotEmpty) {
      emit(state.copyWith(errors: errors));
      return;
    }
    emit(state.copyWith(submitting: true, failure: () => null));
    final draft = GroupDraft(
      name: state.name.trim(),
      subjectId: state.subjectId!,
      levelId: state.levelId!,
      defaultMeetUrl: url.isEmpty ? null : url,
      color: state.color,
    );
    try {
      final group = state.isEditing ? await _repository.update(state.groupId!, draft) : await _repository.create(draft);
      emit(state.copyWith(submitting: false, saved: group));
    } on Object catch (error) {
      emit(state.copyWith(submitting: false, failure: () => ApiFailure.from(error)));
    }
  }
}
