import 'package:attendance/AppColors/app_colors.dart';
import 'package:attendance/Auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen>
    with SingleTickerProviderStateMixin {
  double _adminScale = 1.0;
  double _employeeScale = 1.0;

  void _onTapDown(bool isAdmin) {
    setState(() {
      if (isAdmin) {
        _adminScale = 0.95;
      } else {
        _employeeScale = 0.95;
      }
    });
  }

  void _onTapUp(bool isAdmin) {
    setState(() {
      if (isAdmin) {
        _adminScale = 1.0;
      } else {
        _employeeScale = 1.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: h*0.10,),
            Text("Welcome to Our Company BlueLinesTech",maxLines: 1,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
            Center(
              child: Text(
                "Select Your Type",
                style: TextStyle(
                  fontSize: 24,
                  color: AppColors.orangeShade,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: h * .020),
            GestureDetector(
              onTapDown: (_) => _onTapDown(true),
              onTapUp: (_) => _onTapUp(true),
              onTapCancel: () => _onTapUp(true),
              onTap: () {},
              child: AnimatedScale(
                scale: _adminScale,
                duration: const Duration(milliseconds: 200),
                child: Center(
                  child: Container(
                    height: h * 0.20,
                    width: w * 0.4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.blackColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          color: AppColors.whiteTheme,
                          size: 80,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Admin",
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.whiteTheme,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: h*0.010,),
            GestureDetector(
              onTapDown: (_) => _onTapDown(false),
              onTapUp: (_) => _onTapUp(false),
              onTapCancel: () => _onTapUp(false),
              onTap: () {
                Get.to(SignupScreen());
              },
              child: AnimatedScale(
                scale: _employeeScale,
                duration: const Duration(milliseconds: 200),
                child: Center(
                  child: Container(
                    height: h * 0.20,
                    width: w * 0.4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.blackColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          color: AppColors.whiteTheme,
                          size: 80,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Employee",
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.whiteTheme,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
