import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/student.dart';
import '../../../domain/model/teacher_account.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../common/load_status.dart';

class TeachersState extends Equatable {
  const TeachersState({
    this.status = LoadStatus.loading,
    this.totals = const TeachersTotals(),
    this.teachers = const [],
    this.query = '',
    this.failure,
  });

  final LoadStatus status;
  final TeachersTotals totals;
  final List<TeacherAccount> teachers;
  final String query;
  final ApiFailure? failure;

  /// Filtered by name, username, phone or email; any order of words, accents ignored.
  List<TeacherAccount> get visible {
    final words = _plain(query).split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return teachers;
    return teachers.where((t) {
      final haystack = _plain('${t.firstName} ${t.lastName} ${t.username} ${t.phone ?? ''} ${t.email ?? ''}');
      return words.every(haystack.contains);
    }).toList();
  }

  TeachersState copyWith({
    LoadStatus? status,
    TeachersTotals? totals,
    List<TeacherAccount>? teachers,
    String? query,
    ApiFailure? Function()? failure,
  }) => TeachersState(
    status: status ?? this.status,
    totals: totals ?? this.totals,
    teachers: teachers ?? this.teachers,
    query: query ?? this.query,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, totals, teachers, query, failure?.code];
}

String _plain(String text) {
  const from = 'àâäáãçéèêëíìîïñóòôöõúùûüýÿ';
  const to = 'aaaaaceeeeiiiinooooouuuuyy';
  final lower = text.toLowerCase();
  final out = StringBuffer();
  for (final char in lower.split('')) {
    final i = from.indexOf(char);
    out.write(i < 0 ? char : to[i]);
  }
  return out.toString();
}

/// The owner's dashboard: every teacher, the totals across their spaces, and the account actions.
/// Actions return their [ApiFailure] (or null) so the screen words the result.
class TeachersCubit extends Cubit<TeachersState> {
  TeachersCubit(this._repository) : super(const TeachersState());

  final AdminRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, failure: () => null));
    try {
      final overview = await _repository.teachers();
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.ready, totals: overview.totals, teachers: overview.teachers));
    } on Object catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from(error)));
    }
  }

  void search(String query) => emit(state.copyWith(query: query));

  /// The new teacher goes last; the login details are for the owner to pass on.
  Future<(NewAccount?, ApiFailure?)> create(TeacherDraft draft) async {
    try {
      final (teacher, credential) = await _repository.createTeacher(draft);
      if (!isClosed) {
        final t = state.totals;
        emit(
          state.copyWith(
            teachers: [...state.teachers, teacher],
            totals: TeachersTotals(
              teachers: t.teachers + 1,
              activeTeachers: t.activeTeachers + 1,
              students: t.students,
              parents: t.parents,
              groups: t.groups,
            ),
          ),
        );
      }
      return (credential, null);
    } on Object catch (error) {
      return (null, ApiFailure.from(error));
    }
  }

  Future<(NewAccount?, ApiFailure?)> resetPassword(TeacherAccount teacher) async {
    try {
      final credential = await _repository.resetPassword(teacher);
      if (!isClosed) _replace(teacher.id, (t) => t.withTemporaryPassword());
      return (credential, null);
    } on Object catch (error) {
      return (null, ApiFailure.from(error));
    }
  }

  Future<ApiFailure?> setActive(TeacherAccount teacher, {required bool active}) async {
    try {
      await _repository.setActive(teacher.id, active: active);
      if (!isClosed) {
        _replace(teacher.id, (t) => t.withActive(active));
        final t = state.totals;
        emit(
          state.copyWith(
            totals: TeachersTotals(
              teachers: t.teachers,
              activeTeachers: state.teachers.where((x) => x.active).length,
              students: t.students,
              parents: t.parents,
              groups: t.groups,
            ),
          ),
        );
      }
      return null;
    } on Object catch (error) {
      return ApiFailure.from(error);
    }
  }

  void _replace(String id, TeacherAccount Function(TeacherAccount) change) =>
      emit(state.copyWith(teachers: [for (final t in state.teachers) t.id == id ? change(t) : t]));
}
