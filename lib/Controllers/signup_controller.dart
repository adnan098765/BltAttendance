import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupController extends GetxController {
  // Form key
  final formKey = GlobalKey<FormState>();

  // Text Editing Controllers
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

  // Observable fields
  var gender = ''.obs;
  var status = ''.obs;
  var role = ''.obs;
  var isLoading = false.obs;
  var showPassword = false.obs;
  var showConfirmPassword = false.obs;

  // Validators
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone is required';
    if (!RegExp(r'^[0-9]{11}$').hasMatch(value)) return 'Enter valid 11-digit number';
    return null;
  }

  String? validateCNIC(String? value) {
    if (value == null || value.isEmpty) return 'CNIC is required';
    if (!RegExp(r'^[0-9]{13}$').hasMatch(value)) return 'Enter valid 13-digit CNIC';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(value)) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != password.text) return 'Passwords do not match';
    return null;
  }

  void registerUser() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final Map<String, dynamic> payload = {
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
      "status": int.tryParse(status.value) ?? 0,
      "role": int.tryParse(role.value) ?? 0
    };

    try {
      final response = await http.post(
        Uri.parse('https://your-api-endpoint.com/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      isLoading.value = false;

      if (response.statusCode == 200) {
        Get.snackbar("Success", "User registered successfully");
        // Optionally clear the form or navigate to another page
      } else {
        final errorResponse = json.decode(response.body);
        Get.snackbar(
            "Error",
            "Registration failed: ${errorResponse['message'] ?? 'Unknown error'}",
            backgroundColor: Colors.redAccent,
            colorText: Colors.white
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
          "Error",
          "Network error: ${e.toString()}",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white
      );
    }
  }

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
}