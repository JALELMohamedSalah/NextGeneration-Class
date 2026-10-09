import 'package:dio/dio.dart';

import '../dto/school_dto.dart';

/// `/me/results` (docs/HANDOVER.md, API).
class ResultsApi {
  ResultsApi(this._dio);

  final Dio _dio;

  Future<Json> mine({String? studentId}) async => (await _dio.get<Json>('/me/results', queryParameters: {'studentId': ?studentId})).data!;

  Future<Json> forStudent(String studentId) async => (await _dio.get<Json>('/students/$studentId/results')).data!;
}
