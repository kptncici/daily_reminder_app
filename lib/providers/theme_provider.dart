import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum semua tema warna yang tersedia
enum AppThemeColor { teal, blue, pink, purple, black }

class ThemeProvider with ChangeNotifier {
  static const String _themeColorKey = 'app_theme_color';

  AppThemeColor _currentThemeColor = AppThemeColor.teal;
  ThemeData _currentThemeData = _buildTheme(AppThemeColor.teal);

  AppThemeColor get currentThemeColor => _currentThemeColor;
  ThemeData get currentTheme => _currentThemeData;

  ThemeProvider() {
    _loadThemeColor();
  }

  /// Muat tema tersimpan dari SharedPreferences
  Future<void> _loadThemeColor() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_themeColorKey);

    if (stored != null) {
      try {
        _currentThemeColor = AppThemeColor.values.firstWhere(
          (e) => e.name == stored,
          orElse: () => AppThemeColor.teal,
        );
        _currentThemeData = _buildTheme(_currentThemeColor);
      } catch (_) {
        _currentThemeColor = AppThemeColor.teal;
        _currentThemeData = _buildTheme(AppThemeColor.teal);
      }
    }
    notifyListeners();
  }

  /// Ganti dan simpan tema
  Future<void> setThemeColor(AppThemeColor color) async {
    if (_currentThemeColor == color) return;

    _currentThemeColor = color;
    _currentThemeData = _buildTheme(color);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeColorKey, color.name);

    notifyListeners();
  }

  /// Ambil ThemeData sesuai enum warna utama
  static ThemeData _buildTheme(AppThemeColor color) {
    final primary = _getPrimaryColor(color);
    return ThemeData(
      primarySwatch: primary,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
      ),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: primary,
      ).copyWith(secondary: primary, brightness: Brightness.light),
    );
  }

  /// Ambil MaterialColor sesuai enum
  static MaterialColor _getPrimaryColor(AppThemeColor color) {
    switch (color) {
      case AppThemeColor.teal:
        return Colors.teal;
      case AppThemeColor.blue:
        return Colors.blue;
      case AppThemeColor.pink:
        return Colors.pink;
      case AppThemeColor.purple:
        return Colors.purple;
      case AppThemeColor.black:
        return _blackSwatch;
    }
  }

  /// Getter tambahan agar bisa dipanggil di widget seperti MyApp
  MaterialColor getPrimaryMaterialColor() {
    return _getPrimaryColor(_currentThemeColor);
  }

  /// MaterialColor custom untuk hitam
  static const MaterialColor _blackSwatch =
      MaterialColor(0xFF000000, <int, Color>{
        50: Color(0xFFE0E0E0),
        100: Color(0xFFBDBDBD),
        200: Color(0xFF9E9E9E),
        300: Color(0xFF757575),
        400: Color(0xFF616161),
        500: Color(0xFF424242),
        600: Color(0xFF212121),
        700: Color(0xFF121212),
        800: Color(0xFF0A0A0A),
        900: Color(0xFF000000),
      });
}
