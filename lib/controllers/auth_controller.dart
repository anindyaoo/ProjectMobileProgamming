import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:personal_finance/model/user_model.dart';
import 'package:personal_finance/pages/login_page.dart';
import 'package:personal_finance/pages/main_page.dart';
import 'package:personal_finance/utils/custom_snackbar.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  // Variables
  late Rx<User?> _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Rx<UserModel?> currentUserData = Rx<UserModel?>(null);
  bool _isRegistering = false;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(_auth.currentUser);
    _user.bindStream(_auth.authStateChanges());
    ever(_user, _setInitialScreen);

    // Listen to user data changes if user is logged in
    ever(_user, (User? user) {
      if (user != null) {
        _bindUserData(user.uid);
      } else {
        currentUserData.value = null;
      }
    });
  }

  void _bindUserData(String uid) {
    currentUserData.bindStream(
      _db.collection('users').doc(uid).snapshots().map((snapshot) {
        if (snapshot.exists) {
          return UserModel.fromMap(snapshot.data()!, snapshot.id);
        }
        return null;
      }),
    );
  }

  void _setInitialScreen(User? user) {
    if (_isRegistering) return;

    if (user == null) {
      Get.offAll(() => const LoginPage());
    } else {
      Get.offAll(() => const MainPage());
    }
  }

  // Register
  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      _isRegistering = true;
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save user data to Firestore
      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        email: email,
        username: username,
      );

      await _db.collection('users').doc(newUser.id).set(newUser.toMap());

      // Logout and redirect to Login Page
      await _auth.signOut();
      _isRegistering = false;

      Get.offAll(() => const LoginPage());

      CustomSnackbar.showSuccess(
        title: 'Sukses',
        message: 'Akun berhasil dibuat. Silakan login.',
      );
    } on FirebaseAuthException catch (e) {
      _isRegistering = false;
      CustomSnackbar.showError(
        title: 'Error',
        message: e.message ?? 'Registration failed',
      );
    } catch (_) {
      _isRegistering = false;
      CustomSnackbar.showError(title: 'Error', message: 'Something went wrong');
    }
  }

  // Login with Username
  Future<void> loginWithUsernameAndPassword(
    String username,
    String password,
  ) async {
    try {
      // 1. Find email by username
      final querySnapshot = await _db
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        CustomSnackbar.showError(
          title: 'Login Gagal',
          message: 'Username tidak ditemukan',
        );
        return;
      }

      final email = querySnapshot.docs.first.data()['email'] as String;

      // 2. Login with email & password
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      CustomSnackbar.showSuccess(
        title: 'Login Berhasil',
        message: 'Selamat datang kembali, $username!',
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Terjadi kesalahan saat login';
      if (e.code == 'wrong-password') {
        errorMessage = 'Kata sandi salah';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'Pengguna tidak ditemukan';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Format email tidak valid';
      }

      CustomSnackbar.showError(title: 'Login Gagal', message: errorMessage);
    } catch (_) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Terjadi kesalahan sistem',
      );
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    Get.offAll(() => const LoginPage());
    CustomSnackbar.showInfo(
      title: 'Logout',
      message: 'Anda telah berhasil keluar',
    );
  }
}
