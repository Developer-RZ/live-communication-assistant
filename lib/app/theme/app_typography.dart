import 'package:flutter/material.dart';

class AppTypography {
  static TextStyle headlineLarge(double fontScale, Color color) => TextStyle(
        fontSize: 28 * fontScale,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: -0.5,
        height: 1.25,
      );

  static TextStyle headlineMedium(double fontScale, Color color) => TextStyle(
        fontSize: 22 * fontScale,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.25,
        height: 1.3,
      );

  static TextStyle titleLarge(double fontScale, Color color) => TextStyle(
        fontSize: 18 * fontScale,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.35,
      );

  static TextStyle bodyLarge(double fontScale, Color color) => TextStyle(
        fontSize: 16 * fontScale,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.45,
      );

  static TextStyle liveTranscript(double fontScale, Color color, {bool isPartial = false}) => TextStyle(
        fontSize: 20 * fontScale,
        fontWeight: isPartial ? FontWeight.w400 : FontWeight.w600,
        color: color,
        fontStyle: isPartial ? FontStyle.italic : FontStyle.normal,
        height: 1.5,
      );

  static TextStyle labelLarge(double fontScale, Color color) => TextStyle(
        fontSize: 14 * fontScale,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 0.5,
      );
}
