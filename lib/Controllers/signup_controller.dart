import 'dart:convert';
import 'package:attendance/Auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SignupController extends GetxController {
  final fullName = TextEditingController();
  final fatherName = TextEditingController();
  final phoneNumber = TextEditingController();
  final cnic = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final userName = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final registrationDate = TextEditingController();

  final gender = "M".obs;
  final status = "1".obs;
  final role = "0".obs;

  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  final showPassword = false.obs;
  final showConfirmPassword = false.obs;

  @override
  void onClose() {
    fullName.dispose();
    fatherName.dispose();
    phoneNumber.dispose();
    cnic.dispose();
    email.dispose();
    address.dispose();
    userName.dispose();
    password.dispose();
    confirmPassword.dispose();
    registrationDate.dispose();
    super.onClose();
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (value != confirmPassword.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }
    if (value != password.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    if (!GetUtils.isPhoneNumber(value)) {
      return 'Please enter valid phone number';
    }
    return null;
  }

  String? validateCNIC(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter CNIC';
    }
    if (!GetUtils.isLengthEqualTo(value, 13)) {
      return 'CNIC must be 13 digits';
    }
    return null;
  }

  Future<void> registerUser() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final int statusValue = status.value == "Active" ? 1 : 0;
      final int roleValue = int.parse(role.value);
      final response = await http.post(
        Uri.parse("http://crolahore.azurewebsites.net/api/Master/SaveLpUsers"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": fullName.text.trim(),
          "fatherName": fatherName.text.trim(),
          "gender": gender.value,
          "phoneNumber": phoneNumber.text.trim(),
          "cnic": cnic.text.trim(),
          "email": email.text.trim(),
          "address": address.text.trim(),
          "userName": userName.text.trim(),
          "password": password.text.trim(),
          "registrationDate": registrationDate.text.trim(),
          "status": statusValue,
          "role": roleValue,
        }),
      );

      if (response.statusCode == 200) {
        Get.offAll(LoginScreen());
        Get.snackbar(
          "Success",
          "Registration completed successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw "Server error: ${response.statusCode}";
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}