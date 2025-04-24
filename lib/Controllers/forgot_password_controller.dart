// controllers/forgot_password_controller.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Screens/Auth/new_password_screen.dart';

class ForgotPasswordController extends GetxController {
  var isLoading = false.obs;
  var message = ''.obs;

  Future<void> sendResetEmail(String email) async {
    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse("https://yourapi.com/api/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        message.value = data["message"] ?? "Check your email for reset link.";
        Get.snackbar("Success", message.value,
            backgroundColor: const Color(0xFF4CAF50), colorText: Colors.white);
        // You can navigate to the ChangePasswordScreen or show dialog instead.
        Get.to(() => ChangePasswordScreen());
      } else {
        final error = json.decode(response.body);
        message.value = error["error"] ?? "Failed to send reset email.";
        Get.snackbar("Error", message.value,
            backgroundColor: const Color(0xFFE53935), colorText: Colors.white);
      }
    } catch (e) {
      message.value = "Something went wrong.";
      Get.snackbar("Error", message.value,
          backgroundColor: const Color(0xFFE53935), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
