import 'package:dio/dio.dart';

import '../dto/school_dto.dart';

/// `/reference` and `/groups` (docs/03-conception/06-API_OUTLINE.md).
class SchoolApi {
  SchoolApi(this._dio);

  final Dio _dio;

  Future<Json> reference() async => (await _dio.get<Json>('/reference')).data!;

  /// Teacher only: subjects with their `groupCount`.
  Future<List<Json>> subjects() async => jsonList((await _dio.get<List<dynamic>>('/subjects')).data);

  Future<Json> createSubject(Json body) async => (await _dio.post<Json>('/subjects', data: body)).data!;

  Future<Json> updateSubject(String id, Json body) async => (await _dio.put<Json>('/subjects/$id', data: body)).data!;

  Future<void> deleteSubject(String id) => _dio.delete<void>('/subjects/$id');

  Future<List<Json>> groups() async => jsonList((await _dio.get<List<dynamic>>('/groups')).data);

  Future<Json> group(String id) async => (await _dio.get<Json>('/groups/$id')).data!;

  Future<Json> createGroup(Json body) async => (await _dio.post<Json>('/groups', data: body)).data!;

  Future<Json> updateGroup(String id, Json body) async => (await _dio.put<Json>('/groups/$id', data: body)).data!;

  Future<void> archiveGroup(String id) => _dio.post<void>('/groups/$id/archive');

  Future<Json> setMembers(String id, List<String> studentIds) async =>
      (await _dio.put<Json>('/groups/$id/members', data: {'studentIds': studentIds})).data!;

  Future<Json> createPrivateLesson(String studentId, String subjectId) async =>
      (await _dio.post<Json>('/groups/private-lessons', data: {'studentId': studentId, 'subjectId': subjectId})).data!;
}
