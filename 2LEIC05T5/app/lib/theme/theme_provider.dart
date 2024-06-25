import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

class ThemeProvider extends ChangeNotifier{
  late ThemeData _selectedTheme;

  ThemeProvider({required bool isDarkMode}){
    _selectedTheme = isDarkMode ? darkMode : lightMode;
  }

  set themeData(ThemeData themeData){
    _selectedTheme = themeData;
    notifyListeners();
  }
  Future<void> toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedTheme = _selectedTheme == lightMode ? darkMode : lightMode;
    prefs.setBool("isDarkTheme", _selectedTheme == darkMode);
    notifyListeners();
  }
  String seeMode() {
    if (_selectedTheme == lightMode) {
      return 'light';
    } else {
      return 'dark';
    }
  }
  ThemeData get getTheme => _selectedTheme;
}