import 'dart:convert';
import 'dart:developer';
import 'package:attendance/Screens/Home/home_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/login_model.dart';
import '../Widgets/snack_bar.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;

  Future<LoginModel?> loginUser(String username) async {
    isLoading(true);
    try {
      final response = await http.get(
        Uri.parse('https://crolahore.azurewebsites.net/api/Master/GetLpUserByUsername?username=$username'),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData.isNotEmpty && responseData[0]['ID'] != null) {
          final int userId = responseData[0]['ID'];
          log('Login User ID: $userId');

          //  Save userId to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', userId);
          log('User ID saved to SharedPreferences: $userId');

          Snackbar.snackBar('Line UP', 'Login Successfully!');
          Get.offAll(() => HomeScreen());

          return LoginModel.fromJson(responseData[0]);
        } else {
          Snackbar.snackBar('Line Up', 'User not found');
          return null;
        }
      } else {
        Snackbar.snackBar('Line up', 'Login failed with status ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Login Error: $e');
      Get.snackbar('Error', 'An error occurred!');
      return null;
    } finally {
      isLoading(false);
    }
  }
}
