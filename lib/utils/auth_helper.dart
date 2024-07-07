import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static Future<bool> isLoggedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      return token != null;
    } catch (e) {
      // print('Error fetching token: $e');
      return false; // Handle error gracefully
    }
  }

  static Future<void> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } catch (e) {
      // print('Error removing token: $e');
      // Optionally, handle error or throw it further
    }
  }
}
