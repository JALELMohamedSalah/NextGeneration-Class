import '../../domain/model/clock_time.dart';
import '../../domain/model/group.dart';
import '../../domain/model/reference.dart';
import '../../domain/model/session.dart';
import 'user_dto.dart';

typedef Json = Map<String, dynamic>;

List<Json> jsonList(Object? value) => (value as List<dynamic>? ?? const []).cast<Json>();

DateTime? instant(Object? value) => value is String ? DateTime.parse(value).toUtc() : null;

/// "2027-06-30" as a calendar day.
DateTime? day(Object? value) {
  if (value is! String) return null;
  final parts = value.split('-').map(int.parse).toList();
  return DateTime.utc(parts[0], parts[1], parts[2]);
}

/// A calendar day for the API.
String dayParam(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// `GET /reference`.
class ReferenceDto {
  ReferenceDto(this.json);

  final Json json;

  Reference toDomain() {
    final year = json['currentSchoolYear'] as Json?;
    return Reference(
      subjects: [for (final s in jsonList(json['subjects'])) subjectOf(s)],
      levels: [for (final l in jsonList(json['levels'])) Level(id: l['id'] as String, name: localizedText(l['name']))],
      currentYear: year == null
          ? null
          : SchoolYear(
              id: year['id'] as String,
              label: year['label'] as String? ?? '',
              startsOn: day(year['startsOn'])!,
              endsOn: day(year['endsOn'])!,
            ),
    );
  }
}

Subject subjectOf(Json s) => Subject(id: s['id'] as String, name: localizedText(s['name']), color: s['color'] as String? ?? '#2B3990');

SessionMode sessionMode(Object? value) => value == 'ONLINE' ? SessionMode.online : SessionMode.inPerson;

String sessionModeParam(SessionMode mode) => mode == SessionMode.online ? 'ONLINE' : 'IN_PERSON';

SessionStatus sessionStatus(Object? value) => switch (value) {
  'IN_PROGRESS' => SessionStatus.inProgress,
  'DONE' => SessionStatus.done,
  'CANCELLED' => SessionStatus.cancelled,
  _ => SessionStatus.planned,
};

AttendanceStatus? attendanceStatus(Object? value) => switch (value) {
  'PRESENT' => AttendanceStatus.present,
  'ABSENT' => AttendanceStatus.absent,
  'LATE' => AttendanceStatus.late,
  _ => null,
};

String attendanceParam(AttendanceStatus status) => switch (status) {
  AttendanceStatus.present => 'PRESENT',
  AttendanceStatus.absent => 'ABSENT',
  AttendanceStatus.late => 'LATE',
};

/// `GroupResponse`.
class GroupDto {
  GroupDto(this.json);

  final Json json;

  Group toDomain() => Group(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    code: json['code'] as String? ?? '',
    subjectId: json['subjectId'] as String,
    subject: localizedText(json['subject']),
    levelId: json['levelId'] as String,
    level: localizedText(json['level']),
    color: json['color'] as String? ?? '#2B3990',
    privateLesson: json['privateLesson'] as bool? ?? false,
    defaultMeetUrl: json['defaultMeetUrl'] as String?,
    memberCount: json['memberCount'] as int? ?? 0,
    schedule: [
      for (final r in jsonList(json['schedule']))
        ScheduleSlot(
          ruleId: r['ruleId'] as String,
          weekday: r['weekday'] as int,
          start: ClockTime.parse(r['startTime'] as String),
          end: ClockTime.parse(r['endTime'] as String),
          mode: sessionMode(r['mode']),
          location: r['location'] as String?,
        ),
    ],
  );
}

class GroupDetailDto {
  GroupDetailDto(this.json);

  final Json json;

  GroupDetail toDomain() => GroupDetail(
    group: GroupDto(json['group'] as Json).toDomain(),
    members: [
      for (final m in jsonList(json['members']))
        GroupMember(
          studentId: m['studentId'] as String,
          firstName: m['firstName'] as String? ?? '',
          lastName: m['lastName'] as String? ?? '',
          username: m['username'] as String? ?? '',
          attendanceRate: m['attendanceRate'] as int?,
        ),
    ],
  );
}

GroupRef groupRef(Json json) => GroupRef(
  id: json['id'] as String,
  name: json['name'] as String? ?? '',
  code: json['code'] as String? ?? '',
  color: json['color'] as String? ?? '#2B3990',
  subject: localizedText(json['subject']),
  privateLesson: json['privateLesson'] as bool? ?? false,
);

/// `SessionResponse`.
class SessionDto {
  SessionDto(this.json);

  final Json json;

  Session toDomain() => Session(
    id: json['id'] as String,
    group: groupRef(json['group'] as Json),
    startsAt: instant(json['startsAt'])!,
    endsAt: instant(json['endsAt'])!,
    mode: sessionMode(json['mode']),
    status: sessionStatus(json['status']),
    location: json['location'] as String?,
    meetUrl: json['meetUrl'] as String?,
    ownMeetUrl: json['ownMeetUrl'] as bool? ?? false,
    cancelReason: json['cancelReason'] as String?,
    recurring: json['recurring'] as bool? ?? false,
    followingCount: json['followingCount'] as int? ?? 0,
    seriesEndsOn: day(json['seriesEndsOn']),
    prepNote: json['prepNote'] as String?,
    present: json['present'] as int? ?? 0,
    absent: json['absent'] as int? ?? 0,
    late: json['late'] as int? ?? 0,
  );
}

class SessionDetailDto {
  SessionDetailDto(this.json);

  final Json json;

  SessionDetail toDomain() {
    final previous = json['previous'] as Json?;
    return SessionDetail(
      session: SessionDto(json['session'] as Json).toDomain(),
      roster: [
        for (final r in jsonList(json['roster']))
          RosterEntry(
            studentId: r['studentId'] as String,
            firstName: r['firstName'] as String? ?? '',
            lastName: r['lastName'] as String? ?? '',
            status: attendanceStatus(r['status']),
          ),
      ],
      quickNote: json['quickNote'] as String?,
      sessionNote: json['sessionNote'] as String?,
      previous: previous == null
          ? null
          : PreviousSession(
              startsAt: instant(previous['startsAt'])!,
              sessionNote: previous['sessionNote'] as String?,
              quickNote: previous['quickNote'] as String?,
            ),
    );
  }
}

class MySessionDto {
  MySessionDto(this.json);

  final Json json;

  MySession toDomain() => MySession(
    id: json['id'] as String,
    group: groupRef(json['group'] as Json),
    startsAt: instant(json['startsAt'])!,
    endsAt: instant(json['endsAt'])!,
    mode: sessionMode(json['mode']),
    status: sessionStatus(json['status']),
    location: json['location'] as String?,
    meetUrl: json['meetUrl'] as String?,
    cancelReason: json['cancelReason'] as String?,
    attendance: attendanceStatus(json['attendance']),
  );
}

Json sessionDraftJson(SessionDraft draft) => {
  'groupId': draft.groupId,
  'date': dayParam(draft.date),
  'startTime': draft.start.hhmm,
  'endTime': draft.end.hhmm,
  'mode': sessionModeParam(draft.mode),
  'location': draft.location,
  'meetUrl': draft.meetUrl,
  'prepNote': draft.prepNote,
  'repeatWeekly': draft.repeatWeekly,
  'repeatUntil': draft.repeatUntil == null ? null : dayParam(draft.repeatUntil!),
};
