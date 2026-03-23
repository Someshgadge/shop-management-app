import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Notification Provider for state management
class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  /// Initialize notification streams
  void initialize() {
    // Listen to notifications
    _notificationService.getUserNotifications().listen((notifications) {
      _notifications = notifications;
      notifyListeners();
    });

    // Listen to unread count
    _notificationService.getUnreadCount().listen((count) {
      _unreadCount = count;
      notifyListeners();
    });
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
  }

  /// Send sales entry notification
  Future<void> notifySalesEntry({
    required String storeName,
    required double totalAmount,
    String? relatedEntityId,
  }) async {
    await _notificationService.notifySalesEntry(
      storeName: storeName,
      totalAmount: totalAmount,
      relatedEntityId: relatedEntityId,
    );
  }

  /// Send stock sent notification
  Future<void> notifyStockSent({
    required String shopName,
    required double stockAmount,
    String? relatedEntityId,
  }) async {
    await _notificationService.notifyStockSent(
      shopName: shopName,
      stockAmount: stockAmount,
      relatedEntityId: relatedEntityId,
    );
  }

  /// Send stock rejected notification
  Future<void> notifyStockRejected({
    required String shopName,
    required String reason,
    String? relatedEntityId,
  }) async {
    await _notificationService.notifyStockRejected(
      shopName: shopName,
      reason: reason,
      relatedEntityId: relatedEntityId,
    );
  }

  /// Send stock accepted notification
  Future<void> notifyStockAccepted({
    required String shopName,
    required double stockAmount,
    String? relatedEntityId,
  }) async {
    await _notificationService.notifyStockAccepted(
      shopName: shopName,
      stockAmount: stockAmount,
      relatedEntityId: relatedEntityId,
    );
  }

  /// Send admin change notification
  Future<void> notifyAdminChange({
    required String title,
    required String message,
    String? relatedEntityId,
  }) async {
    await _notificationService.notifyAdminChange(
      title: title,
      message: message,
      relatedEntityId: relatedEntityId,
    );
  }
}
