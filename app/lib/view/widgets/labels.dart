import '../../core/l10n/app_language.dart';
import '../../core/l10n/formatting.dart';
import '../../core/l10n/tunis_time.dart';
import '../../domain/model/session.dart';
import '../../l10n/app_localizations.dart';

/// Relations are stored as codes; anything else typed by hand is shown as is.
const relationCodes = ['mother', 'father', 'guardian'];

String relationLabel(AppLocalizations l10n, String? relation) => switch (relation) {
  'mother' || 'mère' => l10n.relationMother,
  'father' || 'père' => l10n.relationFather,
  'guardian' || 'tuteur' => l10n.relationGuardian,
  _ => relation ?? '',
};

/// "mère" becomes "Mère" at the start of a line.
String capitalized(String text) => text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

/// "1 h 20", "45 min", "2 h".
String durationLabel(AppLocalizations l10n, Duration duration) {
  final minutes = duration.inMinutes < 1 ? 1 : duration.inMinutes;
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  if (hours == 0) return l10n.durationMinutes(rest);
  if (rest == 0) return l10n.durationHours(hours);
  return l10n.durationHoursMinutes(hours, rest.toString().padLeft(2, '0'));
}

/// [family]: pupils and parents read "En classe", the teacher "Présentiel".
String modeLabel(AppLocalizations l10n, SessionMode mode, {bool family = false}) => mode == SessionMode.online
    ? l10n.modeOnline
    : family
    ? l10n.modeInClass
    : l10n.modeInPerson;

/// "Présentiel · Salle 2", "En ligne"; "En classe · Salle 2" for pupils and parents.
String placeLabel(AppLocalizations l10n, SessionMode mode, String? location, {bool family = false}) {
  final room = mode == SessionMode.inPerson && (location?.isNotEmpty ?? false) ? location! : null;
  final parts = [modeLabel(l10n, mode, family: family), if (room != null) family ? isolated(room) : room];
  return parts.join(l10n.dotSeparator);
}

/// "10:00 à 11:30".
String timeRangeLabel(AppLocalizations l10n, DateTime start, DateTime end) => l10n.timeRange(hm(start), hm(end));

/// "Aujourd'hui, mardi 6 octobre", "Demain, ...", or "Jeudi 8 octobre".
String dayHeading(AppLocalizations l10n, AppLanguage language, DateTime day, DateTime today) {
  final date = dayDate(day, language);
  if (TunisTime.sameDay(day, today)) return l10n.todayDate(date.toLowerCase());
  if (TunisTime.sameDay(day, TunisTime.addDays(today, 1))) return l10n.tomorrowDate(date.toLowerCase());
  return date;
}

/// When the next session is, in a child's words: "En cours", "Aujourd'hui, dans 2 h", "Demain, mercredi",
/// "Jeudi" within the coming week, then "Mardi 13 octobre".
String whenLabel(AppLocalizations l10n, AppLanguage language, MySession session, DateTime now) {
  if (!session.startsAt.isAfter(now)) return l10n.statusInProgress;
  final day = TunisTime.day(session.startsAt);
  final today = TunisTime.day(now);
  if (TunisTime.sameDay(day, today)) return l10n.todayInDuration(durationLabel(l10n, session.startsAt.difference(now)));
  if (TunisTime.sameDay(day, TunisTime.addDays(today, 1))) return l10n.tomorrowWeekday(weekdayName(day, language));
  if (day.isBefore(TunisTime.addDays(today, 7))) return capitalized(weekdayName(day, language));
  return dayDate(day, language);
}

/// "mardi" for ISO weekday 2 (Monday is 1).
String weekdayOf(int isoWeekday, AppLanguage language) => weekdayName(DateTime.utc(2024, 1, isoWeekday), language);

/// "À l'instant", "Il y a 5 min", "Il y a 2 h", "Hier", then the day ("Lundi 5 octobre").
String timeAgo(AppLocalizations l10n, AppLanguage language, DateTime instant, DateTime now) {
  final elapsed = now.difference(instant);
  final day = TunisTime.day(instant);
  final today = TunisTime.day(now);
  if (elapsed.inMinutes < 60) return l10n.minutesAgo(elapsed.inMinutes < 0 ? 0 : elapsed.inMinutes);
  if (day == today) return l10n.hoursAgo(elapsed.inHours);
  if (day == TunisTime.addDays(today, -1)) return l10n.yesterday;
  return dayDate(day, language);
}
