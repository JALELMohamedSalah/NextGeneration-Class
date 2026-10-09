import 'package:dio/dio.dart';

import '../../core/network/api_failure.dart';

/// Runs an API call and turns transport errors into an [ApiFailure] the view can word.
Future<T> guard<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    throw ApiFailure.from(e);
  }
}
