import 'package:shared_preferences/shared_preferences.dart';

// Define the keys for Shared Preferences
const String userIdKey = 'userIdKey';
const String token = 'token';
const String bookingIdKey = 'bookingId';
const String confirmBookingIdKey = 'confirmBookingIdKey';
const String vehicleIdKey = 'vehicleIdKey';
const String manufacturedIdKey = 'manufacturedIdKey';
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

// Function to save the booking ID
Future<void> saveBookingId(String id) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(bookingIdKey, id);
}

// Function to retrieve the booking ID
Future<String?> getBookingId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(bookingIdKey);
}

// Function to clear the saved booking ID
Future<void> clearBookingId() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(bookingIdKey);
}

// Function to save the booking ID
saveConfirmBookingId(String id) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(confirmBookingIdKey, id);
}

// Function to retrieve the booking ID
Future<String?> getConfirmBookingId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(confirmBookingIdKey);
}

// Function to clear the saved booking ID
Future<void> clearConfirmBookingId() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(confirmBookingIdKey);
}

// Function to save the vehicle ID
Future<void> saveVehicleId(String vehicleId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(vehicleIdKey, vehicleId);
}

// Function to retrieve the vehicle ID
Future<String?> getVehicleId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(vehicleIdKey);
}

// Function to clear the saved vehicle ID
Future<void> clearVehicleId() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(vehicleIdKey);
}

// Function to save the manufacture ID
Future<void> saveManufactureId(String manufacturedId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(manufacturedIdKey, manufacturedId);
}

// Function to retrieve the manufacture ID
Future<String?> getManufactureId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(manufacturedIdKey);
}

// Function to clear the saved manufacture ID
Future<void> clearManufactureId() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(manufacturedIdKey);
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
