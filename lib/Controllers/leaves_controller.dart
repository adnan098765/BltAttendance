import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Models/save_lp_requests.dart';

class LeaveController extends GetxController {
  Future<bool> submitLeaveApi(SaveLpLeaveRequest request) async {
    const String url = 'https://crolahore.azurewebsites.net/api/Master/SaveLpLeaves';

    try {
      log('Submitting leave request: ${jsonEncode(request.toJson())}');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      log('Server Response Status: ${response.statusCode}');
      log('Server Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('Decoded Response: $data');

        if (data['Status'] == 1) {
          log('Leave submission successful.');
          return true;
        } else {
          log('Leave submission failed. Server responded with status != 1');
          return false;
        }
      } else {
        log('Leave submission failed. HTTP status != 200');
        return false;
      }
    } catch (e, stackTrace) {
      log('Error submitting leave: $e', stackTrace: stackTrace);
      return false;
    }
  }
}
