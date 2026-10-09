import '../../domain/model/app_user.dart';
import '../../domain/model/session.dart';
import '../../domain/model/student.dart';
import 'school_dto.dart';
import 'user_dto.dart';

/// `StudentRow`.
class StudentDto {
  StudentDto(this.json);

  final Json json;

  StudentSummary toDomain() => StudentSummary(
    id: json['id'] as String,
    userId: json['userId'] as String,
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    username: json['username'] as String? ?? '',
    phone: json['phone'] as String?,
    levelId: json['levelId'] as String,
    level: localizedText(json['level']),
    groups: [
      for (final g in jsonList(json['groups']))
        GroupTag(
          id: g['id'] as String,
          name: g['name'] as String? ?? '',
          code: g['code'] as String? ?? '',
          color: g['color'] as String? ?? '#2B3990',
          privateLesson: g['privateLesson'] as bool? ?? false,
        ),
    ],
    parents: [
      for (final p in jsonList(json['parents']))
        ParentTag(
          id: p['id'] as String,
          userId: p['userId'] as String,
          firstName: p['firstName'] as String? ?? '',
          lastName: p['lastName'] as String? ?? '',
          phone: p['phone'] as String?,
          relation: p['relation'] as String?,
        ),
    ],
    loginEnabled: json['loginEnabled'] as bool? ?? false,
    archived: json['archived'] as bool? ?? false,
    attendanceRate: json['attendanceRate'] as int?,
    absences: json['absences'] as int? ?? 0,
  );
}

class StudentProfileDto {
  StudentProfileDto(this.json);

  final Json json;

  StudentProfile toDomain() {
    final attendance = json['attendance'] as Json? ?? const {};
    return StudentProfile(
      student: StudentDto(json['student'] as Json).toDomain(),
      lastLoginAt: instant(json['lastLoginAt']),
      attendance: AttendanceSummary(
        present: attendance['present'] as int? ?? 0,
        absent: attendance['absent'] as int? ?? 0,
        late: attendance['late'] as int? ?? 0,
        rate: attendance['rate'] as int?,
        recent: [
          for (final m in jsonList(attendance['recent']))
            AttendanceMark(sessionStart: instant(m['sessionStart'])!, status: attendanceStatus(m['status']) ?? AttendanceStatus.present),
        ],
      ),
      nextSessions: [
        for (final s in jsonList(json['nextSessions']))
          UpcomingSession(
            id: s['id'] as String,
            groupId: s['groupId'] as String,
            groupName: s['groupName'] as String? ?? '',
            groupColor: s['groupColor'] as String? ?? '#2B3990',
            startsAt: instant(s['startsAt'])!,
            endsAt: instant(s['endsAt'])!,
            mode: sessionMode(s['mode']),
            location: s['location'] as String?,
          ),
      ],
    );
  }
}

UserRole role(Object? value) => switch (value) {
  'ADMIN' => UserRole.admin,
  'TEACHER' => UserRole.teacher,
  'PARENT' => UserRole.parent,
  _ => UserRole.student,
};

NewAccount newAccount(Json json) => NewAccount(
  userId: json['userId'] as String,
  role: role(json['role']),
  firstName: json['firstName'] as String? ?? '',
  lastName: json['lastName'] as String? ?? '',
  username: json['username'] as String? ?? '',
  temporaryPassword: json['temporaryPassword'] as String? ?? '',
);

SavedStudent savedStudent(Json json) => SavedStudent(
  student: StudentDto(json['student'] as Json).toDomain(),
  accounts: [for (final c in jsonList(json['credentials'])) newAccount(c)],
);

NoteEntry noteEntry(Json json) => NoteEntry(
  id: json['id'] as String,
  body: json['body'] as String? ?? '',
  createdAt: instant(json['createdAt'])!,
  updatedAt: instant(json['updatedAt'])!,
);

ParentAccount parentAccount(Json json) => ParentAccount(
  id: json['id'] as String,
  userId: json['userId'] as String,
  firstName: json['firstName'] as String? ?? '',
  lastName: json['lastName'] as String? ?? '',
  phone: json['phone'] as String?,
  children: (json['children'] as List<dynamic>? ?? const []).cast<String>(),
);

Json studentDraftJson(StudentDraft draft) => {
  'firstName': draft.firstName.trim(),
  'lastName': draft.lastName.trim(),
  'levelId': draft.levelId,
  'phone': draft.phone,
  'username': draft.username,
  'groupIds': draft.groupIds,
  'createLogin': draft.createLogin,
  'parents': [
    for (final p in draft.parents)
      p.isExisting
          ? {'existingParentId': p.existingParentId, 'relation': p.relation}
          : {'firstName': p.firstName.trim(), 'lastName': p.lastName.trim(), 'phone': p.phone, 'email': p.email, 'relation': p.relation},
  ],
};
