import 'package:attendance/Screens/Auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../AppColors/app_colors.dart';
import '../../Controllers/login_controller.dart';
import '../../Widgets/custom_text_field.dart';
import '../../Widgets/text_widget.dart';
import '../BottonNavScreen/bottom_nav_screen.dart';
import 'forget_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginController loginController = Get.put(LoginController());

  bool _buttonPressed = false;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.orangeShade.withOpacity(0.8), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.04),
                  Center(
                    child: Hero(
                      tag: 'logo',
                      child: Image.asset("assets/images/applogo.jpeg", height: 100),
                    ),
                  ),
                  SizedBox(height: height * 0.13),
                  Center(
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            Material(
                              borderRadius: BorderRadius.circular(15),
                              elevation: 6,
                              child: InkWell(
                                onTap: () {
                                  if (!loginController.isLoading.value) {
                                    loginController.loginUser(
                                      userController.text.trim(),
                                      // passwordController.text.trim(),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  height: height * 0.06,
                                  width: width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [AppColors.orangeShade, Colors.deepOrangeAccent],
                                    ),
                                  ),
                                  child: Center(
                                    child: Obx(() =>
                                    loginController.isLoading.value
                                        ? CircularProgressIndicator(color: Colors.white)
                                        : CustomText(
                                      text: "Login",
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.02),
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () {
                                  Get.to(ForgotPasswordScreen());
                                },
                                child: Text(
                                  "Forget Password",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.appColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don't have an account? "),
                                InkWell(
                                  onTap: () {
                                    Get.to(SignupScreen());
                                  },
                                  child: Text(
                                    "Signup",
                                    style: TextStyle(
                                      color: AppColors.orangeShade,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.04),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
