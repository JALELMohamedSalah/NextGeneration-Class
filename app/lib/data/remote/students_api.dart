import 'package:dio/dio.dart';

import '../dto/school_dto.dart';

/// `/students`, `/parents` and `/users/{id}/reset-password` (teacher only).
class StudentsApi {
  StudentsApi(this._dio);

  final Dio _dio;

  Future<List<Json>> list({required bool archived}) async =>
      jsonList((await _dio.get<List<dynamic>>('/students', queryParameters: {'archived': archived})).data);

  Future<Json> detail(String id) async => (await _dio.get<Json>('/students/$id')).data!;

  Future<Json> create(Json body) async => (await _dio.post<Json>('/students', data: body)).data!;

  Future<Json> update(String id, Json body) async => (await _dio.put<Json>('/students/$id', data: body)).data!;

  Future<void> archive(String id) => _dio.post<void>('/students/$id/archive');

  Future<void> restore(String id) => _dio.post<void>('/students/$id/restore');

  Future<Json> usernameSuggestion(Map<String, String> query) async =>
      (await _dio.get<Json>('/students/username-suggestion', queryParameters: query)).data!;

  Future<Json> enableLogin(String id) async => (await _dio.post<Json>('/students/$id/login')).data!;

  Future<void> disableLogin(String id) => _dio.delete<void>('/students/$id/login');

  Future<Json> resetPassword(String userId) async => (await _dio.post<Json>('/users/$userId/reset-password')).data!;

  Future<List<Json>> parents() async => jsonList((await _dio.get<List<dynamic>>('/parents')).data);

  Future<List<Json>> privateNotes(String id) async => jsonList((await _dio.get<List<dynamic>>('/students/$id/private-notes')).data);

  Future<Json> addPrivateNote(String id, String body) async =>
      (await _dio.post<Json>('/students/$id/private-notes', data: {'body': body})).data!;

  Future<Json> editPrivateNote(String id, String noteId, String body) async =>
      (await _dio.put<Json>('/students/$id/private-notes/$noteId', data: {'body': body})).data!;

  Future<void> deletePrivateNote(String id, String noteId) => _dio.delete<void>('/students/$id/private-notes/$noteId');

  Future<List<Json>> comments(String id) async => jsonList((await _dio.get<List<dynamic>>('/students/$id/comments')).data);

  Future<Json> addComment(String id, String body) async => (await _dio.post<Json>('/students/$id/comments', data: {'body': body})).data!;
}
