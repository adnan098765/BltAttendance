import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../AppColors/app_colors.dart';
import '../../Controllers/get_leaves_controller.dart';
import '../../Controllers/get_leaves_type_controller.dart';
import '../../Controllers/leaves_controller.dart';
import '../../Models/save_lp_requests.dart';
import '../../Widgets/text_widget.dart';
import '../../prefs/sharedPreferences.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  String? _selectedLeaveType;
  String? _selectedReason;
  final TextEditingController _reasonController = TextEditingController();
  final LeaveController leaveController = Get.put(LeaveController());
  final GetLeavesController getleavesController = Get.put(GetLeavesController());
  final GetLeaveTypesController leaveTypesController = Get.put(GetLeaveTypesController());

  final List<String> predefinedReasons = [
    "Sick Leave",
    "Vacation",
    "Personal Leave",
    "Family Emergency",
    "Bereavement",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    _fetchLeaveTypesAndLeaves();
  }

  Future<void> _fetchLeaveTypesAndLeaves() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId != null) {
      await leaveTypesController.fetchLeaveTypes(userId);
      await getleavesController.fetchLeaves();
    } else {
      Get.snackbar(
        'Error',
        'User ID not found. Please log in again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  int _getLeaveTypeId(String leaveType) {
    final selected = leaveTypesController.leaveTypes.firstWhereOrNull(
          (e) => e.name == leaveType,
    );
    return selected?.id ?? 0;
  }

  void _submitLeave() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      Get.snackbar(
        'Error',
        'User ID not found. Please log in again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    String reason = _selectedReason == "Other" ? _reasonController.text.trim() : _selectedReason ?? "";

    if (_selectedLeaveType != null && reason.isNotEmpty) {
      final leaveRequest = SaveLpLeaveRequest(
        type: _getLeaveTypeId(_selectedLeaveType!),
        reason: reason,
        status: 4, // Assuming 4 is for "Pending" status
        userId: userId,
      );

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      try {
        final success = await leaveController.submitLeaveApi(leaveRequest);
        Get.back();

        if (success) {
          setState(() {
            _selectedLeaveType = null;
            _selectedReason = null;
            _reasonController.clear();
          });
          await getleavesController.fetchLeaves();

          Get.snackbar(
            'Success',
            'Leave submitted successfully!',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.appColor,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'Failed to submit leave. Please try again.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.redColor,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.back();
        Get.snackbar(
          'Error',
          'An error occurred: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Missing Information',
        'Please select a leave type and enter a reason',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appColor,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.whiteTheme),
        ),
        title: Text(
          'Leave Application',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.whiteTheme,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLeaveTypesAndLeaves,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leave Type Dropdown
              Obx(() {
                if (leaveTypesController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (leaveTypesController.leaveTypes.isEmpty) {
                  return const Center(child: Text("No leave types available"));
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: Text(
                      'Select Leave Type',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    value: _selectedLeaveType,
                    items: leaveTypesController.leaveTypes.map((leave) {
                      return DropdownMenuItem<String>(
                        value: leave.name,
                        child: Text(leave.name, style: GoogleFonts.poppins()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLeaveType = value;
                        _selectedReason = null; // Reset reason when leave type changes
                        _reasonController.clear();
                      });
                    },
                    underline: const SizedBox(),
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Reason Dropdown
              if (_selectedLeaveType != null) ...[
                Text(
                  'Select Reason:',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: Text(
                      'Select Reason',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    value: _selectedReason,
                    items: predefinedReasons.map((reason) {
                      return DropdownMenuItem<String>(
                        value: reason,
                        child: Text(reason, style: GoogleFonts.poppins()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedReason = value;
                        if (_selectedReason != "Other") {
                          _reasonController.clear();
                        }
                      });
                    },
                    underline: const SizedBox(),
                  ),
                ),
                const SizedBox(height: 20),

                // Text Field for "Other" Reason
                if (_selectedReason == "Other") ...[
                  TextFormField(
                    controller: _reasonController,
                    decoration: InputDecoration(
                      labelText: 'Enter your reason',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                ],

                // Submit Button
                Center(
                  child: GestureDetector(
                    onTap: _submitLeave,
                    child: Container(
                      height: 50,
                      width: width * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [AppColors.appColor, AppColors.greenColor],
                        ),
                      ),
                      child: Center(
                        child: CustomText(
                          text: "Submit Leave",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteTheme,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Leaves List (Showing only type and reason)
              Obx(() {
                if (getleavesController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (getleavesController.errorMessage.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          getleavesController.errorMessage.value,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => getleavesController.fetchLeaves(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (getleavesController.leaves.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "No leaves submitted yet",
                      style: GoogleFonts.poppins(),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: getleavesController.leaves.length,
                    itemBuilder: (context, index) {
                      final leave = getleavesController.leaves[index];
                      return Card(
                        color: AppColors.appColor,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(
                            'Type: ${leave.type ?? "Not specified"}', // Handle null case
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.whiteTheme,
                            ),
                          ),
                          subtitle: Text(
                            "Reason: ${leave.reason ?? "No reason provided"}", // Handle null case
                            style: const TextStyle(color: AppColors.whiteTheme),
                          ),
                        ),
                      );
                    }
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}