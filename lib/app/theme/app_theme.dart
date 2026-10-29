import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData getDarkTheme({required double fontScale, required bool isHighContrast}) {
    final background = isHighContrast ? Colors.black : AppColors.backgroundDark;
    final surface = isHighContrast ? const Color(0xFF121212) : AppColors.surfaceDark;
    final cardColor = isHighContrast ? const Color(0xFF1E1E1E) : AppColors.cardDark;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.dark(
        primary: isHighContrast ? const Color(0xFF64B5F6) : const Color(0xFF2196F3),
        secondary: isHighContrast ? const Color(0xFF81C784) : const Color(0xFF4CAF50),
        surface: surface,
        error: AppColors.textError,
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isHighContrast
              ? const BorderSide(color: Colors.white70, width: 1.5)
              : BorderSide.none,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20 * fontScale,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 56), // Minimum touch target 48x48
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontSize: 16 * fontScale,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: Colors.white70, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontSize: 16 * fontScale,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
