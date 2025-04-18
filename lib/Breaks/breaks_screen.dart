import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';

class BreaksScreen extends StatefulWidget {
  const BreaksScreen({super.key});

  @override
  State<BreaksScreen> createState() => _BreaksScreenState();
}

class _BreaksScreenState extends State<BreaksScreen> {
  Timer? quickBreakTimer;
  Timer? mealBreakTimer;
  Timer? autoSaveTimer; // Timer for periodic auto-saving

  int quickBreakSeconds = 0;
  int mealBreakSeconds = 0;

  int dailyBreakMinutes = 0;
  int monthlyBreakMinutes = 0;

  bool isQuickBreakActive = false;
  bool isMealBreakActive = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  // Use local assets instead of URLs
  final String startSoundAsset = 'assets/sounds/ringtune.mpeg';
  final String endSoundAsset = 'assets/sounds/ringtune.mpeg';

  // SharedPreferences keys
  static const String keyDailyBreakMinutes = "daily_break_minutes";
  static const String keyMonthlyBreakMinutes = "monthly_break_minutes";
  static const String keyLastBreakDate = "last_break_date";
  static const String keyQuickBreakSeconds = "quick_break_seconds";
  static const String keyMealBreakSeconds = "meal_break_seconds";
  static const String keyQuickBreakActive = "quick_break_active";
  static const String keyMealBreakActive = "meal_break_active";

  @override
  void initState() {
    super.initState();
    loadAllData();

    // Set up auto-save timer to save data every 30 seconds
    autoSaveTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      saveAllData();
    });
  }

  Future<void> loadAllData() async {
    await loadBreakData();
    await loadBreakTimers();
    checkDateForReset();
  }

  Future<void> loadBreakData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        dailyBreakMinutes = prefs.getInt(keyDailyBreakMinutes) ?? 0;
        monthlyBreakMinutes = prefs.getInt(keyMonthlyBreakMinutes) ?? 0;
      });
    } catch (e) {
      debugPrint("Error loading break data: $e");
      // Use default values if loading fails
      dailyBreakMinutes = 0;
      monthlyBreakMinutes = 0;
    }
  }

  Future<void> loadBreakTimers() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Load break timers state
      quickBreakSeconds = prefs.getInt(keyQuickBreakSeconds) ?? 0;
      mealBreakSeconds = prefs.getInt(keyMealBreakSeconds) ?? 0;

      bool wasQuickBreakActive = prefs.getBool(keyQuickBreakActive) ?? false;
      bool wasMealBreakActive = prefs.getBool(keyMealBreakActive) ?? false;

      // Restart timers if they were active
      if (wasQuickBreakActive) {
        setState(() {
          isQuickBreakActive = true;
        });
        restartQuickBreakTimer();
      }

      if (wasMealBreakActive) {
        setState(() {
          isMealBreakActive = true;
        });
        restartMealBreakTimer();
      }

    } catch (e) {
      debugPrint("Error loading timer data: $e");
    }
  }

  Future<void> saveAllData() async {
    await saveBreakData();
    await saveTimerState();
  }

  Future<void> saveBreakData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(keyDailyBreakMinutes, dailyBreakMinutes);
      await prefs.setInt(keyMonthlyBreakMinutes, monthlyBreakMinutes);
      await prefs.setString(keyLastBreakDate, DateFormat('yyyy-MM-dd').format(DateTime.now()));
    } catch (e) {
      debugPrint("Error saving break data: $e");
      Get.snackbar(
        "Save Error",
        "Failed to save break data. Please try again.",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> saveTimerState() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Save current timer values
      await prefs.setInt(keyQuickBreakSeconds, quickBreakSeconds);
      await prefs.setInt(keyMealBreakSeconds, mealBreakSeconds);

      // Save timer active states
      await prefs.setBool(keyQuickBreakActive, isQuickBreakActive);
      await prefs.setBool(keyMealBreakActive, isMealBreakActive);

    } catch (e) {
      debugPrint("Error saving timer state: $e");
    }
  }

  Future<void> checkDateForReset() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String lastDate = prefs.getString(keyLastBreakDate) ?? today;

      if (lastDate != today) {
        // Day changed, transfer daily to monthly and reset daily
        monthlyBreakMinutes += dailyBreakMinutes;
        dailyBreakMinutes = 0;
        await saveBreakData();

        // New day, reset timers if needed
        if (isQuickBreakActive) {
          endQuickBreak(autoEnd: true);
        }

        if (isMealBreakActive) {
          endMealBreak(autoEnd: true);
        }
      }

      // Check for month change
      DateTime lastDateTime = DateFormat('yyyy-MM-dd').parse(lastDate);
      DateTime todayDateTime = DateFormat('yyyy-MM-dd').parse(today);

      if (lastDateTime.month != todayDateTime.month) {
        // Month changed, reset monthly counter
        monthlyBreakMinutes = 0;
        await saveBreakData();
      }

    } catch (e) {
      debugPrint("Error checking date for reset: $e");
    }
  }

  bool isWithinAllowedTime() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final currentTime = hour * 60 + minute;
    final startTime = 19 * 60; // 7 PM
    final endTime = 4 * 60;   // 4 AM
    return currentTime >= startTime || currentTime < endTime;
  }

  void playSound(String assetPath) async {
    try {
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint("Error playing sound: $e");
      // Silent failure - don't let sound errors affect the app's main functionality
    }
  }

  void startQuickBreak() {
    if (!isWithinAllowedTime()) {
      Get.snackbar("Not Allowed", "Breaks are allowed only between 7 PM to 4 AM.",
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    quickBreakTimer?.cancel();
    quickBreakSeconds = 0;
    setState(() {
      isQuickBreakActive = true;
    });

    saveTimerState();
    playSound(startSoundAsset);

    Get.snackbar("Quick Break Started", "Your quick break has started.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
    );

    restartQuickBreakTimer();
  }

  void restartQuickBreakTimer() {
    quickBreakTimer?.cancel();

    quickBreakTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        quickBreakSeconds++;
      });

      if (quickBreakSeconds > 600) {
        quickBreakTimer?.cancel();
        setState(() {
          isQuickBreakActive = false;
        });

        dailyBreakMinutes += (quickBreakSeconds / 60).floor();
        saveAllData();

        playSound(endSoundAsset);

        Get.snackbar("Quick Break Time Over", "Exceeded time limit (10 minutes).",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    });
  }

  void endQuickBreak({bool autoEnd = false}) {
    if (!isQuickBreakActive) return;

    quickBreakTimer?.cancel();
    setState(() {
      isQuickBreakActive = false;
    });

    dailyBreakMinutes += (quickBreakSeconds / 60).floor();
    saveAllData();

    if (!autoEnd) {
      playSound(endSoundAsset);

      Get.snackbar("Quick Break Ended", "Your quick break has ended.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  void startMealBreak() {
    if (!isWithinAllowedTime()) {
      Get.snackbar("Not Allowed", "Breaks are allowed only between 7 PM to 4 AM.",
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    mealBreakTimer?.cancel();
    mealBreakSeconds = 0;
    setState(() {
      isMealBreakActive = true;
    });

    saveTimerState();
    playSound(startSoundAsset);

    Get.snackbar("Meal Break Started", "Your meal break has started.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
    );

    restartMealBreakTimer();
  }

  void restartMealBreakTimer() {
    mealBreakTimer?.cancel();

    mealBreakTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        mealBreakSeconds++;
      });

      if (mealBreakSeconds > 3600) {
        mealBreakTimer?.cancel();
        setState(() {
          isMealBreakActive = false;
        });

        dailyBreakMinutes += (mealBreakSeconds / 60).floor();
        saveAllData();

        playSound(endSoundAsset);

        Get.snackbar("Meal Break Time Over", "Exceeded time limit (60 minutes).",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    });
  }

  void endMealBreak({bool autoEnd = false}) {
    if (!isMealBreakActive) return;

    mealBreakTimer?.cancel();
    setState(() {
      isMealBreakActive = false;
    });

    dailyBreakMinutes += (mealBreakSeconds / 60).floor();
    saveAllData();

    if (!autoEnd) {
      playSound(endSoundAsset);

      Get.snackbar("Meal Break Ended", "Your meal break has ended.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  String formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    // Save data before disposing
    saveAllData();

    // Cancel all timers
    quickBreakTimer?.cancel();
    mealBreakTimer?.cancel();
    autoSaveTimer?.cancel();

    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double quickPercent = quickBreakSeconds / 600;
    double mealPercent = mealBreakSeconds / 3600;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Quick Break (QB)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      if (!isQuickBreakActive)
                        ElevatedButton(
                          onPressed: startQuickBreak,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text("Start", style: TextStyle(color: Colors.white)),
                        )
                      else
                        ElevatedButton(
                          onPressed: endQuickBreak,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text("End", style: TextStyle(color: Colors.white)),
                        ),
                      SizedBox(width: 8),
                      Text(formatTime(quickBreakSeconds), style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              BreakProgressBar(
                label: "Quick Break",
                progress: quickPercent,
                isExceeded: quickBreakSeconds > 600,
                timeText: formatTime(quickBreakSeconds),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Meal Break (MB)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      if (!isMealBreakActive)
                        ElevatedButton(
                          onPressed: startMealBreak,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text("Start", style: TextStyle(color: Colors.white)),
                        )
                      else
                        ElevatedButton(
                          onPressed: endMealBreak,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text("End", style: TextStyle(color: Colors.white)),
                        ),
                      SizedBox(width: 8),
                      Text(formatTime(mealBreakSeconds), style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              BreakProgressBar(
                label: "Meal Break",
                progress: mealPercent,
                isExceeded: mealBreakSeconds > 3600,
                timeText: formatTime(mealBreakSeconds),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Break Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      Text("Today's Total Break: $dailyBreakMinutes min",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      SizedBox(height: 8),
                      Text("This Month's Total Break: ${(monthlyBreakMinutes / 60).toStringAsFixed(2)} hr",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Center(
                child: ElevatedButton.icon(
                  onPressed: saveAllData,
                  icon: Icon(Icons.save),
                  label: Text("Save Break Data"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class BreakProgressBar extends StatelessWidget {
  final String label;
  final double progress;
  final bool isExceeded;
  final String timeText;

  const BreakProgressBar({
    super.key,
    required this.label,
    required this.progress,
    required this.isExceeded,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label Progress",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isExceeded ? Colors.red : Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              isExceeded ? Colors.red : Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}