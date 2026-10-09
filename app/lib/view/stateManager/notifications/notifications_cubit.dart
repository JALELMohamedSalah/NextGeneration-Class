import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_failure.dart';
import '../../../domain/model/app_notification.dart';
import '../../../domain/repositories/notification_repository.dart';
import '../common/load_status.dart';

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = LoadStatus.loading,
    this.items = const [],
    this.unreadCount = 0,
    this.loaded = false,
    this.failure,
  });

  final LoadStatus status;
  final List<AppNotification> items;

  /// What the bell and the tab badge show.
  final int unreadCount;

  /// The list itself was fetched once (the badge alone does not fetch it).
  final bool loaded;
  final ApiFailure? failure;

  NotificationsState copyWith({
    LoadStatus? status,
    List<AppNotification>? items,
    int? unreadCount,
    bool? loaded,
    ApiFailure? Function()? failure,
  }) => NotificationsState(
    status: status ?? this.status,
    items: items ?? this.items,
    unreadCount: unreadCount ?? this.unreadCount,
    loaded: loaded ?? this.loaded,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, items, unreadCount, loaded, failure?.code];
}

/// The signed-in parent's or child's notifications, for the whole role space: the bell and the tab
/// badge follow [NotificationsState.unreadCount], refreshed every [poll]; the list loads when opened.
/// Reading is optimistic: the badge goes down at once, the server follows.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository, {Duration? poll}) : super(const NotificationsState()) {
    if (poll != null) _timer = Timer.periodic(poll, (_) => refreshCount());
  }

  final NotificationRepository _repository;
  Timer? _timer;

  /// Silent: the badge keeps its last value when the network is down. When the count moves and the list
  /// is already shown (the child's home lists what is new), the list follows.
  Future<void> refreshCount() async {
    try {
      final count = await _repository.unreadCount();
      if (isClosed || count == state.unreadCount) return;
      if (state.loaded) {
        await load();
      } else {
        emit(state.copyWith(unreadCount: count));
      }
    } on Object {
      // Shown again at the next refresh.
    }
  }

  /// What the child has not read yet, latest first.
  List<AppNotification> get unread => [
    for (final n in state.items)
      if (!n.read) n,
  ];

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, failure: () => null));
    try {
      final page = await _repository.load();
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.ready, items: page.items, unreadCount: page.unreadCount, loaded: true));
    } on Object catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, failure: () => ApiFailure.from(error)));
    }
  }

  /// Opening a notification reads it.
  void markRead(AppNotification notification) {
    if (notification.read) return;
    emit(
      state.copyWith(
        items: [for (final n in state.items) n.id == notification.id ? n.markedRead() : n],
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      ),
    );
    _repository.markRead(notification.id).ignore();
  }

  void markAllRead() {
    if (state.unreadCount == 0 && state.items.every((n) => n.read)) return;
    emit(state.copyWith(items: [for (final n in state.items) n.markedRead()], unreadCount: 0));
    _repository.markAllRead().ignore();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
