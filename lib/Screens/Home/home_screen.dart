import 'dart:math';

import 'package:attendance/AppColors/app_colors.dart';
import 'package:attendance/Screens/Breaks/breaks_screen.dart';
import 'package:attendance/Screens/Leaves/leaves_screen.dart';
import 'package:attendance/Screens/Profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../Employee/employees_screen.dart';
import 'animated_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // Control shimmer visibility
  bool _showShimmer = true;

  @override
  void initState() {
    super.initState();

    // Main animations controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Separate controller for continuous pulse effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Scale animation with bouncy effect
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // Fade in animation - ensuring values stay between 0.0 and 1.0
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    // Slide up animation
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Subtle pulse animation for welcome card
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Show shimmer immediately while loading
    _showShimmer = true;

    // Start the animations after a reasonable delay to allow shimmer effect to show
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _mainController.forward().then((_) {
          setState(() {
            _showShimmer = false;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      // backgroundColor: AppColors.appColor,
      body: Container(
        height: height*1,
        child: EnhancedBackground(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _mainController,
              _pulseController,
            ]),
            builder: (context, child) {
              return Stack(
                children: [
                  // Main Content
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Header section
                          Opacity(
                            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Transform.rotate(
                                  angle: _mainController.value * 2 * 3.14159,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: height * 0.035),

                          // Welcome Card with synchronized animation
                          Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: Opacity(
                              opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale:
                                _scaleAnimation.value * _pulseAnimation.value,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.blackColor),
                                    borderRadius: BorderRadius.circular(24),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF4A6CFA,
                                        ).withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              color: AppColors.blueAccentColor.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                15,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.waving_hand_rounded,
                                              color: AppColors.blueAccentColor,
                                              size: 30,
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: const [
                                              Text(
                                                'Welcome back!',
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                'Let\'s get started',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.030),

                          // Quick Actions section title with synchronized animation
                          Transform.translate(
                            offset: Offset(0, 30 * (1 - _mainController.value)),
                            child: Opacity(
                              opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  bottom: 15,
                                ),
                                child: Text(
                                  'Quick Actions',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Menu Grid with synchronized animations
                          SizedBox(
                            height: height * 0.470,
                            child: GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: 0.9,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildMenuCard(
                                  title: 'Attendance',
                                  subtitle: 'Manage Attendance',
                                  icon: Icons.people_alt_rounded,
                                  iconColor: Colors.deepPurple,
                                  backgroundColor: Colors.white,
                                  delay: 100,
                                  onTap: () {
                                    _navigateWithTransition(
                                      EmployeeAttendanceScreen(userName: ''),
                                    );
                                  },
                                ),
                                _buildMenuCard(
                                  title: 'Leaves',
                                  subtitle: 'Leave requests',
                                  icon: Icons.event_note,
                                  iconColor: Colors.blue,
                                  backgroundColor: Colors.white,
                                  delay: 200,
                                  onTap: () {
                                    _navigateWithTransition(const LeaveScreen());
                                  },
                                ),
                                _buildMenuCard(
                                  title: 'Breaks',
                                  subtitle: 'Track pauses',
                                  icon: Icons.free_breakfast,
                                  iconColor: Colors.teal,
                                  backgroundColor: Colors.white,
                                  delay: 300,
                                  onTap: () {
                                    _navigateWithTransition(
                                      const BreakTrackerScreen(),
                                    );
                                  },
                                ),
                                _buildMenuCard(
                                  title: 'Profile',
                                  subtitle: 'Your details',
                                  icon: Icons.person,
                                  iconColor: Colors.orange,
                                  backgroundColor: Colors.white,
                                  delay: 400,
                                  onTap: () {
                                    _navigateWithTransition(
                                      const ProfileScreen(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Shimmer loading overlay - only visible during loading
                  if (_showShimmer) _buildShimmerOverlay(height, width),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Shimmer Effect Overlay
  Widget _buildShimmerOverlay(double height, double width) {
    return Container(
      color: Colors.transparent,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header shimmer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.035),

              // Welcome card shimmer
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                ),
              ),
              SizedBox(height: height * 0.030),

              // Title shimmer
              Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.whiteTheme),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),

              // Grid shimmer
              SizedBox(
                height: height * 0.670,
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.9,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(4, (index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.whiteTheme),
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.black,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateWithTransition(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }
  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required int delay,
    required VoidCallback onTap,
  }) {
    final double delayFactor = delay / 1500;
    final double animValue = (_mainController.value - delayFactor).clamp(
      0.0,
      1.0,
    );
    final double curvedValue = Curves.easeOutBack.transform(animValue);
    final double safeOpacity = curvedValue.clamp(0.0, 1.0);

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Transform.scale(
      scale: 0.3 + (0.7 * curvedValue),
      child: Transform.translate(
        offset: Offset(0, 50 * (1 - curvedValue)),
        child: Opacity(
          opacity: safeOpacity,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            splashColor: iconColor.withOpacity(0.1),
            highlightColor: iconColor.withOpacity(0.05),
            child: Ink(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2), // White border
                borderRadius: BorderRadius.circular(24),
                color: backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(2, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: height * 0.080,
                    width: width * 0.20,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white), // White border for the icon container
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(icon, size: 36, color: iconColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}