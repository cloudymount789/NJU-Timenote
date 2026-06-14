import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static const fontFamily = 'Source Han Serif SC';
  static const fontFallback = <String>[
    'Noto Serif CJK SC',
    'Noto Serif SC',
    'Songti SC',
  ];

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: AppColors.surface,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: base.textTheme.apply(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      iconTheme: const IconThemeData(color: AppColors.ink),
      splashFactory: InkRipple.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.android: ZoomPageTransitionsBuilder()},
      ),
    );
  }
}
