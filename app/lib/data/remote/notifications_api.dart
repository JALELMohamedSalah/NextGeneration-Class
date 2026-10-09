import 'package:dio/dio.dart';

import '../dto/school_dto.dart';

/// `/me/notifications` (docs/HANDOVER.md, API).
class NotificationsApi {
  NotificationsApi(this._dio);

  final Dio _dio;

  Future<Json> page() async => (await _dio.get<Json>('/me/notifications')).data!;

  Future<int> unreadCount() async => ((await _dio.get<Json>('/me/notifications/unread-count')).data!['count'] as num).toInt();

  Future<void> markRead(String id) => _dio.post<void>('/me/notifications/$id/read');

  Future<void> markAllRead() => _dio.post<void>('/me/notifications/read-all');
}
