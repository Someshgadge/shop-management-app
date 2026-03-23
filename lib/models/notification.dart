/// Notification model matching your Supabase schema
class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime date; // Your schema: date
  final bool isRead; // Your schema: isread
  final String? relatedEntityId; // Your schema: relatedentityid
  final String entityType; // Your schema: entitytype

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
    this.relatedEntityId,
    required this.entityType,
  });

  // For backwards compatibility
  DateTime get createdAt => date;
  String get type => entityType;

  factory AppNotification.fromSupabase(Map<String, dynamic> data) {
    return AppNotification(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      date:
          data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      isRead: data['isread'] ?? false,
      relatedEntityId: data['relatedentityid'],
      entityType: data['entitytype'] ?? '',
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'title': title,
      'message': message,
      'date': date.toIso8601String(),
      'isread': isRead,
      'relatedentityid': relatedEntityId,
      'entitytype': entityType,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? date,
    bool? isRead,
    String? relatedEntityId,
    String? entityType,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      entityType: entityType ?? this.entityType,
    );
  }
}
