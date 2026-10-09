import 'package:dio/dio.dart';

import '../dto/school_dto.dart';

/// `/me/comments` (docs/HANDOVER.md, API).
class CommentsApi {
  CommentsApi(this._dio);

  final Dio _dio;

  Future<List<Json>> mine({String? studentId}) async =>
      jsonList((await _dio.get<List<dynamic>>('/me/comments', queryParameters: {'studentId': ?studentId})).data);
}
