import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:attendance/prefs/sharedPreferences.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../../AppColors/app_colors.dart';
import '../../Controllers/get_breaks_controller.dart';
import '../../Controllers/get_lp_break_type.dart';
import '../../Controllers/save_lp_breaks_controller.dart';

class BreakTrackerScreen extends StatefulWidget {
  const BreakTrackerScreen({super.key});

  @override
  _BreakTrackerScreenState createState() => _BreakTrackerScreenState();
}

class _BreakTrackerScreenState extends State<BreakTrackerScreen> {
  bool isQuickBreak = false;
  int get dailyBreakSeconds => dailyBreakSecondsTotal.value;
  int get monthlyBreakSeconds => monthlyBreakSecondsTotal.value;
  bool isMealBreak = false;
  DateTime? quickBreakStart;
  DateTime? mealBreakStart;
  List<Map<String, dynamic>> breakRecords = [];
  SaveLpBreaksController saveLpBreaksController = Get.put(
    SaveLpBreaksController(),
  );
  GetLpBreakTypesController getLpBreakTypesController = Get.put(
    GetLpBreakTypesController(),
  );
  final GetBreaksController controller = Get.put(GetBreaksController());

  // RxInt values to track break statistics (using GetX observables for reactive updates)
  final RxInt dailyBreakSecondsTotal = 0.obs;
  final RxInt monthlyBreakSecondsTotal = 0.obs;

  // Add this to store user ID
  int? userId;

  Timer? _quickTimer;
  Timer? _mealTimer;
  int quickElapsedSeconds = 0;
  int mealElapsedSeconds = 0;
  Map<String, int> breakTypeElapsedSeconds = {};
  Map<String, DateTime?> breakTypeStartTimes = {};
  Map<String, Timer?> breakTypeTimers = {};
  Map<String, bool> activeBreaks = {};

  // Timer to periodically update the summaries
  Timer? _summaryUpdateTimer;

  String _calculateDuration(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) {
      return "Invalid dates";
    }

    try {
      DateTime start = DateTime.parse(startDate);
      DateTime end = DateTime.parse(endDate);
      Duration duration = end.difference(start);

      // Return formatted duration in minutes
      return '${duration.inMinutes} mins';
    } catch (e) {
      return 'Error calculating duration';
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserId();
    loadBreakRecords();
    loadBreakStatus();
    _fetchBreaksAndTypes();
    log('BreakTypeController Initialized');

    // Start a timer that updates summary data every second
    _summaryUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateBreakSummaries();
    });
  }

  // Method to update break summaries
  void _updateBreakSummaries() {
    if (mounted) {
      final daily = _calculateDailyBreakSeconds();
      final monthly = _calculateMonthlyBreakSeconds();

      // Update the observable values
      dailyBreakSecondsTotal.value = daily;
      monthlyBreakSecondsTotal.value = monthly;
    }
  }

  // Calculate daily break seconds including active breaks
  int _calculateDailyBreakSeconds() {
    final now = DateTime.now();
    int total = 0;

    // First add completed breaks from API
    if (controller.breaksList.isNotEmpty) {
      total += controller.breaksList
          .where((record) {
        if (record.endDate == null) return false;
        try {
          final date = DateTime.parse(record.startDate!);
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        } catch (e) {
          return false;
        }
      })
          .fold(0, (sum, record) => sum + (record.duration ?? 0));
    }

    // Then add from local records
    total += breakRecords
        .where((record) {
      if (record['userId'] != userId) return false;
      try {
        final date = DateTime.parse(record['start']);
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      } catch (e) {
        return false;
      }
    })
        .fold(0, (sum, record) => sum + (record['duration'] as int));

    // Add currently active breaks
    activeBreaks.forEach((type, isActive) {
      if (isActive && breakTypeStartTimes[type] != null) {
        final startTime = breakTypeStartTimes[type]!;
        final today = DateTime(now.year, now.month, now.day);
        final startDate = DateTime(startTime.year, startTime.month, startTime.day);

        if (today.isAtSameMomentAs(startDate)) {
          total += breakTypeElapsedSeconds[type] ?? 0;
        }
      }
    });

    // Add active quick break if it's today
    if (isQuickBreak && quickBreakStart != null) {
      final startDate = DateTime(
          quickBreakStart!.year,
          quickBreakStart!.month,
          quickBreakStart!.day
      );
      final today = DateTime(now.year, now.month, now.day);

      if (today.isAtSameMomentAs(startDate)) {
        total += quickElapsedSeconds;
      }
    }

    // Add active meal break if it's today
    if (isMealBreak && mealBreakStart != null) {
      final startDate = DateTime(
          mealBreakStart!.year,
          mealBreakStart!.month,
          mealBreakStart!.day
      );
      final today = DateTime(now.year, now.month, now.day);

      if (today.isAtSameMomentAs(startDate)) {
        total += mealElapsedSeconds;
      }
    }

    return total;
  }

  // Calculate monthly break seconds including active breaks
  int _calculateMonthlyBreakSeconds() {
    final now = DateTime.now();
    int total = 0;

    // First add completed breaks from API
    if (controller.breaksList.isNotEmpty) {
      total += controller.breaksList
          .where((record) {
        if (record.endDate == null) return false;
        try {
          final date = DateTime.parse(record.startDate!);
          return date.year == now.year && date.month == now.month;
        } catch (e) {
          return false;
        }
      })
          .fold(0, (sum, record) => sum + (record.duration ?? 0));
    }

    // Then add from local records
    total += breakRecords
        .where((record) {
      if (record['userId'] != userId) return false;
      try {
        final date = DateTime.parse(record['start']);
        return date.year == now.year && date.month == now.month;
      } catch (e) {
        return false;
      }
    })
        .fold(0, (sum, record) => sum + (record['duration'] as int));

    // Add currently active breaks
    activeBreaks.forEach((type, isActive) {
      if (isActive && breakTypeStartTimes[type] != null) {
        final startTime = breakTypeStartTimes[type]!;
        final currentMonth = DateTime(now.year, now.month);
        final startMonth = DateTime(startTime.year, startTime.month);

        if (currentMonth.isAtSameMomentAs(startMonth)) {
          total += breakTypeElapsedSeconds[type] ?? 0;
        }
      }
    });

    // Add active quick break if it's this month
    if (isQuickBreak && quickBreakStart != null) {
      final startMonth = DateTime(quickBreakStart!.year, quickBreakStart!.month);
      final currentMonth = DateTime(now.year, now.month);

      if (currentMonth.isAtSameMomentAs(startMonth)) {
        total += quickElapsedSeconds;
      }
    }

    // Add active meal break if it's this month
    if (isMealBreak && mealBreakStart != null) {
      final startMonth = DateTime(mealBreakStart!.year, mealBreakStart!.month);
      final currentMonth = DateTime(now.year, now.month);

      if (currentMonth.isAtSameMomentAs(startMonth)) {
        total += mealElapsedSeconds;
      }
    }

    return total;
  }

  // Add this method to get userId
  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
    });
    log('User ID loaded: $userId');
  }

  Future<void> _fetchBreaksAndTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId'); // Get the stored user ID

    if (userId != null) {
      // Fetch breaks for the logged-in user
      await controller.fetchBreaks(userId);
      await getLpBreakTypesController.fetchLpBreakTypes(); // Fetch break types
      _updateBreakSummaries(); // Update summaries after fetching
    } else {
      log('User ID not found. Cannot fetch breaks.');
    }
  }

  void loadBreakRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('breakRecords');
    if (data != null) {
      setState(() {
        breakRecords = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
      _updateBreakSummaries(); // Update summaries after loading records
    }
  }

  void saveBreakRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('breakRecords', jsonEncode(breakRecords));
    _updateBreakSummaries(); // Update summaries after saving records
  }

  void saveBreakStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save general break status
    await prefs.setBool('isQuickBreak', isQuickBreak);
    await prefs.setBool('isMealBreak', isMealBreak);
    await prefs.setInt('quickElapsedSeconds', quickElapsedSeconds);
    await prefs.setInt('mealElapsedSeconds', mealElapsedSeconds);

    // Save the status of all break types
    for (var breakType in getLpBreakTypesController.breakTypes) {
      final typeName = breakType.name;
      await prefs.setBool(
        'isActive_$typeName',
        activeBreaks[typeName] ?? false,
      );
      await prefs.setInt(
        'elapsed_$typeName',
        breakTypeElapsedSeconds[typeName] ?? 0,
      );

      if (breakTypeStartTimes[typeName] != null) {
        await prefs.setString(
          'startTime_$typeName',
          breakTypeStartTimes[typeName]!.toIso8601String(),
        );
      } else {
        await prefs.remove('startTime_$typeName');
      }
    }

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

    // Let's delay loading other break types until API data is loaded
    ever(getLpBreakTypesController.breakTypes, (_) {
      loadAllBreakTypesStatus(prefs);
    });

    if (isQuickBreak) startQuickTimer();
    if (isMealBreak) startMealTimer();

    _updateBreakSummaries(); // Update summaries after loading status
  }

  void loadAllBreakTypesStatus(SharedPreferences prefs) {
    for (var breakType in getLpBreakTypesController.breakTypes) {
      final typeName = breakType.name;

      // Load active status
      activeBreaks["$typeName"] = prefs.getBool('isActive_$typeName') ?? false;

      // Load elapsed seconds
      breakTypeElapsedSeconds["$typeName"] =
          prefs.getInt('elapsed_$typeName') ?? 0;

      // Load start time
      String? startTimeStr = prefs.getString('startTime_$typeName');
      if (startTimeStr != null) {
        breakTypeStartTimes["$typeName"] = DateTime.parse(startTimeStr);
      }

      // Restart timer if break is active
      if (activeBreaks[typeName] == true) {
        startBreakTypeTimer(typeName!);
      }
    }

    _updateBreakSummaries(); // Update summaries after loading break types
  }

  bool isWithinAllowedBreakTime() {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final currentDay = now.weekday;

    // Monday to Friday restrictions
    if (currentDay >= DateTime.monday && currentDay <= DateTime.friday) {
      // General break times (7 PM to 4 AM)
      final isWithinGeneralBreakTime = currentHour >= 19 || currentHour < 4;

      // Restricted periods (7-8 PM, 11 PM-2 AM)
      final is7to8PM = currentHour == 19;
      final is11PMto2AM = currentHour >= 23 || currentHour < 2;

      // Meal break only allowed 12 AM to 1 AM
      final isMealBreakTime = currentHour == 0; // 12 AM to 1 AM

      // Check if current time is during a restricted period
      if (is7to8PM || is11PMto2AM) {
        return false;
      }

      return isWithinGeneralBreakTime;
    }
    // Saturday restrictions
    else if (currentDay == DateTime.saturday) {
      // General break times (11 AM to 6 PM)
      final isWithinGeneralBreakTime = currentHour >= 11 && currentHour < 18;

      // Restricted periods (12 AM-2 AM, 10-11 AM, 1:30-4:30 PM)
      final is12AMto2AM = currentHour >= 0 && currentHour < 2;
      final is10to11AM = currentHour == 10;
      final is1_30to4_30PM = (currentHour == 13 && currentMinute >= 30) ||
          (currentHour > 13 && currentHour < 16) ||
          (currentHour == 16 && currentMinute < 30);

      // Check if current time is during a restricted period
      if (is12AMto2AM || is10to11AM || is1_30to4_30PM) {
        return false;
      }

      return isWithinGeneralBreakTime;
    }
    // Sunday - no breaks allowed
    return false;
  }

  String currentBreakTimeMessage() {
    final now = DateTime.now();
    final currentDay = now.weekday;

    if (currentDay >= DateTime.monday && currentDay <= DateTime.friday) {
      return "Breaks allowed between 7 PM to 4 AM (except 7-8 PM, 11 PM-2 AM). Meal break only 12 AM-1 AM";
    } else if (currentDay == DateTime.saturday) {
      return "Breaks allowed between 11 AM to 6 PM (except 12 AM-2 AM, 10-11 AM, 1:30-4:30 PM)";
    } else {
      return "No breaks allowed on Sunday";
    }
  }

  // Check if any break is currently active
  bool isAnyBreakActive() {
    // Check quick break
    if (isQuickBreak) return true;

    // Check meal break
    if (isMealBreak) return true;

    // Check all other break types
    return activeBreaks.values.any((isActive) => isActive);
  }

  void startBreak() {
    if (!isWithinAllowedBreakTime()) {
      Get.snackbar(
          "Break Not Allowed",
          currentBreakTimeMessage(),
          backgroundColor: AppColors.redColor,
          colorText: AppColors.whiteTheme
      );
      return;
    }

    // Check if any break is already active
    if (isAnyBreakActive()) {
      Get.snackbar(
          "Break Already Active",
          "Please end your current break before starting a new one",
          backgroundColor: AppColors.appColor,
          colorText: AppColors.whiteTheme
      );
      return;
    }

    final selectedType = getLpBreakTypesController.selectedBreakType.value;
    if (selectedType.isEmpty) {
      Get.snackbar(
          "Error",
          "Please select a break type first",
          backgroundColor: AppColors.redColor,
          colorText: AppColors.whiteTheme
      );
      return;
    }

    startBreakByType(selectedType);
  }

  void startBreakByType(String breakType) {
    final now = DateTime.now();

    // Initialize the maps if keys don't exist yet
    activeBreaks[breakType] = true;
    breakTypeElapsedSeconds[breakType] = 0;
    breakTypeStartTimes[breakType] = now;

    startBreakTypeTimer(breakType);
    saveBreakStatus();
    _updateBreakSummaries(); // Update summaries when starting a break

    // Save to API using controller
    final Map<String, dynamic> breakData = {
      'userId': userId, // Add user ID to the break data
      'breakType': breakType,
      'startTime': now.toIso8601String(),
      'endTime': null,
      'duration': 0,
      'status': 'Started',
    };

    saveLpBreaksController.saveLpBreaks(breakData).then((_) {
      // Refresh the breaks list after saving
      if (userId != null) {
        controller.fetchBreaks(userId!);
      }
    });

    Get.snackbar(
      breakType,
      "$breakType started",
      backgroundColor: AppColors.orangeShade,
    );
  }

  void startBreakTypeTimer(String breakType) {
    breakTypeTimers[breakType]?.cancel();
    breakTypeTimers[breakType] = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Check if widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          final seconds = breakTypeElapsedSeconds[breakType] ?? 0;
          breakTypeElapsedSeconds[breakType] = seconds + 1;
        });

        // Update summary when timer is updated
        if ((breakTypeElapsedSeconds[breakType] ?? 0) % 5 == 0) {
          _updateBreakSummaries();
        }

        if ((breakTypeElapsedSeconds[breakType] ?? 0) % 10 == 0)
          saveBreakStatus();
      } else {
        // Widget is no longer mounted, cancel the timer
        timer.cancel();
        breakTypeTimers[breakType] = null;
      }
    });
  }

  void endBreak() {
    final selectedType = getLpBreakTypesController.selectedBreakType.value;
    if (selectedType.isEmpty) {
      return;
    }

    endBreakByType(selectedType);
  }

  void endBreakByType(String breakType) {
    if (breakTypeStartTimes[breakType] != null) {
      final endTime = DateTime.now();
      final duration =
          endTime.difference(breakTypeStartTimes[breakType]!).inSeconds;

      // Save to API using controller
      final Map<String, dynamic> breakData = {
        'userId': userId, // Include userId when ending a break
        'breakType': breakType,
        'startTime': breakTypeStartTimes[breakType]!.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'duration': duration,
        'status': 'Completed',
      };

      saveLpBreaksController.saveLpBreaks(breakData).then((_) {
        // Refresh the breaks list after saving
        if (userId != null) {
          controller.fetchBreaks(userId!);
        }
      });

      setState(() {
        breakRecords.add({
          'userId': userId, // Include userId in break record
          'type': breakType,
          'start': breakTypeStartTimes[breakType].toString(),
          'end': endTime.toString(),
          'duration': duration,
        });
        breakRecords.sort(
              (a, b) =>
              DateTime.parse(b['start']).compareTo(DateTime.parse(a['start'])),
        );

        activeBreaks[breakType] = false;
        breakTypeStartTimes[breakType] = null;
        breakTypeTimers[breakType]?.cancel();
        breakTypeTimers[breakType] = null;
      });

      saveBreakRecords();
      saveBreakStatus();
      _updateBreakSummaries(); // Update summaries when ending a break

      Get.snackbar(
        "$breakType ended",
        "Duration: ${formatFullTime(duration)}",
        backgroundColor: AppColors.redColor,
      );
    }
  }

  void startQuickBreak() {
    // Check if any break is already active
    if (isAnyBreakActive()) {
      Get.snackbar(
          "Break Already Active",
          "Please end your current break before starting a new one",
          backgroundColor: AppColors.appColor,
          colorText: AppColors.whiteTheme
      );
      return;
    }

    final now = DateTime.now();

    setState(() {
      isQuickBreak = true;
      quickBreakStart = now;
      quickElapsedSeconds = 0;
    });

    startQuickTimer();
    saveBreakStatus();
    _updateBreakSummaries(); // Update summaries when starting quick break

    // Save to API using controller
    final Map<String, dynamic> breakData = {
      'userId': userId, // Include userId for quick break
      'breakType': 'Quick Break',
      'startTime': now.toIso8601String(),
      'endTime': null,
      'duration': 0,
      'status': 'Started',
    };

    saveLpBreaksController.saveLpBreaks(breakData).then((_) {
      // Refresh the breaks list after saving
      if (userId != null) {
        controller.fetchBreaks(userId!);
      }
    });

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
        'userId': userId, // Include userId when ending quick break
        'breakType': 'Quick Break',
        'startTime': quickBreakStart!.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'duration': duration,
        'status': 'Completed',
      };

      saveLpBreaksController.saveLpBreaks(breakData).then((_) {
        // Refresh the breaks list after saving
        if (userId != null) {
          controller.fetchBreaks(userId!);
        }
      });

      setState(() {
        breakRecords.add({
          'userId': userId, // Include userId in break record
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
        _quickTimer = null;
      });
      saveBreakRecords();
      saveBreakStatus();
      _updateBreakSummaries(); // Update summaries when ending quick break

      Get.snackbar(
        "Quick break ended",
        "Duration: ${formatFullTime(duration)}",
        backgroundColor: AppColors.appColor,
      );
    }
  }

  void startMealBreak() {
    // Check if any break is already active
    if (isAnyBreakActive()) {
      Get.snackbar(
          "Break Already Active",
          "Please end your current break before starting a new one",
          backgroundColor: AppColors.appColor,
          colorText: AppColors.whiteTheme
      );
      return;
    }

    // Check if meal break is allowed at this time (only 12 AM to 1 AM on weekdays)
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentDay = now.weekday;

    if (currentDay >= DateTime.monday && currentDay <= DateTime.friday) {
      if (currentHour != 0) { // 12 AM to 1 AM
        Get.snackbar(
            "Meal Break Not Allowed",
            "Meal breaks are only allowed from 12 AM to 1 AM on weekdays",
            backgroundColor: AppColors.appColor,
            colorText: AppColors.whiteTheme
        );
        return;
      }
    } else {
      // No meal breaks on weekends
      Get.snackbar(
          "Meal Break Not Allowed",
          "Meal breaks are not allowed on weekends",
          backgroundColor: AppColors.appColor,
          colorText: AppColors.whiteTheme
      );
      return;
    }

    setState(() {
      isMealBreak = true;
      mealBreakStart = now;
      mealElapsedSeconds = 0;
    });

    startMealTimer();
    saveBreakStatus();
    _updateBreakSummaries(); // Update summaries when starting meal break

    // Save to API using controller
    final Map<String, dynamic> breakData = {
      'userId': userId, // Include userId for meal break
      'breakType': 'Meal Break',
      'startTime': now.toIso8601String(),
      'endTime': null,
      'duration': 0,
      'status': 'Started',
    };

    saveLpBreaksController.saveLpBreaks(breakData).then((_) {
      // Refresh the breaks list after saving
      if (userId != null) {
        controller.fetchBreaks(userId!);
      }
    });

    Get.snackbar(
      "Meal Break",
      "Meal break started",
      backgroundColor: AppColors.greenColor,
    );
  }

  void endMealBreak() {
    if (mealBreakStart != null) {
      final endTime = DateTime.now();
      final duration = endTime.difference(mealBreakStart!).inSeconds;

      // Save to API using controller
      final Map<String, dynamic> breakData = {
        'userId': userId, // Include userId when ending meal break
        'breakType': 'Meal Break',
        'startTime': mealBreakStart!.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'duration': duration,
        'status': 'Completed',
      };

      saveLpBreaksController.saveLpBreaks(breakData).then((_) {
        // Refresh the breaks list after saving
        if (userId != null) {
          controller.fetchBreaks(userId!);
        }
      });

      setState(() {
        breakRecords.add({
          'userId': userId, // Include userId in break record
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
        _mealTimer = null;
      });
      saveBreakRecords();
      saveBreakStatus();
      _updateBreakSummaries(); // Update summaries when ending meal break

      Get.snackbar(
        "Meal break ended",
        "Duration: ${formatFullTime(duration)}",
        backgroundColor: AppColors.appColor,
      );
    }
  }

  void startQuickTimer() {
    _quickTimer?.cancel();
    _quickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => quickElapsedSeconds++);

        // Update summaries periodically for active breaks
        if (quickElapsedSeconds % 5 == 0) {
          _updateBreakSummaries();
        }

        if (quickElapsedSeconds % 10 == 0) saveBreakStatus();
      } else {
        timer.cancel();
        _quickTimer = null;
      }
    });
  }

  void startMealTimer() {
    _mealTimer?.cancel();
    _mealTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => mealElapsedSeconds++);

        // Update summaries periodically for active breaks
        if (mealElapsedSeconds % 5 == 0) {
          _updateBreakSummaries();
        }

        if (mealElapsedSeconds % 10 == 0) saveBreakStatus();
      } else {
        timer.cancel();
        _mealTimer = null;
      }
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

  int getActiveBreakSeconds(String breakType) {
    return breakTypeElapsedSeconds[breakType] ?? 0;
  }

  double getActiveBreakPercent(String breakType) {
    final seconds = getActiveBreakSeconds(breakType);
    // Default to Quick Break limit (10 mins) if unknown
    int maxDuration = 600; // 10 minutes = 600 seconds

    // You can extend this with a map of break types to their max durations
    if (breakType == 'Meal Break') {
      maxDuration = 3600; // 1 hour = 3600 seconds
    }

    return seconds / maxDuration;
  }

  bool isBreakActiveByType(String breakType) {
    return activeBreaks[breakType] ?? false;
  }

  @override
  void dispose() {
    // Cancel the summary update timer
    _summaryUpdateTimer?.cancel();
    _summaryUpdateTimer = null;

    // Cancel quick and meal timers
    _quickTimer?.cancel();
    _quickTimer = null;
    _mealTimer?.cancel();
    _mealTimer = null;

    // Cancel all break type timers and clear the map
    breakTypeTimers.forEach((type, timer) {
      timer?.cancel();
      breakTypeTimers[type] = null;
    });
    breakTypeTimers.clear();

    super.dispose();
  }

  Future<void> _handleRefresh() async {
    try {
      if (userId != null) {
        await controller.fetchBreaks(userId!);
        await getLpBreakTypesController.fetchLpBreakTypes();
        _updateBreakSummaries();
      }
    } catch (e) {
      log('Refresh error: $e');
      Get.snackbar(
        "Error",
        "Failed to refresh data",
        backgroundColor: AppColors.redColor,
        colorText: AppColors.whiteTheme,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = getLpBreakTypesController.selectedBreakType.value;
    final isBreakActive =
        selectedType.isNotEmpty && isBreakActiveByType(selectedType);

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
      body: Obx(
            () => Stack(
          children: [
            RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColors.appColor,
              backgroundColor: AppColors.whiteTheme,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
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
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (getLpBreakTypesController.breakTypes.isEmpty) {
                                return const Text("No break types found");
                              }

                              return DropdownButton<String>(
                                value:
                                getLpBreakTypesController
                                    .selectedBreakType
                                    .value
                                    .isEmpty
                                    ? null
                                    : getLpBreakTypesController
                                    .selectedBreakType
                                    .value,
                                isExpanded: true,
                                hint: const Text("Select Break Type"),
                                underline: const SizedBox(),
                                items:
                                getLpBreakTypesController.breakTypes.map((
                                    type,
                                    ) {
                                  return DropdownMenuItem<String>(
                                    value: type.name,
                                    child: Text("${type.name}"),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  if (newValue != null && !isAnyBreakActive()) {
                                    getLpBreakTypesController
                                        .selectedBreakType
                                        .value = newValue;
                                  } else if (isAnyBreakActive()) {
                                    Get.snackbar(
                                        "Break Active",
                                        "Cannot change break type while a break is active",
                                        backgroundColor: AppColors.redColor,
                                        colorText: AppColors.whiteTheme
                                    );
                                  }
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
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Obx(() {
                                        final type =
                                            getLpBreakTypesController
                                                .selectedBreakType
                                                .value;
                                        return Text(
                                          type.isEmpty
                                              ? "Select Break Type"
                                              : type,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }),
                                      Obx(() {
                                        final type =
                                            getLpBreakTypesController
                                                .selectedBreakType
                                                .value;
                                        if (type.isEmpty)
                                          return const Text("00:00");

                                        return Text(
                                          formatTime(getActiveBreakSeconds(type)),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Obx(() {
                                    final type =
                                        getLpBreakTypesController
                                            .selectedBreakType
                                            .value;
                                    if (type.isEmpty) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: LinearProgressIndicator(
                                          value: 0,
                                          backgroundColor: Colors.grey[200],
                                          color: AppColors.appColor,
                                          minHeight: 10,
                                        ),
                                      );
                                    }

                                    final percent = getActiveBreakPercent(type);
                                    final isOvertime =
                                        (type == 'Quick Break' &&
                                            getActiveBreakSeconds(type) > 600) ||
                                            (type == 'Meal Break' &&
                                                getActiveBreakSeconds(type) > 3600);

                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: LinearProgressIndicator(
                                        value: percent,
                                        backgroundColor: Colors.grey[200],
                                        color:
                                        isOvertime
                                            ? Colors.red
                                            : AppColors.appColor,
                                        minHeight: 10,
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 5),
                                  Obx(() {
                                    final selectedType =
                                        getLpBreakTypesController
                                            .selectedBreakType
                                            .value;
                                    final isActive =
                                        selectedType.isNotEmpty &&
                                            isBreakActiveByType(selectedType);

                                    return SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed:
                                        selectedType.isEmpty
                                            ? null
                                            : (isActive
                                            ? endBreak
                                            : startBreak),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                          isActive
                                              ? AppColors.redColor
                                              : AppColors.appColor,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          isActive ? "STOP BREAK" : "START BREAK",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
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

                    // THIS IS THE FIXED PART - Setting a fixed height for the ListView
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      height: 300, // Fixed height for the ListView
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (controller.breaksList.isEmpty) {
                          return const Center(child: Text("No break records yet"));
                        }

                        return ListView.builder(
                          shrinkWrap: true, // Make the ListView adapt to its content
                          physics: const AlwaysScrollableScrollPhysics(), // Allow scrolling
                          itemCount: controller.breaksList.length,
                          itemBuilder: (context, index) {
                            final record = controller.breaksList[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              color: AppColors.appColor,
                              child: ListTile(
                                title: Text(
                                  "${record.type}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.whiteTheme,
                                  ),
                                ),
                                subtitle: Text(
                                  "Start: ${record.startDate}\nEnd: ${record.endDate ?? 'In progress'}",
                                  style: const TextStyle(color: AppColors.whiteTheme),
                                ),
                                trailing: Text(
                                  _calculateDuration(record.startDate, record.endDate),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.whiteTheme,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            // Loading overlay
            if (saveLpBreaksController.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}