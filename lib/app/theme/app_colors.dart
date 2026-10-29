import 'package:flutter/material.dart';

class AppColors {
  // WCAG AAA high contrast palettes
  static const Color primaryDark = Color(0xFF0D1B2A);
  static const Color surfaceDark = Color(0xFF1B263B);
  static const Color cardDark = Color(0xFF273852);
  static const Color backgroundDark = Color(0xFF0A0F18);

  static const Color textHighContrast = Color(0xFFFFFFFF);
  static const Color textMutedDark = Color(0xFFB0C4DE);
  static const Color textWarning = Color(0xFFFFD166);
  static const Color textError = Color(0xFFFF6B6B);
  static const Color textSuccess = Color(0xFF06D6A0);

  // Status Colors
  static const Color statusListening = Color(0xFF00E676); // High visibility green
  static const Color statusPaused = Color(0xFFFFC107);    // Amber
  static const Color statusStopped = Color(0xFF9E9E9E);   // Neutral grey
  static const Color statusError = Color(0xFFFF5252);     // Red
  static const Color statusInitializing = Color(0xFF40C4FF); // Cyan
}
