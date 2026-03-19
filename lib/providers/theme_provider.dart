import 'package:flutter/material.dart';

import '../services/shared_prefs_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({this.isDarkMode = false, SharedPrefsService? prefsService})
    : _prefsService = prefsService ?? SharedPrefsService.instance;

  // Quản lý Light/Dark Mode cho app.
  bool isDarkMode;

  final SharedPrefsService _prefsService;

  /// Luu cau hinh cuc bo bang SharedPreferences.
  Future<void> loadTheme() async {
    try {
      isDarkMode = await _prefsService.getDarkMode();
      // UI tu dong rebuild khi theme thay doi.
      notifyListeners();
    } catch (_) {
      // Keep default theme when read fails.
    }
  }

  /// Luu cau hinh cuc bo bang SharedPreferences.
  Future<void> toggleTheme() async {
    try {
      isDarkMode = !isDarkMode;
      await _prefsService.setDarkMode(isDarkMode);
      // UI tu dong rebuild khi theme thay doi.
      notifyListeners();
    } catch (_) {
      // Roll back state when save fails.
      isDarkMode = !isDarkMode;
      notifyListeners();
    }
  }
}
