import 'package:flutter/foundation.dart';

/// Values chosen at build time with `--dart-define`.
class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  /// `API_BASE_URL` when given. Otherwise a release web build talks to its own origin
  /// (Caddy serves the app and proxies /api), and development talks to the local API.
  factory AppConfig.fromEnvironment() {
    const defined = String.fromEnvironment('API_BASE_URL');
    if (defined.isNotEmpty) return const AppConfig(apiBaseUrl: defined);
    if (kIsWeb && kReleaseMode) return AppConfig(apiBaseUrl: '${Uri.base.origin}/api/v1');
    return const AppConfig(apiBaseUrl: 'http://localhost:8080/api/v1');
  }

  final String apiBaseUrl;
}
