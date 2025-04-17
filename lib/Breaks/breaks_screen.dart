import 'dart:async';
import 'package:attendance/AppColors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class BreaksScreen extends StatefulWidget {
  const BreaksScreen({super.key});

  @override
  State<BreaksScreen> createState() => _BreaksScreenState();
}

class _BreaksScreenState extends State<BreaksScreen> {
  Timer? quickBreakTimer;
  Timer? mealBreakTimer;

  int quickBreakSeconds = 0;
  int mealBreakSeconds = 0;

  bool isQuickBreakActive = false;
  bool isMealBreakActive = false;

  // Initialize the audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Start Quick Break
  void startQuickBreak() {
    quickBreakTimer?.cancel();
    quickBreakSeconds = 0;
    isQuickBreakActive = true;

    // Play start sound
    _audioPlayer.play(AssetSource('sounds/start_sound.mp3'));

    // Show snackbar
    Get.snackbar(
      "Quick Break Started",
      "Your quick break has started.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
    );

    quickBreakTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        quickBreakSeconds++;
      });

      // Check if Quick Break exceeded 10 minutes (600 seconds)
      if (quickBreakSeconds > 600) {
        quickBreakTimer?.cancel();
        setState(() {
          isQuickBreakActive = false;
        });

        // Play end sound
        _audioPlayer.play(AssetSource('sounds/end_sound.mp3'));

        // Show snackbar
        Get.snackbar(
          "Quick Break Time Over",
          "Your quick break has exceeded the time limit (10 minutes).",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    });
  }

  // End Quick Break
  void endQuickBreak() {
    quickBreakTimer?.cancel();
    setState(() {
      isQuickBreakActive = false;
    });

    // Play end sound
    _audioPlayer.play(AssetSource('sounds/end_sound.mp3'));

    // Show snackbar
    Get.snackbar(
      "Quick Break Ended",
      "Your quick break has ended.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  // Start Meal Break
  void startMealBreak() {
    mealBreakTimer?.cancel();
    mealBreakSeconds = 0;
    isMealBreakActive = true;

    // Play start sound
    _audioPlayer.play(AssetSource('sounds/start_sound.mp3'));

    // Show snackbar
    Get.snackbar(
      "Meal Break Started",
      "Your meal break has started.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
    );

    mealBreakTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        mealBreakSeconds++;
      });

      // Check if Meal Break exceeded 60 minutes (3600 seconds)
      if (mealBreakSeconds > 3600) {
        mealBreakTimer?.cancel();
        setState(() {
          isMealBreakActive = false;
        });

        // Play end sound
        _audioPlayer.play(AssetSource('sounds/end_sound.mp3'));

        // Show snackbar
        Get.snackbar(
          "Meal Break Time Over",
          "Your meal break has exceeded the time limit (60 minutes).",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    });
  }

  // End Meal Break
  void endMealBreak() {
    mealBreakTimer?.cancel();
    setState(() {
      isMealBreakActive = false;
    });

    // Play end sound
    _audioPlayer.play(AssetSource('sounds/end_sound.mp3'));

    // Show snackbar
    Get.snackbar(
      "Meal Break Ended",
      "Your meal break has ended.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  // Format time in MM:SS format
  String formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    quickBreakTimer?.cancel();
    mealBreakTimer?.cancel();
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
            children: [
              SizedBox(height: 30),
              Row(
                children: [
                  const Text("Quick Break (QB): "),
                  InkWell(
                    onTap: startQuickBreak,
                    child: Text("Start Break", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.appColor)),
                  ),
                  const SizedBox(width: 2),
                  Text(formatTime(quickBreakSeconds)),
                  const SizedBox(width: 2),
                  InkWell(
                    onTap: endQuickBreak,
                    child: Text("End Break", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.redColor)),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ECGLine(
                progress: quickPercent,
                isExceeded: quickBreakSeconds > 600,
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  const Text("Meal Break (MB): "),
                  InkWell(
                    onTap: startMealBreak,
                    child: Text("Start Break", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.appColor)),
                  ),
                  const SizedBox(width: 2),
                  Text(formatTime(mealBreakSeconds)),
                  const SizedBox(width: 2),
                  InkWell(
                    onTap: endMealBreak,
                    child: Text("End Break", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.redColor)),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ECGLine(
                progress: mealPercent,
                isExceeded: mealBreakSeconds > 3600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ECG Line Widget
class ECGLine extends StatelessWidget {
  final double progress;
  final bool isExceeded;

  const ECGLine({required this.progress, required this.isExceeded, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ECGPainter(
        color: isExceeded ? Colors.red : AppColors.appColor,
        progress: progress.clamp(0.0, 1.0),
      ),
      size: Size(double.infinity, 30),
    );
  }
}

// ECG Custom Painter
class ECGPainter extends CustomPainter {
  final Color color;
  final double progress;

  ECGPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    double width = size.width;
    double height = size.height;
    double x = 0;
    double spacing = 10;

    path.moveTo(0, height / 2);

    while (x < width * progress) {
      path.relativeLineTo(spacing / 2, -10);
      path.relativeLineTo(spacing / 2, 20);
      path.relativeLineTo(spacing / 2, -10);
      path.relativeLineTo(spacing / 2, 0);
      x += spacing * 2;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
