import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/reference.dart';
import '../../../domain/repositories/reference_repository.dart';
import '../common/load_status.dart';

class SubjectsSettingsState extends Equatable {
  const SubjectsSettingsState({this.status = LoadStatus.loading, this.subjects = const [], this.failure});

  final LoadStatus status;
  final List<SubjectUsage> subjects;
  final ApiFailure? failure;

  SubjectsSettingsState copyWith({LoadStatus? status, List<SubjectUsage>? subjects, ApiFailure? Function()? failure}) =>
      SubjectsSettingsState(
        status: status ?? this.status,
        subjects: subjects ?? this.subjects,
        failure: failure != null ? failure() : this.failure,
      );

  @override
  List<Object?> get props => [status, subjects, failure?.code];
}

/// Paramètres > Matières: the subjects with how many groups use them. Changes are made through
/// [ReferenceCubit] (which keeps every form in step); this list only follows them.
class SubjectsSettingsCubit extends Cubit<SubjectsSettingsState> {
  SubjectsSettingsCubit(this._repository) : super(const SubjectsSettingsState());

  final ReferenceRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, failure: () => null));
    try {
      final subjects = await _repository.subjectsWithUsage();
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.ready, subjects: subjects));
    } on Object catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from(error)));
    }
  }

  /// A created subject goes last with no group; an edited one keeps its place and its count.
  void saved(Subject subject) {
    final known = state.subjects.any((s) => s.subject.id == subject.id);
    emit(
      state.copyWith(
        subjects: known
            ? [for (final s in state.subjects) s.subject.id == subject.id ? s.withSubject(subject) : s]
            : [...state.subjects, SubjectUsage(subject: subject, groupCount: 0)],
      ),
    );
  }

  void removed(String subjectId) => emit(state.copyWith(subjects: state.subjects.where((s) => s.subject.id != subjectId).toList()));
}
