import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  Locale _locale = const Locale('ar');
  ThemeMode _themeMode = ThemeMode.dark;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  AppState() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString('language') ?? 'ar';
      final theme = prefs.getString('theme') ?? 'dark';
      _locale = Locale(lang);
      _themeMode = theme == 'light' ? ThemeMode.light : ThemeMode.dark;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setLanguage(String code) async {
    _locale = Locale(code);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', code);
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme', _themeMode == ThemeMode.light ? 'light' : 'dark');
    } catch (_) {}
  }
}