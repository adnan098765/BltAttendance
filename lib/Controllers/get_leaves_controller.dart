import 'dart:convert';
import 'dart:math';
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
      // Updated URL to use the correct controller name
      // Based on error message, 'LpRequests' is not a valid controller
      final userId = await getUserId();
      log(userId as num);
      final response = await http.get(
        Uri.parse("https://crolahore.azurewebsites.net/api/Master/GetLpLeavesByUserID?UserID=1"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );



      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('Raw response body: $responseBody');

        try {
          final decodedData = jsonDecode(responseBody);

          if (decodedData is List) {
            if (decodedData.isNotEmpty) {
              // For debugging - print the first item structure
              print('First item sample: ${decodedData.first}');

              leaves.value = decodedData.map((e) => GetLeavesModel.fromJson(e)).toList();
              print('Successfully parsed ${leaves.length} leaves');
            } else {
              print('API returned empty list');
              leaves.clear();
            }
          } else {
            print('API did not return a list: $decodedData');
            errorMessage('Unexpected response format from server');
            leaves.clear();
          }
        } catch (e) {
          print('JSON decoding error: $e');
          errorMessage('Failed to parse server response');
          leaves.clear();
        }
      } else {
        print('Failed to fetch leaves, status: ${response.statusCode}, response: ${response.body}');
        errorMessage('Server returned error code: ${response.statusCode}');
        leaves.clear();
      }
    } catch (e) {
      print('Network error fetching leaves: $e');
      errorMessage('Network error: $e');
      leaves.clear();
    } finally {
      isLoading(false);
    }
  }
// Function to cancel a leave request
// Future<bool> cancelLeave(int leaveId) async {
//   try {
//     // Implement your API call to cancel the leave
//     final response = await http.delete(
//       Uri.parse('https://crolahore.azurewebsites.net/api/LpLeaveRequests/$leaveId'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//     );
//
//     if (response.statusCode == 200 || response.statusCode == 204) {
//       // Refresh the leaves list after successful cancellation
//       await fetchLeaves();
//       return true;
//     } else {
//       print('Failed to cancel leave: ${response.statusCode}, ${response.body}');
//       return false;
//     }
//   } catch (e) {
//     print('Error cancelling leave: $e');
//     return false;
//   }
// }
}