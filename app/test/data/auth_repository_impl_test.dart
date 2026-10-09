import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ngclass/core/network/token_store.dart';
import 'package:ngclass/data/remote/auth_api.dart';
import 'package:ngclass/data/repository/auth_repository_impl.dart';
import 'package:ngclass/domain/model/app_user.dart';

class _MockApi extends Mock implements AuthApi {}

class _MockTokens extends Mock implements TokenStore {}

DioException _error({int? status}) {
  final request = RequestOptions(path: '/auth/refresh');
  return status == null
      ? DioException(requestOptions: request, type: DioExceptionType.connectionError)
      : DioException(
          requestOptions: request,
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(requestOptions: request, statusCode: status),
        );
}

void main() {
  late _MockApi api;
  late _MockTokens tokens;
  late AuthRepositoryImpl repository;

  setUp(() {
    api = _MockApi();
    tokens = _MockTokens();
    repository = AuthRepositoryImpl(api: api, tokens: tokens);
    when(() => tokens.readRefreshToken()).thenAnswer((_) async => 'refresh');
    when(() => tokens.clear()).thenAnswer((_) async {});
  });

  test('no network at start keeps the user signed in with the last known account', () async {
    when(() => api.refresh('refresh')).thenThrow(_error());
    when(
      () => tokens.readUser(),
    ).thenAnswer((_) async => jsonEncode({'id': '7', 'role': 'PARENT', 'username': 'p', 'firstName': 'Mouna', 'children': []}));

    final user = await repository.restoreSession();

    expect(user?.role, UserRole.parent);
    expect(user?.firstName, 'Mouna');
    verifyNever(() => tokens.clear());
  });

  test('a session refused by the server is cleared', () async {
    when(() => api.refresh('refresh')).thenThrow(_error(status: 401));

    expect(await repository.restoreSession(), isNull);
    verify(() => tokens.clear()).called(1);
  });

  test('no saved session means signed out', () async {
    when(() => tokens.readRefreshToken()).thenAnswer((_) async => null);

    expect(await repository.restoreSession(), isNull);
    verifyNever(() => api.refresh(any()));
  });
}
