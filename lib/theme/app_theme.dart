import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const primary = Color(0xFF1DB954);      // Spotify green
  static const primaryDark = Color(0xFF1AA34A);
  static const accent = Color(0xFFFF6B6B);        // Accent red
  static const accentBlue = Color(0xFF4ECDC4);

  // Dark theme
  static const darkBg = Color(0xFF0D0D0D);
  static const darkCard = Color(0xFF1A1A1A);
  static const darkSurface = Color(0xFF242424);
  static const darkElevated = Color(0xFF2D2D2D);

  // Light theme
  static const lightBg = Color(0xFFF5F5F5);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFEEEEEE);

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
  static const textDisabled = Color(0xFF535353);

  // Gradient
  static const gradientStart = Color(0xFF1DB954);
  static const gradientEnd = Color(0xFF121212);

  // Player bg gradient presets
  static const List<List<Color>> playerGradients = [
    [Color(0xFF1DB954), Color(0xFF0D0D0D)],
    [Color(0xFF4158D0), Color(0xFF0D0D0D)],
    [Color(0xFFFF6B6B), Color(0xFF0D0D0D)],
    [Color(0xFFF7971E), Color(0xFF0D0D0D)],
    [Color(0xFF11998E), Color(0xFF0D0D0D)],
    [Color(0xFF8E2DE2), Color(0xFF0D0D0D)],
  ];
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.darkCard,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.darkBg,
        fontFamily: 'Circular',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: TextStyle(
            fontFamily: 'Circular',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkCard,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
        cardTheme: CardTheme(
          color: AppColors.darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontFamily: 'Circular',
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.darkElevated,
          thumbColor: Colors.white,
          overlayColor: AppColors.primary.withOpacity(0.2),
          trackHeight: 3,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontFamily: 'Circular',
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Circular',
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Circular',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Circular',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Circular',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Circular',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Circular',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
          labelSmall: TextStyle(
            fontFamily: 'Circular',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textDisabled,
          ),
        ),
      );

  static ThemeData get lightTheme => darkTheme.copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBg,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.lightCard,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black,
        ),
      );
}
