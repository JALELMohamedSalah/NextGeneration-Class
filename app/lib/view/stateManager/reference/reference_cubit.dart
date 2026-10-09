import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/reference.dart';
import '../../../domain/repositories/reference_repository.dart';
import '../common/load_status.dart';

class ReferenceState extends Equatable {
  const ReferenceState({this.status = LoadStatus.loading, this.reference, this.failure});

  final LoadStatus status;
  final Reference? reference;
  final ApiFailure? failure;

  @override
  List<Object?> get props => [status, reference, failure?.code];
}

/// Subjects, levels and the school year, loaded once per teacher session for the forms. Every change to a
/// subject goes through here, so the forms, the planning and Paramètres all see it at once.
class ReferenceCubit extends Cubit<ReferenceState> {
  ReferenceCubit(this._repository) : super(const ReferenceState());

  final ReferenceRepository _repository;

  Future<void> load() async {
    if (state.reference != null) return;
    emit(const ReferenceState());
    try {
      emit(ReferenceState(status: LoadStatus.ready, reference: await _repository.load()));
    } on Object catch (error) {
      emit(ReferenceState(status: LoadStatus.failure, failure: ApiFailure.from(error)));
    }
  }

  /// A subject the teacher just created: every form sees it right away.
  Future<(Subject?, ApiFailure?)> createSubject(SubjectDraft draft) => _changeSubject(() => _repository.createSubject(draft));

  /// A renamed or recolored subject keeps its place in every list.
  Future<(Subject?, ApiFailure?)> updateSubject(String id, SubjectDraft draft) =>
      _changeSubject(() => _repository.updateSubject(id, draft));

  /// Refused by the server (`subject_in_use`) while a group uses it. Returns the failure, or null.
  Future<ApiFailure?> deleteSubject(String id) async {
    try {
      await _repository.deleteSubject(id);
      final reference = state.reference;
      if (reference != null) emit(ReferenceState(status: LoadStatus.ready, reference: reference.withoutSubject(id)));
      return null;
    } on Object catch (error) {
      return ApiFailure.from(error);
    }
  }

  Future<(Subject?, ApiFailure?)> _changeSubject(Future<Subject> Function() change) async {
    try {
      final subject = await change();
      final reference = state.reference;
      if (reference != null) emit(ReferenceState(status: LoadStatus.ready, reference: reference.withSubject(subject)));
      return (subject, null);
    } on Object catch (error) {
      return (null, ApiFailure.from(error));
    }
  }
}
