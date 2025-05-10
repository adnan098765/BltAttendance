import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/get_lpuser_model.dart';

class LpUserController extends GetxController {
  var users = <LpUser>[].obs;
  var isLoading = false.obs;

  Future<void> fetchLpUsers(String username) async {
    try {
      isLoading.value = true;
      final url = Uri.parse('https://crolahore.azurewebsites.net/api/Master/GetLpUserByUsername?username=$username');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        users.value = jsonData.map((e) => LpUser.fromJson(e)).toList();
      } else {
        Get.snackbar('Error', 'Failed to load users');
      }
    } catch (e) {
      Get.snackbar('Error', 'Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
