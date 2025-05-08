import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/leave_type_model.dart';

class GetLeaveTypesController extends GetxController {
  var leaveTypes = <LeaveTypeModel>[].obs;
  var isLoading = false.obs;

  Future<void> fetchLeaveTypes(int userId) async {
    try {
      isLoading.value = true;
      Get.log("Fetching leave types for user ID: $userId");

      final response = await http.get(
        Uri.parse('https://crolahore.azurewebsites.net/api/Master/GetLpLeaveTypes?UserID=$userId'),
      );

      Get.log("Response status: ${response.statusCode}");
      Get.log("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        leaveTypes.value = jsonList.map((e) => LeaveTypeModel.fromJson(e)).toList();
        Get.log("Fetched ${leaveTypes.length} leave types.");
      } else {
        Get.snackbar("Error", "Failed to load leave types");
        Get.log("Error: Failed to load leave types - ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
      Get.log("Exception during fetchLeaveTypes: $e");
    } finally {
      isLoading.value = false;
      Get.log("Loading finished.");
    }
  }
}