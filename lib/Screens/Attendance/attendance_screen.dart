import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool isMarked = false;
  String todayKey = "";

  @override
  void initState() {
    super.initState();
    todayKey = _getTodayKey();
    _checkAttendance();
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return "attendance_${now.year}-${now.month}-${now.day}";
  }

  Future<void> _checkAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isMarked = prefs.getBool(todayKey) ?? false;
    });
  }

  Future<void> _markAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(todayKey, true);
    setState(() {
      isMarked = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Attendance marked for today")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Attendance'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: isMarked
            ? const Text(
          "✅ Your attendance is already marked today!",
          style: TextStyle(fontSize: 18, color: Colors.green),
        )
            : ElevatedButton(
          onPressed: _markAttendance,
          child: const Text("Mark Attendance"),
        ),
      ),
    );
  }
}
