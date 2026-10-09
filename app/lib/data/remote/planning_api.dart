import 'package:dio/dio.dart';

import '../dto/school_dto.dart';

/// `/sessions` for the teacher, `/me/sessions` for students and parents.
class PlanningApi {
  PlanningApi(this._dio);

  final Dio _dio;

  Future<List<Json>> sessions(Map<String, String> query) async =>
      jsonList((await _dio.get<List<dynamic>>('/sessions', queryParameters: query)).data);

  Future<Json> detail(String id) async => (await _dio.get<Json>('/sessions/$id')).data!;

  Future<List<Json>> overlaps(Map<String, String> query) async =>
      jsonList((await _dio.get<List<dynamic>>('/sessions/overlaps', queryParameters: query)).data);

  Future<Json> create(Json body) async => (await _dio.post<Json>('/sessions', data: body)).data!;

  Future<Json> update(String id, String scope, Json body) async =>
      (await _dio.put<Json>('/sessions/$id', queryParameters: {'scope': scope}, data: body)).data!;

  Future<Json> cancel(String id, String scope, String? reason) async =>
      (await _dio.post<Json>('/sessions/$id/cancel', queryParameters: {'scope': scope}, data: {'reason': reason})).data!;

  Future<Json> restore(String id) async => (await _dio.post<Json>('/sessions/$id/restore')).data!;

  Future<Json> start(String id) async => (await _dio.post<Json>('/sessions/$id/start')).data!;

  Future<Json> end(String id) async => (await _dio.post<Json>('/sessions/$id/end')).data!;

  Future<Json> attendance(String id, List<Json> entries) async =>
      (await _dio.put<Json>('/sessions/$id/attendance', data: {'entries': entries})).data!;

  Future<void> notes(String id, Json body) => _dio.put<void>('/sessions/$id/notes', data: body);

  Future<List<Json>> mySessions(Map<String, String> query) async =>
      jsonList((await _dio.get<List<dynamic>>('/me/sessions', queryParameters: query)).data);
}
