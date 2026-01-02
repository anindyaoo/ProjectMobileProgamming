import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class NotificationHistoryPage extends StatelessWidget {
  const NotificationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationService service = Get.find<NotificationService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          'Riwayat Notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF355C9A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            tooltip: 'Tandai semua sudah dibaca',
            onPressed: () => service.markAllAsRead(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            tooltip: 'Hapus Riwayat',
            onPressed: () {
              Get.defaultDialog(
                title: 'Hapus Riwayat',
                middleText:
                    'Apakah Anda yakin ingin menghapus semua riwayat notifikasi?',
                textConfirm: 'Hapus',
                textCancel: 'Batal',
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () {
                  service.clearHistory();
                  Get.back();
                },
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (service.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada notifikasi',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: service.notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final notification = service.notifications[index];
            return _buildNotificationItem(notification);
          },
        );
      }),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    Color color;
    IconData icon;

    switch (notification.type) {
      case NotificationType.success:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case NotificationType.error:
        color = Colors.red;
        icon = Icons.error;
        break;
      case NotificationType.warning:
        color = Colors.orange;
        icon = Icons.warning;
        break;
      default:
        color = const Color(0xFF355C9A);
        icon = Icons.info;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: notification.isRead
            ? null
            : Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead
                      ? FontWeight.normal
                      : FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (notification.priority == NotificationPriority.urgent ||
                notification.priority == NotificationPriority.high)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  'URGENT',
                  style: TextStyle(fontSize: 10, color: Colors.red.shade700),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd MMM HH:mm').format(notification.timestamp),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
