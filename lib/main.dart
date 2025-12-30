import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Finance',
      home: const MainPage(),
    );
  }
}
