import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The session: access token in memory only; refresh token and the last known user in the OS secure
/// storage, so the app reopens signed in, even without network (client decision: stay connected).
///
/// When the secure storage is unavailable (PlatformException), values are kept in memory: login still
/// works, the session just does not survive a restart.
class TokenStore {
  TokenStore(this._storage);

  static const _refreshKey = 'ngclass.refresh_token';
  static const _userKey = 'ngclass.user';

  final FlutterSecureStorage _storage;
  String? _accessToken;
  final _memory = <String, String>{};
  bool _storageUnavailable = false;

  String? get accessToken => _accessToken;

  Future<String?> readRefreshToken() => _read(_refreshKey);

  /// The user as last returned by the API, as JSON.
  Future<String?> readUser() => _read(_userKey);

  Future<void> save({required String accessToken, required String refreshToken, required String userJson}) async {
    _accessToken = accessToken;
    await _write(_refreshKey, refreshToken);
    await _write(_userKey, userJson);
  }

  Future<void> saveUser(String userJson) => _write(_userKey, userJson);

  Future<void> clear() async {
    _accessToken = null;
    _memory.clear();
    if (_storageUnavailable) return;
    try {
      await _storage.delete(key: _refreshKey);
      await _storage.delete(key: _userKey);
    } on PlatformException {
      _storageUnavailable = true;
    }
  }

  Future<String?> _read(String key) async {
    if (_storageUnavailable) return _memory[key];
    try {
      return await _storage.read(key: key);
    } on PlatformException {
      _storageUnavailable = true;
      return _memory[key];
    }
  }

  Future<void> _write(String key, String value) async {
    _memory[key] = value;
    if (_storageUnavailable) return;
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException {
      _storageUnavailable = true;
    }
  }
}
