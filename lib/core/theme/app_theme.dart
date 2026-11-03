import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores definida por el equipo
  static const Color navy = Color(0xFF2F4058);
  static const Color slateBlue = Color(0xFF5F7F99);
  static const Color skyBlue = Color(0xFFC8D9E6);
  static const Color palePink = Color(0xFFFFE1E6);
  static const Color azalea = Color(0xFFF7C9D4);
  static const Color beige = Color(0xFFF5EFEB);
  static const Color darkPink = Color(0xFFC45B78);
  static const Color background = Color(0xFFF7F7F5);

  static const String fontFamily = 'Plus Jakarta Sans';

  // DESIGN.md de Stitch: radio único de 16 px para tarjetas, campos y botones.
  static final BorderRadius _radius = BorderRadius.circular(16);

  // Todos los roles de Material 3 salen de la paleta, para que ningún
  // componente (barra inferior, diálogos, selector de hora) use el morado
  // por defecto de Flutter.
  static final ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: navy)
      .copyWith(
        primary: navy,
        onPrimary: Colors.white,
        primaryContainer: skyBlue,
        onPrimaryContainer: navy,
        secondary: slateBlue,
        onSecondary: Colors.white,
        secondaryContainer: skyBlue,
        onSecondaryContainer: navy,
        tertiary: darkPink,
        onTertiary: Colors.white,
        tertiaryContainer: azalea,
        onTertiaryContainer: navy,
        error: darkPink,
        onError: Colors.white,
        errorContainer: palePink,
        onErrorContainer: navy,
        surface: beige,
        onSurface: navy,
        onSurfaceVariant: slateBlue,
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: background,
        surfaceContainer: beige,
        surfaceContainerHigh: beige,
        surfaceContainerHighest: skyBlue,
        surfaceTint: Colors.transparent,
        outline: slateBlue,
        outlineVariant: skyBlue,
        inverseSurface: navy,
        onInverseSurface: Colors.white,
        inversePrimary: skyBlue,
      );

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: fontFamily,
    );
    final text = base.textTheme;

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(
          color: navy,
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(borderRadius: _radius),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: _radius),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: navy,
          minimumSize: const Size(64, 48),
          side: const BorderSide(color: skyBlue),
          shape: RoundedRectangleBorder(borderRadius: _radius),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: navy,
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background,
        indicatorColor: skyBlue.withValues(alpha: 0.6),
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? navy : slateBlue,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected) ? navy : slateBlue,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: beige,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: const TextStyle(color: slateBlue),
        hintStyle: TextStyle(color: slateBlue.withValues(alpha: 0.7)),
        prefixIconColor: slateBlue,
        suffixIconColor: slateBlue,
        border: OutlineInputBorder(
          borderRadius: _radius,
          borderSide: const BorderSide(color: skyBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _radius,
          borderSide: const BorderSide(color: skyBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _radius,
          borderSide: const BorderSide(color: navy, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: _radius,
          borderSide: const BorderSide(color: darkPink),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: _radius,
          borderSide: const BorderSide(color: darkPink, width: 2),
        ),
      ),
      // En la app los avisos flotantes son errores: Stitch los pide en Rosa Oscuro.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkPink,
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
        actionTextColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: _radius),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: text.titleLarge?.copyWith(
          color: navy,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: text.bodyMedium?.copyWith(color: slateBlue),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: background,
        dialBackgroundColor: beige,
        hourMinuteShape: RoundedRectangleBorder(borderRadius: _radius),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: navy,
        linearTrackColor: skyBlue,
      ),
      dividerTheme: const DividerThemeData(color: skyBlue),
    );
  }
}
