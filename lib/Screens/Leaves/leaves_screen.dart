import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../AppColors/app_colors.dart';
import '../../Controllers/get_leaves_controller.dart';
import '../../Controllers/get_leaves_status_controller.dart';
import '../../Controllers/get_leaves_type_controller.dart';
import '../../Controllers/leaves_controller.dart';
import '../../Models/save_lp_requests.dart';
import '../../Widgets/text_widget.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  String? _selectedLeaveType;
  final TextEditingController _reasonController = TextEditingController();
  final List<Map<String, String>> _submittedLeaves = [];
  final Map<String, Timer> _cancelTimers = {};
  final LeaveController leaveController = Get.put(LeaveController());
  final leaveStatusController = Get.put(GetLpLeaveStatusController());
  final GetLeavesController getleavesController = Get.put(
    GetLeavesController(),
  );
  final GetLeaveTypesController leaveTypesController = Get.put(
    GetLeaveTypesController(),
  );

  @override
  void initState() {
    super.initState();
    _loadSubmittedLeaves();
    leaveTypesController.fetchLeaveTypes();
    getleavesController.fetchLeaves();
  }

  Future<void> _loadSubmittedLeaves() async {
    final prefs = await SharedPreferences.getInstance();
    final leavesString = prefs.getString('leaves');
    if (leavesString != null) {
      final decoded = jsonDecode(leavesString) as List;
      for (var e in decoded) {
        final leave = Map<String, String>.from(e);
        final timestamp = DateTime.parse(leave['timestamp']!);
        final difference = DateTime.now().difference(timestamp).inMinutes;
        _submittedLeaves.add(leave);

        if (difference < 60) {
          final remaining = Duration(minutes: 60 - difference);
          _cancelTimers[leave['timestamp']!] = Timer(remaining, () {
            setState(() {
              _cancelTimers.remove(leave['timestamp']);
            });
          });
        }
      }
      setState(() {});
    }
  }

  Future<void> _saveSubmittedLeaves() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('leaves', jsonEncode(_submittedLeaves));
  }

  int _getLeaveTypeId(String leaveType) {
    final selected = leaveTypesController.leaveTypes.firstWhereOrNull(
      (e) => e.name == leaveType,
    );
    return selected?.id ?? 0;
  }

  void _submitLeave() async {
    const int loggedInUserId = 1;

    if (_selectedLeaveType != null && _reasonController.text.isNotEmpty) {
      final leaveRequest = SaveLpLeaveRequest(
        type: _getLeaveTypeId(_selectedLeaveType!),
        reason: _reasonController.text.trim(),
        status: 4,
        userId: loggedInUserId,
      );

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final success = await leaveController.submitLeaveApi(leaveRequest);
      Get.back();

      if (success) {
        final newLeave = {
          'type': _selectedLeaveType!,
          'reason': _reasonController.text.trim(),
          'timestamp': DateTime.now().toIso8601String(),
        };
        setState(() {
          _submittedLeaves.add(newLeave);
          _selectedLeaveType = null;
          _reasonController.clear();
        });
        await _saveSubmittedLeaves();
        _startCancelTimer(newLeave);

        Get.snackbar(
          'Leave Submitted',
          'Your leave has been recorded successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.appColor,
          colorText: Colors.white,
        );
        getleavesController.fetchLeaves();
      } else {
        Get.snackbar(
          'Submission Failed',
          'Failed to submit leave. Try again later.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Missing Info',
        'Please select leave type and enter reason.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }

  void _startCancelTimer(Map<String, String> leave) {
    final id = leave['timestamp']!;
    _cancelTimers[id] = Timer(const Duration(minutes: 60), () {
      setState(() {
        _cancelTimers.remove(id);
      });
    });
  }

  void _cancelLeave(String timestamp) async {
    setState(() {
      _submittedLeaves.removeWhere((leave) => leave['timestamp'] == timestamp);
      _cancelTimers[timestamp]?.cancel();
      _cancelTimers.remove(timestamp);
    });
    await _saveSubmittedLeaves();
    Get.snackbar(
      'Leave Cancelled',
      'Your leave has been cancelled.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange.shade400,
      colorText: Colors.white,
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _cancelTimers.values.forEach((timer) => timer.cancel());
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
          'Leave',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.whiteTheme,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              if (leaveTypesController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                  items:
                      leaveTypesController.leaveTypes.map((leave) {
                        return DropdownMenuItem<String>(
                          value: leave.name,
                          child: Text(leave.name, style: GoogleFonts.poppins()),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLeaveType = value;
                    });
                  },
                  underline: const SizedBox(),
                ),
              );
            }),
            const SizedBox(height: 20),

            if (_selectedLeaveType != null) ...[
              Text(
                'Reason for $_selectedLeaveType:',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
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
              Center(
                child: GestureDetector(
                  onTap: _submitLeave,
                  child: Container(
                    height: 50,
                    width: width * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [AppColors.orangeShade, AppColors.orangeShade],
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

            if (_submittedLeaves.isNotEmpty ||
                getleavesController.leaves.isNotEmpty)
              Obx(() {
                if (getleavesController.isLoading.value) {
                  return const Center(child: Text(""));
                }

                if (getleavesController.errorMessage.value.isNotEmpty) {
                  return Text(
                    getleavesController.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  );
                }

                if (getleavesController.leaves.isEmpty) {
                  return Text(
                    "No leaves submitted yet",
                    style: GoogleFonts.poppins(),
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
                          'Type: ${leave.type}',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.whiteTheme,
                          ),
                        ),
                        subtitle: Text(
                          "${leave.reason}",
                          style: const TextStyle(color: AppColors.whiteTheme),
                        ),
                        trailing: TextButton(
                          onPressed: () {
                            // Future: Call cancel API here if needed.
                          },
                          child: const Text(
                            'Cancel leave',
                            style: TextStyle(color: AppColors.blackColor),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
          ],
        ),
      ),
    );
  }
}
