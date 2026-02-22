import 'package:flutter/material.dart';
import '../storage/hive_service.dart';

// --- CONTRACT ---
abstract class ThemeRepository {
  Future<void> saveThemeMode(ThemeMode mode);
  ThemeMode getThemeMode();
}

// --- IMPLEMENTATION ---
class ThemeRepositoryImpl implements ThemeRepository {
  static const String _themeKey = 'theme_mode';

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    // We store the enum as a simple string ('system', 'light', 'dark')
    // This avoids needing to write custom Hive TypeAdapters for a single enum.
    await HiveService.instance.put(BoxNames.appMeta, _themeKey, mode.name);
  }

  @override
  ThemeMode getThemeMode() {
    // Read the string from our appMeta box
    final themeString =
        HiveService.instance.get<String>(BoxNames.appMeta, _themeKey);

    // Map the string back to the Flutter enum. Default to system if null.
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
