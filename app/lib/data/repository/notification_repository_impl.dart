import '../../domain/model/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../dto/school_dto.dart';
import '../remote/notifications_api.dart';
import 'api_guard.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._api);

  final NotificationsApi _api;

  @override
  Future<NotificationsPage> load() => guard(() async {
    final json = await _api.page();
    return NotificationsPage(
      unreadCount: (json['unreadCount'] as num? ?? 0).toInt(),
      items: [for (final item in jsonList(json['items'])) notificationOf(item)],
    );
  });

  @override
  Future<int> unreadCount() => guard(_api.unreadCount);

  @override
  Future<void> markRead(String id) => guard(() => _api.markRead(id));

  @override
  Future<void> markAllRead() => guard(_api.markAllRead);
}

AppNotification notificationOf(Json json) => AppNotification(
  id: json['id'] as String,
  kind: switch (json['type']) {
    'SESSION_MOVED' => NotificationKind.moved,
    'SESSION_RESTORED' => NotificationKind.restored,
    'HOMEWORK_ASSIGNED' => NotificationKind.homework,
    'HOMEWORK_CORRECTED' => NotificationKind.corrected,
    'EVALUATION_GRADED' => NotificationKind.evaluation,
    'WORK_SUBMITTED' => NotificationKind.workSent,
    'DEADLINE_PASSED' => NotificationKind.deadlinePassed,
    _ => NotificationKind.cancelled,
  },
  studentId: json['studentId'] as String?,
  childFirstName: json['childFirstName'] as String?,
  groupName: json['groupName'] as String? ?? '',
  sessionId: json['sessionId'] as String?,
  startsAt: instant(json['startsAt'])!,
  previousStartsAt: instant(json['previousStartsAt']),
  sessionCount: (json['sessionCount'] as num? ?? 1).toInt(),
  reason: json['reason'] as String?,
  assignmentId: json['assignmentId'] as String?,
  evaluationId: json['evaluationId'] as String?,
  title: json['title'] as String?,
  pupils: [
    for (final pupil in jsonList(json['pupils']))
      NamedPupil(id: pupil['id'] as String, firstName: pupil['firstName'] as String? ?? '', lastName: pupil['lastName'] as String? ?? ''),
  ],
  late: json['late'] as bool? ?? false,
  createdAt: instant(json['createdAt'])!,
  read: json['read'] as bool? ?? false,
);
