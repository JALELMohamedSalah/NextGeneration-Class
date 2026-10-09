import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/app_user.dart';
import '../../../domain/model/group.dart';
import '../../../domain/model/student.dart';
import '../../../domain/repositories/group_repository.dart';
import '../../../domain/repositories/student_repository.dart';
import '../common/load_status.dart';

class StudentProfileState extends Equatable {
  const StudentProfileState({
    this.status = LoadStatus.loading,
    this.profile,
    this.privateNotes = const [],
    this.comments = const [],
    this.failure,
  });

  final LoadStatus status;
  final StudentProfile? profile;
  final List<NoteEntry> privateNotes;
  final List<NoteEntry> comments;
  final ApiFailure? failure;

  StudentProfileState copyWith({
    LoadStatus? status,
    StudentProfile? profile,
    List<NoteEntry>? privateNotes,
    List<NoteEntry>? comments,
    ApiFailure? Function()? failure,
  }) => StudentProfileState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    privateNotes: privateNotes ?? this.privateNotes,
    comments: comments ?? this.comments,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, profile, privateNotes, comments, failure?.code];
}

/// "Fiche élève". Actions return their failure (or null) so the screen can say what happened.
class StudentProfileCubit extends Cubit<StudentProfileState> {
  StudentProfileCubit(this._students, this._groups, this.studentId) : super(const StudentProfileState());

  final StudentRepository _students;
  final GroupRepository _groups;
  final String studentId;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, failure: () => null));
    try {
      final results = await Future.wait([_students.profile(studentId), _students.privateNotes(studentId), _students.comments(studentId)]);
      if (isClosed) return;
      emit(
        StudentProfileState(
          status: LoadStatus.ready,
          profile: results[0] as StudentProfile,
          privateNotes: results[1] as List<NoteEntry>,
          comments: results[2] as List<NoteEntry>,
        ),
      );
    } on Object catch (error) {
      if (!isClosed) emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from(error)));
    }
  }

  /// After the edit panel saved: show the new values.
  Future<void> refreshProfile() async {
    try {
      final profile = await _students.profile(studentId);
      if (!isClosed) emit(state.copyWith(profile: profile));
    } on Object {
      // The old values stay; the next visit loads again.
    }
  }

  Future<ApiFailure?> addPrivateNote(String body) => _run(() async {
    final note = await _students.addPrivateNote(studentId, body.trim());
    emit(state.copyWith(privateNotes: [note, ...state.privateNotes]));
  });

  Future<ApiFailure?> editPrivateNote(String noteId, String body) => _run(() async {
    final note = await _students.editPrivateNote(studentId, noteId, body.trim());
    emit(state.copyWith(privateNotes: [for (final n in state.privateNotes) n.id == noteId ? note : n]));
  });

  Future<ApiFailure?> deletePrivateNote(String noteId) => _run(() async {
    await _students.deletePrivateNote(studentId, noteId);
    emit(state.copyWith(privateNotes: state.privateNotes.where((n) => n.id != noteId).toList()));
  });

  Future<ApiFailure?> addComment(String body) => _run(() async {
    final comment = await _students.addComment(studentId, body.trim());
    emit(state.copyWith(comments: [comment, ...state.comments]));
  });

  Future<ApiFailure?> archive() => _run(() => _students.archive(studentId));

  /// A new temporary password, shown once.
  Future<(NewAccount?, ApiFailure?)> resetPassword() async {
    final student = state.profile?.student;
    if (student == null) return (null, null);
    try {
      final account = await _students.resetPassword(
        userId: student.userId,
        role: UserRole.student,
        firstName: student.firstName,
        lastName: student.lastName,
      );
      return (account, null);
    } on Object catch (error) {
      return (null, ApiFailure.from(error));
    }
  }

  /// Opens the child's own login; the details are shown once.
  Future<(NewAccount?, ApiFailure?)> enableLogin() async {
    final student = state.profile?.student;
    if (student == null) return (null, null);
    try {
      final account = await _students.enableLogin(student);
      await refreshProfile();
      return (account, null);
    } on Object catch (error) {
      return (null, ApiFailure.from(error));
    }
  }

  Future<ApiFailure?> disableLogin() => _run(() async {
    await _students.disableLogin(studentId);
    await refreshProfile();
  });

  Future<(Group?, ApiFailure?)> createPrivateLesson(String subjectId) async {
    try {
      final group = await _groups.createPrivateLesson(studentId: studentId, subjectId: subjectId);
      await refreshProfile();
      return (group, null);
    } on Object catch (error) {
      return (null, ApiFailure.from(error));
    }
  }

  Future<ApiFailure?> _run(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } on Object catch (error) {
      return ApiFailure.from(error);
    }
  }
}
