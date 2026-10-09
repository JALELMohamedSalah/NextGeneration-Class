import 'package:ngclass/core/l10n/tunis_time.dart';
import 'package:ngclass/domain/model/app_notification.dart';
import 'package:ngclass/domain/model/app_user.dart';
import 'package:ngclass/domain/model/clock_time.dart';
import 'package:ngclass/domain/model/localized_text.dart';
import 'package:ngclass/domain/model/session.dart';

import 'fakes.dart';

/// A pupil's two weeks (Adam, 4ème année) and what changed in them, for the student space tests.
/// Tuesday 6 October 2026, 10:00 in Tunis.
final now = TunisTime.instant(DateTime.utc(2026, 10, 6), const ClockTime(10, 0));

DateTime at(int day, int hour, [int minute = 0]) => TunisTime.instant(DateTime.utc(2026, 10, day), ClockTime(hour, minute));

const lecture = GroupRef(
  id: 'g4l',
  name: '4ème année · Lecture',
  code: '4L',
  color: '#12A39A',
  subject: LocalizedText(fr: 'Lecture', ar: 'القراءة'),
  privateLesson: false,
);

MySession mine(
  String id,
  GroupRef group,
  DateTime start, {
  SessionMode mode = SessionMode.inPerson,
  SessionStatus status = SessionStatus.planned,
  String? reason,
}) => MySession(
  id: id,
  group: group,
  startsAt: start,
  endsAt: start.add(const Duration(minutes: 90)),
  mode: mode,
  status: status,
  location: mode == SessionMode.inPerson ? 'Salle 2' : null,
  meetUrl: mode == SessionMode.online ? 'https://meet.google.com/abc' : null,
  cancelReason: reason,
);

/// This week: Lecture tomorrow, Maths cancelled on Thursday, Maths on Saturday. Next week: Maths moved
/// from Monday 10:00 to Tuesday 15:00, Lecture online on Wednesday.
List<MySession> week() => [
  mine('done', ref4A, at(5, 10), status: SessionStatus.done),
  mine('w1', lecture, at(7, 14)),
  mine('c1', ref4A, at(8, 10), status: SessionStatus.cancelled, reason: 'sortie scolaire'),
  mine('s1', ref4A, at(10, 9)),
  mine('m1', ref4A, at(13, 15)),
  mine('o1', lecture, at(14, 14), mode: SessionMode.online),
];

List<AppNotification> changes() => [
  AppNotification(
    id: 'n-move',
    kind: NotificationKind.moved,
    studentId: 'me',
    groupName: ref4A.name,
    sessionId: 'm1',
    startsAt: at(13, 15),
    previousStartsAt: at(12, 10),
    createdAt: now.subtract(const Duration(hours: 1)),
  ),
  AppNotification(
    id: 'n-cancel',
    kind: NotificationKind.cancelled,
    studentId: 'me',
    groupName: ref4A.name,
    sessionId: 'c1',
    startsAt: at(8, 10),
    reason: 'sortie scolaire',
    createdAt: now.subtract(const Duration(hours: 2)),
  ),
];

const pupil = AppUser(id: 'c', role: UserRole.student, username: 'adam', firstName: 'Adam', lastName: 'Gharbi', mustChangePassword: false);

const parent = AppUser(
  id: 'p',
  role: UserRole.parent,
  username: 'mouna',
  firstName: 'Mouna',
  lastName: 'Gharbi',
  mustChangePassword: false,
  children: [ChildSummary(studentId: 'me', firstName: 'Adam', lastName: 'Gharbi', level: fourth)],
);
