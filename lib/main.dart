import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'AppColors/app_colors.dart';
import 'Screens/Breaks/notifications.dart';
import 'Screens/Splash/splash_screen.dart';

// Initialize notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Configure notification channel for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'break_tracker_channel',
    'Break Tracker Notifications',
    description: 'Notifications for break tracking',
    importance: Importance.high,
    showBadge: true, // Show badge on app icon for notifications
  );

  // Initialize notifications
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Configure the background service
  try {
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'break_tracker_channel',
        initialNotificationTitle: 'Break Tracker Running',
        initialNotificationContent: 'Tracking your breaks in the background',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
    await service.startService();
    print('Background service started successfully');
  } catch (e) {
    print('Error starting background service: $e');
  }
}

// Background service entry point
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Handle foreground service for Android
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  // Stop service if requested
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Periodic task to update break timers
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    bool isQuickBreak = prefs.getBool('isQuickBreak') ?? false;
    bool isMealBreak = prefs.getBool('isMealBreak') ?? false;
    Map<String, bool> activeBreaks = {};
    String? activeBreaksJson = prefs.getString('activeBreakTypes');
    if (activeBreaksJson != null) {
      activeBreaks = Map<String, bool>.from(jsonDecode(activeBreaksJson));
    }

    // Update Quick Break
    if (isQuickBreak) {
      int seconds = prefs.getInt('quickElapsedSeconds') ?? 0;
      seconds++;
      await prefs.setInt('quickElapsedSeconds', seconds);
      // Show notification every 60 seconds
      if (seconds % 60 == 0) {
        flutterLocalNotificationsPlugin.show(
          1,
          'Quick Break Active',
          'Quick Break running: ${formatTime(seconds)}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'break_tracker_channel',
              'Break Tracker Notifications',
              importance: Importance.high,
              priority: Priority.high,
              showWhen: true,
              ticker: 'Quick Break',
            ),
          ),
        );
      }
    }

    // Update Meal Break
    if (isMealBreak) {
      int seconds = prefs.getInt('mealElapsedSeconds') ?? 0;
      seconds++;
      await prefs.setInt('mealElapsedSeconds', seconds);
      if (seconds % 60 == 0) {
        flutterLocalNotificationsPlugin.show(
          2,
          'Meal Break Active',
          'Meal Break running: ${formatTime(seconds)}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'break_tracker_channel',
              'Break Tracker Notifications',
              importance: Importance.high,
              priority: Priority.high,
              showWhen: true,
              ticker: 'Meal Break',
            ),
          ),
        );
      }
    }

    // Update Dynamic Break Types
    for (var typeName in activeBreaks.keys) {
      if (activeBreaks[typeName] == true) {
        int seconds = prefs.getInt('elapsed_$typeName') ?? 0;
        seconds++;
        await prefs.setInt('elapsed_$typeName', seconds);
        if (seconds % 60 == 0) {
          flutterLocalNotificationsPlugin.show(
            typeName.hashCode,
            '$typeName Active',
            '$typeName running: ${formatTime(seconds)}',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'break_tracker_channel',
                'Break Tracker Notifications',
                importance: Importance.high,
                priority: Priority.high,
                showWhen: true,
                ticker: 'Break Type',
              ),
            ),
          );
        }
      }
    }

    // Update foreground service notification
    if (service is AndroidServiceInstance) {
      String activeBreaksText = [
        if (isQuickBreak) 'Quick',
        if (isMealBreak) 'Meal',
        ...activeBreaks.keys.where((k) => activeBreaks[k]!),
      ].join(', ');
      service.setForegroundNotificationInfo(
        title: 'Break Tracker Running',
        content: activeBreaksText.isEmpty ? 'No active breaks' : 'Active breaks: $activeBreaksText',
      );
    }

    // Invoke update to notify app
    service.invoke('update');
  });
}

// iOS background handler
@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  return true;
}

// Utility to format time for notifications
String formatTime(int seconds) {
  int minutes = (seconds ~/ 60);
  int remainingSeconds = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}

// Request battery optimization permission
Future<void> requestBatteryOptimization() async {
  var status = await Permission.ignoreBatteryOptimizations.status;
  if (!status.isGranted) {
    await Permission.ignoreBatteryOptimizations.request();
  }
}

// Request notification permission for Android 13+
Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher'); // Fixed: Removed .jpg
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    // iOS: IOSInitializationSettings(), // Added for iOS support
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Request permissions
  await requestNotificationPermission();
  await requestBatteryOptimization();

  // Initialize background service
  await initializeService();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Line Up',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.appColor,
          surfaceTintColor: AppColors.whiteTheme,
        ),
        primarySwatch: AppColors.blueColor,
        scaffoldBackgroundColor: AppColors.whiteTheme,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
    );
  }
}