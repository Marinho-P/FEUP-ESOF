import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFD0FCB3), // main Color
    secondary: Color(0xFF0A2E36), // secondary color
    tertiary: Color(0xFFB4DD99), // semi darkened main Color
    onPrimary:Colors.black, // text color light mode
    onSecondary: Colors.white,  // Text color on secondary color
    surface: Colors.white,
  ),
  fontFamily: 'Ruda',
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary:  Color(0xFF0A2E36),
    secondary: Color.fromARGB(255, 1, 97, 73),
    tertiary: Color(0x8B014F3B), // semi darkened main Color
    onPrimary: Colors.white,  // text color dark mode
    onSecondary: Colors.black, // Text color on secondary color
    surface: Color(0xFF014F3B),
  ),
  fontFamily: 'Ruda',
);
