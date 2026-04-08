import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData darkTheme(bool isDarkMode) {
    final colorScheme = ColorScheme.fromSeed(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      seedColor: AppColors.accentGreen,
      primary: AppColors.accentGreen,
      surface: AppColors.primaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: AppColors.softWhite,
        ),
        titleLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: AppColors.softWhite,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.w400,
          color: AppColors.softWhite,
        ),
        labelLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: AppColors.softWhite,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.softWhite,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        hintStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.accentGreen),
        ),
      ),
      cardColor: Colors.white.withValues(alpha: 0.08),
    );
  }
}
