import '../../domain/model/clock_time.dart';

/// "Now", injected so tests can set the time.
typedef Now = DateTime Function();

/// Tunisia is UTC+1 all year (no daylight saving since 2009). Screens show and enter times in it,
/// whatever the device's zone. A "wall" DateTime is UTC-flagged and only its fields mean something.
abstract final class TunisTime {
  static const offset = Duration(hours: 1);

  /// The Tunisian clock for an instant.
  static DateTime wall(DateTime instant) => instant.toUtc().add(offset);

  /// The calendar day (00:00) of an instant, in Tunisia.
  static DateTime day(DateTime instant) {
    final w = wall(instant);
    return DateTime.utc(w.year, w.month, w.day);
  }

  /// The instant of a Tunisian day and time.
  static DateTime instant(DateTime day, [ClockTime time = const ClockTime(0, 0)]) =>
      DateTime.utc(day.year, day.month, day.day, time.hour, time.minute).subtract(offset);

  static ClockTime clock(DateTime instant) {
    final w = wall(instant);
    return ClockTime(w.hour, w.minute);
  }

  /// Monday 00:00 of the week of [day].
  static DateTime weekStart(DateTime day) => DateTime.utc(day.year, day.month, day.day - (day.weekday - 1));

  static DateTime addDays(DateTime day, int days) => DateTime.utc(day.year, day.month, day.day + days);

  static bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
