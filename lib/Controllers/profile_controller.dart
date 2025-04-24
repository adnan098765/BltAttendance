// Create a new file: lib/controllers/profile_controller.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../Models/user_model.dart';

class ProfileController extends GetxController {
  Rx<UserModel?> user = Rx<UserModel?>(null);
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');

      if (userData != null) {
        user.value = UserModel.fromJson(jsonDecode(userData));
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Method to save profile image path (could be extended to upload to backend)
  Future<void> saveProfileImage(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', imagePath);
    } catch (e) {
      print('Error saving profile image: $e');
    }
  }

  // Method to get profile image path
  Future<String?> getProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('profile_image');
    } catch (e) {
      print('Error getting profile image: $e');
      return null;
    }
  }
}