import 'package:equatable/equatable.dart';

import 'clock_time.dart';
import 'localized_text.dart';
import 'session.dart';

/// One line of a weekly schedule: Tuesday 10:00 to 11:30.
class ScheduleSlot extends Equatable {
  const ScheduleSlot({
    required this.ruleId,
    required this.weekday,
    required this.start,
    required this.end,
    required this.mode,
    this.location,
  });

  final String ruleId;

  /// ISO day of week, 1 = Monday.
  final int weekday;
  final ClockTime start;
  final ClockTime end;
  final SessionMode mode;
  final String? location;

  @override
  List<Object?> get props => [ruleId, weekday, start, end, mode, location];
}

class Group extends Equatable {
  const Group({
    required this.id,
    required this.name,
    required this.code,
    required this.subjectId,
    required this.subject,
    required this.levelId,
    required this.level,
    required this.color,
    this.privateLesson = false,
    this.defaultMeetUrl,
    this.memberCount = 0,
    this.schedule = const [],
  });

  final String id;
  final String name;

  /// "7A", the colored square of the sidebar.
  final String code;
  final String subjectId;
  final LocalizedText subject;
  final String levelId;
  final LocalizedText level;
  final String color;
  final bool privateLesson;
  final String? defaultMeetUrl;
  final int memberCount;
  final List<ScheduleSlot> schedule;

  GroupRef get ref => GroupRef(id: id, name: name, code: code, color: color, subject: subject, privateLesson: privateLesson);

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    subjectId,
    subject,
    levelId,
    level,
    color,
    privateLesson,
    defaultMeetUrl,
    memberCount,
    schedule,
  ];
}

class GroupMember extends Equatable {
  const GroupMember({
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.attendanceRate,
  });

  final String studentId;
  final String firstName;
  final String lastName;
  final String username;
  final int? attendanceRate;

  String get fullName => '$firstName $lastName'.trim();

  String get initials => '${firstName.isEmpty ? '' : firstName[0]}${lastName.isEmpty ? '' : lastName[0]}'.toUpperCase();

  @override
  List<Object?> get props => [studentId, firstName, lastName, username, attendanceRate];
}

class GroupDetail extends Equatable {
  const GroupDetail({required this.group, required this.members});

  final Group group;
  final List<GroupMember> members;

  @override
  List<Object?> get props => [group, members];
}

class GroupDraft extends Equatable {
  const GroupDraft({required this.name, required this.subjectId, required this.levelId, this.defaultMeetUrl, this.color});

  final String name;
  final String subjectId;
  final String levelId;
  final String? defaultMeetUrl;

  /// Null: the next color of the palette.
  final String? color;

  @override
  List<Object?> get props => [name, subjectId, levelId, defaultMeetUrl, color];
}
