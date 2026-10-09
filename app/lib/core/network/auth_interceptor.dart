import 'dart:convert';

import 'package:dio/dio.dart';

import 'dio_client.dart';
import 'token_store.dart';

enum _Refresh { done, rejected, unreachable }

/// Adds the access token, and on 401 refreshes it once then replays the request.
/// Only a refresh refused by the server ends the session; no network keeps it.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({required this.dio, required this.refreshDio, required this.tokens});

  final Dio dio;
  final Dio refreshDio;
  final TokenStore tokens;

  static const _retriedFlag = 'ngclass.retried';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokens.accessToken;
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final isAuthCall = request.path.startsWith('/auth/');
    if (err.response?.statusCode != 401 || isAuthCall || request.extra[_retriedFlag] == true) {
      return handler.next(err);
    }
    switch (await _refresh()) {
      case _Refresh.rejected:
        await tokens.clear();
        DioClient.onSessionExpired?.call();
        return handler.next(err);
      case _Refresh.unreachable:
        return handler.next(err);
      case _Refresh.done:
        request.extra[_retriedFlag] = true;
        request.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
        try {
          handler.resolve(await dio.fetch<dynamic>(request));
        } on DioException catch (e) {
          handler.next(e);
        }
    }
  }

  Future<_Refresh> _refresh() async {
    final refreshToken = await tokens.readRefreshToken();
    if (refreshToken == null) return _Refresh.rejected;
    try {
      final response = await refreshDio.post<Map<String, dynamic>>('/auth/refresh', data: {'refreshToken': refreshToken});
      final body = response.data ?? const <String, dynamic>{};
      final access = body['accessToken'] as String?;
      if (access == null) return _Refresh.rejected;
      await tokens.save(
        accessToken: access,
        refreshToken: body['refreshToken'] as String? ?? refreshToken,
        userJson: jsonEncode(body['user']),
      );
      return _Refresh.done;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      return status == 401 || status == 403 ? _Refresh.rejected : _Refresh.unreachable;
    }
  }
}
