import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Models/signup_model.dart';

import '../Screens/BottonNavScreen/bottom_nav_screen.dart';
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
  final registrationDate = TextEditingController();

  var gender = "M".obs;
  var status = "".obs;
  var role = "".obs;
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

  // Updated registerUser method in SignupController
  void registerUser() async {
    if (formKey.currentState!.validate()) {
      try {
        // Convert string status/role to int
        int statusValue = int.parse(status.value);
        int roleValue = int.parse(role.value);

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
          registrationDate.text,
          statusValue,
          roleValue,
        );
      } catch (e) {
        log('Registration error: $e');
        // Errors will be handled in loginUser method
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
    String redDate,
    int status,
    int role,
  ) async {
    isLoading(true);
    try {
      log('Attempting to register: $username');

      final response = await http.post(
        Uri.parse('https://crolahore.azurewebsites.net/api/Master/SaveLpUsers'),
        body: {
          'Name': name,
          'FatherName': fatherName,
          'Gender': gender,
          'Mobile': mobile,
          'CNIC': cnic,
          'Email': email,
          'Address': address,
          'UserName': username,
          'Password': password,
          'RegDate': redDate,
          "Status": status.toString(),
          'Role': role.toString(),
        },
      );

      log('API Response: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        log('Response data: $responseData');

        if (responseData['Status'] == 1) {
          // Success case
          Snackbar.snackBar('LineUp', 'Registration Successful!');
          Get.offAll(() => BottomNavScreen());
          return SignUpModel.fromJson(responseData);
        } else {
          // Handle specific error messages from server
          String errorMessage =
              responseData['Message'] ?? 'Registration failed';

          // Provide user-friendly messages for known errors
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

// Future getApi()async{
//   Response response = (await http.get(Uri.parse("https://crolahore.azurewebsites.net/api/Master/SaveLpUsers"))) as Response;
//   try{
//     if(response.statusCode)
//   }catch(e){
//
//   }
// }
