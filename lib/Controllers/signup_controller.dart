import 'dart:convert';
import 'dart:developer';
import 'package:attendance/Screens/Auth/login_screen.dart';
import 'package:attendance/Screens/Home/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; // for userId storage

import '../Models/signup_model.dart';
import '../Widgets/snack_bar.dart';

class SignupController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final fullName = TextEditingController();
  final fatherName = TextEditingController();
  final phoneNumber = TextEditingController();
  final cnic = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final userName = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  var gender = "Male".obs;
  var showPassword = false.obs;
  var showConfirmPassword = false.obs;
  var isLoading = false.obs;

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required field';
    }
    if (!RegExp(r'^\d{11}$').hasMatch(value)) {
      return 'Please enter valid phone number';
    }
    return null;
  }

  String? validateCNIC(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required field';
    }
    if (!RegExp(r'^\d{13}$').hasMatch(value)) {
      return 'Please enter a valid 13-digit CNIC';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required field';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required field';
    }
    if (value.length < 6) {
      return 'Password should be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required field';
    }
    if (value != password.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void registerUser() async {
    if (formKey.currentState!.validate()) {
      try {
        await loginUser(
          fullName.text,
          fatherName.text,
          gender.value,
          phoneNumber.text,
          cnic.text,
          email.text,
          address.text,
          userName.text,
          password.text,
        );
      } catch (e) {
        log('Registration error: $e');
      }
    }
  }

  Future loginUser(
      String name,
      String fatherName,
      String gender,
      String mobile,
      String cnic,
      String email,
      String address,
      String username,
      String password,
      ) async {
    isLoading(true);
    try {
      log('Attempting to register: $username');

      String currentDate = DateTime.now().toIso8601String().split('T')[0];

      final response = await http.post(
        Uri.parse('https://crolahore.azurewebsites.net/api/Master/SaveLpUsers'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'Name': name,
          'FatherName': fatherName,
          'Gender': gender,
          'Mobile': mobile,
          'CNIC': cnic,
          'Email': email,
          'Address': address,
          'UserName': username,
          'Password': password,
          'RegDate': currentDate,
          'Status': "1",
          'Role': "0",
        }),
      );

      log('API Response: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        log('Response data: $responseData');

        if (responseData['Status'] == 1) {
          // Get userId from response (make sure backend is sending this!)
          int? userId = responseData['UserId'];

          // Store userId using SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          if (userId != null) {
            await prefs.setInt('userId', userId);
            log("User ID saved: $userId");
          }

          Snackbar.snackBar('LineUp', 'Registration Successful!');
          Get.offAll(() => LoginScreen());

          return SignUpModel.fromJson(responseData);
        } else {
          String errorMessage = responseData['Message'] ?? 'Registration failed';

          if (errorMessage.contains("UK_LpUsers_Mobile")) {
            errorMessage = 'This mobile number is already registered';
          } else if (errorMessage.contains("UK_LpUsers_Email")) {
            errorMessage = 'This email address is already registered';
          } else if (errorMessage.contains("UK_LpUsers_UserName")) {
            errorMessage = 'This username is already taken';
          }

          Snackbar.snackBar('Registration Error', errorMessage);
          return null;
        }
      } else {
        Snackbar.snackBar(
          'Error',
          'Registration failed with status ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      log('Error during registration: $e');
      Snackbar.snackBar(
        'Error',
        'An error occurred during registration. Please try again later.',
      );
      return null;
    } finally {
      isLoading(false);
    }
  }
}
