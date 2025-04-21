import 'package:attendance/Auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../BreakTracker/break_tracker_screen.dart';
import '../Widgets/text_widget.dart';
import '../AppColors/app_colors.dart';
import '../Widgets/custom_text_field.dart';

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
  final TextEditingController registrationDateController = TextEditingController();

  String selectedGender = "Male";
  String selectedStatus = "Active"; // New status
  String selectedRole = "User"; // New role

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
                _buildGenderDropdown(),
                SizedBox(height: height * 0.025),
                CustomTextField(
                  controller: phoneNumberController,
                  hintText: "Mobile Number",
                  prefixIcon: Icons.phone,
                ),
                SizedBox(height: height * 0.025),
                CustomTextField(
                  controller: cnicController,
                  hintText: "CNIC",
                  prefixIcon: Icons.person_2_outlined,
                ),
                SizedBox(height: height * 0.025),
                CustomTextField(
                  controller: mailNameController,
                  hintText: "Email",
                  prefixIcon: Icons.mail,
                ),
                SizedBox(height: height * 0.025),
                CustomTextField(
                  controller: addressController,
                  hintText: "Address",
                  prefixIcon: Icons.home,
                ),
                SizedBox(height: height * 0.025),
                CustomTextField(
                  controller: userNameController,
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
                CustomTextField(
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  prefixIcon: Icons.lock,
                  obscureText: true,
                ),
                SizedBox(height: height * 0.025),
                _buildRegistrationDateField(),
                SizedBox(height: height * 0.025),
                _buildStatusDropdown(),
                SizedBox(height: height * 0.025),
                _buildRoleDropdown(),
                SizedBox(height: height * 0.025),
                _buildRegisterButton(),
                SizedBox(height: height * 0.025),
                _buildLoginPrompt(height, width),
                SizedBox(height: height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
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
          prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
        ),
        dropdownColor: Colors.grey[200],
        style: TextStyle(fontSize: 16, color: Colors.black87),
        items: ["Male", "Female", "Other"].map((String value) {
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
    );
  }

  Widget _buildRegistrationDateField() {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            registrationDateController.text = "${pickedDate.toLocal()}".split(' ')[0]; // Format as needed
          });
        }
      },
      child: AbsorbPointer(
        child: CustomTextField(
          controller: registrationDateController,
          hintText: "Registration Date",
          prefixIcon: Icons.calendar_today,
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
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
        value: selectedStatus,
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
          prefixIcon: Icon(Icons.check_circle_outline, color: Colors.grey[600]),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
        ),
        dropdownColor: Colors.grey[200],
        style: TextStyle(fontSize: 16, color: Colors.black87),
        items: ["1", "0"].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            selectedStatus = newValue!;
          });
        },
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
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
        value: selectedRole,
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
          prefixIcon: Icon(Icons.group, color: Colors.grey[600]),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
        ),
        dropdownColor: Colors.grey[200],
        style: TextStyle(fontSize: 16, color: Colors.black87),
        items: ["User", "Admin"].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            selectedRole = newValue!;
          });
        },
      ),
    );
  }

  Widget _buildRegisterButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Handle registration logic here
          Get.to(LoginScreen());
        },
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.blackColor,
            borderRadius: BorderRadius.circular(15),
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
    );
  }

  Widget _buildLoginPrompt(double height, double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account!"),
        SizedBox(width: width * 0.020),
        InkWell(
          onTap: () {
            Get.to(LoginScreen());
          },
          child: Text(
            "Login",
            style: TextStyle(
              color: AppColors.orangeShade,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}