enum NotificationType { info, success, warning, error }
enum NotificationPriority { low, normal, high, urgent }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.type = NotificationType.info,
    this.priority = NotificationPriority.normal,
    required this.timestamp,
    this.isRead = false,
  });
}
