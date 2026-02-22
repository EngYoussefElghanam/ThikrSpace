import 'package:flutter/material.dart';

class AppTypography {
  static const TextTheme textTheme = TextTheme(
    headlineLarge:
        TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
    titleLarge:
        TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2),
    titleMedium:
        TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.2),
    bodyLarge:
        TextStyle(fontSize: 16, fontWeight: FontWeight.normal, height: 1.5),
    bodyMedium:
        TextStyle(fontSize: 14, fontWeight: FontWeight.normal, height: 1.4),
    labelLarge: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600, height: 1.0), // Buttons
    bodySmall: TextStyle(
        fontSize: 12, fontWeight: FontWeight.normal, height: 1.4), // Captions
  );
}
