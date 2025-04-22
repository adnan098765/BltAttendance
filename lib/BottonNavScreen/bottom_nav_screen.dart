import 'package:attendance/Breaks/breaks_screen.dart';
import 'package:attendance/Leaves/leaves_screen.dart';
import 'package:attendance/TimeTable/time_table_screen.dart';
import 'package:flutter/material.dart';

import '../Home/home_screen.dart';
import '../Profile/profile_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({Key? key}) : super(key: key);

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 2;

  final List<Widget> _screens = [
    const LeaveScreen(),
    const BreakTrackerScreen(),
    const HomeScreen(),
    // const TimetableScreen(),
    const ProfileScreen(),
  ];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemSelected,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'Leaves',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.free_breakfast),
            label: 'Breaks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.schedule),
          //   label: 'TimeTable',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}