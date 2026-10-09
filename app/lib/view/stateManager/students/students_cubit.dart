import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/student.dart';
import '../../../domain/repositories/student_repository.dart';
import '../common/load_status.dart';

class StudentsState extends Equatable {
  const StudentsState({
    this.status = LoadStatus.loading,
    this.students = const [],
    this.archived = false,
    this.query = '',
    this.levelId,
    this.failure,
  });

  final LoadStatus status;
  final List<StudentSummary> students;

  /// The "Archivés" tab.
  final bool archived;
  final String query;
  final String? levelId;
  final ApiFailure? failure;

  /// What the list shows after the search box and the level filter.
  List<StudentSummary> get visible => students.where((s) => s.matches(query) && (levelId == null || s.levelId == levelId)).toList();

  StudentsState copyWith({
    LoadStatus? status,
    List<StudentSummary>? students,
    bool? archived,
    String? query,
    String? Function()? levelId,
    ApiFailure? Function()? failure,
  }) => StudentsState(
    status: status ?? this.status,
    students: students ?? this.students,
    archived: archived ?? this.archived,
    query: query ?? this.query,
    levelId: levelId != null ? levelId() : this.levelId,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, students, archived, query, levelId, failure?.code];
}

class StudentsCubit extends Cubit<StudentsState> {
  StudentsCubit(this._repository) : super(const StudentsState());

  final StudentRepository _repository;

  Future<void> load({bool? archived}) async {
    final showArchived = archived ?? state.archived;
    final switching = showArchived != state.archived;
    emit(state.copyWith(status: LoadStatus.loading, archived: showArchived, students: switching ? const [] : null, failure: () => null));
    try {
      final students = await _repository.list(archived: showArchived);
      if (isClosed || state.archived != showArchived) return;
      emit(state.copyWith(status: LoadStatus.ready, students: students));
    } on Object catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from(error)));
    }
  }

  void search(String query) => emit(state.copyWith(query: query));

  void filterLevel(String? levelId) => emit(state.copyWith(levelId: () => levelId));

  /// "Restaurer" from the Archivés tab. Returns the failure, or null.
  Future<ApiFailure?> restore(String studentId) async {
    try {
      await _repository.restore(studentId);
      emit(state.copyWith(students: state.students.where((s) => s.id != studentId).toList()));
      return null;
    } on Object catch (error) {
      return ApiFailure.from(error);
    }
  }
}
