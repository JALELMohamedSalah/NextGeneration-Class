import 'package:equatable/equatable.dart';

import 'app_user.dart';
import 'localized_text.dart';
import 'session.dart';

/// A group as a student row shows it: colored square with its code, and its name.
class GroupTag extends Equatable {
  const GroupTag({required this.id, required this.name, required this.code, required this.color, this.privateLesson = false});

  final String id;
  final String name;
  final String code;
  final String color;
  final bool privateLesson;

  @override
  List<Object?> get props => [id, name, code, color, privateLesson];
}

class ParentTag extends Equatable {
  const ParentTag({required this.id, required this.userId, required this.firstName, required this.lastName, this.phone, this.relation});

  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String? phone;

  /// "mère", "père", "tuteur", as the teacher typed it.
  final String? relation;

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [id, userId, firstName, lastName, phone, relation];
}

/// One line of the students list.
class StudentSummary extends Equatable {
  const StudentSummary({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.levelId,
    required this.level,
    this.phone,
    this.groups = const [],
    this.parents = const [],
    this.loginEnabled = false,
    this.archived = false,
    this.attendanceRate,
    this.absences = 0,
  });

  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String username;
  final String? phone;
  final String levelId;
  final LocalizedText level;
  final List<GroupTag> groups;
  final List<ParentTag> parents;

  /// The child signs in with their own username; otherwise parents follow for them.
  final bool loginEnabled;
  final bool archived;

  /// Null until a session has been counted.
  final int? attendanceRate;
  final int absences;

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final value = '${firstName.isEmpty ? '' : firstName[0]}${lastName.isEmpty ? '' : lastName[0]}'.toUpperCase();
    return value.isEmpty ? '?' : value;
  }

  /// Matches the search box: name, username or phone, without accents or case.
  bool matches(String query) {
    final q = foldAccents(query.trim().toLowerCase());
    if (q.isEmpty) return true;
    final haystack = foldAccents('$firstName $lastName $lastName $firstName $username ${phone ?? ''}'.toLowerCase());
    return haystack.contains(q);
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    firstName,
    lastName,
    username,
    phone,
    levelId,
    level,
    groups,
    parents,
    loginEnabled,
    archived,
    attendanceRate,
    absences,
  ];
}

/// "Éya" and "eya" match.
String foldAccents(String text) {
  const from = 'àâäáãåçéèêëíìîïñóòôöõúùûüýÿ';
  const to = 'aaaaaaceeeeiiiinooooouuuuyy';
  final out = StringBuffer();
  for (final char in text.split('')) {
    final index = from.indexOf(char);
    out.write(index < 0 ? char : to[index]);
  }
  return out.toString();
}

class AttendanceMark extends Equatable {
  const AttendanceMark({required this.sessionStart, required this.status});

  final DateTime sessionStart;
  final AttendanceStatus status;

  @override
  List<Object?> get props => [sessionStart, status];
}

/// Attendance % = (present + late) / sessions counted (docs/03-conception/03-BUSINESS_RULES.md).
class AttendanceSummary extends Equatable {
  const AttendanceSummary({this.present = 0, this.absent = 0, this.late = 0, this.rate, this.recent = const []});

  final int present;
  final int absent;
  final int late;
  final int? rate;

  /// Newest first, 10 at most.
  final List<AttendanceMark> recent;

  int get counted => present + absent + late;

  @override
  List<Object?> get props => [present, absent, late, rate, recent];
}

class UpcomingSession extends Equatable {
  const UpcomingSession({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.groupColor,
    required this.startsAt,
    required this.endsAt,
    required this.mode,
    this.location,
  });

  final String id;
  final String groupId;
  final String groupName;
  final String groupColor;
  final DateTime startsAt;
  final DateTime endsAt;
  final SessionMode mode;
  final String? location;

  @override
  List<Object?> get props => [id, groupId, groupName, groupColor, startsAt, endsAt, mode, location];
}

/// Everything "Fiche élève" shows, except notes and comments (loaded apart).
class StudentProfile extends Equatable {
  const StudentProfile({required this.student, required this.attendance, this.lastLoginAt, this.nextSessions = const []});

  final StudentSummary student;
  final DateTime? lastLoginAt;
  final AttendanceSummary attendance;
  final List<UpcomingSession> nextSessions;

  @override
  List<Object?> get props => [student, lastLoginAt, attendance, nextSessions];
}

/// An account and its temporary password, shown once after creation or reset.
class NewAccount extends Equatable {
  const NewAccount({
    required this.userId,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.temporaryPassword,
  });

  final String userId;
  final UserRole role;
  final String firstName;
  final String lastName;
  final String username;
  final String temporaryPassword;

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [userId, role, firstName, lastName, username, temporaryPassword];
}

class SavedStudent extends Equatable {
  const SavedStudent({required this.student, this.accounts = const []});

  final StudentSummary student;

  /// New accounts only (the student when created, new parents).
  final List<NewAccount> accounts;

  @override
  List<Object?> get props => [student, accounts];
}

/// A parent in the student form: an existing account, or a new one.
class ParentDraft extends Equatable {
  const ParentDraft({this.existingParentId, this.firstName = '', this.lastName = '', this.phone = '', this.email, this.relation});

  final String? existingParentId;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String? relation;

  bool get isExisting => existingParentId != null;

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [existingParentId, firstName, lastName, phone, email, relation];
}

class StudentDraft extends Equatable {
  const StudentDraft({
    required this.firstName,
    required this.lastName,
    required this.levelId,
    this.phone,
    this.username,
    this.groupIds = const [],
    this.parents = const [],
    this.createLogin = false,
  });

  final String firstName;
  final String lastName;
  final String levelId;
  final String? phone;

  /// Null: generated as prenom.nom by the server.
  final String? username;
  final List<String> groupIds;

  /// Parents to link; existing links are kept when editing.
  final List<ParentDraft> parents;

  /// The child gets their own login (most primary pupils do not: parents follow).
  final bool createLogin;

  @override
  List<Object?> get props => [firstName, lastName, levelId, phone, username, groupIds, parents, createLogin];
}

class UsernameCheck extends Equatable {
  const UsernameCheck({required this.username, required this.available});

  final String username;
  final bool available;

  @override
  List<Object?> get props => [username, available];
}

/// A private note (teacher only) or a comment (read by the student and parents).
class NoteEntry extends Equatable {
  const NoteEntry({required this.id, required this.body, required this.createdAt, required this.updatedAt});

  final String id;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, body, createdAt, updatedAt];
}

/// An existing parent account, to link to another child.
class ParentAccount extends Equatable {
  const ParentAccount({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.children = const [],
  });

  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String? phone;

  /// First names of the children already linked.
  final List<String> children;

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [id, userId, firstName, lastName, phone, children];
}
