import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:attendance/prefs/sharedPreferences.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import '../../AppColors/app_colors.dart';
import '../../Controllers/get_breaks_controller.dart';
import '../../Controllers/get_lp_break_type.dart';
import '../../Controllers/save_lp_breaks_controller.dart';

class BreakTrackerScreen extends StatefulWidget {
  const BreakTrackerScreen({super.key});

  @override
  _BreakTrackerScreenState createState() => _BreakTrackerScreenState();
}

class _BreakTrackerScreenState extends State<BreakTrackerScreen> with WidgetsBindingObserver {
  bool isQuickBreak = false;
  int get dailyBreakSeconds => dailyBreakSecondsTotal.value;
  int get monthlyBreakSeconds => monthlyBreakSecondsTotal.value;
  bool isMealBreak = false;
  DateTime? quickBreakStart;
  DateTime? mealBreakStart;
  List<Map<String, dynamic>> breakRecords = [];
  SaveLpBreaksController saveLpBreaksController = Get.put(SaveLpBreaksController());
  GetLpBreakTypesController getLpBreakTypesController = Get.put(GetLpBreakTypesController());
  final GetBreaksController controller = Get.put(GetBreaksController());

  // RxInt values to track break statistics (using GetX observables for reactive updates)
  final RxInt dailyBreakSecondsTotal = 0.obs;
  final RxInt monthlyBreakSecondsTotal = 0.obs;

  // Store user ID
  int? userId;

  // Break tracking maps
  Map<String, int> breakTypeElapsedSeconds = {};
  Map<String, DateTime?> breakTypeStartTimes = {};
  Map<String, bool> activeBreaks = {};
  Map<String, Timer?> breakTypeTimers = {};

  // Timers
  Timer? _summaryUpdateTimer;
  Timer? _quickTimer;
  Timer? _mealTimer;
  FlutterBackgroundService? _backgroundService;

  // Elapsed seconds for quick and meal breaks
  int quickElapsedSeconds = 0;
  int mealElapsedSeconds = 0;

  String _calculateDuration(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return "Invalid dates";
    try {
      DateTime start = DateTime.parse(startDate);
      DateTime end = DateTime.parse(endDate);
      Duration duration = end.difference(start);
      return '${duration.inMinutes} mins';
    } catch (e) {
      return 'Error calculating duration';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getUserId();
    loadBreakRecords();
    _fetchBreaksAndTypes();
    _initBackgroundService();
    log('BreakTypeController Initialized');
    _summaryUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateBreakSummaries();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      saveBreakStatus();
    } else if (state == AppLifecycleState.resumed) {
      loadBreakStatus();
      _fetchBreaksAndTypes();
      _updateBreakSummaries();
    }
  }

  Future<void> _initBackgroundService() async {
    _backgroundService = FlutterBackgroundService();
    var isRunning = await _backgroundService!.isRunning();
    if (!isRunning) await _backgroundService!.startService();
    _backgroundService!.on('update').listen((event) {
      if (mounted) {
        loadBreakStatus();
        _updateBreakSummaries();
      }
    });
  }

  void _updateBreakSummaries() {
    if (mounted) {
      final daily = _calculateDailyBreakSeconds();
      final monthly = _calculateMonthlyBreakSeconds();
      dailyBreakSecondsTotal.value = daily;
      monthlyBreakSecondsTotal.value = monthly;
    }
  }

  int _calculateDailyBreakSeconds() {
    final now = DateTime.now();
    int total = 0;

    if (controller.breaksList.isNotEmpty) {
      total += controller.breaksList
          .where((record) {
        if (record.endDate == null) return false;
        try {
          final date = DateTime.parse(record.startDate!);
          return date.year == now.year && date.month == now.month && date.day == now.day;
        } catch (e) {
          return false;
        }
      })
          .fold(0, (sum, record) => sum + (record.duration ?? 0));
    }

    total += breakRecords
        .where((record) {
      if (record['userId'] != userId) return false;
      try {
        final date = DateTime.parse(record['start']);
        return date.year == now.year && date.month == now.month && date.day == now.day;
      } catch (e) {
        return false;
      }
    })
        .fold(0, (sum, record) => sum + (record['duration'] as int));

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

    if (isQuickBreak && quickBreakStart != null) {
      final startDate = DateTime(quickBreakStart!.year, quickBreakStart!.month, quickBreakStart!.day);
      final today = DateTime(now.year, now.month, now.day);
      if (today.isAtSameMomentAs(startDate)) total += quickElapsedSeconds;
    }

    if (isMealBreak && mealBreakStart != null) {
      final startDate = DateTime(mealBreakStart!.year, mealBreakStart!.month, mealBreakStart!.day);
      final today = DateTime(now.year, now.month, now.day);
      if (today.isAtSameMomentAs(startDate)) total += mealElapsedSeconds;
    }

    return total;
  }

  int _calculateMonthlyBreakSeconds() {
    final now = DateTime.now();
    int total = 0;

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

    if (isQuickBreak && quickBreakStart != null) {
      final startMonth = DateTime(quickBreakStart!.year, quickBreakStart!.month);
      final currentMonth = DateTime(now.year, now.month);
      if (currentMonth.isAtSameMomentAs(startMonth)) total += quickElapsedSeconds;
    }

    if (isMealBreak && mealBreakStart != null) {
      final startMonth = DateTime(mealBreakStart!.year, mealBreakStart!.month);
      final currentMonth = DateTime(now.year, now.month);
      if (currentMonth.isAtSameMomentAs(startMonth)) total += mealElapsedSeconds;
    }

    return total;
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
    });
    log('User ID loaded: $userId');
    loadBreakStatus();
  }

  Future<void> _fetchBreaksAndTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      await controller.fetchBreaks(userId);
      await getLpBreakTypesController.fetchLpBreakTypes();
      _updateBreakSummaries();
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
      _updateBreakSummaries();
    }
  }

  void saveBreakRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('breakRecords', jsonEncode(breakRecords));
    _updateBreakSummaries();
  }

  void saveBreakStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isQuickBreak', isQuickBreak);
    await prefs.setBool('isMealBreak', isMealBreak);
    await prefs.setInt('quickElapsedSeconds', quickElapsedSeconds);
    await prefs.setInt('mealElapsedSeconds', mealElapsedSeconds);
    await prefs.setString('activeBreakTypes', jsonEncode(activeBreaks));

    for (var breakType in getLpBreakTypesController.breakTypes) {
      final typeName = breakType.name;
      if (typeName == null) continue; // Skip null names
      await prefs.setBool('isActive_$typeName', activeBreaks[typeName] ?? false);
      await prefs.setInt('elapsed_$typeName', breakTypeElapsedSeconds[typeName] ?? 0);
      if (breakTypeStartTimes[typeName] != null) {
        await prefs.setString('startTime_$typeName', breakTypeStartTimes[typeName]!.toIso8601String());
      } else {
        await prefs.remove('startTime_$typeName');
      }
    }

    if (quickBreakStart != null) {
      await prefs.setString('quickBreakStart', quickBreakStart!.toIso8601String());
    } else {
      await prefs.remove('quickBreakStart');
    }

    if (mealBreakStart != null) {
      await prefs.setString('mealBreakStart', mealBreakStart!.toIso8601String());
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
        if (isQuickBreak) startQuickTimer();
      }

      String? mealStartStr = prefs.getString('mealBreakStart');
      if (mealStartStr != null) {
        mealBreakStart = DateTime.parse(mealStartStr);
        if (isMealBreak) startMealTimer();
      }
    });

    ever(getLpBreakTypesController.breakTypes, (_) {
      loadAllBreakTypesStatus(prefs);
    });

    _updateBreakSummaries();
  }

  void loadAllBreakTypesStatus(SharedPreferences prefs) {
    for (var breakType in getLpBreakTypesController.breakTypes) {
      final typeName = breakType.name;
      if (typeName == null) {
        log('Skipping break type with null name');
        continue; // Skip this iteration if name is null
      }
      activeBreaks[typeName] = prefs.getBool('isActive_$typeName') ?? false;
      breakTypeElapsedSeconds[typeName] = prefs.getInt('elapsed_$typeName') ?? 0;
      String? startTimeStr = prefs.getString('startTime_$typeName');
      if (startTimeStr != null) {
        try {
          breakTypeStartTimes[typeName] = DateTime.parse(startTimeStr);
          if (activeBreaks[typeName] == true) startBreakTimer(typeName);
        } catch (e) {
          log('Error parsing start time for $typeName: $e');
          breakTypeStartTimes[typeName] = null;
        }
      } else {
        breakTypeStartTimes[typeName] = null;
      }
    }
    _updateBreakSummaries();
  }

  bool isWithinAllowedBreakTime() {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final currentDay = now.weekday;

    if (currentDay >= DateTime.monday && currentDay <= DateTime.friday) {
      final isWithinGeneralBreakTime = currentHour >= 19 || currentHour < 4;
      final is7to8PM = currentHour == 19;
      final is11PMto2AM = currentHour >= 23 || currentHour < 2;
      if (is7to8PM || is11PMto2AM) return false;
      return isWithinGeneralBreakTime;
    } else if (currentDay == DateTime.saturday) {
      final isWithinGeneralBreakTime = currentHour >= 11 && currentHour < 18;
      final is12AMto2AM = currentHour >= 0 && currentHour < 2;
      final is10to11AM = currentHour == 10;
      final is1_30to4_30PM = (currentHour == 13 && currentMinute >= 30) ||
          (currentHour > 13 && currentHour < 16) ||
          (currentHour == 16 && currentMinute < 30);
      if (is12AMto2AM || is10to11AM || is1_30to4_30PM) return false;
      return isWithinGeneralBreakTime;
    }
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

  bool isAnyBreakActive() {
    return isQuickBreak || isMealBreak || activeBreaks.values.any((isActive) => isActive);
  }

  void startBreak() {
    if (!isWithinAllowedBreakTime()) {
      Get.snackbar("Break Not Allowed", currentBreakTimeMessage(),
          backgroundColor: AppColors.redColor, colorText: AppColors.whiteTheme);
      return;
    }
    if (isAnyBreakActive()) {
      Get.snackbar("Break Already Active", "Please end your current break before starting a new one",
          backgroundColor: AppColors.appColor, colorText: AppColors.whiteTheme);
      return;
    }
    final selectedType = getLpBreakTypesController.selectedBreakType.value;
    if (selectedType.isEmpty) {
      Get.snackbar("Error", "Please select a break type first",
          backgroundColor: AppColors.redColor, colorText: AppColors.whiteTheme);
      return;
    }
    startBreakByType(selectedType);
  }

  void startBreakByType(String breakType) {
    final now = DateTime.now();
    activeBreaks[breakType] = true;
    breakTypeElapsedSeconds[breakType] = 0;
    breakTypeStartTimes[breakType] = now;

    startBreakTimer(breakType);
    saveBreakStatus();
    _updateBreakSummaries();

    final Map<String, dynamic> breakData = {
      'userId': userId,
      'breakType': breakType,
      'startTime': now.toIso8601String(),
      'endTime': null,
      'duration': 0,
      'status': 'Started',
    };

    saveLpBreaksController.saveLpBreaks(breakData).then((_) {
      if (userId != null) controller.fetchBreaks(userId!);
    });

    Get.snackbar(breakType, "$breakType started", backgroundColor: AppColors.orangeShade);
  }

  void startBreakTimer(String breakType) {
    breakTypeTimers[breakType]?.cancel();
    breakTypeTimers[breakType] = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          breakTypeElapsedSeconds[breakType] = (breakTypeElapsedSeconds[breakType] ?? 0) + 1;
        });
        if (breakTypeElapsedSeconds[breakType]! % 5 == 0) _updateBreakSummaries();
        if (breakTypeElapsedSeconds[breakType]! % 10 == 0) saveBreakStatus();
      } else {
        timer.cancel();
        breakTypeTimers[breakType] = null;
      }
    });
  }

  void endBreak() {
    final selectedType = getLpBreakTypesController.selectedBreakType.value;
    if (selectedType.isEmpty) return;
    endBreakByType(selectedType);
  }

  void endBreakByType(String breakType) {
    if (breakTypeStartTimes[breakType] != null) {
      final endTime = DateTime.now();
      final duration = endTime.difference(breakTypeStartTimes[breakType]!).inSeconds;

      final Map<String, dynamic> breakData = {
        'userId': userId,
        'breakType': breakType,
        'startTime': breakTypeStartTimes[breakType]!.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'duration': duration,
        'status': 'Completed',
      };

      saveLpBreaksController.saveLpBreaks(breakData).then((_) {
        if (userId != null) controller.fetchBreaks(userId!);
      });

      setState(() {
        breakRecords.add({
          'userId': userId,
          'type': breakType,
          'start': breakTypeStartTimes[breakType].toString(),
          'end': endTime.toString(),
          'duration': duration,
        });
        breakRecords.sort((a, b) => DateTime.parse(b['start']).compareTo(DateTime.parse(a['start'])));
        activeBreaks[breakType] = false;
        breakTypeStartTimes[breakType] = null;
        breakTypeTimers[breakType]?.cancel();
        breakTypeTimers[breakType] = null;
      });

      saveBreakRecords();
      saveBreakStatus();
      _updateBreakSummaries();

      Get.snackbar("$breakType ended", "Duration: ${formatFullTime(duration)}",
          backgroundColor: AppColors.redColor);
    }
  }

  void startQuickBreak() {
    if (isAnyBreakActive()) {
      Get.snackbar("Break Already Active", "Please end your current break before starting a new one",
          backgroundColor: AppColors.appColor, colorText: AppColors.whiteTheme);
      return;
    }
    if (!isWithinAllowedBreakTime()) {
      Get.snackbar("Break Not Allowed", currentBreakTimeMessage(),
          backgroundColor: AppColors.redColor, colorText: AppColors.whiteTheme);
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
    _updateBreakSummaries();

    final Map<String, dynamic> breakData = {
      'userId': userId,
      'breakType': 'Quick Break',
      'startTime': now.toIso8601String(),
      'endTime': null,
      'duration': 0,
      'status': 'Started',
    };

    saveLpBreaksController.saveLpBreaks(breakData).then((_) {
      if (userId != null) controller.fetchBreaks(userId!);
    });

    Get.snackbar("Quick Break", "Quick break started", backgroundColor: AppColors.orangeShade);
  }

  void endQuickBreak() {
    if (quickBreakStart != null) {
      final endTime = DateTime.now();
      final duration = endTime.difference(quickBreakStart!).inSeconds;

      final Map<String, dynamic> breakData = {
        'userId': userId,
        'breakType': 'Quick Break',
        'startTime': quickBreakStart!.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'duration': duration,
        'status': 'Completed',
      };

      saveLpBreaksController.saveLpBreaks(breakData).then((_) {
        if (userId != null) controller.fetchBreaks(userId!);
      });

      setState(() {
        breakRecords.add({
          'userId': userId,
          'type': 'Quick Break',
          'start': quickBreakStart.toString(),
          'end': endTime.toString(),
          'duration': duration,
        });
        breakRecords.sort((a, b) => DateTime.parse(b['start']).compareTo(DateTime.parse(a['start'])));
        isQuickBreak = false;
        quickBreakStart = null;
        _quickTimer?.cancel();
        _quickTimer = null;
      });

      saveBreakRecords();
      saveBreakStatus();
      _updateBreakSummaries();

      Get.snackbar("Quick break ended", "Duration: ${formatFullTime(duration)}",
          backgroundColor: AppColors.appColor);
    }
  }

  void startMealBreak() {
    if (isAnyBreakActive()) {
      Get.snackbar("Break Already Active", "Please end your current break before starting a new one",
          backgroundColor: AppColors.appColor, colorText: AppColors.whiteTheme);
      return;
    }

    final now = DateTime.now();
    final currentHour = now.hour;
    final currentDay = now.weekday;

    if (currentDay >= DateTime.monday && currentDay <= DateTime.friday) {
      if (currentHour != 0) {
        Get.snackbar("Meal Break Not Allowed", "Meal breaks are only allowed from 12 AM to 1 AM on weekdays",
            backgroundColor: AppColors.appColor, colorText: AppColors.whiteTheme);
        return;
      }
    } else {
      Get.snackbar("Meal Break Not Allowed", "Meal breaks are not allowed on weekends",
          backgroundColor: AppColors.appColor, colorText: AppColors.whiteTheme);
      return;
    }

    setState(() {
      isMealBreak = true;
      mealBreakStart = now;
      mealElapsedSeconds = 0;
    });

    startMealTimer();
    saveBreakStatus();
    _updateBreakSummaries();

    final Map<String, dynamic> breakData = {
      'userId': userId,
      'breakType': 'Meal Break',
      'startTime': now.toIso8601String(),
      'endTime': null,
      'duration': 0,
      'status': 'Started',
    };

    saveLpBreaksController.saveLpBreaks(breakData).then((_) {
      if (userId != null) controller.fetchBreaks(userId!);
    });

    Get.snackbar("Meal Break", "Meal break started", backgroundColor: AppColors.greenColor);
  }

  void endMealBreak() {
    if (mealBreakStart != null) {
      final endTime = DateTime.now();
      final duration = endTime.difference(mealBreakStart!).inSeconds;

      final Map<String, dynamic> breakData = {
        'userId': userId,
        'breakType': 'Meal Break',
        'startTime': mealBreakStart!.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'duration': duration,
        'status': 'Completed',
      };

      saveLpBreaksController.saveLpBreaks(breakData).then((_) {
        if (userId != null) controller.fetchBreaks(userId!);
      });

      setState(() {
        breakRecords.add({
          'userId': userId,
          'type': 'Meal Break',
          'start': mealBreakStart.toString(),
          'end': endTime.toString(),
          'duration': duration,
        });
        breakRecords.sort((a, b) => DateTime.parse(b['start']).compareTo(DateTime.parse(a['start'])));
        isMealBreak = false;
        mealBreakStart = null;
        _mealTimer?.cancel();
        _mealTimer = null;
      });

      saveBreakRecords();
      saveBreakStatus();
      _updateBreakSummaries();

      Get.snackbar("Meal break ended", "Duration: ${formatFullTime(duration)}",
          backgroundColor: AppColors.appColor);
    }
  }

  void startQuickTimer() {
    _quickTimer?.cancel();
    _quickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => quickElapsedSeconds++);
        if (quickElapsedSeconds % 5 == 0) _updateBreakSummaries();
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
        if (mealElapsedSeconds % 5 == 0) _updateBreakSummaries();
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
    int maxDuration = 600;
    if (breakType == 'Meal Break') maxDuration = 3600;
    return seconds / maxDuration;
  }

  bool isBreakActiveByType(String breakType) {
    return activeBreaks[breakType] ?? false;
  }

  @override
  void dispose() {
    _summaryUpdateTimer?.cancel();
    _quickTimer?.cancel();
    _mealTimer?.cancel();
    breakTypeTimers.forEach((type, timer) => timer?.cancel());
    breakTypeTimers.clear();
    WidgetsBinding.instance.removeObserver(this);
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
      Get.snackbar("Error", "Failed to refresh data",
          backgroundColor: AppColors.redColor, colorText: AppColors.whiteTheme);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = getLpBreakTypesController.selectedBreakType.value;
    final isBreakActive = selectedType.isNotEmpty && isBreakActiveByType(selectedType);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: AppColors.whiteTheme),
        ),
        title: const Text("Break Tracker", style: TextStyle(color: AppColors.whiteTheme)),
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
                physics: const AlwaysScrollableScrollPhysics(),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Break Summary",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.whiteTheme),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Today's Total:", style: TextStyle(fontSize: 16, color: AppColors.whiteTheme)),
                                      Text(formatFullTime(dailyBreakSeconds), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.whiteTheme)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("This Month's Total:", style: TextStyle(fontSize: 16, color: AppColors.whiteTheme)),
                                      Text(formatFullTime(monthlyBreakSeconds), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.whiteTheme)),
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
                                items: getLpBreakTypesController.breakTypes
                                    .where((type) => type.name != null) // Filter out null names
                                    .map((type) => DropdownMenuItem<String>(
                                  value: type.name,
                                  child: Text(type.name!),
                                ))
                                    .toList(),
                                onChanged: (newValue) {
                                  if (newValue != null && !isAnyBreakActive()) {
                                    getLpBreakTypesController.selectedBreakType.value = newValue;
                                  } else if (isAnyBreakActive()) {
                                    Get.snackbar("Break Active", "Cannot change break type while a break is active",
                                        backgroundColor: AppColors.redColor, colorText: AppColors.whiteTheme);
                                  }
                                },
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Obx(() {
                                        final type = getLpBreakTypesController.selectedBreakType.value;
                                        return Text(
                                          type.isEmpty ? "Select Break Type" : type,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        );
                                      }),
                                      Obx(() {
                                        final type = getLpBreakTypesController.selectedBreakType.value;
                                        if (type.isEmpty) return const Text("00:00");
                                        return Text(
                                          formatTime(getActiveBreakSeconds(type)),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        );
                                      }),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Obx(() {
                                    final type = getLpBreakTypesController.selectedBreakType.value;
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
                                    final isOvertime = (type == 'Quick Break' && getActiveBreakSeconds(type) > 600) ||
                                        (type == 'Meal Break' && getActiveBreakSeconds(type) > 3600);
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: LinearProgressIndicator(
                                        value: percent,
                                        backgroundColor: Colors.grey[200],
                                        color: isOvertime ? Colors.red : AppColors.appColor,
                                        minHeight: 10,
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 5),
                                  Obx(() {
                                    final selectedType = getLpBreakTypesController.selectedBreakType.value;
                                    final isActive = selectedType.isNotEmpty && isBreakActiveByType(selectedType);
                                    return SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: selectedType.isEmpty ? null : (isActive ? endBreak : startBreak),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isActive ? AppColors.redColor : AppColors.appColor,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: Text(
                                          isActive ? "STOP BREAK" : "START BREAK",
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.appColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (controller.breaksList.isEmpty) {
                          return const Center(child: Text("No break records yet"));
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.breaksList.length,
                          itemBuilder: (context, index) {
                            final record = controller.breaksList[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              color: AppColors.appColor,
                              child: ListTile(
                                title: Text(
                                  "${record.type}",
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.whiteTheme),
                                ),
                                subtitle: Text(
                                  "Start: ${record.startDate}\nEnd: ${record.endDate ?? 'In progress'}",
                                  style: const TextStyle(color: AppColors.whiteTheme),
                                ),
                                trailing: Text(
                                  _calculateDuration(record.startDate, record.endDate),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.whiteTheme),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
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