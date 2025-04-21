
import 'dart:convert';
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

  final gender = "Male".obs;
  final status = 1.obs;
  final role = 1.obs;

  // Loading state
  final isLoading = false.obs;

  Future<void> registerUser() async {
    isLoading.value = true;

    final url = Uri.parse("http://crolahore.azurewebsites.net/api/Master/SaveLpUsers"); // Replace with real endpoint

    final Map<String, dynamic> data = {
      "fullName": fullName.text,
      "fatherName": fatherName.text,
      "gender": gender.value,
      "phoneNumber": phoneNumber.text,
      "cnic": cnic.text,
      "email": email.text,
      "address": address.text,
      "userName": userName.text,
      "password": password.text,
      "registrationDate": registrationDate.text,
      "status": status.value,
      "role": role.value,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Registration completed",
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.offAllNamed('/login');
      } else {
        Get.snackbar("Error", response.body,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
