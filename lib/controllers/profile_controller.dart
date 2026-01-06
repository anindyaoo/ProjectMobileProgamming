import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:personal_finance/controllers/auth_controller.dart';
import 'package:personal_finance/utils/custom_snackbar.dart';
import 'package:path/path.dart' as path;

class ProfileController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  var profileImagePath = ''.obs;
  var appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ever(AuthController.instance.currentUserData, (_) => loadProfileImage());
    loadProfileImage();
    getAppVersion();
  }

  Future<void> loadProfileImage() async {
    final user = AuthController.instance.currentUserData.value;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      final savedPath = prefs.getString('profile_image_${user.id}') ?? '';

      if (savedPath.isNotEmpty) {
        if (kIsWeb) {
          profileImagePath.value = savedPath;
        } else {
          if (await File(savedPath).exists()) {
            profileImagePath.value = savedPath;
          } else {
            profileImagePath.value = '';
          }
        }
      } else {
        profileImagePath.value = '';
      }
    } else {
      profileImagePath.value = '';
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final user = AuthController.instance.currentUserData.value;
        if (user != null) {
          final prefs = await SharedPreferences.getInstance();

          if (kIsWeb) {
            final bytes = await image.readAsBytes();
            final base64Image = base64Encode(bytes);
            profileImagePath.value = base64Image;
            await prefs.setString('profile_image_${user.id}', base64Image);
          } else {
            final appDir = await getApplicationDocumentsDirectory();
            final fileName = 'profile_${user.id}${path.extension(image.path)}';
            final savedImage = await File(image.path).copy('${appDir.path}/$fileName');

            profileImagePath.value = savedImage.path;
            await prefs.setString('profile_image_${user.id}', savedImage.path);
          }
        }
      }
    } catch (e) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Gagal mengambil gambar: $e',
      );
    }
  }

  Future<void> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = packageInfo.version;
  }
}