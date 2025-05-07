import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../Models/get_breaks_model.dart';
import 'package:http/http.dart' as http;

class GetBreaksController extends GetxController {
  var isLoading = false.obs;
  var breaksList = <GetBreaksModel>[].obs;

  Future<void> fetchBreaks(int userId) async {
    isLoading.value = true;
    final url = Uri.parse(
        'https://crolahore.azurewebsites.net/api/Master/GetLpBreaksByUserID?UserID=$userId');

    log('Fetching breaks for userId: $userId');
    log('Request URL: $url');

    try {
      final response = await http.get(url);
      log('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Add debug logging to inspect the actual JSON structure
        log('Response body first 500 chars: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

        final List<dynamic> jsonList = jsonDecode(response.body);

        // Process each item individually with error handling
        breaksList.clear();
        for (var i = 0; i < jsonList.length; i++) {
          try {
            final item = jsonList[i];
            log('Processing item $i: ${jsonEncode(item)}');
            final model = GetBreaksModel.fromJson(item);
            breaksList.add(model);
          } catch (e) {
            log('Error parsing item $i: $e');
          }
        }

        log('Successfully parsed ${breaksList.length} out of ${jsonList.length} breaks');
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
// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:get/get.dart';
// import 'package:get/get_state_manager/src/simple/get_controllers.dart';
//
// import '../Models/get_breaks_model.dart';
// import 'package:http/http.dart' as http;
//
// class GetBreaksController extends GetxController {
//   var isLoading = false.obs;
//   var breaksList = <GetBreaksModel>[].obs;
//
//   Future<void> fetchBreaks(int userId) async {
//     isLoading.value = true;
//     final url = Uri.parse(
//         'https://crolahore.azurewebsites.net/api/Master/GetLpBreaksByUserID?UserID=$userId');
//
//     log('Fetching breaks for userId: $userId');
//     log('Request URL: $url');
//
//     try {
//       final response = await http.get(url);
//       log('Response status: ${response.statusCode}');
//
//       if (response.statusCode == 200) {
//         final List<dynamic> jsonList = jsonDecode(response.body);
//
//         // Debug: Print the entire JSON structure of the first item
//         if (jsonList.isNotEmpty) {
//           log('First item structure: ${jsonEncode(jsonList[0])}');
//
//           // Log the types of each field in the first item
//           final firstItem = jsonList[0];
//           firstItem.forEach((key, value) {
//             log('Field: $key, Type: ${value.runtimeType}, Value: $value');
//           });
//         }
//
//         // Process each item individually with better error handling
//         breaksList.clear();
//         for (var i = 0; i < jsonList.length; i++) {
//           try {
//             final item = jsonList[i];
//             final model = GetBreaksModel.fromJson(item);
//             breaksList.add(model);
//           } catch (e, stackTrace) {
//             log('Error parsing item $i: $e');
//             log('Stack trace: $stackTrace');
//             log('Item content: ${jsonEncode(jsonList[i])}');
//           }
//         }
//
//         log('Successfully parsed ${breaksList.length} out of ${jsonList.length} breaks');
//       } else {
//         Get.snackbar('Error', 'Failed to fetch breaks: ${response.statusCode}');
//         log('Failed to fetch breaks with status: ${response.statusCode}');
//         log('Response body: ${response.body}');
//       }
//     } catch (e, stackTrace) {
//       Get.snackbar('Exception', 'Breaks fetch error: $e');
//       log('Exception occurred while fetching breaks: $e');
//       log('Stack trace: $stackTrace');
//     } finally {
//       isLoading.value = false;
//       log('Loading finished');
//     }
//   }
// }