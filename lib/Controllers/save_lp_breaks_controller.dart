import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Models/save_lp_breaks.dart';

class SaveLpBreaksController extends GetxController {
  var isLoading = false.obs;
  var responseModel = SaveLpBreaksModels().obs;

  Future<void> saveLpBreaks(Map<String, dynamic> body) async {
    isLoading.value = true;

    print('🟡 [SaveLpBreaksController] Request initiated...');
    print('📤 Request Body: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        Uri.parse("https://crolahore.azurewebsites.net/api/Master/SaveLpBreaks"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      log('Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        responseModel.value = SaveLpBreaksModels.fromJson(jsonData);

        log(' Success Message: ${responseModel.value.message}');
        log(' Full Response Body: ${response.body}');
      } else {
        log(' Failed with status: ${response.statusCode}');
        log(' Error Response Body: ${response.body}');
      }
    } catch (e) {
      log(' Exception occurred: $e');
    } finally {
      isLoading.value = false;
      log(' [SaveLpBreaksController] Request completed.');
    }
  }
}
