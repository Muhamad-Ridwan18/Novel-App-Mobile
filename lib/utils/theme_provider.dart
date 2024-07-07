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
    _saveThemeMode(_themeMode); // Save theme preference
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
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        titleSmall: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
      ),
      colorScheme: const ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.amber,
        surface: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
        onError: Colors.white,
      ),
      cardColor: Colors.white,
      dividerColor: Colors.grey[400],
      splashColor: Colors.blue.shade200,
      hintColor: Colors.amber,
    );
  }

  static ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.deepPurple,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
      ),
      colorScheme: const ColorScheme.dark(
        primary: Colors.deepPurple,
        secondary: Colors.orangeAccent,
        surface: Colors.grey,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onError: Colors.white,
      ),
      cardColor: Colors.grey[800],
      dividerColor: Colors.grey[600],
      splashColor: Colors.deepPurple.shade200,
      hintColor: Colors.orangeAccent,
    );
  }
}
