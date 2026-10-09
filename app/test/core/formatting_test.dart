import 'package:flutter_test/flutter_test.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/formatting.dart';

void main() {
  setUpAll(initializeAppDates);

  test('Arabic dates use the month names of Tunisia, with Latin digits', () {
    expect(fullDate(DateTime.utc(2027, 6, 30), AppLanguage.ar), '30 جوان 2027');
    expect(monthYear(DateTime.utc(2027, 2, 1), AppLanguage.ar), 'فيفري 2027');
    expect(shortDate(DateTime.utc(2027, 1, 12), AppLanguage.ar), '12 جانفي');
    expect(fullDate(DateTime.utc(2026, 8, 3), AppLanguage.ar), '3 أوت 2026');
  });

  test('French writes the first day of a month as an ordinal', () {
    expect(fullDate(DateTime.utc(2026, 9, 1), AppLanguage.fr), '1er septembre 2026');
    expect(fullDate(DateTime.utc(2027, 6, 30), AppLanguage.fr), '30 juin 2027');
    expect(fullDate(DateTime.utc(2026, 10, 11), AppLanguage.fr), '11 octobre 2026');
  });
}
