import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../AppColors/app_colors.dart';

class Snackbar {
  static void snackBar(String title, String message) {
    Get.snackbar(
      title,
      message,
      colorText: AppColors.whiteTheme,
      backgroundColor: AppColors.appColor,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      snackPosition: SnackPosition.TOP,
    );
  }
}