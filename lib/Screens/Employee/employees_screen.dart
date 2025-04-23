import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attendance/AppColors/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  final String userName;

  const EmployeeAttendanceScreen({super.key, required this.userName});

  @override
  State<EmployeeAttendanceScreen> createState() =>
      _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  bool? isPresent;
  DateTime currentDate = DateTime.now();
  final DateFormat dateFormatter = DateFormat('EEEE, MMMM d, yyyy');
  final DateFormat timeFormatter = DateFormat('hh:mm a');
  String? markedTime;
  bool isConnectedToOfficeWifi = false;
  bool isLoading = false;

  final String officeWifiSSID = "TechBees-2.4G";

  @override
  void initState() {
    super.initState();
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    setState(() => isLoading = true);
    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        await checkWifiConnection();
      } else {
        Get.snackbar(
          'Permission Required',
          'Location permission is needed to detect Wi-Fi',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint('Permission error: $e');
      Get.snackbar(
        'Error',
        'Failed to check permissions',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> checkWifiConnection() async {
    setState(() => isLoading = true);
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.wifi) {
        final networkInfo = NetworkInfo();
        String? wifiName = await networkInfo.getWifiName();

        debugPrint('Detected Wi-Fi Name: $wifiName');

        setState(() {
          isConnectedToOfficeWifi = wifiName != null &&
              (wifiName.replaceAll('"', '') == officeWifiSSID ||
                  wifiName.startsWith("TechBees"));
        });
      } else {
        setState(() => isConnectedToOfficeWifi = false);
      }
    } catch (e) {
      debugPrint('Wi-Fi check error: $e');
      setState(() => isConnectedToOfficeWifi = false);
      Get.snackbar(
        'Error',
        'Failed to check Wi-Fi connection',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void markAttendance(bool present) {
    if (!isConnectedToOfficeWifi) {
      Get.snackbar(
        'Wi-Fi Required',
        'Please connect to office Wi-Fi to mark attendance',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    setState(() {
      isPresent = present;
      markedTime = timeFormatter.format(DateTime.now());
    });

    Get.snackbar(
      'Attendance Marked',
      'Your attendance has been recorded as ${present ? 'Present' : 'Absent'}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: present
          ? AppColors.greenColor.withOpacity(0.8)
          : AppColors.redColor.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.whiteTheme),
        ),
        title: const Text(
          'Attendance Portal',
          style: TextStyle(
            color: AppColors.whiteTheme,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.appColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.whiteTheme),
            onPressed: () {
              checkPermissions();
              Get.snackbar(
                'Refreshing',
                'Checking connection status',
                snackPosition: SnackPosition.TOP,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.whiteTheme),
            onPressed: () {
              Get.snackbar(
                'Coming Soon',
                'Attendance history will be available soon',
                snackPosition: SnackPosition.TOP,
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: AppColors.appColor,
              padding: const EdgeInsets.only(
                bottom: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormatter.format(currentDate),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Wi-Fi Status Indicator
            Container(
              color: isConnectedToOfficeWifi ? Colors.green : Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isConnectedToOfficeWifi ? Icons.wifi : Icons.wifi_off,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnectedToOfficeWifi
                        ? "Connected to Office Wi-Fi"
                        : "Not Connected to Office Wi-Fi",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Employee Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: AppColors.orangeShade,
                            child: Text(
                              widget.userName.isNotEmpty
                                  ? widget.userName[0].toUpperCase()
                                  : "U",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.userName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Employee ID: EMP-${widget.userName.hashCode.abs()}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Attendance Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Text(
                            "Today's Attendance",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (isPresent != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                color: isPresent!
                                    ? AppColors.greenColor.withOpacity(0.1)
                                    : AppColors.redColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isPresent!
                                      ? AppColors.greenColor
                                      : AppColors.redColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isPresent!
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: isPresent!
                                        ? AppColors.greenColor
                                        : AppColors.redColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isPresent! ? "Present" : "Absent",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isPresent!
                                          ? AppColors.greenColor
                                          : AppColors.redColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (markedTime != null) ...[
                              const SizedBox(height: 15),
                              Text(
                                "Marked at $markedTime",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ] else
                            const Text(
                              "You haven't marked your attendance yet",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),

                          const SizedBox(height: 20),

                          // Attendance Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isConnectedToOfficeWifi
                                      ? () => markAttendance(true)
                                      : null,
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text("Present"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.greenColor,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: AppColors.greenColor.withOpacity(0.3),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isConnectedToOfficeWifi
                                      ? () => markAttendance(false)
                                      : null,
                                  icon: const Icon(Icons.cancel),
                                  label: const Text("Absent"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.redColor,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: AppColors.redColor.withOpacity(0.3),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (!isConnectedToOfficeWifi)
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(
                                "Please connect to office Wi-Fi to mark attendance",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "This Month's Statistics",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _buildStatItem(
                                "Present",
                                "22",
                                Colors.green,
                                Icons.check_circle,
                              ),
                              _buildStatItem(
                                "Absent",
                                "3",
                                Colors.red,
                                Icons.cancel,
                              ),
                              _buildStatItem(
                                "Leave",
                                "1",
                                Colors.orange,
                                Icons.event_busy,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label,
      String value,
      Color color,
      IconData icon,
      ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }
}