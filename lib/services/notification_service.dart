import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:personal_finance/utils/custom_snackbar.dart';
import '../models/notification_model.dart';

class NotificationService extends GetxController {
  // Observable list for history
  var notifications = <NotificationModel>[].obs;

  // Add notification to history
  void _addToHistory(NotificationModel notification) {
    notifications.insert(0, notification);
  }

  // Clear history
  void clearHistory() {
    notifications.clear();
  }

  // Mark all as read
  void markAllAsRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
  }

  // Main method to show notification
  void showNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    NotificationPriority priority = NotificationPriority.normal,
    VoidCallback? onConfirm,
  }) {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      priority: priority,
      timestamp: DateTime.now(),
    );

    _addToHistory(notification);

    // Determine display method based on priority
    if (priority == NotificationPriority.high ||
        priority == NotificationPriority.urgent) {
      _showDialog(notification, onConfirm);
    } else {
      _showSnackBar(notification);
    }
  }

  void _showSnackBar(NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.success:
        CustomSnackbar.showSuccess(
          title: notification.title,
          message: notification.message,
        );
        break;
      case NotificationType.error:
        CustomSnackbar.showError(
          title: notification.title,
          message: notification.message,
        );
        break;
      case NotificationType.warning:
        CustomSnackbar.showWarning(
          title: notification.title,
          message: notification.message,
        );
        break;
      default:
        CustomSnackbar.showInfo(
          title: notification.title,
          message: notification.message,
        );
    }
  }

  void _showDialog(NotificationModel notification, VoidCallback? onConfirm) {
    Color color;
    IconData icon;

    switch (notification.type) {
      case NotificationType.success:
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case NotificationType.error:
        color = Colors.red;
        icon = Icons.error_outline;
        break;
      case NotificationType.warning:
        color = Colors.orange;
        icon = Icons.warning_amber_rounded;
        break;
      default:
        color = Colors.blue;
        icon = Icons.info_outline;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 60, color: color),
              const SizedBox(height: 16),
              Text(
                notification.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                notification.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (notification.priority == NotificationPriority.urgent)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  if (notification.priority == NotificationPriority.urgent)
                    const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        if (onConfirm != null) onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text(
                        notification.priority == NotificationPriority.urgent
                            ? 'Konfirmasi'
                            : 'Mengerti',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: notification.priority != NotificationPriority.urgent,
    );
  }
}
