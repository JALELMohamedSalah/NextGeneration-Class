import 'package:dio/dio.dart';

import '../dto/user_dto.dart';

/// /auth and /me endpoints (docs/03-conception/06-API_OUTLINE.md).
class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<AuthSessionDto> login(String login, String password) async {
    final response = await _dio.post<Map<String, dynamic>>('/auth/login', data: {'login': login, 'password': password});
    return AuthSessionDto.fromJson(response.data!);
  }

  Future<AuthSessionDto> refresh(String refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>('/auth/refresh', data: {'refreshToken': refreshToken});
    return AuthSessionDto.fromJson(response.data!);
  }

  Future<void> logout(String refreshToken) => _dio.post<void>('/auth/logout', data: {'refreshToken': refreshToken});

  Future<void> changePassword(String currentPassword, String newPassword) =>
      _dio.post<void>('/me/password', data: {'currentPassword': currentPassword, 'newPassword': newPassword});

  Future<void> updateLanguage(String code) => _dio.put<void>('/me/language', data: {'language': code});
}
