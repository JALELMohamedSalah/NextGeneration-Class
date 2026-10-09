import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';

/// The language chosen on this device, kept across restarts.
class LanguageStore {
  LanguageStore(this._preferences);

  static const _key = 'ngclass.language';

  final SharedPreferencesAsync _preferences;

  Future<AppLanguage?> read() async {
    final code = await _preferences.getString(_key);
    return code == null ? null : AppLanguage.fromCode(code);
  }

  Future<void> save(AppLanguage language) => _preferences.setString(_key, language.code);
}
