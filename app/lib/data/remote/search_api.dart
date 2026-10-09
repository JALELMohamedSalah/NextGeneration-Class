import 'package:dio/dio.dart';

import '../dto/school_dto.dart';

/// `/search` (docs/HANDOVER.md, API).
class SearchApi {
  SearchApi(this._dio);

  final Dio _dio;

  Future<Json> search(String query) async => (await _dio.get<Json>('/search', queryParameters: {'q': query})).data!;
}
