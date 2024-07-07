import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  final ThemeData _lightTheme = _buildLightTheme();
  final ThemeData _darkTheme = _buildDarkTheme();
  ThemeMode _themeMode = ThemeMode.system;

  ThemeData getLightTheme() => _lightTheme;
  ThemeData getDarkTheme() => _darkTheme;
  ThemeMode getThemeMode() => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveThemeMode(_themeMode); // Simpan preferensi tema
    notifyListeners();
  }

  Future<void> _saveThemeMode(ThemeMode themeMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = themeMode == ThemeMode.dark;
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  static ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.blue,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black),
      ),
    );
  }

  static ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.deepPurple,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.deepPurple,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
      ),
    );
  }
}
