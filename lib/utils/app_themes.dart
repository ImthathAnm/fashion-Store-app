import 'package:flutter/material.dart';

class AppThemes {
  static final light = ThemeData(
    primaryColor: const Color(0xFF808000),
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF808000),
      primary: const Color(0xFF808000),
      brightness: Brightness.light,
      surface: Colors.white,
    ),
    cardColor: Colors.white,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF808000),
      unselectedItemColor: Colors.grey,
    ),
  );

  static ThemeData? get dark => null;
}