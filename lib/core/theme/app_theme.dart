import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color cream = Color(0xFFFFF8E8);
  static const Color pastelYellow = Color(0xFFFFD966);
  static const Color lightOrange = Color(0xFFFFB56B);
  static const Color softBlue = Color(0xFF8ECDF8);
  static const Color cocoa = Color(0xFF5A4632);

  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: lightOrange,
          brightness: Brightness.light,
        ).copyWith(
          primary: lightOrange,
          secondary: pastelYellow,
          tertiary: softBlue,
          surface: cream,
          onPrimary: cocoa,
          onSecondary: cocoa,
          onTertiary: cocoa,
          onSurface: cocoa,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: cream,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: cream,
        foregroundColor: cocoa,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: lightOrange,
          foregroundColor: cocoa,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: softBlue, width: 2),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w800, color: cocoa),
        headlineMedium: TextStyle(fontWeight: FontWeight.w800, color: cocoa),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: cocoa),
        bodyLarge: TextStyle(fontSize: 18, height: 1.35, color: cocoa),
        bodyMedium: TextStyle(height: 1.35, color: cocoa),
      ),
    );
  }
}
