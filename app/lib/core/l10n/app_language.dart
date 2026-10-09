import 'dart:ui';

/// The two languages of the app. Arabic turns the whole interface right to left.
enum AppLanguage {
  fr,
  ar;

  Locale get locale => Locale(name);

  /// The code sent to the API (Accept-Language, /me/language).
  String get code => name;

  /// The locale dates are written in. Arabic uses the Maghreb month names of Tunisia (جانفي، فيفري، جوان)
  /// that intl keeps under `ar_DZ`, not the Middle-East ones of `ar` (يناير، فبراير، يونيو).
  String get dateLocale => this == AppLanguage.ar ? 'ar_DZ' : 'fr';

  static AppLanguage fromCode(String? code) => code == 'ar' ? AppLanguage.ar : AppLanguage.fr;

  /// The device language when it is one of ours, French otherwise.
  static AppLanguage fromDevice() => fromCode(PlatformDispatcher.instance.locale.languageCode);
}
