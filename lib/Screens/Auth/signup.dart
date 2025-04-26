import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../AppColors/app_colors.dart';
import '../../Controllers/signup_controller.dart';
import '../../Widgets/custom_text_field.dart';
import '../../Widgets/text_widget.dart';
import 'login_screen.dart';


class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final SignupController controller = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteTheme,
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: CustomText(
                  text: "Registration Form",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.orangeShade,
                ),
              ),
              const SizedBox(height: 30),

              // Full Name
              CustomTextField(
                controller: controller.fullName,
                hintText: "Full Name",
                prefixIcon: Icons.person,
                validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: controller.fatherName,
                hintText: "Father Name",
                prefixIcon: Icons.person,
                validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
              ),
              const SizedBox(height: 15),

              // Gender Dropdown
              _buildGenderDropdown(),
              const SizedBox(height: 15),

              // Phone Number
              CustomTextField(
                controller: controller.phoneNumber,
                hintText: "Mobile Number",
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: controller.validatePhone,
              ),
              const SizedBox(height: 15),

              // CNIC
              CustomTextField(
                controller: controller.cnic,
                hintText: "CNIC (without dashes)",
                prefixIcon: Icons.credit_card,
                keyboardType: TextInputType.number,
                validator: controller.validateCNIC,
              ),
              const SizedBox(height: 15),

              // Email
              CustomTextField(
                controller: controller.email,
                hintText: "Email",
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
              ),
              const SizedBox(height: 15),

              // Address
              CustomTextField(
                controller: controller.address,
                hintText: "Address",
                prefixIcon: Icons.location_on,
                validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
              ),
              const SizedBox(height: 15),

              // Username
              CustomTextField(
                controller: controller.userName,
                hintText: "Username",
                prefixIcon: Icons.person_outline,
                validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,

              ),
              const SizedBox(height: 15),

              // Password Field
              Obx(() => CustomTextField(
                controller: controller.password,
                hintText: "Password",
                prefixIcon: Icons.lock,
                suffixIcon: controller.showPassword.value ? Icons.visibility : Icons.visibility_off,
                obscureText: !controller.showPassword.value,
                validator: controller.validatePassword,
                onSuffixIconPressed: () => controller.showPassword.toggle(),
              )),
              const SizedBox(height: 15),

              // Confirm Password Field
              Obx(() => CustomTextField(
                controller: controller.confirmPassword,
                hintText: "Confirm Password",
                prefixIcon: Icons.lock,
                suffixIcon: controller.showConfirmPassword.value ? Icons.visibility : Icons.visibility_off,
                obscureText: !controller.showConfirmPassword.value,
                validator: controller.validateConfirmPassword,
                onSuffixIconPressed: () => controller.showConfirmPassword.toggle(),
              )),
              // const SizedBox(height: 15),
              // _buildRegistrationDateField(),
              // const SizedBox(height: 15),

              // Status Dropdown
              // _buildStatusDropdown(),
              const SizedBox(height: 15),

              // Role Dropdown
              // _buildRoleDropdown(),


              Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.registerUser,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(AppColors.orangeShade),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )),
              const SizedBox(height: 15),

              // Login Prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () => Get.off(() => LoginScreen()),
                    child: Text(
                      "Login",
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
    );
  }

  Widget _buildGenderDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
      value: controller.gender.value,
      decoration: _dropdownDecoration(Icons.person_outline),
      items: ["Male", "Female", "Other"].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) => controller.gender.value = value!,
      validator: (value) => value == null ? 'Please select gender' : null,
    ));
  }

  // Widget _buildRegistrationDateField() {
  //   return TextFormField(
  //     controller: controller.registrationDate,
  //     readOnly: true,
  //     decoration: _dropdownDecoration(Icons.calendar_today).copyWith(
  //       hintText: "Joining Date",hintStyle: TextStyle(color: Colors.grey[600]),
  //     ),
  //     onTap: () async {
  //       final DateTime? pickedDate = await showDatePicker(
  //         context: Get.context!,
  //         initialDate: DateTime.now(),
  //         firstDate: DateTime(2000),
  //         lastDate: DateTime(2100),
  //       );
  //       if (pickedDate != null) {
  //         controller.registrationDate.text =
  //         "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
  //       }
  //     },
  //     validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
  //   );
  // }
  //
  // Widget _buildStatusDropdown() {
  //   return Obx(() => DropdownButtonFormField<String>(
  //     value: controller.status.value.isEmpty ? null : controller.status.value,
  //     decoration: _dropdownDecoration(Icons.check_circle_outline),
  //     items: [
  //       DropdownMenuItem(
  //         value: "1",  // API expects "1" for Active
  //         child: Text("1"),
  //       ),
  //       DropdownMenuItem(
  //         value: "0",  // API expects "0" for Inactive
  //         child: Text("0"),
  //       ),
  //     ],
  //     hint: Text("Select Status"),
  //     onChanged: (value) => controller.status.value = value!,
  //     validator: (value) => value == null ? 'Please select status' : null,
  //   ));
  // }
  //
  // Widget _buildRoleDropdown() {
  //   return Obx(() => DropdownButtonFormField<String>(
  //     value: controller.role.value.isEmpty ? null : controller.role.value,
  //     decoration: _dropdownDecoration(Icons.group),
  //     items: [
  //       DropdownMenuItem(
  //         value: "0",  // API expects "0" for Regular User
  //         child: Text("0"),
  //       ),
  //       DropdownMenuItem(
  //         value: "1",  // API expects "1" for Admin
  //         child: Text("1"),
  //       ),
  //     ],
  //     hint: Text("Select Role"),
  //     onChanged: (value) => controller.role.value = value!,
  //     validator: (value) => value == null ? 'Please select role' : null,
  //   ));
  // }

  InputDecoration _dropdownDecoration(IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
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
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
    );
  }
}