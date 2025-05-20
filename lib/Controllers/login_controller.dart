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

  Future<LoginModel?> loginUser(String username, String password) async {
    isLoading(true);
    log('Attempting login for username: $username'); // Log for login attempt

    if (username.isEmpty || password.isEmpty) {
      Snackbar.snackBar('Line Up', 'Please enter both username and password');
      isLoading(false);
      return null;
    }

    try {
      // Get user information using username
      final userResponse = await http.get(
        Uri.parse('https://crolahore.azurewebsites.net/api/Master/GetLpUserByUsername?username=$username'),
      );

      log('Response status code: ${userResponse.statusCode}'); // Log response status code

      if (userResponse.statusCode == 200) {
        var userData = jsonDecode(userResponse.body);
        log('User data response: $userData');

        if (userData.isNotEmpty && userData[0]['ID'] != null) {
          final profile = userData[0];

          // Check if password matches the one stored in the user profile
          // Based on the SignupController implementation, password should be stored in the profile
          if (profile.containsKey('Password') && profile['Password'] == password) {
            log('User authenticated successfully. Saving profile and ID: ${profile['ID']}');

            await setUserId(profile['ID']);
            await setUserProfile(profile); // Save whole profile

            Snackbar.snackBar('Line UP', 'Login Successfully!');
            Get.offAll(() => const HomeScreen());

            return LoginModel.fromJson(profile);
          } else {
            log('Invalid password');
            Snackbar.snackBar('Line Up', 'Invalid password');
            return null;
          }
        } else {
          log('User not found'); // Log if user is not found
          Snackbar.snackBar('Line Up', 'User not found');
          return null;
        }
      } else {
        log('Login failed with status code: ${userResponse.statusCode}'); // Log failed login attempt
        Snackbar.snackBar('Line Up', 'Login failed: ${userResponse.statusCode}');
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