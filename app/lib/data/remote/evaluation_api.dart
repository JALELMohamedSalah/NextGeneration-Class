import 'package:dio/dio.dart';

import '../dto/school_dto.dart';

/// `/evaluations` (docs/HANDOVER.md, API).
class EvaluationApi {
  EvaluationApi(this._dio);

  final Dio _dio;

  Future<List<Json>> list() async => jsonList((await _dio.get<List<dynamic>>('/evaluations')).data);

  Future<Json> create(Json body) async => (await _dio.post<Json>('/evaluations', data: body)).data!;

  Future<Json> detail(String id) async => (await _dio.get<Json>('/evaluations/$id')).data!;

  Future<Json> update(String id, Json body) async => (await _dio.put<Json>('/evaluations/$id', data: body)).data!;

  Future<Json> saveGrades(String id, List<Json> grades) async =>
      (await _dio.put<Json>('/evaluations/$id/grades', data: {'grades': grades})).data!;
}
