import 'package:shared_preferences/shared_preferences.dart';

// Define the keys for Shared Preferences
const String userIdKey = 'userIdKey';
const String token = 'token';
const String receiverIdKey = 'receiverIdKey';
const String clientIdKey = 'clientIdKey';

// Function to save the user ID
Future<String?> saveUserId(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(userIdKey, userId);
  return null;
}

// Function to retrieve the user ID
Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(userIdKey);
}

// Function to clear the saved user ID
Future<void> clearUserId() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(userIdKey);
}



// Function to save the receiver ID
Future<String?> saveReceiverId(String receiverId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(receiverIdKey, receiverId);
  return null;
}

// Function to retrieve the receiver ID
Future<String?> getReceiverId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(receiverIdKey);
}

// Function to clear the saved receiver ID
Future<void> clearReceiverId() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(receiverIdKey);
}
//

// Function to save the receiver ID
Future<String?> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(token, token);
  return null;
}

// Function to retrieve the receiver ID
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(token);
}

// Function to clear the saved receiver ID
Future<void> removeToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(token);
}
