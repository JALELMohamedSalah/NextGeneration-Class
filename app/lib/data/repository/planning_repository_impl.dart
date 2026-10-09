import '../../domain/model/clock_time.dart';
import '../../domain/model/session.dart';
import '../../domain/repositories/planning_repository.dart';
import '../dto/school_dto.dart';
import '../remote/planning_api.dart';
import 'api_guard.dart';

class PlanningRepositoryImpl implements PlanningRepository {
  PlanningRepositoryImpl(this._api);

  final PlanningApi _api;

  @override
  Future<List<Session>> sessions({required DateTime from, required DateTime to, String? groupId}) => guard(() async {
    final list = await _api.sessions({'from': from.toUtc().toIso8601String(), 'to': to.toUtc().toIso8601String(), 'groupId': ?groupId});
    return [for (final s in list) SessionDto(s).toDomain()];
  });

  @override
  Future<SessionDetail> detail(String sessionId) => guard(() async => SessionDetailDto(await _api.detail(sessionId)).toDomain());

  @override
  Future<List<Session>> overlaps({required DateTime date, required ClockTime start, required ClockTime end, String? excludeId}) =>
      guard(() async {
        final list = await _api.overlaps({'date': dayParam(date), 'start': start.hhmm, 'end': end.hhmm, 'exclude': ?excludeId});
        return [for (final s in list) SessionDto(s).toDomain()];
      });

  @override
  Future<CreatedSessions> create(SessionDraft draft) => guard(() async {
    final json = await _api.create(sessionDraftJson(draft));
    return CreatedSessions(
      count: json['count'] as int? ?? 0,
      first: SessionDto(json['first'] as Json).toDomain(),
      overlaps: [for (final s in jsonList(json['overlaps'])) SessionDto(s).toDomain()],
    );
  });

  @override
  Future<Session> update(String sessionId, EditScope scope, SessionDraft change) =>
      guard(() async => SessionDto(await _api.update(sessionId, _scope(scope), sessionDraftJson(change))).toDomain());

  @override
  Future<Session> cancel(String sessionId, EditScope scope, {String? reason}) =>
      guard(() async => SessionDto(await _api.cancel(sessionId, _scope(scope), reason)).toDomain());

  @override
  Future<Session> restore(String sessionId) => guard(() async => SessionDto(await _api.restore(sessionId)).toDomain());

  @override
  Future<SessionDetail> start(String sessionId) => guard(() async => SessionDetailDto(await _api.start(sessionId)).toDomain());

  @override
  Future<SessionDetail> end(String sessionId) => guard(() async => SessionDetailDto(await _api.end(sessionId)).toDomain());

  @override
  Future<SessionDetail> saveAttendance(String sessionId, Map<String, AttendanceStatus> marks) => guard(() async {
    final entries = [
      for (final e in marks.entries) {'studentId': e.key, 'status': attendanceParam(e.value)},
    ];
    return SessionDetailDto(await _api.attendance(sessionId, entries)).toDomain();
  });

  @override
  Future<void> saveNotes(String sessionId, {String? prepNote, String? quickNote, String? sessionNote}) =>
      guard(() => _api.notes(sessionId, {'prepNote': prepNote, 'quickNote': quickNote, 'sessionNote': sessionNote}));

  @override
  Future<List<MySession>> mySessions({required DateTime from, required DateTime to, String? studentId}) => guard(() async {
    final list = await _api.mySessions({
      'from': from.toUtc().toIso8601String(),
      'to': to.toUtc().toIso8601String(),
      'studentId': ?studentId,
    });
    return [for (final s in list) MySessionDto(s).toDomain()];
  });

  static String _scope(EditScope scope) => scope == EditScope.following ? 'FOLLOWING' : 'ONE';
}
