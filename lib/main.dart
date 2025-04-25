import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'AppColors/app_colors.dart';
import 'Screens/Splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Line Up',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.appColor,
            surfaceTintColor: AppColors.whiteTheme),
                primarySwatch: AppColors.blueColor,
               scaffoldBackgroundColor: AppColors.whiteTheme,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
    );
  }
}

