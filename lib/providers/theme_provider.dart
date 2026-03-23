import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _key = 'theme_mode';

  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final v = p.getString(_key);
      if (v == 'light') _mode = ThemeMode.light;
      if (v == 'dark') _mode = ThemeMode.dark;
      if (v == 'system') _mode = ThemeMode.system;
      notifyListeners();
    } catch (_) {
      _mode = ThemeMode.light;
      notifyListeners();
    }
  }

  Future<void> setMode(ThemeMode m) async {
    _mode = m;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(
        _key,
        m == ThemeMode.dark ? 'dark' : (m == ThemeMode.light ? 'light' : 'system'),
      );
    } catch (_) {}
  }

  void toggleLightDark() {
    final next = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setMode(next);
  }
}
