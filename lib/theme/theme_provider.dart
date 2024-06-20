import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app_open_weather/theme/theme.dart';

final themeProvider = ChangeNotifierProvider((ref) => ThemeProvider());

class ThemeProvider extends ChangeNotifier {
  //set initail theme as light mode
  ThemeData _themeData = lightMode;
  //get the current theme
  ThemeData get themeData => _themeData;
  //check for datk mode
  bool get isDarkMode => _themeData == darkMode;

  //set theme data
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  //toggle the theme
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
