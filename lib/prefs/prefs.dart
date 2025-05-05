// import 'package:shared_preferences/shared_preferences.dart';
//
// abstract class SharedPrefKey {
//   static const String userId = 'userId';
//   static const String bookingId = 'bookingId';
//   static const String accessToken = 'token';
//   static const String manufactureId = 'manufactureId';
//
//   // static const String driverId = 'driverId';
// }
//
// class SharedPrefService {
//   static const String keyPrefix = 'meq_driver';
//   static SharedPrefService? _instance;
//   static SharedPreferences? _pref;
//
//   SharedPrefService._internal();
//
//   static Future<SharedPrefService> getInstance() async {
//     if (_instance == null) {
//       _instance = SharedPrefService._internal();
//       await _instance!._init();
//     }
//     return _instance!;
//   }
//
//   Future _init() async {
//     _pref ??= await SharedPreferences.getInstance();
//   }
//
//   static Future<void> saveString(String key, String value) async {
//     await _pref?.setString(keyPrefix + key, value);
//   }
//
//   static Future<String?> getString(String key) async {
//     return _pref?.getString(keyPrefix + key);
//   }
//
//   static Future<void> saveInt(String key, int value) async {
//     await _pref!.setInt(keyPrefix + key, value);
//   }
//
//   static Future<int?> getInt(String key) async {
//     return _pref!.getInt(keyPrefix + key);
//   }
//
//   static Future<void> removeKey(String key) async {
//     await _pref!.remove(keyPrefix + key);
//   }
//
//   static Future<void> clearAll() async {
//     await _pref!.clear();
//   }
// }
