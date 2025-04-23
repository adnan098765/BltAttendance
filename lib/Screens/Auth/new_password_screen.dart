import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attendance/AppColors/app_colors.dart';
import 'package:attendance/Widgets/text_widget.dart';

import 'login_screen.dart';

class ChangePasswordScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    bool _buttonPressed = false;

    return Scaffold(

      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              // IconButton(
              //   icon: const Icon(Icons.arrow_back),
              //   onPressed: () => Get.back(),
              // ),

               SizedBox(height:height*0.0540),

              // Title
              Text(
                'Change Password',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.orangeShade,
                ),
              ),

               SizedBox(height: height*0.012),

              // Subtitle
              Text(
                "Enter your new password and confirm it",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 32),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Password Field
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        obscuringCharacter: "*",

                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.orangeShade,
                              width: 1.5,
                            ),
                          ),
                          hintText: "New Password",
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 15,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),

                     SizedBox(height:height*0.02520),

                    // Confirm Password Field
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        obscuringCharacter: "*",
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.orangeShade,
                              width: 1.5,
                            ),
                          ),
                          hintText: "Confirm Password",
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 15,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),

                     SizedBox(height: height*0.030),

                    // Change Password Button
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTapDown: (_) => _buttonPressed = true,
                        onTapUp: (_) => _buttonPressed = false,
                        onTapCancel: () => _buttonPressed = false,
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            // Password change logic here
                            Get.to(LoginScreen());
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          height: height * 0.06,
                          width: width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: _buttonPressed
                                ? []
                                : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
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
                              text: "Change Password",
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.whiteTheme,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Already have account text
                    // Center(
                    //   child: TextButton(
                    //     onPressed: () {
                    //       // Navigate to login screen
                    //       Get.back();
                    //     },
                    //     child: Text.rich(
                    //       TextSpan(
                    //         text: "Already have an account? ",
                    //         children: [
                    //           TextSpan(
                    //             text: "Sign in",
                    //             style: TextStyle(
                    //               color: AppColors.orangeShade,
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       style: Theme.of(context)
                    //           .textTheme
                    //           .bodyMedium!
                    //           .copyWith(color: Colors.grey[600]),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}