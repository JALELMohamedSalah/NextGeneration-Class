import 'package:ngclass/core/l10n/tunis_time.dart';
import 'package:ngclass/core/network/api_failure.dart';
import 'package:ngclass/domain/model/app_notification.dart';
import 'package:ngclass/domain/model/app_user.dart';
import 'package:ngclass/domain/model/clock_time.dart';
import 'package:ngclass/domain/model/group.dart';
import 'package:ngclass/domain/model/localized_text.dart';
import 'package:ngclass/domain/model/reference.dart';
import 'package:ngclass/domain/model/session.dart';
import 'package:ngclass/domain/model/student.dart';
import 'package:ngclass/domain/model/teacher_account.dart';
import 'package:ngclass/domain/repositories/admin_repository.dart';
import 'package:ngclass/domain/repositories/group_repository.dart';
import 'package:ngclass/domain/repositories/notification_repository.dart';
import 'package:ngclass/domain/repositories/planning_repository.dart';
import 'package:ngclass/domain/repositories/reference_repository.dart';
import 'package:ngclass/domain/repositories/student_repository.dart';

const math = LocalizedText(fr: 'Mathématiques', ar: 'الرياضيات');
const fourth = LocalizedText(fr: '4ème année', ar: 'السنة الرابعة ابتدائي');

const reference = Reference(
  subjects: [Subject(id: 'math', name: math, color: '#2B3990')],
  levels: [Level(id: 'l4', name: fourth)],
  currentYear: null,
);

const group4A = Group(
  id: 'g4a',
  name: '4ème année · Maths',
  code: '4A',
  subjectId: 'math',
  subject: math,
  levelId: 'l4',
  level: fourth,
  color: '#2B3990',
  memberCount: 2,
);

GroupRef get ref4A => group4A.ref;

StudentSummary student(String id, String first, String last, {int? rate, int absences = 0, bool archived = false}) => StudentSummary(
  id: id,
  userId: 'u$id',
  firstName: first,
  lastName: last,
  username: '${first.toLowerCase()}.${last.toLowerCase()}',
  levelId: 'l4',
  level: fourth,
  groups: const [GroupTag(id: 'g4a', name: '4ème année · Maths', code: '4A', color: '#2B3990')],
  attendanceRate: rate,
  absences: absences,
  archived: archived,
);

/// A session of 4ème année · Maths on a Tunisian day and time.
Session session(
  String id,
  DateTime day,
  ClockTime start, {
  int minutes = 90,
  SessionStatus status = SessionStatus.planned,
  SessionMode mode = SessionMode.inPerson,
  String? meetUrl,
  bool recurring = false,
}) => Session(
  id: id,
  group: ref4A,
  startsAt: TunisTime.instant(day, start),
  endsAt: TunisTime.instant(day, start).add(Duration(minutes: minutes)),
  mode: mode,
  status: status,
  location: mode == SessionMode.inPerson ? 'Salle 2' : null,
  meetUrl: meetUrl,
  recurring: recurring,
);

/// The reference lists with a current school year (Paramètres shows it).
final referenceWithYear = Reference(
  subjects: reference.subjects,
  levels: reference.levels,
  currentYear: SchoolYear(id: 'y', label: '2026-2027', startsOn: DateTime.utc(2026, 9, 1), endsOn: DateTime.utc(2027, 6, 30)),
);

class FakeReferenceRepository implements ReferenceRepository {
  FakeReferenceRepository({Reference? reference, List<SubjectUsage>? usage})
    : _reference = reference,
      usage =
          usage ??
          [
            const SubjectUsage(
              subject: Subject(id: 'math', name: math, color: '#2B3990'),
              groupCount: 1,
            ),
          ];

  final Reference? _reference;

  /// What Paramètres lists.
  List<SubjectUsage> usage;
  ApiFailure? usageFailure;

  /// Thrown by [deleteSubject], e.g. `subject_in_use` when a group took the subject meanwhile.
  ApiFailure? deleteFailure;

  final List<SubjectDraft> createdSubjects = [];
  final List<(String, SubjectDraft)> updatedSubjects = [];
  final List<String> deletedSubjects = [];

  @override
  Future<Reference> load() async => _reference ?? reference;

  @override
  Future<List<SubjectUsage>> subjectsWithUsage() async {
    if (usageFailure != null) throw usageFailure!;
    return usage;
  }

  @override
  Future<Subject> createSubject(SubjectDraft draft) async {
    createdSubjects.add(draft);
    return Subject(
      id: 'new-subject',
      name: LocalizedText(fr: draft.nameFr, ar: draft.nameAr),
      color: draft.color ?? '#12A39A',
    );
  }

  @override
  Future<Subject> updateSubject(String id, SubjectDraft draft) async {
    updatedSubjects.add((id, draft));
    return Subject(
      id: id,
      name: LocalizedText(fr: draft.nameFr, ar: draft.nameAr),
      color: draft.color ?? '#12A39A',
    );
  }

  @override
  Future<void> deleteSubject(String id) async {
    if (deleteFailure != null) throw deleteFailure!;
    deletedSubjects.add(id);
  }
}

class FakeGroupRepository implements GroupRepository {
  List<Group> groups = [group4A];
  List<String>? lastMembers;

  @override
  Future<List<Group>> list() async => groups;

  @override
  Future<GroupDetail> detail(String groupId) async => GroupDetail(group: groups.firstWhere((g) => g.id == groupId), members: const []);

  @override
  Future<Group> create(GroupDraft draft) async => group4A;

  @override
  Future<Group> update(String groupId, GroupDraft draft) async => group4A;

  @override
  Future<void> archive(String groupId) async {}

  @override
  Future<GroupDetail> setMembers(String groupId, List<String> studentIds) async {
    lastMembers = studentIds;
    return GroupDetail(group: group4A, members: const []);
  }

  @override
  Future<Group> createPrivateLesson({required String studentId, required String subjectId}) async => group4A;
}

class FakeStudentRepository implements StudentRepository {
  List<StudentSummary> students = [];
  final List<StudentDraft> created = [];
  final List<Map<String, String?>> usernameChecks = [];
  Set<String> takenUsernames = {};
  ApiFailure? failure;

  @override
  Future<List<StudentSummary>> list({bool archived = false}) async {
    if (failure != null) throw failure!;
    return students.where((s) => s.archived == archived).toList();
  }

  @override
  Future<StudentProfile> profile(String studentId) async =>
      StudentProfile(student: students.firstWhere((s) => s.id == studentId), attendance: const AttendanceSummary());

  @override
  Future<SavedStudent> create(StudentDraft draft) async {
    if (failure != null) throw failure!;
    created.add(draft);
    final saved = student('new', draft.firstName, draft.lastName);
    return SavedStudent(
      student: saved,
      accounts: [
        if (draft.createLogin)
          NewAccount(
            userId: 'unew',
            role: UserRole.student,
            firstName: draft.firstName,
            lastName: draft.lastName,
            username: draft.username ?? saved.username,
            temporaryPassword: 'kprate4827',
          ),
      ],
    );
  }

  @override
  Future<SavedStudent> update(String studentId, StudentDraft draft) async =>
      SavedStudent(student: student(studentId, draft.firstName, draft.lastName));

  @override
  Future<void> archive(String studentId) async {}

  @override
  Future<void> restore(String studentId) async {}

  @override
  Future<UsernameCheck> checkUsername({String? firstName, String? lastName, String? username}) async {
    usernameChecks.add({'firstName': firstName, 'lastName': lastName, 'username': username});
    if (username != null) return UsernameCheck(username: username, available: !takenUsernames.contains(username));
    return UsernameCheck(username: '${firstName!.toLowerCase()}.${lastName!.toLowerCase()}', available: true);
  }

  @override
  Future<NewAccount> resetPassword({
    required String userId,
    required UserRole role,
    required String firstName,
    required String lastName,
  }) async =>
      NewAccount(userId: userId, role: role, firstName: firstName, lastName: lastName, username: 'x', temporaryPassword: 'abcdef2345');

  @override
  Future<NewAccount> enableLogin(StudentSummary student) async => NewAccount(
    userId: student.userId,
    role: UserRole.student,
    firstName: student.firstName,
    lastName: student.lastName,
    username: student.username,
    temporaryPassword: 'hjkmnp2345',
  );

  @override
  Future<void> disableLogin(String studentId) async {}

  @override
  Future<List<ParentAccount>> parents() async => const [];

  @override
  Future<List<NoteEntry>> privateNotes(String studentId) async => const [];

  @override
  Future<NoteEntry> addPrivateNote(String studentId, String body) async =>
      NoteEntry(id: 'n', body: body, createdAt: DateTime.utc(2026), updatedAt: DateTime.utc(2026));

  @override
  Future<NoteEntry> editPrivateNote(String studentId, String noteId, String body) async =>
      NoteEntry(id: noteId, body: body, createdAt: DateTime.utc(2026), updatedAt: DateTime.utc(2026));

  @override
  Future<void> deletePrivateNote(String studentId, String noteId) async {}

  @override
  Future<List<NoteEntry>> comments(String studentId) async => const [];

  @override
  Future<NoteEntry> addComment(String studentId, String body) async =>
      NoteEntry(id: 'c', body: body, createdAt: DateTime.utc(2026), updatedAt: DateTime.utc(2026));
}

/// Keeps sessions in memory and records what was asked.
class FakePlanningRepository implements PlanningRepository {
  List<Session> all = [];
  List<MySession> mine = [];
  List<Session> overlapping = [];
  SessionDetail? detailResult;
  final List<({DateTime from, DateTime to, String? groupId})> ranges = [];
  final List<Map<String, AttendanceStatus>> attendanceSaves = [];
  final List<String?> quickNotes = [];
  final List<SessionDraft> drafts = [];
  int ends = 0;

  @override
  Future<List<Session>> sessions({required DateTime from, required DateTime to, String? groupId}) async {
    ranges.add((from: from, to: to, groupId: groupId));
    return all.where((s) => s.startsAt.isBefore(to) && s.endsAt.isAfter(from) && (groupId == null || s.group.id == groupId)).toList();
  }

  @override
  Future<SessionDetail> detail(String sessionId) async => detailResult!;

  @override
  Future<List<Session>> overlaps({required DateTime date, required ClockTime start, required ClockTime end, String? excludeId}) async =>
      overlapping;

  @override
  Future<CreatedSessions> create(SessionDraft draft) async {
    drafts.add(draft);
    final first = session('created', draft.date, draft.start);
    return CreatedSessions(count: draft.repeatWeekly ? 5 : 1, first: first, overlaps: const []);
  }

  @override
  Future<Session> update(String sessionId, EditScope scope, SessionDraft change) async => session(sessionId, change.date, change.start);

  @override
  Future<Session> cancel(String sessionId, EditScope scope, {String? reason}) async => all.first;

  @override
  Future<Session> restore(String sessionId) async => all.first;

  @override
  Future<SessionDetail> start(String sessionId) async => detailResult!;

  @override
  Future<SessionDetail> end(String sessionId) async {
    ends++;
    final d = detailResult!;
    final s = d.session;
    return SessionDetail(
      session: Session(id: s.id, group: s.group, startsAt: s.startsAt, endsAt: s.endsAt, mode: s.mode, status: SessionStatus.done),
      roster: d.roster,
    );
  }

  @override
  Future<SessionDetail> saveAttendance(String sessionId, Map<String, AttendanceStatus> marks) async {
    attendanceSaves.add(Map.of(marks));
    return detailResult!;
  }

  @override
  Future<void> saveNotes(String sessionId, {String? prepNote, String? quickNote, String? sessionNote}) async => quickNotes.add(quickNote);

  @override
  Future<List<MySession>> mySessions({required DateTime from, required DateTime to, String? studentId}) async => mine;
}

/// Notifications in memory: what the list and the badge read, and what was marked read.
class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository({this.items = const [], int? unread}) : unread = unread ?? items.where((n) => !n.read).length;

  List<AppNotification> items;
  int unread;
  ApiFailure? failure;
  final List<String> readIds = [];
  int readAll = 0;
  int countCalls = 0;

  @override
  Future<NotificationsPage> load() async {
    if (failure != null) throw failure!;
    return NotificationsPage(unreadCount: unread, items: items);
  }

  @override
  Future<int> unreadCount() async {
    countCalls++;
    if (failure != null) throw failure!;
    return unread;
  }

  @override
  Future<void> markRead(String id) async => readIds.add(id);

  @override
  Future<void> markAllRead() async => readAll++;
}

/// Teachers in memory for the owner's dashboard, with what each call received.
class FakeAdminRepository implements AdminRepository {
  FakeAdminRepository({List<TeacherAccount>? accounts}) : accounts = accounts ?? [];

  List<TeacherAccount> accounts;
  ApiFailure? failure;
  ApiFailure? createFailure;
  final List<TeacherDraft> created = [];
  final List<(String, bool)> activations = [];
  final List<String> resets = [];

  @override
  Future<TeachersOverview> teachers() async {
    if (failure != null) throw failure!;
    return TeachersOverview(
      totals: TeachersTotals(
        teachers: accounts.length,
        activeTeachers: accounts.where((t) => t.active).length,
        students: accounts.fold(0, (sum, t) => sum + t.students),
        parents: accounts.fold(0, (sum, t) => sum + t.parents),
        groups: accounts.fold(0, (sum, t) => sum + t.groups),
      ),
      teachers: accounts,
    );
  }

  @override
  Future<(TeacherAccount, NewAccount)> createTeacher(TeacherDraft draft) async {
    if (createFailure != null) throw createFailure!;
    created.add(draft);
    final teacher = TeacherAccount(
      id: 't${created.length + 10}',
      firstName: draft.firstName,
      lastName: draft.lastName,
      username: draft.username,
      phone: draft.phone,
      active: true,
      awaitingFirstLogin: true,
      createdAt: DateTime.utc(2026, 10, 6),
    );
    return (
      teacher,
      NewAccount(
        userId: teacher.id,
        role: UserRole.teacher,
        firstName: draft.firstName,
        lastName: draft.lastName,
        username: draft.username,
        temporaryPassword: 'kprate4827',
      ),
    );
  }

  @override
  Future<NewAccount> resetPassword(TeacherAccount teacher) async {
    resets.add(teacher.id);
    return NewAccount(
      userId: teacher.id,
      role: UserRole.teacher,
      firstName: teacher.firstName,
      lastName: teacher.lastName,
      username: teacher.username,
      temporaryPassword: 'hjkmnp2345',
    );
  }

  @override
  Future<void> setActive(String teacherId, {required bool active}) async => activations.add((teacherId, active));
}
