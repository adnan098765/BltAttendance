import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../Models/save_lp_breaks.dart';
import '../prefs/sharedPreferences.dart';

class SaveLpBreaksController extends GetxController {
  var isLoading = false.obs;
  var responseModel = SaveLpBreaksModels().obs;

  Future<void> saveLpBreaks(Map<String, dynamic> body) async {
    isLoading.value = true;

    log('[SaveLpBreaksController] Request initiated...');

    try {
      // Fetch userId from SharedPreferences
      final userId = await getUserId();

      if (userId == null) {
        log('[SaveLpBreaksController] ❌ userId not found in SharedPreferences!');
        isLoading.value = false;
        return;
      }

      body['userId'] = userId;

      log('📤 Request Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse("https://crolahore.azurewebsites.net/api/Master/SaveLpBreaks"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      log('📥 Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        responseModel.value = SaveLpBreaksModels.fromJson(jsonData);

        log('✅ Success Message: ${responseModel.value.message}');
        log('📦 Full Response Body: ${response.body}');
      } else {
        log('❌ Failed with status: ${response.statusCode}');
        log('❗ Error Response Body: ${response.body}');
      }
    } catch (e) {
      log('❌ Exception occurred: $e');
    } finally {
      isLoading.value = false;
      log('✅ [SaveLpBreaksController] Request completed.');
    }
  }
}
