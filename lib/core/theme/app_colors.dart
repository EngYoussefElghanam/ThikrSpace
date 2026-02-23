import 'package:flutter/material.dart';

/// ThikrSpace palette (matches Etsy banner vibe):
/// - Parchment + Camel Gold + Ink Charcoal
/// RULE: All raw hex stays in this file only.
class AppColors {
  // Brand anchors
  static const Color ink = Color(0xFF1F2427); // deep charcoal
  static const Color inkSoft =
      Color(0xFF3A4046); // softer charcoal for secondary text

  static const Color parchment = Color(0xFFF6F2EA); // warm paper background
  static const Color surface =
      Color(0xFFFEFDFB); // near-white (premium, not harsh)
  static const Color surfaceAlt = Color(0xFFF0E8DA); // warm elevated surface
  static const Color outline = Color(0xFFE3DAC7); // subtle borders/dividers

  // Camel gold (from your banner gold range, tuned to be premium)
  static const Color gold = Color(0xFFC3A46E);
  static const Color goldSoft =
      Color(0xFFD8C09A); // lighter gold for containers

  // Dark mode (warm, not bluish)
  static const Color darkBg = Color(0xFF0F1112);
  static const Color darkSurface = Color(0xFF171A1C);
  static const Color darkSurfaceAlt = Color(0xFF1E2225);
  static const Color darkOutline = Color(0xFF2C3136);

  static const Color darkText = Color(0xFFEDE6DB);
  static const Color darkTextSoft = Color(0xFFBDB4A7);

  // Status
  static const Color errorLight = Color(0xFFB3261E);
  static const Color errorDark = Color(0xFFFFB4AB);

  static const ColorScheme lightScheme = ColorScheme.light(
    // Brand actions / accents
    primary: gold,
    onPrimary: ink,
    primaryContainer: goldSoft,
    onPrimaryContainer: ink,

    // Secondary emphasis (ink-based chips/labels if needed)
    secondary: ink,
    onSecondary: parchment,
    secondaryContainer: surfaceAlt,
    onSecondaryContainer: ink,

    // Surfaces
    background: parchment,
    onBackground: ink,
    surface: surface,
    onSurface: ink,
    surfaceVariant: surfaceAlt,
    onSurfaceVariant: inkSoft,

    // Lines / elevation tint
    outline: outline,
    surfaceTint: gold,

    // Errors
    error: errorLight,
    onError: Color(0xFFFFFFFF),
  );

  static const ColorScheme darkScheme = ColorScheme.dark(
    // Keep gold as the brand accent in dark mode too (slightly brighter)
    primary: Color(0xFFD2B07A),
    onPrimary: Color(0xFF0E1011),
    primaryContainer: Color(0xFF9E8456),
    onPrimaryContainer: darkText,

    // Secondary stays warm + readable (avoid cold grays)
    secondary: Color(0xFFE2D4BE),
    onSecondary: Color(0xFF0E1011),
    secondaryContainer: darkSurfaceAlt,
    onSecondaryContainer: darkText,

    // Surfaces
    background: darkBg,
    onBackground: darkText,
    surface: darkSurface,
    onSurface: darkText,
    surfaceVariant: darkSurfaceAlt,
    onSurfaceVariant: darkTextSoft,

    outline: darkOutline,
    surfaceTint: Color(0xFFD2B07A),

    error: errorDark,
    onError: Color(0xFF0E1011),
  );

  /// Extra semantic colors that you’ll actually use in the UI kit
  /// (use these instead of inventing new ones in screens).
  static const AppExtras extrasLight = AppExtras(
    divider: outline,
    textSecondary: inkSoft,
    surfaceAlt: surfaceAlt,
  );

  static const AppExtras extrasDark = AppExtras(
    divider: darkOutline,
    textSecondary: darkTextSoft,
    surfaceAlt: darkSurfaceAlt,
  );
}

class AppExtras {
  final Color divider;
  final Color textSecondary;
  final Color surfaceAlt;
  const AppExtras({
    required this.divider,
    required this.textSecondary,
    required this.surfaceAlt,
  });
}
