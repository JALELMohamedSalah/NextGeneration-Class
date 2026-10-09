import 'package:dio/dio.dart';

import '../dto/school_dto.dart';

/// `/admin/teachers` (docs/HANDOVER.md, API): the owner of the platform only.
class AdminApi {
  AdminApi(this._dio);

  final Dio _dio;

  Future<Json> teachers() async => (await _dio.get<Json>('/admin/teachers')).data!;

  Future<Json> createTeacher(Json body) async => (await _dio.post<Json>('/admin/teachers', data: body)).data!;

  Future<Json> resetPassword(String id) async => (await _dio.post<Json>('/admin/teachers/$id/reset-password')).data!;

  Future<void> setActive(String id, {required bool active}) => _dio.post<void>('/admin/teachers/$id/${active ? 'enable' : 'disable'}');
}
