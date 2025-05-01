import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../Models/get_leaves_status.dart';

class GetLpLeaveStatusController extends GetxController {
  var statusList = <GetLpLeaveStatus>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    Get.log("LeaveStatusController initialized");
    fetchLeaveStatuses();
    super.onInit();
  }

  Future<void> fetchLeaveStatuses() async {
    Get.log("Fetching leave statuses...");
    isLoading(true);

    try {
      final url = Uri.parse('https://crolahore.azurewebsites.net/api/Master/GetLpLeavesByUserID?UserID=1');
      Get.log("Requesting URL: $url");

      final response = await http.get(url);

      Get.log("Response Code: ${response.statusCode}");
      Get.log("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        statusList.value = data.map((e) => GetLpLeaveStatus.fromJson(e)).toList();
        Get.log("Fetched ${statusList.length} leave statuses.");
      } else {
        Get.log('Failed to load leave statuses. Status code: ${response.statusCode}');
        statusList.clear();
      }
    } catch (e) {
      Get.log('Error occurred while fetching leave statuses: $e');
      statusList.clear();
    } finally {
      isLoading(false);
    }
  }

  String getStatusNameById(int id) {
    final statusName = statusList.firstWhereOrNull((status) => status.iD == id)?.name ?? 'Unknown';
    Get.log("Status ID: $id → Status Name: $statusName");
    return statusName;
  }
}
