import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import '../AppColors/app_colors.dart';
import '../Widgets/text_widget.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  String? _selectedLeaveType;
  final TextEditingController _reasonController = TextEditingController();
  bool _buttonPressed = false;

  void _selectLeaveType(String type) {
    setState(() {
      if (_selectedLeaveType == type) {
        _selectedLeaveType = null; // Unselect if clicked again
      } else {
        _selectedLeaveType = type;
      }
      _reasonController.clear();
    });
  }

  void _submitLeave() {
    if (_selectedLeaveType != null && _reasonController.text.isNotEmpty) {
      Get.snackbar(
        'Leave Submitted',
        '$_selectedLeaveType submitted successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      );
      setState(() {
        _selectedLeaveType = null;
        _reasonController.clear();
      });
    } else {
      Get.snackbar(
        'Missing Information',
        'Please select a leave type and enter a reason.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.orangeShade,
        leading: IconButton(onPressed: (){
          Get.back();
        }, icon: Icon(Icons.arrow_back_ios)),
        title: Text('Leave', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Leave Type:',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildLeaveButton('Half Leave'),
                  _buildLeaveButton('Emergency Leave'),
                  _buildLeaveButton('Long Leave'),
                  _buildLeaveButton('Sick Leave'),
                  _buildLeaveButton('Personal Leave'),
                ],
              ),
              const SizedBox(height: 24),
              if (_selectedLeaveType != null) ...[
                Text(
                  'Reason for $_selectedLeaveType:',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
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
                  child: TextField(
                    controller: _reasonController,
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
                      hintText: 'Enter your reason...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 15,
                      ),
                    ),
                    maxLines: 4,
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _buttonPressed = true),
                      onTapUp: (_) => setState(() => _buttonPressed = false),
                      onTapCancel: () => setState(() => _buttonPressed = false),
                      onTap: _submitLeave,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        height: height * 0.06,
                        width: width * 0.9,
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
                            text: "Submit Leave",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.whiteTheme,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveButton(String type) {
    final isSelected = _selectedLeaveType == type;
    final isAnotherSelected = _selectedLeaveType != null && !isSelected;

    return ChoiceChip(
      label: Text(type),
      selected: isSelected,
      selectedColor: AppColors.orangeShade,
      backgroundColor: isAnotherSelected ? Colors.grey[300] : Colors.grey[200],
      labelStyle: GoogleFonts.poppins(
        color: isSelected
            ? Colors.white
            : isAnotherSelected
            ? Colors.grey
            : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      onSelected: isAnotherSelected
          ? null // disable tap when another leave is selected
          : (_) => _selectLeaveType(type),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}