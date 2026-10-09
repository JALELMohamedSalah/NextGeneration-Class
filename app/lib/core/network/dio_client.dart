import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'auth_interceptor.dart';
import 'token_store.dart';

/// The API client. Every request carries the app language (Accept-Language), so the server answers
/// its messages in French or Arabic.
class DioClient {
  DioClient({required AppConfig config, required TokenStore tokens, required String Function() language}) {
    final options = BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    );
    final languageHeader = _LanguageInterceptor(language);
    final refreshDio = Dio(options)..interceptors.add(languageHeader);
    dio = Dio(options);
    dio.interceptors
      ..add(languageHeader)
      ..add(AuthInterceptor(dio: dio, refreshDio: refreshDio, tokens: tokens));
  }

  late final Dio dio;

  /// Called when the server refuses the session (wired to AuthCubit in main).
  static void Function()? onSessionExpired;
}

class _LanguageInterceptor extends Interceptor {
  _LanguageInterceptor(this._language);

  final String Function() _language;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = _language();
    handler.next(options);
  }
}
