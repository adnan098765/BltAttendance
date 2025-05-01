import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../../AppColors/app_colors.dart';
import '../../Controllers/get_lp_break_type.dart';
import '../../Controllers/save_lp_breaks_controller.dart';

class BreakTrackerScreen extends StatefulWidget {
  const BreakTrackerScreen({super.key});

  @override
  _BreakTrackerScreenState createState() => _BreakTrackerScreenState();
}

class _BreakTrackerScreenState extends State<BreakTrackerScreen> {
  bool isQuickBreak = false;
  bool isMealBreak = false;
  DateTime? quickBreakStart;
  DateTime? mealBreakStart;
  List<Map<String, dynamic>> breakRecords = [];
  String selectedBreakType = 'Quick Break';
  SaveLpBreaksController saveLpBreaksController = Get.put(SaveLpBreaksController());
  GetLpBreakTypesController getLpBreakTypesController = Get.put(GetLpBreakTypesController());
  Timer? _quickTimer;
  Timer? _mealTimer;
  int quickElapsedSeconds = 0;
  int mealElapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    loadBreakRecords();
    loadBreakStatus();
    log('BreakTypeController Initialized');
    getLpBreakTypesController.fetchLpBreakTypes();

  }

  void loadBreakRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('breakRecords');
    if (data != null) {
      setState(() {
        breakRecords = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  void saveBreakRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('breakRecords', jsonEncode(breakRecords));
  }

  void saveBreakStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isQuickBreak', isQuickBreak);
    await prefs.setBool('isMealBreak', isMealBreak);
    await prefs.setInt('quickElapsedSeconds', quickElapsedSeconds);
    await prefs.setInt('mealElapsedSeconds', mealElapsedSeconds);

    if (quickBreakStart != null) {
      await prefs.setString(
        'quickBreakStart',
        quickBreakStart!.toIso8601String(),
      );
    } else {
      await prefs.remove('quickBreakStart');
    }

    if (mealBreakStart != null) {
      await prefs.setString(
        'mealBreakStart',
        mealBreakStart!.toIso8601String(),
      );
    } else {
      await prefs.remove('mealBreakStart');
    }
  }

  void loadBreakStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isQuickBreak = prefs.getBool('isQuickBreak') ?? false;
      isMealBreak = prefs.getBool('isMealBreak') ?? false;
      quickElapsedSeconds = prefs.getInt('quickElapsedSeconds') ?? 0;
      mealElapsedSeconds = prefs.getInt('mealElapsedSeconds') ?? 0;

      String? quickStartStr = prefs.getString('quickBreakStart');
      if (quickStartStr != null) {
        quickBreakStart = DateTime.parse(quickStartStr);
      }

      String? mealStartStr = prefs.getString('mealBreakStart');
      if (mealStartStr != null) {
        mealBreakStart = DateTime.parse(mealStartStr);
      }
    });

    if (isQuickBreak) startQuickTimer();
    if (isMealBreak) startMealTimer();
  }

  bool isWithinAllowedBreakTime() {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentDay = now.weekday;

    // Monday to Friday (7 PM to 4 AM)
    if (currentDay >= DateTime.monday && currentDay <= DateTime.friday) {
      return currentHour >= 19 || currentHour < 4;
    }
    // Saturday (11 AM to 6 PM)
    else if (currentDay == DateTime.saturday) {
      return currentHour >= 11 && currentHour < 18;
    }
    // Sunday - no breaks allowed
    return false;
  }

  void startBreak() {
    if (!isWithinAllowedBreakTime()) {
      Get.snackbar(
        "Break Not Allowed",
        currentBreakTimeMessage(),
        backgroundColor: AppColors.redColor,
      );
      return;
    }

    if (selectedBreakType == 'Quick Break') {
      if (!isQuickBreak) startQuickBreak();
    } else {
      if (!isMealBreak) startMealBreak();
    }
  }

  String currentBreakTimeMessage() {
    final now = DateTime.now();
    final currentDay = now.weekday;

    if (currentDay >= DateTime.monday && currentDay <= DateTime.friday) {
      return "Breaks only allowed between 7 PM to 4 AM from Monday to Friday";
    } else if (currentDay == DateTime.saturday) {
      return "Breaks only allowed between 11 AM to 6 PM on Saturday";
    } else {
      return "No breaks allowed on Sunday";
    }
  }

  void endBreak() {
    if (selectedBreakType == 'Quick Break') {
      if (isQuickBreak) endQuickBreak();
    } else {
      if (isMealBreak) endMealBreak();
    }
  }

  void startQuickBreak() {
    final now = DateTime.now();

    setState(() {
      isQuickBreak = true;
      quickBreakStart = now;
      quickElapsedSeconds = 0;
    });

    startQuickTimer();
    saveBreakStatus();

    // Save to API using controller
    final Map<String, dynamic> breakData = {
      'breakType': 'Quick Break',
      'startTime': now.toIso8601String(),
      'endTime': null,
      'duration': 0,
      'status': 'Started'
    };

    saveLpBreaksController.saveLpBreaks(breakData);

    Get.snackbar(
      "Quick Break",
      "Quick break started",
      backgroundColor: AppColors.orangeShade,
    );
  }

  void endQuickBreak() {
    if (quickBreakStart != null) {
      final endTime = DateTime.now();
      final duration = endTime.difference(quickBreakStart!).inSeconds;

      // Save to API using controller
      final Map<String, dynamic> breakData = {
        'breakType': 'Quick Break',
        'startTime': quickBreakStart!.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'duration': duration,
        'status': 'Completed'
      };

      saveLpBreaksController.saveLpBreaks(breakData);

      setState(() {
        breakRecords.add({
          'type': 'Quick Break',
          'start': quickBreakStart.toString(),
          'end': endTime.toString(),
          'duration': duration,
        });
        breakRecords.sort(
              (a, b) =>
              DateTime.parse(b['start']).compareTo(DateTime.parse(a['start'])),
        );
        isQuickBreak = false;
        quickBreakStart = null;
        _quickTimer?.cancel();
      });
      saveBreakRecords();
      saveBreakStatus();
      Get.snackbar(
        "Quick break ended",
        "Duration: ${formatFullTime(duration)}",
        backgroundColor: AppColors.redColor,
      );
    }
  }

  void startMealBreak() {
    final now = DateTime.now();

    setState(() {
      isMealBreak = true;
      mealBreakStart = now;
      mealElapsedSeconds = 0;
    });

    startMealTimer();
    saveBreakStatus();

    // Save to API using controller
    final Map<String, dynamic> breakData = {
      'breakType': 'Meal Break',
      'startTime': now.toIso8601String(),
      'endTime': null,
      'duration': 0,
      'status': 'Started'
    };

    saveLpBreaksController.saveLpBreaks(breakData);

    Get.snackbar(
      "Meal Break",
      "Meal break started",
      backgroundColor: AppColors.orangeShade,
    );
  }

  void endMealBreak() {
    if (mealBreakStart != null) {
      final endTime = DateTime.now();
      final duration = endTime.difference(mealBreakStart!).inSeconds;

      // Save to API using controller
      final Map<String, dynamic> breakData = {
        'breakType': 'Meal Break',
        'startTime': mealBreakStart!.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'duration': duration,
        'status': 'Completed'
      };

      saveLpBreaksController.saveLpBreaks(breakData);

      setState(() {
        breakRecords.add({
          'type': 'Meal Break',
          'start': mealBreakStart.toString(),
          'end': endTime.toString(),
          'duration': duration,
        });
        breakRecords.sort(
              (a, b) =>
              DateTime.parse(b['start']).compareTo(DateTime.parse(a['start'])),
        );
        isMealBreak = false;
        mealBreakStart = null;
        _mealTimer?.cancel();
      });
      saveBreakRecords();
      saveBreakStatus();
      Get.snackbar(
        "Meal break ended",
        "Duration: ${formatFullTime(duration)}",
        backgroundColor: AppColors.redColor,
      );
    }
  }

  void startQuickTimer() {
    _quickTimer?.cancel();
    _quickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => quickElapsedSeconds++);
      if (quickElapsedSeconds % 10 == 0) saveBreakStatus();
    });
  }

  void startMealTimer() {
    _mealTimer?.cancel();
    _mealTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => mealElapsedSeconds++);
      if (mealElapsedSeconds % 10 == 0) saveBreakStatus();
    });
  }

  String formatTime(int seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String formatFullTime(int totalSeconds) {
    final hours = (totalSeconds ~/ 3600);
    final minutes = ((totalSeconds % 3600) ~/ 60);
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
  }

  int get activeBreakSeconds {
    return selectedBreakType == 'Quick Break'
        ? quickElapsedSeconds
        : mealElapsedSeconds;
  }

  double get activeBreakPercent {
    return selectedBreakType == 'Quick Break'
        ? activeBreakSeconds /
        600 // 10 minutes = 600 seconds
        : activeBreakSeconds / 3600; // 1 hour = 3600 seconds
  }

  int get dailyBreakSeconds {
    final now = DateTime.now();
    return breakRecords
        .where((record) {
      final date = DateTime.parse(record['start']);
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    })
        .fold(0, (sum, record) => sum + (record['duration'] as int));
  }

  int get monthlyBreakSeconds {
    final now = DateTime.now();
    return breakRecords
        .where((record) {
      final date = DateTime.parse(record['start']);
      return date.year == now.year && date.month == now.month;
    })
        .fold(0, (sum, record) => sum + (record['duration'] as int));
  }

  @override
  void dispose() {
    _quickTimer?.cancel();
    _mealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBreakActive =
        (selectedBreakType == 'Quick Break' && isQuickBreak) ||
            (selectedBreakType == 'Meal Break' && isMealBreak);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios, color: AppColors.whiteTheme),
        ),
        title: const Text(
          "Break Tracker",
          style: TextStyle(color: AppColors.whiteTheme),
        ),
        backgroundColor: AppColors.appColor,
      ),
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Card(
                        color: AppColors.appColor,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Break Summary",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.whiteTheme,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Today's Total:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.whiteTheme,
                                    ),
                                  ),
                                  Text(
                                    formatFullTime(dailyBreakSeconds),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.whiteTheme,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "This Month's Total:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.whiteTheme,
                                    ),
                                  ),
                                  Text(
                                    formatFullTime(monthlyBreakSeconds),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.whiteTheme,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Obx(() {
                          if (getLpBreakTypesController.isLoading.value) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (getLpBreakTypesController.breakTypes.isEmpty) {
                            return const Text("No break types found");
                          }

                          return DropdownButton<String>(
                            value: getLpBreakTypesController.selectedBreakType.value.isEmpty
                                ? null
                                : getLpBreakTypesController.selectedBreakType.value,
                            isExpanded: true,
                            hint: const Text("Select Break Type"),
                            underline: const SizedBox(),
                            items: getLpBreakTypesController.breakTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type.name,
                                child: Text("${type.name}"),
                              );
                            }).toList(),
                            onChanged: isBreakActive
                                ? null
                                : (newValue) {
                              getLpBreakTypesController.selectedBreakType.value = newValue!;
                            },
                          );
                        }),
                      ),




                      const SizedBox(height: 4),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Obx(() {
                                    return Text(
                                      getLpBreakTypesController.selectedBreakType.value.isEmpty
                                          ? "Select Break Type"
                                          : getLpBreakTypesController.selectedBreakType.value,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }),
                                  Text(
                                    formatTime(activeBreakSeconds),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: LinearProgressIndicator(
                                  value: activeBreakPercent,
                                  backgroundColor: Colors.grey[200],
                                  color: (getLpBreakTypesController.selectedBreakType.value == 'Quick Break' &&
                                      activeBreakSeconds > 600)
                                      ? Colors.red
                                      : AppColors.appColor,
                                  minHeight: 10,
                                ),
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isBreakActive ? endBreak : startBreak,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isBreakActive
                                        ? AppColors.redColor
                                        : AppColors.appColor,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    isBreakActive ? "STOP BREAK" : "START BREAK",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Break History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.appColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: breakRecords.isEmpty
                      ? const Center(child: Text("No break records yet"))
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: breakRecords.length,  // Display all break records
                    itemBuilder: (context, index) {
                      final record = breakRecords[index];
                      return Card(
                        color: AppColors.appColor,
                        child: ListTile(
                          title: Text(
                            record['type'],  // Display break type (Quick/Meal)
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.whiteTheme,
                            ),
                          ),
                          subtitle: Text(
                            "Start: ${record['start']}\nEnd: ${record['end']}",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.whiteTheme,
                            ),
                          ),
                          trailing: Text(
                            formatTime(record['duration']),  // Format and display duration
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.whiteTheme,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )

              ],
            ),
          ),
          // Loading overlay
          if (saveLpBreaksController.isLoading.value)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      )),
    );
  }
}