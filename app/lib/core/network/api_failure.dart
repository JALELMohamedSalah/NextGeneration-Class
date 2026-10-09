import 'package:dio/dio.dart';

/// Why an API call failed. [message] comes from the server, already in the language sent in
/// Accept-Language; local problems (no network) have no message and the view words them.
class ApiFailure implements Exception {
  const ApiFailure({required this.code, this.message, this.statusCode});

  static const network = 'network';
  static const unknown = 'unknown';

  /// A stable code: the server's (`invalid_credentials`, `weak_password`...) or [network] / [unknown].
  final String code;
  final String? message;
  final int? statusCode;

  bool get isNetwork => code == network;

  factory ApiFailure.from(Object error) {
    if (error is ApiFailure) return error;
    if (error is DioException) {
      final response = error.response;
      final data = response?.data;
      if (data is Map && data['code'] is String) {
        return ApiFailure(code: data['code'] as String, message: data['message'] as String?, statusCode: response?.statusCode);
      }
      if (response == null) return const ApiFailure(code: network);
      return ApiFailure(code: unknown, statusCode: response.statusCode);
    }
    return const ApiFailure(code: unknown);
  }

  @override
  String toString() => 'ApiFailure($code, $statusCode)';
}
