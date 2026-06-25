import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      read: json['read'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class NotificationsState {
  final List<NotificationModel> items;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  NotificationsState({
    this.items = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  NotificationsState copyWith({
    List<NotificationModel>? items,
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final ApiClient _apiClient = ApiClient();

  NotificationsNotifier() : super(NotificationsState()) {
    fetchUnreadCount();
  }

  // Fetch all notifications
  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get(ApiEndpoints.notifications);
      if (response.statusCode == 200) {
        final List list = response.data['data']['items'];
        final items = list.map((json) => NotificationModel.fromJson(json)).toList();
        
        // Also fetch unread count to keep in sync
        final unreadRes = await _apiClient.get(ApiEndpoints.unreadCount);
        final unreadCount = unreadRes.data['data']['unreadCount'] as int;

        state = state.copyWith(
          items: items,
          unreadCount: unreadCount,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Fetch unread count only
  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.unreadCount);
      if (response.statusCode == 200) {
        final count = response.data['data']['unreadCount'] as int;
        state = state.copyWith(unreadCount: count);
      }
    } catch (_) {}
  }

  // Trigger Notification scan on Server
  Future<void> triggerServerChecks() async {
    try {
      await _apiClient.post(ApiEndpoints.triggerNotificationChecks);
      await fetchNotifications();
    } catch (_) {}
  }

  // Mark single notification as read
  Future<void> markAsRead(int id) async {
    try {
      final response = await _apiClient.put(ApiEndpoints.readNotification(id));
      if (response.statusCode == 200) {
        final updatedItems = state.items.map((item) {
          if (item.id == id) {
            return NotificationModel(
              id: item.id,
              title: item.title,
              message: item.message,
              type: item.type,
              read: true,
              createdAt: item.createdAt,
            );
          }
          return item;
        }).toList();

        state = state.copyWith(
          items: updatedItems,
          unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
        );
      }
    } catch (_) {}
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final response = await _apiClient.put(ApiEndpoints.readAllNotifications);
      if (response.statusCode == 200) {
        final updatedItems = state.items.map((item) {
          return NotificationModel(
            id: item.id,
            title: item.title,
            message: item.message,
            type: item.type,
            read: true,
            createdAt: item.createdAt,
          );
        }).toList();

        state = state.copyWith(
          items: updatedItems,
          unreadCount: 0,
        );
      }
    } catch (_) {}
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier();
});
