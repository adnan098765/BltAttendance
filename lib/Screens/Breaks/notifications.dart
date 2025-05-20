// Add these dependencies to your pubspec.yaml
// flutter_background_service: ^3.0.1
// flutter_local_notifications: ^12.0.4
// shared_preferences: ^2.0.15

// File: main.dart (Add this method to initialize background service)
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'break_tracker_channel',
    'Break Tracker Service',
    description: 'This channel is used for break tracker service notifications',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'break_tracker_channel',
      initialNotificationTitle: 'Break Tracker Service',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

// Background handler for iOS
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

// Main background service handler
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Access shared instance
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Create a periodic timer to check breaks
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    // Get shared preferences instance
    final prefs = await SharedPreferences.getInstance();

    // Check active breaks
    final isQuickBreak = prefs.getBool('isQuickBreak') ?? false;
    final isMealBreak = prefs.getBool('isMealBreak') ?? false;

    // Get all custom break types that might be active
    final breakTypesJson = prefs.getString('activeBreakTypes') ?? '{}';
    Map<String, dynamic> activeBreaks = jsonDecode(breakTypesJson);

    // Update break timers in background
    if (isQuickBreak) {
      int seconds = prefs.getInt('quickElapsedSeconds') ?? 0;
      seconds++;
      await prefs.setInt('quickElapsedSeconds', seconds);

      // Update notification
      await flutterLocalNotificationsPlugin.show(
        888,
        'Quick Break Active',
        'Duration: ${formatTime(seconds)}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'break_tracker_channel',
            'Break Tracker Service',
            ongoing: true,
          ),
        ),
      );
    }

    if (isMealBreak) {
      int seconds = prefs.getInt('mealElapsedSeconds') ?? 0;
      seconds++;
      await prefs.setInt('mealElapsedSeconds', seconds);

      // Update notification
      await flutterLocalNotificationsPlugin.show(
        889,
        'Meal Break Active',
        'Duration: ${formatTime(seconds)}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'break_tracker_channel',
            'Break Tracker Service',
            ongoing: true,
          ),
        ),
      );
    }

    // Update custom break types
    activeBreaks.forEach((type, isActive) async {
      if (isActive) {
        int seconds = prefs.getInt('elapsed_$type') ?? 0;
        seconds++;
        await prefs.setInt('elapsed_$type', seconds);

        // Update notification
        await flutterLocalNotificationsPlugin.show(
          890 + activeBreaks.keys.toList().indexOf(type),
          '$type Break Active',
          'Duration: ${formatTime(seconds)}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'break_tracker_channel',
              'Break Tracker Service',
              ongoing: true,
            ),
          ),
        );
      }
    });

    // Broadcast to app if it's running
    service.invoke(
      'update',
      {
        'isRunning': true,
      },
    );
  });
}

String formatTime(int seconds) {
  int minutes = (seconds / 60).floor();
  int remainingSeconds = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}