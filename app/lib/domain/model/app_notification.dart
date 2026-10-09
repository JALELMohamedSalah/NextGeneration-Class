import 'package:equatable/equatable.dart';

/// What happened to a session (R1), new homework or a corrected one (R2). Later releases add announcements.
/// [evaluation]: a paper evaluation's grade (release 2, step 5).
/// The teacher's: [workSent] (work sent by pupils or parents, gathered by homework while unread) and
/// [deadlinePassed] (a homework's deadline: who did not send).
enum NotificationKind { cancelled, moved, restored, homework, corrected, evaluation, workSent, deadlinePassed }

/// A pupil named in a teacher's notification, as written then.
class NamedPupil extends Equatable {
  const NamedPupil({required this.id, required this.firstName, required this.lastName});

  final String id;
  final String firstName;
  final String lastName;

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [id, firstName, lastName];
}

/// A notification as the server keeps it: facts, no sentence. The app words it in French or Arabic.
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.groupName,
    required this.startsAt,
    required this.createdAt,
    this.studentId,
    this.childFirstName,
    this.sessionId,
    this.previousStartsAt,
    this.sessionCount = 1,
    this.reason,
    this.assignmentId,
    this.evaluationId,
    this.title,
    this.pupils = const [],
    this.late = false,
    this.read = false,
  });

  final String id;
  final NotificationKind kind;

  /// The child it is about; [childFirstName] is null on a child's own notifications.
  final String? studentId;
  final String? childFirstName;
  final String groupName;
  final String? sessionId;

  /// The (first) session concerned; for a moved one, its new time.
  final DateTime startsAt;

  /// A moved session: its former time.
  final DateTime? previousStartsAt;

  /// More than 1 when a whole series changed at once ("3 séances annulées").
  final int sessionCount;
  final String? reason;

  /// New or corrected homework: which one, and its title; [startsAt] is then its deadline.
  final String? assignmentId;

  /// An evaluation's grade: the evaluation (its title in [title]).
  final String? evaluationId;
  final String? title;

  /// The teacher's: who sent ([NotificationKind.workSent], in the order they first sent) or who did not
  /// ([NotificationKind.deadlinePassed]; empty when everyone sent).
  final List<NamedPupil> pupils;

  /// [NotificationKind.workSent]: some of the work came after the deadline.
  final bool late;
  final DateTime createdAt;
  final bool read;

  AppNotification markedRead() => AppNotification(
    id: id,
    kind: kind,
    groupName: groupName,
    startsAt: startsAt,
    createdAt: createdAt,
    studentId: studentId,
    childFirstName: childFirstName,
    sessionId: sessionId,
    previousStartsAt: previousStartsAt,
    sessionCount: sessionCount,
    reason: reason,
    assignmentId: assignmentId,
    evaluationId: evaluationId,
    title: title,
    pupils: pupils,
    late: late,
    read: true,
  );

  @override
  List<Object?> get props => [
    id,
    kind,
    studentId,
    childFirstName,
    groupName,
    sessionId,
    startsAt,
    previousStartsAt,
    sessionCount,
    reason,
    assignmentId,
    evaluationId,
    title,
    pupils,
    late,
    createdAt,
    read,
  ];
}

class NotificationsPage extends Equatable {
  const NotificationsPage({required this.unreadCount, required this.items});

  final int unreadCount;

  /// The latest first.
  final List<AppNotification> items;

  @override
  List<Object?> get props => [unreadCount, items];
}
