import 'dart:convert';
import 'dart:developer';
import 'package:attendance/Screens/Home/home_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/login_model.dart';
import '../Widgets/snack_bar.dart';
import '../prefs/sharedPreferences.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;

  Future<LoginModel?> loginUser(String username) async {
    isLoading(true);
    log('Attempting login for username: $username'); // Log for login attempt
    try {
      final response = await http.get(
        Uri.parse('https://crolahore.azurewebsites.net/api/Master/GetLpUserByUsername?username=$username'),
      );

      log('Response status code: ${response.statusCode}'); // Log response status code

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        log('Response data: $responseData');

        if (responseData.isNotEmpty && responseData[0]['ID'] != null) {
          final profile = responseData[0];

          log('User found. Saving profile and ID: ${profile['ID']}'); // Log user found and profile data

          await setUserId(profile['ID']);
          await setUserProfile(profile); // Save whole profile

          Snackbar.snackBar('Line UP', 'Login Successfully!');
          Get.offAll(() => const HomeScreen());

          return LoginModel.fromJson(profile);
        } else {
          log('User not found'); // Log if user is not found
          Snackbar.snackBar('Line Up', 'User not found');
          return null;
        }
      } else {
        log('Login failed with status code: ${response.statusCode}'); // Log failed login attempt
        Snackbar.snackBar('Line Up', 'Login failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error during login: $e'); // Log exception if it occurs
      Snackbar.snackBar('Line Up', 'Login failed: $e');
      return null;
    } finally {
      isLoading(false);
      log('Login process completed'); // Log after process completes
    }
  }
}
