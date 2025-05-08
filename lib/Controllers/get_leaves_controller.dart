import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../Models/get_leaves_model.dart';
import '../prefs/sharedPreferences.dart';

class GetLeavesController extends GetxController {
  var leaves = <GetLeavesModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    fetchLeaves();
    super.onInit();
  }

  Future<void> fetchLeaves() async {
    isLoading(true);
    errorMessage('');

    try {
      final userId = await getUserId();
      if (userId == null) {
        errorMessage('User ID not found. Please log in again');
        leaves.clear();
        return;
      }

      final response = await http.get(
        Uri.parse("https://crolahore.azurewebsites.net/api/Master/GetLpLeavesByUserID?UserID=$userId"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _processResponse(response.body);
      } else {
        errorMessage('Server error: ${response.statusCode}');
        leaves.clear();
      }
    } catch (e, stackTrace) {
      log('Network error: $e\n$stackTrace');
      errorMessage('Network error: ${e.toString()}');
      leaves.clear();
    } finally {
      isLoading(false);
    }
  }

  void _processResponse(String responseBody) {
    try {
      final dynamic data = jsonDecode(responseBody);

      if (data == null) {
        errorMessage('Empty response from server');
        return;
      }

      if (data is List) {
        leaves.assignAll(
            (data as List).whereType<Map>().map((item) =>
                GetLeavesModel.fromJson(Map<String, dynamic>.from(item))
            ).toList()
        );
      } else if (data is Map) {
        leaves.assignAll([
          GetLeavesModel.fromJson(Map<String, dynamic>.from(data as Map<dynamic, dynamic>))
        ]);
      } else {
        errorMessage('Unexpected response format');
      }
    } catch (e, stackTrace) {
      log('Failed to parse response: $e\n$stackTrace');
      errorMessage('Failed to process response: ${e.toString()}');
      leaves.clear();
    }
  }

  // Future<void> cancelLeave(int leaveId) async {
  //   try {
  //     isLoading(true);
  //     final response = await http.post(
  //       Uri.parse("https://crolahore.azurewebsites.net/api/Master/CancelLeave?LeaveID=$leaveId"),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       await fetchLeaves();
  //       Get.snackbar('Success', 'Leave cancelled successfully');
  //     } else {
  //       throw Exception('Failed to cancel leave: ${response.statusCode}');
  //     }
  //   } catch (e, stackTrace) {
  //     log('Cancel leave error: $e\n$stackTrace');
  //     Get.snackbar('Error', 'Failed to cancel leave: ${e.toString()}');
  //   } finally {
  //     isLoading(false);
  //   }
  // }
}