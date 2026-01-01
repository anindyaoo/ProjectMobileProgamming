import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
<<<<<<< HEAD
import 'pages/main_page.dart';
=======
>>>>>>> e0f755864721bd845f382f2dac02d0c4a7023dd6

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
<<<<<<< HEAD
      title: 'Personal Finance',
      home: const MainPage(),
    );
  }
}
=======
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Firebase App"),
          backgroundColor: Colors.teal,
        ),
        body: const Center(
          child: Text(
            "HALAMAN ROUTE",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
      ),
    );
  }
}
>>>>>>> e0f755864721bd845f382f2dac02d0c4a7023dd6
