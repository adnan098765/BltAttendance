import 'package:attendance/Auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../BreakTracker/break_tracker_screen.dart';
import '../Widgets/text_widget.dart';
import '../AppColors/app_colors.dart';
import 'custom_text_field.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController mailNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String selectedGender = "Male";

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
                  text: "Registration Form",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.orangeShade,
                ),
                SizedBox(height: height * 0.025),
                CustomTextField(
                  controller: fullNameController,
                  hintText: "Full Name",
                  prefixIcon: Icons.person,
                ),
                SizedBox(height: height * 0.025),
                CustomTextField(
                  controller: fatherNameController,
                  hintText: "Father Name",
                  prefixIcon: Icons.person,
                ),
                SizedBox(height: height * 0.025),
                CustomTextField(
                  controller: phoneNumberController,
                  hintText: "Mobile Number",
                  prefixIcon: Icons.phone,
                ),                SizedBox(height: height * 0.025),
                CustomTextField(
                  controller: cnicController,
                  hintText: "CNIC",
                  prefixIcon: Icons.person_2_outlined,
                ),                SizedBox(height: height * 0.025),
                CustomTextField(
                  controller: mailNameController,
                  hintText: "Email",
                  prefixIcon: Icons.mail,
                ),                SizedBox(height: height * 0.025),
                CustomTextField(
                  controller: addressController,
                  hintText: "Address",
                  prefixIcon: Icons.home,
                ),                SizedBox(height: height * 0.025),
                CustomTextField(
                  controller: userNameController,
                  hintText: "Username",
                  prefixIcon: Icons.person,
                ),                SizedBox(height: height * 0.025),
                CustomTextField(
                  controller: passwordController,
                  hintText: "Password",
                  prefixIcon: Icons.lock,
                  obscureText: true,
                ),                SizedBox(height: height * 0.025),
                CustomTextField(
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  prefixIcon: Icons.lock,
                  obscureText: true,
                ),                SizedBox(height: height * 0.025),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedGender,
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
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Colors.grey[600],
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 2,
                      ),
                    ),
                    dropdownColor: Colors.grey[200],
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    items:
                    ["Male", "Female", "Other"].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedGender = newValue!;
                      });
                    },
                  ),
                ),

                SizedBox(height: height * 0.025),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _buttonPressed = true),
                    onTapUp: (_) => setState(() => _buttonPressed = false),
                    onTapCancel: () => setState(() => _buttonPressed = false),
                    onTap: () {
                      Get.to(LoginScreen());
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
                          text: "Register",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteTheme,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.025),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Text("Already have an account!"),
                    SizedBox(width: width*0.020,),
                    InkWell(
                      onTap: (){
                        Get.to(LoginScreen());
                      },
                        child: Text("Login",style: TextStyle(color: AppColors.orangeShade,fontWeight: FontWeight.bold),))
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
