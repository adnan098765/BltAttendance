import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class Employee {
  String name;
  bool isPresent;
  Map<String, bool> attendanceLog; // key: date, value: present or not

  Employee({required this.name, this.isPresent = false, Map<String, bool>? attendanceLog})
      : attendanceLog = attendanceLog ?? {};

  Map<String, dynamic> toJson() => {
    'name': name,
    'isPresent': isPresent,
    'attendanceLog': attendanceLog,
  };

  static Employee fromJson(Map<String, dynamic> json) => Employee(
    name: json['name'],
    isPresent: json['isPresent'],
    attendanceLog: Map<String, bool>.from(json['attendanceLog']),
  );
}

class EmployeeData {
  static List<Employee> employeeList = [];

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('employee_data');
    if (data != null) {
      final decoded = jsonDecode(data) as List;
      employeeList = decoded.map((e) => Employee.fromJson(e)).toList();
    }
  }

  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(employeeList.map((e) => e.toJson()).toList());
    await prefs.setString('employee_data', encoded);
  }

  static void addEmployee(Employee employee) {
    employeeList.add(employee);
    saveData();
  }

  static void markAttendance(int index, bool isPresent) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    employeeList[index].isPresent = isPresent;
    employeeList[index].attendanceLog[today] = isPresent;
    saveData();
  }

  static int getMonthlyAbsences(Employee employee) {
    final now = DateTime.now();
    final currentMonth = DateFormat('yyyy-MM').format(now);
    return employee.attendanceLog.entries
        .where((entry) =>
    entry.key.startsWith(currentMonth) && entry.value == false)
        .length;
  }
}