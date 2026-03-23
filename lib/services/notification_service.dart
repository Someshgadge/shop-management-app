import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Notification Service with Supabase
class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Create notification
  Future<String> createNotification(AppNotification notification) async {
    try {
      final response = await _supabase
          .from('notifications')
          .insert(notification.toSupabase())
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      debugPrint('Error creating notification: $e');
      rethrow;
    }
  }

  /// Get notifications (real-time stream)
  Stream<List<AppNotification>> getUserNotifications() {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('date', ascending: false)
        .limit(50)
        .map((snapshot) {
          return snapshot
              .map((data) => AppNotification.fromSupabase(data))
              .toList();
        });
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'isread': true}).eq('id', notificationId);
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _supabase
        .from('notifications')
        .update({'isread': true}).eq('isread', false);
  }

  /// Get unread notification count (stream)
  Stream<int> getUnreadCount() {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('isread', false)
        .map((snapshot) => snapshot.length);
  }

  // ==================== NOTIFICATION HELPERS ====================

  /// Create sales entry notification
  Future<void> notifySalesEntry({
    required String storeName,
    required double totalAmount,
    String? relatedEntityId,
  }) async {
    await createNotification(AppNotification(
      id: '',
      title: 'New Sales Entry',
      message: 'New sales of ₹$totalAmount recorded for $storeName',
      date: DateTime.now(),
      entityType: 'sale',
      relatedEntityId: relatedEntityId,
    ));
  }

  /// Notify about stock sent to shop
  Future<void> notifyStockSent({
    required String shopName,
    required double stockAmount,
    String? relatedEntityId,
  }) async {
    await createNotification(AppNotification(
      id: '',
      title: 'Stock Sent',
      message: 'Stock of ₹$stockAmount has been sent to $shopName',
      date: DateTime.now(),
      entityType: 'distribution',
      relatedEntityId: relatedEntityId,
    ));
  }

  /// Notify about stock rejection
  Future<void> notifyStockRejected({
    required String shopName,
    required String reason,
    String? relatedEntityId,
  }) async {
    await createNotification(AppNotification(
      id: '',
      title: 'Stock Rejected',
      message: 'Stock for $shopName was rejected. Reason: $reason',
      date: DateTime.now(),
      entityType: 'distribution',
      relatedEntityId: relatedEntityId,
    ));
  }

  /// Notify about stock acceptance
  Future<void> notifyStockAccepted({
    required String shopName,
    required double stockAmount,
    String? relatedEntityId,
  }) async {
    await createNotification(AppNotification(
      id: '',
      title: 'Stock Accepted',
      message: 'Stock of ₹$stockAmount for $shopName has been accepted',
      date: DateTime.now(),
      entityType: 'distribution',
      relatedEntityId: relatedEntityId,
    ));
  }

  /// Notify about admin change
  Future<void> notifyAdminChange({
    required String title,
    required String message,
    String? relatedEntityId,
  }) async {
    await createNotification(AppNotification(
      id: '',
      title: title,
      message: message,
      date: DateTime.now(),
      entityType: 'system',
      relatedEntityId: relatedEntityId,
    ));
  }
}
