import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/tunis_time.dart';
import '../../../core/network/api_failure.dart';
import '../../../domain/model/clock_time.dart';
import '../../../domain/model/group.dart';
import '../../../domain/model/session.dart';
import '../../../domain/repositories/planning_repository.dart';

enum SessionFormError { group, time, meetUrl, repeatUntil }

class SessionFormState extends Equatable {
  const SessionFormState({
    required this.date,
    required this.start,
    required this.end,
    required this.repeatUntil,
    this.sessionId,
    this.recurring = false,
    this.groupId,
    this.groupMeetUrl,
    this.mode = SessionMode.inPerson,
    this.location = '',
    this.meetUrl = '',
    this.prepNote = '',
    this.repeatWeekly = false,
    this.overlaps = const [],
    this.errors = const {},
    this.submitting = false,
    this.failure,
    this.created,
    this.updated,
  });

  /// Null when creating.
  final String? sessionId;

  /// The session being edited belongs to a weekly series: saving asks for the scope.
  final bool recurring;
  final String? groupId;

  /// The group's default link, used when [meetUrl] is empty.
  final String? groupMeetUrl;
  final DateTime date;
  final ClockTime start;
  final ClockTime end;
  final SessionMode mode;
  final String location;
  final String meetUrl;
  final String prepNote;
  final bool repeatWeekly;
  final DateTime repeatUntil;
  final List<Session> overlaps;
  final Set<SessionFormError> errors;
  final bool submitting;
  final ApiFailure? failure;
  final CreatedSessions? created;
  final Session? updated;

  bool get isEditing => sessionId != null;

  /// How many sessions "Créer" makes: one, or one per week until [repeatUntil].
  int get sessionCount {
    if (!repeatWeekly || isEditing) return 1;
    if (repeatUntil.isBefore(date)) return 0;
    return repeatUntil.difference(date).inDays ~/ 7 + 1;
  }

  SessionFormState copyWith({
    String? Function()? groupId,
    String? Function()? groupMeetUrl,
    DateTime? date,
    ClockTime? start,
    ClockTime? end,
    SessionMode? mode,
    String? location,
    String? meetUrl,
    String? prepNote,
    bool? repeatWeekly,
    DateTime? repeatUntil,
    List<Session>? overlaps,
    Set<SessionFormError>? errors,
    bool? submitting,
    ApiFailure? Function()? failure,
    CreatedSessions? created,
    Session? updated,
  }) => SessionFormState(
    sessionId: sessionId,
    recurring: recurring,
    groupId: groupId != null ? groupId() : this.groupId,
    groupMeetUrl: groupMeetUrl != null ? groupMeetUrl() : this.groupMeetUrl,
    date: date ?? this.date,
    start: start ?? this.start,
    end: end ?? this.end,
    mode: mode ?? this.mode,
    location: location ?? this.location,
    meetUrl: meetUrl ?? this.meetUrl,
    prepNote: prepNote ?? this.prepNote,
    repeatWeekly: repeatWeekly ?? this.repeatWeekly,
    repeatUntil: repeatUntil ?? this.repeatUntil,
    overlaps: overlaps ?? this.overlaps,
    errors: errors ?? this.errors,
    submitting: submitting ?? this.submitting,
    failure: failure != null ? failure() : this.failure,
    created: created ?? this.created,
    updated: updated ?? this.updated,
  );

  @override
  List<Object?> get props => [
    sessionId,
    recurring,
    groupId,
    groupMeetUrl,
    date,
    start,
    end,
    mode,
    location,
    meetUrl,
    prepNote,
    repeatWeekly,
    repeatUntil,
    overlaps,
    errors,
    submitting,
    failure?.code,
    failure?.message,
    created,
    updated,
  ];
}

/// "Nouvelle séance" and "Modifier la séance" (spec 03). Overlaps are only a warning.
class SessionFormCubit extends Cubit<SessionFormState> {
  SessionFormCubit(this._repository, {required SessionFormState initial, this.debounce = const Duration(milliseconds: 400)})
    : super(initial);

  /// A new session on [date] at [start] (a calendar slot, or the next round hour).
  factory SessionFormCubit.create(
    PlanningRepository repository, {
    required DateTime date,
    required ClockTime start,
    required DateTime schoolYearEnd,
    Group? group,
  }) => SessionFormCubit(
    repository,
    initial: SessionFormState(
      date: date,
      start: start,
      end: start.plusMinutes(90),
      repeatUntil: schoolYearEnd,
      groupId: group?.id,
      groupMeetUrl: group?.defaultMeetUrl,
      mode: group?.defaultMeetUrl != null ? SessionMode.online : SessionMode.inPerson,
    ),
  );

  factory SessionFormCubit.edit(PlanningRepository repository, Session session, {String? groupMeetUrl}) => SessionFormCubit(
    repository,
    initial: SessionFormState(
      sessionId: session.id,
      recurring: session.recurring,
      groupId: session.group.id,
      groupMeetUrl: groupMeetUrl,
      date: TunisTime.day(session.startsAt),
      start: TunisTime.clock(session.startsAt),
      end: TunisTime.clock(session.endsAt),
      repeatUntil: session.seriesEndsOn ?? TunisTime.day(session.startsAt),
      mode: session.mode,
      location: session.location ?? '',
      meetUrl: session.ownMeetUrl ? (session.meetUrl ?? '') : '',
      prepNote: session.prepNote ?? '',
    ),
  );

  final PlanningRepository _repository;
  final Duration debounce;
  Timer? _overlapTimer;
  int _check = 0;

  void setGroup(Group group) {
    emit(
      state.copyWith(
        groupId: () => group.id,
        groupMeetUrl: () => group.defaultMeetUrl,
        mode: !state.isEditing && group.defaultMeetUrl != null ? SessionMode.online : null,
        errors: state.errors.difference({SessionFormError.group}),
      ),
    );
  }

  void setDate(DateTime date) {
    emit(state.copyWith(date: date, errors: state.errors.difference({SessionFormError.repeatUntil})));
    _scheduleOverlaps();
  }

  /// Moving the start keeps the length of the session.
  void setStart(ClockTime start) {
    final length = state.end.minutes - state.start.minutes;
    emit(
      state.copyWith(
        start: start,
        end: start.plusMinutes(length > 0 ? length : 90),
        errors: state.errors.difference({SessionFormError.time}),
      ),
    );
    _scheduleOverlaps();
  }

  void setEnd(ClockTime end) {
    emit(state.copyWith(end: end, errors: state.errors.difference({SessionFormError.time})));
    _scheduleOverlaps();
  }

  void setMode(SessionMode mode) => emit(state.copyWith(mode: mode));

  void setLocation(String value) => emit(state.copyWith(location: value));

  void setMeetUrl(String value) => emit(state.copyWith(meetUrl: value, errors: state.errors.difference({SessionFormError.meetUrl})));

  void setPrepNote(String value) => emit(state.copyWith(prepNote: value));

  void setRepeatWeekly(bool value) => emit(state.copyWith(repeatWeekly: value));

  void setRepeatUntil(DateTime value) =>
      emit(state.copyWith(repeatUntil: value, errors: state.errors.difference({SessionFormError.repeatUntil})));

  /// Checks overlaps for the first slot right away (the form opens on a slot).
  void checkOverlaps() => _scheduleOverlaps(immediately: true);

  /// [scope] matters only when editing a session of a series.
  Future<void> submit({EditScope scope = EditScope.one}) async {
    if (state.submitting) return;
    final url = state.meetUrl.trim();
    final errors = {
      if (state.groupId == null) SessionFormError.group,
      if (!state.end.isAfter(state.start)) SessionFormError.time,
      if (url.isNotEmpty && !url.startsWith('https://')) SessionFormError.meetUrl,
      if (state.repeatWeekly && !state.isEditing && state.repeatUntil.isBefore(state.date)) SessionFormError.repeatUntil,
    };
    if (errors.isNotEmpty) {
      emit(state.copyWith(errors: errors));
      return;
    }
    emit(state.copyWith(submitting: true, failure: () => null));
    final draft = SessionDraft(
      groupId: state.groupId!,
      date: state.date,
      start: state.start,
      end: state.end,
      mode: state.mode,
      location: state.mode == SessionMode.inPerson && state.location.trim().isNotEmpty ? state.location.trim() : null,
      meetUrl: state.mode == SessionMode.online && url.isNotEmpty ? url : null,
      prepNote: state.prepNote.trim().isEmpty ? null : state.prepNote.trim(),
      repeatWeekly: state.repeatWeekly && !state.isEditing,
      repeatUntil: state.repeatWeekly && !state.isEditing ? state.repeatUntil : null,
    );
    try {
      if (state.isEditing) {
        emit(state.copyWith(submitting: false, updated: await _repository.update(state.sessionId!, scope, draft)));
      } else {
        emit(state.copyWith(submitting: false, created: await _repository.create(draft)));
      }
    } on Object catch (error) {
      emit(state.copyWith(submitting: false, failure: () => ApiFailure.from(error)));
    }
  }

  void _scheduleOverlaps({bool immediately = false}) {
    _overlapTimer?.cancel();
    if (!state.end.isAfter(state.start)) {
      emit(state.copyWith(overlaps: const []));
      return;
    }
    _overlapTimer = Timer(immediately ? Duration.zero : debounce, _checkOverlaps);
  }

  Future<void> _checkOverlaps() async {
    final ticket = ++_check;
    try {
      final overlaps = await _repository.overlaps(date: state.date, start: state.start, end: state.end, excludeId: state.sessionId);
      if (!isClosed && ticket == _check) {
        emit(state.copyWith(overlaps: overlaps.where((s) => !s.isCancelled).toList()));
      }
    } on Object {
      // Only a warning: no check, no warning.
    }
  }

  @override
  Future<void> close() {
    _overlapTimer?.cancel();
    return super.close();
  }
}
