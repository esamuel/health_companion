// lib/config/app_theme.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  // Font size constants
  static const double minFontSize = 14.0;
  static const double maxFontSize = 28.0;
  static const double defaultFontSize = 18.0;

  // Colors for high contrast mode
  static const Color highContrastTextColor = Colors.white;
  static const Color highContrastBackgroundColor = Colors.black;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('fontSize')) {
      await prefs.setDouble('fontSize', defaultFontSize);
    }
  }

  static ThemeData getLightTheme({
    double fontSize = defaultFontSize,
    bool isHighContrast = false,
  }) {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: isHighContrast ? Colors.white : Colors.grey[50],
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: fontSize * 2.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        displayMedium: TextStyle(
          fontSize: fontSize * 1.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        titleLarge: TextStyle(
          fontSize: fontSize * 1.25,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSize,
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSize * 0.9,
          letterSpacing: 0.5,
          height: 1.5,
        ),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(fontSize),
          textStyle: TextStyle(fontSize: fontSize),
          minimumSize: Size(88, fontSize * 3),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.all(fontSize * 0.75),
        labelStyle: TextStyle(fontSize: fontSize),
        hintStyle: TextStyle(fontSize: fontSize * 0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            width: 2,
            color: isHighContrast ? Colors.black : Colors.grey,
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: isHighContrast ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isHighContrast
              ? BorderSide(color: Colors.black, width: 2)
              : BorderSide.none,
        ),
      ),
    );
  }

  static ThemeData getDarkTheme({
    double fontSize = defaultFontSize,
    bool isHighContrast = false,
  }) {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: isHighContrast ? Colors.black : Colors.grey[900],
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: fontSize * 2.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: isHighContrast ? highContrastTextColor : null,
        ),
        displayMedium: TextStyle(
          fontSize: fontSize * 1.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: isHighContrast ? highContrastTextColor : null,
        ),
        titleLarge: TextStyle(
          fontSize: fontSize * 1.25,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: isHighContrast ? highContrastTextColor : null,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSize,
          letterSpacing: 0.5,
          height: 1.5,
          color: isHighContrast ? highContrastTextColor : null,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSize * 0.9,
          letterSpacing: 0.5,
          height: 1.5,
          color: isHighContrast ? highContrastTextColor : null,
        ),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(fontSize),
          textStyle: TextStyle(fontSize: fontSize),
          minimumSize: Size(88, fontSize * 3),
          backgroundColor: isHighContrast ? Colors.white : Colors.blue,
          foregroundColor: isHighContrast ? Colors.black : Colors.white,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.all(fontSize * 0.75),
        labelStyle: TextStyle(
          fontSize: fontSize,
          color: isHighContrast ? highContrastTextColor : null,
        ),
        hintStyle: TextStyle(
          fontSize: fontSize * 0.9,
          color: isHighContrast ? highContrastTextColor.withOpacity(0.7) : null,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            width: 2,
            color: isHighContrast ? highContrastTextColor : Colors.grey,
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: isHighContrast ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isHighContrast
              ? BorderSide(color: highContrastTextColor, width: 2)
              : BorderSide.none,
        ),
      ),
    );
  }
}