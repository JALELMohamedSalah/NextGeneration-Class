import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/session.dart';
import '../../../domain/repositories/planning_repository.dart';
import '../common/load_status.dart';

enum SaveStatus { idle, saving, saved, failed }

class SessionModeState extends Equatable {
  const SessionModeState({
    this.status = LoadStatus.loading,
    this.detail,
    this.marks = const {},
    this.quickNote = '',
    this.noteSave = SaveStatus.idle,
    this.attendanceSave = SaveStatus.idle,
    this.ending = false,
    this.ended = false,
    this.failure,
  });

  final LoadStatus status;
  final SessionDetail? detail;

  /// Everyone is present until tapped.
  final Map<String, AttendanceStatus> marks;
  final String quickNote;
  final SaveStatus noteSave;
  final SaveStatus attendanceSave;
  final bool ending;
  final bool ended;
  final ApiFailure? failure;

  int count(AttendanceStatus status) => marks.values.where((m) => m == status).length;

  AttendanceStatus markOf(String studentId) => marks[studentId] ?? AttendanceStatus.present;

  SessionModeState copyWith({
    LoadStatus? status,
    SessionDetail? detail,
    Map<String, AttendanceStatus>? marks,
    String? quickNote,
    SaveStatus? noteSave,
    SaveStatus? attendanceSave,
    bool? ending,
    bool? ended,
    ApiFailure? Function()? failure,
  }) => SessionModeState(
    status: status ?? this.status,
    detail: detail ?? this.detail,
    marks: marks ?? this.marks,
    quickNote: quickNote ?? this.quickNote,
    noteSave: noteSave ?? this.noteSave,
    attendanceSave: attendanceSave ?? this.attendanceSave,
    ending: ending ?? this.ending,
    ended: ended ?? this.ended,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, detail, marks, quickNote, noteSave, attendanceSave, ending, ended, failure?.code];
}

/// "Démarrer la séance" (spec 03): one tap per student, saved on its own; the quick note saves itself.
class SessionModeCubit extends Cubit<SessionModeState> {
  SessionModeCubit(
    this._repository,
    this.sessionId, {
    this.attendanceDelay = const Duration(milliseconds: 700),
    this.noteDelay = const Duration(milliseconds: 900),
  }) : super(const SessionModeState());

  final PlanningRepository _repository;
  final String sessionId;
  final Duration attendanceDelay;
  final Duration noteDelay;
  Timer? _attendanceTimer;
  Timer? _noteTimer;
  bool _attendanceDirty = false;
  bool _noteDirty = false;

  /// Opening session mode starts the session (Prévue becomes En cours).
  Future<void> open() async {
    emit(state.copyWith(status: LoadStatus.loading, failure: () => null));
    try {
      final detail = await _repository.start(sessionId);
      if (isClosed) return;
      emit(
        SessionModeState(
          status: LoadStatus.ready,
          detail: detail,
          marks: {for (final r in detail.roster) r.studentId: r.status ?? AttendanceStatus.present},
          quickNote: detail.quickNote ?? '',
          ended: detail.session.isDone,
        ),
      );
    } on Object catch (error) {
      if (!isClosed) emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from(error)));
    }
  }

  void tap(String studentId) {
    final marks = {...state.marks, studentId: state.markOf(studentId).next};
    _attendanceDirty = true;
    emit(state.copyWith(marks: marks, attendanceSave: SaveStatus.saving));
    _attendanceTimer?.cancel();
    _attendanceTimer = Timer(attendanceDelay, _saveAttendance);
  }

  void setQuickNote(String text) {
    _noteDirty = true;
    emit(state.copyWith(quickNote: text, noteSave: SaveStatus.saving));
    _noteTimer?.cancel();
    _noteTimer = Timer(noteDelay, _saveNote);
  }

  /// Saves what is pending, then ends the session. Students nobody tapped are present.
  Future<void> end() async {
    if (state.ending) return;
    emit(state.copyWith(ending: true, failure: () => null));
    _attendanceTimer?.cancel();
    _noteTimer?.cancel();
    try {
      if (_noteDirty) await _saveNote();
      await _saveAttendance(force: true);
      final detail = await _repository.end(sessionId);
      if (!isClosed) emit(state.copyWith(detail: detail, ending: false, ended: true));
    } on Object catch (error) {
      if (!isClosed) emit(state.copyWith(ending: false, failure: () => ApiFailure.from(error)));
    }
  }

  Future<void> _saveAttendance({bool force = false}) async {
    if (!_attendanceDirty && !force) return;
    _attendanceDirty = false;
    final marks = state.marks;
    try {
      await _repository.saveAttendance(sessionId, marks);
      if (!isClosed && !_attendanceDirty) emit(state.copyWith(attendanceSave: SaveStatus.saved));
    } on Object catch (error) {
      _attendanceDirty = true;
      if (!isClosed) emit(state.copyWith(attendanceSave: SaveStatus.failed, failure: () => ApiFailure.from(error)));
      if (force) rethrow;
    }
  }

  Future<void> _saveNote() async {
    _noteDirty = false;
    final text = state.quickNote;
    try {
      await _repository.saveNotes(sessionId, quickNote: text);
      if (!isClosed && !_noteDirty) emit(state.copyWith(noteSave: SaveStatus.saved));
    } on Object {
      _noteDirty = true;
      if (!isClosed) emit(state.copyWith(noteSave: SaveStatus.failed));
    }
  }

  /// Leaving the screen still saves what was typed or tapped.
  @override
  Future<void> close() async {
    _attendanceTimer?.cancel();
    _noteTimer?.cancel();
    if (_attendanceDirty) unawaited(_repository.saveAttendance(sessionId, state.marks).then((_) {}, onError: (_) {}));
    if (_noteDirty) unawaited(_repository.saveNotes(sessionId, quickNote: state.quickNote).then((_) {}, onError: (_) {}));
    return super.close();
  }
}
