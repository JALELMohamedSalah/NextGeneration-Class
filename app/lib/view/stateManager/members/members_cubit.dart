import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/student.dart';
import '../../../domain/repositories/student_repository.dart';
import '../common/load_status.dart';

class MembersState extends Equatable {
  const MembersState({this.status = LoadStatus.loading, this.students = const [], this.selected = const {}, this.query = '', this.failure});

  final LoadStatus status;
  final List<StudentSummary> students;
  final Set<String> selected;
  final String query;
  final ApiFailure? failure;

  List<StudentSummary> get visible => students.where((s) => s.matches(query)).toList();

  @override
  List<Object?> get props => [status, students, selected, query, failure?.code];
}

/// "Choisir les élèves" of a group: every active student, the current members ticked.
class MembersCubit extends Cubit<MembersState> {
  MembersCubit(this._repository, Iterable<String> current) : super(MembersState(selected: {...current}));

  final StudentRepository _repository;

  Future<void> load() async {
    emit(MembersState(selected: state.selected, query: state.query));
    try {
      final students = await _repository.list();
      if (!isClosed) {
        emit(MembersState(status: LoadStatus.ready, students: students, selected: state.selected, query: state.query));
      }
    } on Object catch (error) {
      if (!isClosed) emit(MembersState(status: LoadStatus.failure, selected: state.selected, failure: ApiFailure.from(error)));
    }
  }

  void toggle(String studentId) {
    final selected = {...state.selected};
    if (!selected.remove(studentId)) selected.add(studentId);
    emit(MembersState(status: state.status, students: state.students, selected: selected, query: state.query));
  }

  void search(String query) => emit(MembersState(status: state.status, students: state.students, selected: state.selected, query: query));
}
