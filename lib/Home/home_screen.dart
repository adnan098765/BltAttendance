import 'package:attendance/Employee/employees_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Attendance/attendance_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildMenuCard(
                      context,
                      'Employees',
                      Icons.people,
                      Colors.blue,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MainEmployeeAttendancePage(),
                        ),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      'Attendance',
                      Icons.calendar_today,
                      Colors.orange,
                        (){
                        Get.to(AttendanceScreen());
                        }
                    ),
                    // _buildMenuCard(
                    //   context,
                    //   'Timetable',
                    //   Icons.schedule,
                    //   Colors.purple,
                    //   //     () => Navigator.push(
                    //   //   context,
                    //   //   MaterialPageRoute(
                    //   //     builder: (context) => const TimetableScreen(),
                    //   //   ),
                    //   // ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
