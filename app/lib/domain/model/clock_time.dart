import 'package:equatable/equatable.dart';

/// A time of day without a date ("10:00"), as the teacher types it, in Tunisian time.
class ClockTime extends Equatable implements Comparable<ClockTime> {
  const ClockTime(this.hour, this.minute);

  /// "10:00" or "10:00:00".
  factory ClockTime.parse(String value) {
    final parts = value.split(':');
    return ClockTime(int.parse(parts[0]), int.parse(parts[1]));
  }

  final int hour;
  final int minute;

  int get minutes => hour * 60 + minute;

  ClockTime plusMinutes(int delta) {
    final total = (minutes + delta).clamp(0, 23 * 60 + 59);
    return ClockTime(total ~/ 60, total % 60);
  }

  /// "10:00", the API format too.
  String get hhmm => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  int compareTo(ClockTime other) => minutes.compareTo(other.minutes);

  bool isAfter(ClockTime other) => minutes > other.minutes;

  @override
  List<Object?> get props => [hour, minute];

  @override
  String toString() => hhmm;
}
