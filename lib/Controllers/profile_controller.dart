import 'dart:convert';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/user_model.dart';

class ProfileController extends GetxController {
  var user = Rx<UserModel?>(null);
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('userData');

      if (userData != null) {
        user.value = UserModel.fromJson(jsonDecode(userData));
      }
    } finally {
      isLoading(false);
    }
  }

// ... rest of your existing code ...
}