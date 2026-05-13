import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();
  static const String _accentColorKey = 'accent_color';
  static const Color _defaultAccent = Color(0xFF7E8BFF);
  static const List<Color> presetColors = <Color>[
    Color(0xFF7E8BFF),
    Color(0xFF5B8CFF),
    Color(0xFFFF8A65),
    Color(0xFF4DB6AC),
    Color(0xFFE573A8),
    Color(0xFFFFC857),
  ];

  Color _accentColor = _defaultAccent;
  bool _isLoaded = false;

  Color get accentColor => _accentColor;

  Future<void> ensureLoaded() async {
    if (_isLoaded) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedValue = prefs.getInt(_accentColorKey);
    if (storedValue != null) {
      _accentColor = Color(storedValue);
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    if (_accentColor.toARGB32() == color.toARGB32()) {
      return;
    }

    _accentColor = color;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, color.toARGB32());
  }
}
