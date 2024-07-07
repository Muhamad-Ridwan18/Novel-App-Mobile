import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/novel_list_screen.dart';
import 'screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/theme_provider.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(), 
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Login Demo',
            theme: themeProvider.getLightTheme(),
            darkTheme: themeProvider.getDarkTheme(),
            themeMode: themeProvider.getThemeMode(),
            home: FutureBuilder<bool>(
              future: _checkLoginStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData && snapshot.data == true) {
                  return const NovelScreen();
                } else {
                  return const LoginScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }
}
