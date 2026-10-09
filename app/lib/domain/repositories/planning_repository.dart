import '../model/clock_time.dart';
import '../model/session.dart';

/// Sessions and attendance. Instants are UTC; dates and clock times are Tunisian.
abstract interface class PlanningRepository {
  Future<List<Session>> sessions({required DateTime from, required DateTime to, String? groupId});

  Future<SessionDetail> detail(String sessionId);

  /// Sessions overlapping a slot, for the warning of the form (allowed anyway).
  Future<List<Session>> overlaps({required DateTime date, required ClockTime start, required ClockTime end, String? excludeId});

  Future<CreatedSessions> create(SessionDraft draft);

  Future<Session> update(String sessionId, EditScope scope, SessionDraft change);

  Future<Session> cancel(String sessionId, EditScope scope, {String? reason});

  Future<Session> restore(String sessionId);

  Future<SessionDetail> start(String sessionId);

  Future<SessionDetail> end(String sessionId);

  Future<SessionDetail> saveAttendance(String sessionId, Map<String, AttendanceStatus> marks);

  Future<void> saveNotes(String sessionId, {String? prepNote, String? quickNote, String? sessionNote});

  /// A student's sessions, or a parent's child's ([studentId]).
  Future<List<MySession>> mySessions({required DateTime from, required DateTime to, String? studentId});
}
