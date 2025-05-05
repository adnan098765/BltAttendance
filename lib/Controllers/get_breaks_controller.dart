import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/get_breaks_model.dart';
import '../models/get_leaves_model.dart';

class GetBreaksController extends GetxController {
  var isLoading = false.obs;
  var breaksList = <GetBreaksModel>[].obs;
  // var leavesList = <GetLeavesModel>[].obs;

  Future<void> fetchBreaks(int userId) async {
    isLoading.value = true;
    final url = Uri.parse(
        'https://crolahore.azurewebsites.net/api/Master/GetLpBreaksByUserID?UserID=$userId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        breaksList.value = jsonList.map((json) => GetBreaksModel.fromJson(json)).toList();
      } else {
        Get.snackbar('Error', 'Failed to fetch breaks: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Exception', 'Breaks fetch error: $e');
    } finally {
      isLoading.value = false;
    }
  }

}
