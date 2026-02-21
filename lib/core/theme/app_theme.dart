import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(AppColors.lightScheme);
  static ThemeData get darkTheme => _buildTheme(AppColors.darkScheme);

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),

      // Global Card Styling
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
        color: colorScheme.surface,
        margin: EdgeInsets.zero,
      ),

      // Global Button Styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md, horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md, horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      // Global Text Field Styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.onSurface.withOpacity(0.05),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: AppRadius.fieldRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.fieldRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.fieldRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.fieldRadius,
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
      ),

      // Global Bottom Sheet Styling
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
        backgroundColor: colorScheme.surface,
      ),
    );
  }
}
