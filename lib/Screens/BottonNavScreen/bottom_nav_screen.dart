// import 'package:flutter/material.dart';
// import 'package:attendance/AppColors/app_colors.dart';
// import '../Home/home_screen.dart';
// import '../Leaves/leaves_screen.dart';
// import '../Breaks/breaks_screen.dart';
// import '../Profile/profile_screen.dart';
//
// class BottomNavScreen extends StatefulWidget {
//   const BottomNavScreen({Key? key}) : super(key: key);
//
//   @override
//   State<BottomNavScreen> createState() => _BottomNavScreenState();
// }
//
// class _BottomNavScreenState extends State<BottomNavScreen> with TickerProviderStateMixin {
//   int _selectedIndex = 0;
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//
//   final List<Widget> _screens = [
//     const HomeScreen(),
//     const LeaveScreen(),
//     const BreakTrackerScreen(),
//     const ProfileScreen(),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeInOut,
//       ),
//     );
//     _controller.forward();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _onItemSelected(int index) {
//     if (_selectedIndex != index) {
//       setState(() {
//         _selectedIndex = index;
//         _controller.reset();
//         _controller.forward();
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: _screens[_selectedIndex],
//       ),
//       bottomNavigationBar: _buildAnimatedNavBar(),
//     );
//   }
//
//   Widget _buildAnimatedNavBar() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [AppColors.appColor, AppColors.appColor.withOpacity(0.9)],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 10,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: List.generate(
//             _screens.length,
//                 (index) => _buildNavItem(index),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNavItem(int index) {
//     bool isSelected = _selectedIndex == index;
//     return GestureDetector(
//       onTap: () => _onItemSelected(index),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.fastOutSlowIn,
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               _getIcon(index),
//               color: isSelected ? AppColors.whiteTheme : Colors.grey,
//               size: isSelected ? 26 : 24,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               _getLabel(index),
//               style: TextStyle(
//                 color: isSelected ? AppColors.whiteTheme : Colors.grey,
//                 fontSize: isSelected ? 12 : 11,
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   IconData _getIcon(int index) {
//     switch (index) {
//       case 0:
//         return Icons.home;
//       case 1:
//         return Icons.event_note;
//       case 2:
//         return Icons.free_breakfast;
//       case 3:
//         return Icons.person;
//       default:
//         return Icons.home;
//     }
//   }
//
//   String _getLabel(int index) {
//     switch (index) {
//       case 0:
//         return 'Home';
//       case 1:
//         return 'Leaves';
//       case 2:
//         return 'Breaks';
//       case 3:
//         return 'Profile';
//       default:
//         return '';
//     }
//   }
// }