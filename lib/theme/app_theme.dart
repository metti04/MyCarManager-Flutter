import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bianco,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blu, primary: AppColors.blu),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
}
