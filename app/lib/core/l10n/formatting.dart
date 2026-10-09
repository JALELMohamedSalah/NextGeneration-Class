import 'dart:ui' show TextDirection;

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'app_language.dart';
import 'tunis_time.dart';

/// Loads the date names of both languages, once at start (and in tests). Arabic dates keep Latin digits,
/// as written in Tunisia (12/10/2026, 15,25).
Future<void> initializeAppDates() async {
  await Future.wait([initializeDateFormatting(AppLanguage.fr.dateLocale), initializeDateFormatting(AppLanguage.ar.dateLocale)]);
  DateFormat.useNativeDigitsByDefaultFor(AppLanguage.ar.dateLocale, false);
}

/// "Lundi 5 octobre 2026" / "الاثنين 5 أكتوبر 2026" (Latin digits in Arabic, as written in Tunisia).
String longDate(DateTime date, AppLanguage language) => _capitalized(DateFormat.yMMMMEEEEd(language.dateLocale).format(date));

/// "Mardi 6 octobre" / "الثلاثاء 6 أكتوبر": the day at the top of a home screen.
String dayDate(DateTime date, AppLanguage language) => _capitalized(DateFormat.MMMMEEEEd(language.dateLocale).format(date));

/// "mardi 20 octobre" / "الثلاثاء 20 أكتوبر": a day inside a sentence ("À partir du mardi 20 octobre").
String dayInSentence(DateTime date, AppLanguage language) => DateFormat.MMMMEEEEd(language.dateLocale).format(date);

/// "6 oct." / "6 أكتوبر".
/// "6 octobre", "6 أكتوبر".
String dayMonth(DateTime date, AppLanguage language) => DateFormat.MMMMd(language.dateLocale).format(date);

String shortDate(DateTime date, AppLanguage language) => DateFormat.MMMd(language.dateLocale).format(date);

/// "30 juin 2027" / "30 جوان 2027", "1er septembre 2026": French writes the first day of a month as an ordinal.
String fullDate(DateTime date, AppLanguage language) {
  final text = DateFormat.yMMMMd(language.dateLocale).format(date);
  return language == AppLanguage.fr && date.day == 1 ? text.replaceFirst(RegExp(r'^1 '), '1er ') : text;
}

/// "Octobre 2026".
String monthYear(DateTime date, AppLanguage language) => _capitalized(DateFormat.yMMMM(language.dateLocale).format(date));

/// "mardi" / "الثلاثاء".
String weekdayName(DateTime date, AppLanguage language) => DateFormat.EEEE(language.dateLocale).format(date);

/// "Mar" / "الثلاثاء" for day tiles and calendar heads.
String weekdayShort(DateTime date, AppLanguage language) =>
    _capitalized(DateFormat.E(language.dateLocale).format(date).replaceAll('.', ''));

/// "14:00" in Tunisian time.
String hm(DateTime instant) => DateFormat('HH:mm').format(TunisTime.wall(instant));

/// Keeps a name or a free text in its own direction inside a sentence of the other script, so a French
/// group name or reason stays whole in an Arabic line (and an Arabic one in a French line).
String isolated(String text) => '\u2068$text\u2069';

/// A short name ("4ème année · Maths") at the end of a line of facts: isolated, and never split over two
/// lines, so a phone moves it whole to the next line.
String keptTogether(String name) => isolated(name.replaceAll(' ', '\u00A0'));

/// "14", "14,5", "12,25": a score with a decimal comma, as written in Tunisia, without trailing zeros.
String scoreText(double score) {
  final fixed = score.toStringAsFixed(2);
  final trimmed = fixed.contains('.') ? fixed.replaceFirst(RegExp(r'\.?0+$'), '') : fixed;
  return trimmed.replaceAll('.', ',');
}

/// "15,25": an average, always with two decimals.
String averageText(double value) => value.toStringAsFixed(2).replaceAll('.', ',');

/// What the teacher typed as a score ("14", "14,5", "14.5"); null when it is not a number.
double? parseScore(String text) => double.tryParse(text.trim().replaceAll(',', '.'));

/// The direction of a text someone wrote (instructions, a comment): French stays left to right in the
/// Arabic app, so its final period stays at its end; Arabic stays right to left in the French one.
TextDirection writtenDirection(String text) => Bidi.detectRtlDirectionality(text) ? TextDirection.rtl : TextDirection.ltr;

String _capitalized(String text) => text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
