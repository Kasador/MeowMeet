import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFEB6600); // Orange
  static const Color secondaryColor = Color(0xFF28363D); // Dark Gray
  static const Color accentColor = Color(0xFF3F5E60); // Teal
  static const Color textColor = Color(0xFF28363D); // Dark Gray
  static const Color backgroundColor = Color(0xFFFFFFFF); // White


  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: primaryColor,
      selectedItemColor: accentColor,
      unselectedItemColor: Colors.white,
      selectedLabelStyle: TextStyle(color: Colors.white),
      unselectedLabelStyle: TextStyle(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: secondaryColor,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textColor, fontSize: 18),
      bodyMedium: TextStyle(color: textColor, fontSize: 16),
      headlineLarge: TextStyle(color: primaryColor, fontSize: 32, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: primaryColor, fontSize: 20, fontWeight: FontWeight.bold),
    ),
  );
}
