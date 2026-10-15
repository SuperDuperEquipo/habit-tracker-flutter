import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores definida por el equipo
  static const Color navy = Color(0xFF2F4058);
  static const Color skyBlue = Color(0xFFC8D9E6);
  static const Color palePink = Color(0xFFFFE1E6);
  static const Color azalea = Color(0xFFF7C9D4);
  static const Color beige = Color(0xFFF5EFEB);
  static const Color darkPink = Color(0xFFC45B78);
  static const Color background = Color(0xFFF7F7F5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      fontFamily: 'Plus Jakarta Sans',
      colorScheme: ColorScheme.light(
        primary: navy,
        secondary: darkPink,
        surface: beige,
        error: darkPink,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: navy,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: navy,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: skyBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: skyBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: navy, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkPink),
        ),
      ),
    );
  }
}
