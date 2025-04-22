import 'package:attendance/AppColors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Attendance/attendance_screen.dart';
import 'model.dart';
import 'package:intl/intl.dart';

class MainEmployeeAttendancePage extends StatefulWidget {
  const MainEmployeeAttendancePage({super.key});

  @override
  State<MainEmployeeAttendancePage> createState() => _MainEmployeeAttendancePageState();
}

class _MainEmployeeAttendancePageState extends State<MainEmployeeAttendancePage> {
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    EmployeeData.loadData().then((_) => setState(() {}));
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _navigateToAddEmployeesScreen() async {
    await Get.to(() => const AttendanceScreen());
    setState(() {}); // Refresh UI when returning from add employees screen
  }

  void _markAttendanceForAll(bool isPresent) {
    setState(() {
      for (int i = 0; i < EmployeeData.employeeList.length; i++) {
        EmployeeData.markAttendance(i, isPresent);
      }
    });
  }

  void _toggleAttendance(int index) {
    final isPresent = !EmployeeData.employeeList[index].isPresent;
    setState(() {
      EmployeeData.markAttendance(index, isPresent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Attendance'),
        backgroundColor: AppColors.orangeShade,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _navigateToAddEmployeesScreen,
            tooltip: 'Add Employees',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dateFormat.format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
          ),

          // Quick actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    label: const Text('Mark All Present'),
                    onPressed: () => _markAttendanceForAll(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text('Mark All Absent'),
                    onPressed: () => _markAttendanceForAll(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
          const Divider(),

          // Employee list
          Expanded(
            child: EmployeeData.employeeList.isEmpty
                ? const Center(
              child: Text(
                'No employees added yet.\nTap the "Add Employees" button to add employees.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: EmployeeData.employeeList.length,
              itemBuilder: (context, index) {
                final employee = EmployeeData.employeeList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.orangeShade.withOpacity(0.2),
                      child: Text(
                        employee.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: AppColors.orangeShade,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(employee.name),
                    subtitle: Text(
                      'Leaves: ${EmployeeData.getMonthlyAbsences(employee)}',
                    ),
                    trailing: GestureDetector(
                      onTap: () => _toggleAttendance(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: employee.isPresent ? AppColors.greenColor : AppColors.redColor,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          employee.isPresent ? 'Present' : 'Absent',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}