import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pages/main_page.dart';
import 'pages/login_page.dart';
import 'bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // --- MULAI PERBAIKAN ---
  // Gunakan try-catch untuk menangani error "duplicate-app" saat Hot Restart
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBZLyJ9z9xM0r-ei6sGiaaEsUpcadjUlBY",
        authDomain: "personal-finance-abcf3.firebaseapp.com",
        projectId: "personal-finance-abcf3",
        storageBucket: "personal-finance-abcf3.firebasestorage.app",
        messagingSenderId: "936724906392",
        appId: "1:936724906392:web:d3a8f1ff1eae2566beebed",
      ),
    );
  } catch (e) {
    // Jika error karena sudah ada app default (duplicate), kita abaikan saja
    // supaya aplikasi tetap lanjut jalan.
    if (e.toString().contains("duplicate-app")) {
      debugPrint("Firebase sudah terinisialisasi (abaikan error duplicate).");
    } else {
      // Jika error lain, tetap tampilkan
      debugPrint("Error inisialisasi Firebase: $e");
    }
  }
  // --- SELESAI PERBAIKAN ---

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Finance',
      initialBinding: InitialBinding(),
      home: const MainPage(),
      getPages: [
        GetPage(name: '/', page: () => const MainPage()),
        GetPage(name: '/login', page: () => const LoginPage()),
      ],
    );
  }
}