import 'package:equatable/equatable.dart';

import 'clock_time.dart';
import 'localized_text.dart';

enum SessionMode { inPerson, online }

enum SessionStatus { planned, inProgress, done, cancelled }

enum AttendanceStatus {
  present,
  absent,
  late;

  /// One tap in session mode: Présent, then Absent, then En retard, then Présent again.
  AttendanceStatus get next => switch (this) {
    present => absent,
    absent => late,
    late => present,
  };
}

/// Editing or cancelling a session of a weekly series.
enum EditScope { one, following }

/// The group a session belongs to, as lists show it.
class GroupRef extends Equatable {
  const GroupRef({
    required this.id,
    required this.name,
    required this.code,
    required this.color,
    required this.subject,
    required this.privateLesson,
  });

  final String id;
  final String name;
  final String code;
  final String color;
  final LocalizedText subject;
  final bool privateLesson;

  @override
  List<Object?> get props => [id, name, code, color, subject, privateLesson];
}

/// A session as the teacher sees it. Times are UTC instants; screens show them in Tunisian time.
class Session extends Equatable {
  const Session({
    required this.id,
    required this.group,
    required this.startsAt,
    required this.endsAt,
    required this.mode,
    required this.status,
    this.location,
    this.meetUrl,
    this.ownMeetUrl = false,
    this.cancelReason,
    this.recurring = false,
    this.followingCount = 0,
    this.seriesEndsOn,
    this.prepNote,
    this.present = 0,
    this.absent = 0,
    this.late = 0,
  });

  final String id;
  final GroupRef group;
  final DateTime startsAt;
  final DateTime endsAt;
  final SessionMode mode;
  final SessionStatus status;
  final String? location;
  final String? meetUrl;
  final bool ownMeetUrl;
  final String? cancelReason;
  final bool recurring;

  /// Sessions of the series from this one on (detail only).
  final int followingCount;
  final DateTime? seriesEndsOn;
  final String? prepNote;
  final int present;
  final int absent;
  final int late;

  bool get isCancelled => status == SessionStatus.cancelled;

  bool get isDone => status == SessionStatus.done;

  bool get isEditable => status == SessionStatus.planned || status == SessionStatus.inProgress;

  bool get attendanceTaken => present + absent + late > 0;

  @override
  List<Object?> get props => [
    id,
    group,
    startsAt,
    endsAt,
    mode,
    status,
    location,
    meetUrl,
    ownMeetUrl,
    cancelReason,
    recurring,
    followingCount,
    seriesEndsOn,
    prepNote,
    present,
    absent,
    late,
  ];
}

class RosterEntry extends Equatable {
  const RosterEntry({required this.studentId, required this.firstName, required this.lastName, this.status});

  final String studentId;
  final String firstName;
  final String lastName;

  /// Null until attendance is taken: session mode shows "Présent" by default.
  final AttendanceStatus? status;

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [studentId, firstName, lastName, status];
}

class PreviousSession extends Equatable {
  const PreviousSession({required this.startsAt, this.sessionNote, this.quickNote});

  final DateTime startsAt;
  final String? sessionNote;
  final String? quickNote;

  /// What session mode shows under "Dernière séance".
  String? get note => (sessionNote?.isNotEmpty ?? false) ? sessionNote : quickNote;

  @override
  List<Object?> get props => [startsAt, sessionNote, quickNote];
}

/// Everything the session panel and session mode show.
class SessionDetail extends Equatable {
  const SessionDetail({required this.session, required this.roster, this.quickNote, this.sessionNote, this.previous});

  final Session session;
  final List<RosterEntry> roster;
  final String? quickNote;
  final String? sessionNote;
  final PreviousSession? previous;

  @override
  List<Object?> get props => [session, roster, quickNote, sessionNote, previous];
}

/// A new session, or a weekly series. [date] is a calendar day (time ignored), times are Tunisian.
class SessionDraft extends Equatable {
  const SessionDraft({
    required this.groupId,
    required this.date,
    required this.start,
    required this.end,
    required this.mode,
    this.location,
    this.meetUrl,
    this.prepNote,
    this.repeatWeekly = false,
    this.repeatUntil,
  });

  final String groupId;
  final DateTime date;
  final ClockTime start;
  final ClockTime end;
  final SessionMode mode;
  final String? location;
  final String? meetUrl;
  final String? prepNote;
  final bool repeatWeekly;
  final DateTime? repeatUntil;

  @override
  List<Object?> get props => [groupId, date, start, end, mode, location, meetUrl, prepNote, repeatWeekly, repeatUntil];
}

class CreatedSessions extends Equatable {
  const CreatedSessions({required this.count, required this.first, required this.overlaps});

  final int count;
  final Session first;
  final List<Session> overlaps;

  @override
  List<Object?> get props => [count, first, overlaps];
}

/// A session as a student or a parent sees it: no private notes, no link for parents.
class MySession extends Equatable {
  const MySession({
    required this.id,
    required this.group,
    required this.startsAt,
    required this.endsAt,
    required this.mode,
    required this.status,
    this.location,
    this.meetUrl,
    this.cancelReason,
    this.attendance,
  });

  final String id;
  final GroupRef group;
  final DateTime startsAt;
  final DateTime endsAt;
  final SessionMode mode;
  final SessionStatus status;
  final String? location;
  final String? meetUrl;
  final String? cancelReason;

  /// The student's own mark, once taken.
  final AttendanceStatus? attendance;

  bool get isCancelled => status == SessionStatus.cancelled;

  /// Spec 03: "Rejoindre" from 15 minutes before the start until the end.
  bool canJoin(DateTime now) =>
      !isCancelled &&
      mode == SessionMode.online &&
      meetUrl != null &&
      !now.isBefore(startsAt.subtract(const Duration(minutes: 15))) &&
      now.isBefore(endsAt);

  @override
  List<Object?> get props => [id, group, startsAt, endsAt, mode, status, location, meetUrl, cancelReason, attendance];
}
