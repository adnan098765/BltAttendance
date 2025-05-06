import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../Models/get_breaks_model.dart';
import 'package:http/http.dart'as http;
class GetBreaksController extends GetxController {
  var isLoading = false.obs;
  var breaksList = <GetBreaksModel>[].obs;

  Future<void> fetchBreaks(int userId) async {
    isLoading.value = true;
    final url = Uri.parse(
        'https://crolahore.azurewebsites.net/api/Master/GetLpBreaksByUserID?UserID=5}');

    log('Fetching breaks for userId: $userId');
    log('Request URL: $url');

    try {
      final response = await http.get(url);
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        breaksList.value = jsonList.map((json) => GetBreaksModel.fromJson(json)).toList();

        log('Fetched ${breaksList.length} breaks');
      } else {
        Get.snackbar('Error', 'Failed to fetch breaks: ${response.statusCode}');
        log('Failed to fetch breaks with status: ${response.statusCode}');
        log('Response body: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Exception', 'Breaks fetch error: $e');
      log('Exception occurred while fetching breaks: $e');
    } finally {
      isLoading.value = false;
      log('Loading finished');
    }
  }

}
