import 'package:flutter/material.dart';

class AppColors {
  // Primary Accent: A calm, deep Emerald/Teal
  static const Color primary = Color(0xFF0F766E); // Tailwind Teal 600
  static const Color primaryDark = Color(0xFF2DD4BF); // Tailwind Teal 400

  static const ColorScheme lightScheme = ColorScheme.light(
    primary: primary,
    onPrimary: Colors.white,
    secondary: Color(0xFF0369A1),
    onSecondary: Colors.white,
    surface: Color.fromARGB(255, 222, 222, 222), // Very light gray background
    onSurface: Color(0xFF0F172A), // Dark slate text
    error: Color(0xFFDC2626),
    onError: Colors.white,
  );

  static const ColorScheme darkScheme = ColorScheme.dark(
    primary: primaryDark,
    onPrimary: Color(0xFF042F2E),
    secondary: Color(0xFF38BDF8),
    onSecondary: Color(0xFF0C4A6E),
    surface: Color(0xFF0F172A), // Dark slate background
    onSurface: Color(0xFFF8FAFC), // Light text
    error: Color(0xFFEF4444),
    onError: Colors.white,
  );
}
