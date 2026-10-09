import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/l10n/app_language.dart';
import '../../core/network/api_failure.dart';
import '../../core/network/token_store.dart';
import '../../domain/model/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../dto/user_dto.dart';
import '../remote/auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthApi api, required TokenStore tokens}) : _api = api, _tokens = tokens;

  final AuthApi _api;
  final TokenStore _tokens;

  @override
  Future<AppUser> login({required String login, required String password}) async {
    try {
      return await _open(await _api.login(login, password));
    } on DioException catch (e) {
      throw ApiFailure.from(e);
    }
  }

  @override
  Future<AppUser?> restoreSession() async {
    final refreshToken = await _tokens.readRefreshToken();
    if (refreshToken == null) return null;
    try {
      return await _open(await _api.refresh(refreshToken));
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        await _tokens.clear();
        return null;
      }
      // Server unreachable: stay signed in with the last known user.
      final cached = await _tokens.readUser();
      return cached == null ? null : UserDto(jsonDecode(cached) as Map<String, dynamic>).toDomain();
    }
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _tokens.readRefreshToken();
    try {
      if (refreshToken != null) await _api.logout(refreshToken);
    } on DioException {
      // Offline logout still signs this device out.
    }
    await _tokens.clear();
  }

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      await _api.changePassword(currentPassword, newPassword);
      final cached = await _tokens.readUser();
      if (cached != null) {
        final json = jsonDecode(cached) as Map<String, dynamic>..['mustChangePassword'] = false;
        await _tokens.saveUser(jsonEncode(json));
      }
    } on DioException catch (e) {
      throw ApiFailure.from(e);
    }
  }

  @override
  Future<void> updateLanguage(AppLanguage language) async {
    try {
      await _api.updateLanguage(language.code);
    } on DioException catch (e) {
      throw ApiFailure.from(e);
    }
  }

  Future<AppUser> _open(AuthSessionDto session) async {
    await _tokens.save(accessToken: session.accessToken, refreshToken: session.refreshToken, userJson: jsonEncode(session.user.json));
    return session.user.toDomain();
  }
}
