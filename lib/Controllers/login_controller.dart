import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../Models/login_controller.dart';
import '../Screens/BottonNavScreen/bottom_nav_screen.dart';
import '../Widgets/snack_bar.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;

  Future<LoginModel?> loginUser(String username) async {
     isLoading(true);
    try {
      final response = await http.get(
        Uri.parse('http://crolahore.azurewebsites.net/api/Master/GetLpUserByUsername?username=$username'),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData.isNotEmpty && responseData[0]['ID'] != null) {
          final String id = responseData[0]['ID'].toString();
          log('ID in login controller: $id');
          // Store ID in SharedPreferences
          // await getUserId();

          Snackbar.snackBar('Line UP', 'Login Successfully!');
          Get.offAll(BottomNavScreen());
          return LoginModel.fromJson(responseData[0]);
        } else {
          Snackbar.snackBar('Line Up', 'User not found ${response.statusCode}');
          return null;
        }
      } else {
        Snackbar.snackBar('Line up', 'Login failed with status ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error: $e');
      Get.snackbar('Error', "An error occurred!");
      return null;
    } finally {
      isLoading(false);
    }
  }
}