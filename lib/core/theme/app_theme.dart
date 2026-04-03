import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette (romantic pink/purple)
  static const Color primary = Color(0xFFFF6B9D);
  static const Color primaryDark = Color(0xFFE0508A);
  static const Color primaryLight = Color(0xFFFF9EC8);
  static const Color secondary = Color(0xFFC04FD6);
  static const Color secondaryLight = Color(0xFFD975EA);
  static const Color accent = Color(0xFFFF9EC8);

  // Dark theme surfaces
  static const Color darkBg = Color(0xFF0F0518);
  static const Color darkSurface = Color(0xFF1A0A2E);
  static const Color darkCard = Color(0xFF261440);
  static const Color darkBorder = Color(0xFF3D1F5C);

  // Light theme surfaces
  static const Color lightBg = Color(0xFFFFF0F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFF5FA);
  static const Color lightBorder = Color(0xFFFFCCE2);

  // Text
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A0A14);
  static const Color textMuted = Color(0xFF9E86A2);
  static const Color textMutedLight = Color(0xFF9E6B7E);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);

  // Gradient colors
  static const List<Color> primaryGradient = [Color(0xFFFF6B9D), Color(0xFFC04FD6)];
  static const List<Color> darkBgGradient = [Color(0xFF0F0518), Color(0xFF1A0A2E), Color(0xFF0D1033)];
  static const List<Color> heartGradient = [Color(0xFFFF6B9D), Color(0xFFFF4D7D)];
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.darkBg,
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w800),
          displayMedium: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700),
          bodyLarge: const TextStyle(color: AppColors.textLight),
          bodyMedium: const TextStyle(color: AppColors.textMuted),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textLight),
        titleTextStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textMuted),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.lightBg,
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData.light().textTheme.copyWith(
          displayLarge: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w800),
          displayMedium: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
          bodyLarge: const TextStyle(color: AppColors.textDark),
          bodyMedium: const TextStyle(color: AppColors.textMutedLight),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textMutedLight),
        hintStyle: const TextStyle(color: AppColors.textMutedLight),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
    );
  }
}
