import 'package:attendance/AppColors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Employee/model.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int present = 0, absent = 0, leaves = 0;

  @override
  void initState() {
    super.initState();
    EmployeeData.loadData().then((_) {
      _calculateChartData();
      setState(() {});
    });
  }

  void _calculateChartData() {
    final employees = EmployeeData.employeeList;
    present = employees.where((e) => e.isPresent).length;
    absent = employees.where((e) => !e.isPresent).length;
    leaves = employees.fold(0, (sum, e) => sum + EmployeeData.getMonthlyAbsences(e));
  }

  @override
  Widget build(BuildContext context) {
    final employees = EmployeeData.employeeList;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.arrow_back_ios,color: AppColors.whiteTheme,)),
        title: const Text('Attendance Summary',style: TextStyle(color: AppColors.whiteTheme),),
        backgroundColor: AppColors.appColor,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text('Attendance Chart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(value: present.toDouble(), title: 'Present', color: Colors.green, radius: 50),
                  PieChartSectionData(value: absent.toDouble(), title: 'Absent', color: Colors.red, radius: 50),
                  PieChartSectionData(value: leaves.toDouble(), title: 'Leaves', color: Colors.orange, radius: 50),
                ],
                centerSpaceRadius: 30,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Employee List', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(
                      employee.isPresent ? Icons.check_circle : Icons.cancel,
                      color: employee.isPresent ? AppColors.greenColor : AppColors.redColor,
                    ),
                    title: Text(employee.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(employee.isPresent ? 'Present' : 'Absent'),
                    trailing: Text('Leaves: ${EmployeeData.getMonthlyAbsences(employee)}'),
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
