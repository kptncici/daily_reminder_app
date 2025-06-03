import 'package:flutter/material.dart';

enum AppThemeColor { teal, blue, purple, orange, red }

MaterialColor getMaterialColor(AppThemeColor color) {
  switch (color) {
    case AppThemeColor.teal:
      return Colors.teal;
    case AppThemeColor.blue:
      return Colors.blue;
    case AppThemeColor.purple:
      return Colors.deepPurple;
    case AppThemeColor.orange:
      return Colors.orange;
    case AppThemeColor.red:
      return Colors.red;
  }
}

ThemeData getThemeData(MaterialColor color) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: color),
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: color,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    cardTheme: const CardThemeData(
      // ✅ Ganti dari CardTheme ke CardThemeData
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: color),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
