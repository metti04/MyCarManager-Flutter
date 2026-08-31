import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      // Configurazione dello schema colori principale
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blu,
        primary: AppColors.blu,
        secondary: AppColors.azzurro,
        surface: AppColors.bianco,
      ),
      // Colore di sfondo degli Scaffold
      scaffoldBackgroundColor: AppColors.bianco,
      // Stile dell'AppBar principale
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.blu,
        foregroundColor: AppColors.bianco,
        elevation: 0,
      ),
      // Stile per le schede
      cardTheme: CardThemeData(
        color: AppColors.bianco,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      // Stile per i campi di testo
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bianco,
        labelStyle: const TextStyle(color: AppColors.blu),
        hintStyle: const TextStyle(color: AppColors.bluChiaro),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: AppColors.blu),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: AppColors.blu),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: AppColors.blu, width: 2),
        ),
      ),
      // Stile per i pulsanti pieni
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blu,
          foregroundColor: AppColors.bianco,
          minimumSize: const Size.fromHeight(60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      // Stile per i pulsanti con bordo
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blu,
          side: const BorderSide(color: AppColors.blu, width: 2),
          minimumSize: const Size.fromHeight(60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          textStyle: const TextStyle(fontSize: 18),
        ),
      ),
      // Stile per la barra di navigazione inferiore (NavigationBar).
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.blu,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: AppColors.azzurro, fontWeight: FontWeight.bold);
          }
          return const TextStyle(color: AppColors.bianco, fontWeight: FontWeight.bold);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.azzurro);
          }
          return const IconThemeData(color: AppColors.bianco);
        }),
      ),
    );
  }
}
