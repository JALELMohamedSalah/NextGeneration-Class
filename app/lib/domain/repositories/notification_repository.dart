import '../model/app_notification.dart';

/// The signed-in person's own notifications. Every method throws an ApiFailure when the call fails.
abstract interface class NotificationRepository {
  Future<NotificationsPage> load();

  /// Cheap: asked every minute for the bell and the tab badge.
  Future<int> unreadCount();

  Future<void> markRead(String id);

  Future<void> markAllRead();
}
