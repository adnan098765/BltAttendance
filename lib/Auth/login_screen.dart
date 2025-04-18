import 'package:attendance/Auth/forget_password.dart';
import 'package:attendance/Auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../BottonNavScreen/bottom_nav_screen.dart';
import '../BreakTracker/break_tracker_screen.dart';
import '../Widgets/text_widget.dart';
import '../AppColors/app_colors.dart';
import 'custom_text_field.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.whiteTheme,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.04),
                CustomText(
                  text: "Login",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.orangeShade,
                ),
                SizedBox(height: height * 0.025),
                CustomTextField(
                  controller: userController,
                  hintText: "Username",
                  prefixIcon: Icons.person,
                ),
                SizedBox(height: height * 0.025),
                CustomTextField(
                  controller: passwordController,
                  hintText: "Password",
                  prefixIcon: Icons.lock,
                  obscureText: true,
                ),
                SizedBox(height: height * 0.025),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _buttonPressed = true),
                    onTapUp: (_) => setState(() => _buttonPressed = false),
                    onTapCancel: () => setState(() => _buttonPressed = false),
                    onTap: () {
                      Get.to(BottomNavScreen());
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 100),
                      height: height * 0.06,
                      width: width,
                      decoration: BoxDecoration(
                        color: AppColors.blackColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow:
                        _buttonPressed
                            ? []
                            : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.orangeShade,
                            AppColors.orangeShade,
                          ],
                        ),
                      ),
                      child: Center(
                        child: CustomText(
                          text: "Login",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteTheme,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.010),
               Align(
                   alignment: Alignment(0.9, 5),
                   child: InkWell(
                     onTap: (){
                      Get.to(ForgotPasswordScreen());
                     },
                       child: Text("Forget Password",style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.appColor),))),
                SizedBox(height: height * 0.010),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account"),
                    SizedBox(width: width*0.020,),
                    InkWell(
                      onTap: (){
                        Get.to(SignupScreen());
                      },
                        child: Text("Signup",style: TextStyle(color: AppColors.orangeShade,fontWeight: FontWeight.bold),))
                  ],
                ),

                SizedBox(height: height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _buttonPressed = false;
}
