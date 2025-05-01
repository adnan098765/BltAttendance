import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/get_lp_breaks_types.dart';

class GetLpBreakTypesController extends GetxController {
  var isLoading = false.obs;
  var selectedBreakType = ''.obs;

  var breakTypes = <GetLpBreakTypesModel>[].obs;

  // Method to fetch the break types from the API
  Future<void> fetchLpBreakTypes() async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse("https://crolahore.azurewebsites.net/api/Master/GetLpBreakTypes"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);

        breakTypes.value = jsonData.map((data) => GetLpBreakTypesModel.fromJson(data)).toList();
        print('Break Types: ${breakTypes}');
      } else {
        print('Failed to load break types: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while fetching break types: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
