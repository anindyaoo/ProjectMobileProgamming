import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackbar {
  /// Internal method untuk konfigurasi snackbar yang konsisten
  /// Menggunakan desain modern ala web (clean, smooth animation, shadow)
  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    int durationSeconds = 3,
  }) {
    Get.snackbar(
      title,
      message,
      // Posisi & Style Dasar
      snackPosition: SnackPosition.TOP,
      snackStyle: SnackStyle.FLOATING,

      // Tipografi Custom
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
      ),

      // Warna & Tampilan
      // Menggunakan sedikit transparansi untuk efek modern
      backgroundColor: backgroundColor.withValues(alpha: 0.95),
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white, size: 28),

      // Border & Shape
      borderRadius: 12,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      borderWidth: 1.5,
      borderColor: Colors.white.withValues(alpha: 0.15),

      // Shadow yang lebih lembut dan menyebar
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -2,
        ),
      ],

      // Animasi Profesional (Diperlambat untuk kesan premium)
      duration: Duration(seconds: durationSeconds),
      animationDuration: const Duration(milliseconds: 850),
      // Menggunakan Curve easeOutQuart untuk efek 'gliding' yang mewah
      forwardAnimationCurve: Curves.easeOutQuart,
      // Menggunakan Curve easeInQuart untuk exit yang smooth
      reverseAnimationCurve: Curves.easeInQuart,

      // Interaksi
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      mainButton: TextButton(
        onPressed: () {
          if (Get.isSnackbarOpen) {
            Get.back();
          }
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.white.withValues(alpha: 0.8),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: const Icon(Icons.close, size: 20),
      ),

      // Efek Tambahan
      shouldIconPulse: false, // Mematikan pulse agar lebih statis & elegan
      barBlur: 10, // Efek glassmorphism halus di belakang snackbar
    );
  }

  static void showSuccess({required String title, required String message}) {
    _show(
      title: title,
      message: message,
      backgroundColor: const Color(0xFF2E7D32), // Deep Green
      icon: Icons.check_circle_rounded,
    );
  }

  static void showError({required String title, required String message}) {
    _show(
      title: title,
      message: message,
      backgroundColor: const Color(0xFFC62828), // Deep Red
      icon: Icons.error_rounded,
      durationSeconds: 4,
    );
  }

  static void showInfo({required String title, required String message}) {
    _show(
      title: title,
      message: message,
      backgroundColor: const Color(0xFF1565C0), // Deep Blue
      icon: Icons.info_rounded,
    );
  }

  static void showWarning({required String title, required String message}) {
    _show(
      title: title,
      message: message,
      backgroundColor: const Color(0xFFEF6C00), // Deep Orange
      icon: Icons.warning_rounded,
    );
  }
}
