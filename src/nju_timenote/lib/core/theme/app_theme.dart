import 'package:flutter/material.dart';

class AppColors {
  static const accent = Color(0xFF0062FF);
  static const accentDark = Color(0xFF003FA6);
  static const background = Color(0xFFF7F8FA);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);
  static const border = Color(0xFFE9EEF7);
  static const cardShadow = Color(0x1A0F4C81);
}

class AppRadii {
  static const card = 14.0;
  static const control = 12.0;
  static const sheet = 18.0;
}

ThemeData buildTimenoteTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: Brightness.light,
    primary: AppColors.accent,
    surface: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Noto Sans SC',
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.textMuted, fontSize: 12),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: AppColors.textPrimary),
    ),
  );
}

BoxDecoration softCardDecoration({Color color = Colors.white}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(AppRadii.card),
    boxShadow: const [
      BoxShadow(
        color: AppColors.cardShadow,
        blurRadius: 18,
        offset: Offset(0, 8),
      ),
    ],
  );
}
