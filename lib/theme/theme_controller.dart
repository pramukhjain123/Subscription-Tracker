import 'package:flutter/material.dart';

class ThemeController with ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  bool get isDark => _mode == ThemeMode.dark;
}
