import 'package:attendance/AppColors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'model.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  const EmployeeAttendanceScreen({super.key});

  @override
  State<EmployeeAttendanceScreen> createState() => _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    EmployeeData.loadData().then((_) => setState(() {}));
  }

  void _addEmployee() {
    if (_nameController.text.trim().isNotEmpty) {
      setState(() {
        EmployeeData.addEmployee(Employee(name: _nameController.text.trim()));
        _nameController.clear();
      });
    }
  }

  void _toggleAttendance(int index) {
    final isPresent = !EmployeeData.employeeList[index].isPresent;
    setState(() {
      EmployeeData.markAttendance(index, isPresent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final employees = EmployeeData.employeeList;

    return Scaffold(
      appBar: AppBar(

        leading: IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.arrow_back_ios,color: AppColors.whiteTheme,)),
        title: const Text('Add Employees',style: TextStyle(color: AppColors.whiteTheme),),
        backgroundColor: AppColors.appColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter employee name to add',
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _addEmployee),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(employees[index].name),
                    subtitle: Text(
                      'Leaves: ${EmployeeData.getMonthlyAbsences(employees[index])}',
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        employees[index].isPresent ? Icons.check_circle : Icons.cancel,
                        color: employees[index].isPresent ? AppColors.greenColor : AppColors.redColor,
                      ),
                      onPressed: () => _toggleAttendance(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
