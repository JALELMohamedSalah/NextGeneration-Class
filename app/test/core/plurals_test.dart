import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngclass/l10n/app_localizations.dart';

void main() {
  test('zero is never worded as one (French puts 0 in the singular)', () {
    final fr = lookupAppLocalizations(const Locale('fr'));
    expect(fr.absentCount(0), '0 absent');
    expect(fr.presentCount(0), '0 présent');
    expect(fr.absencesCount(0), 'Aucune absence');
  });

  test('every plural of both languages says what zero is', () {
    for (final file in ['lib/l10n/app_fr.arb', 'lib/l10n/app_ar.arb']) {
      final arb = jsonDecode(File(file).readAsStringSync()) as Map<String, dynamic>;
      final missing = [
        for (final entry in arb.entries)
          if (entry.value is String && (entry.value as String).contains('plural,') && !(entry.value as String).contains('=0{')) entry.key,
      ];
      expect(missing, isEmpty, reason: file);
    }
  });
}
