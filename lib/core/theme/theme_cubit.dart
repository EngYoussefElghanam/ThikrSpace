import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_repository.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final ThemeRepository _repository;

  // 1. Start safely with system default BEFORE Hive is ready
  ThemeCubit(this._repository) : super(ThemeMode.system);

  // 2. Add a load method to call AFTER Hive initializes
  void loadTheme() {
    try {
      emit(_repository.getThemeMode());
    } catch (_) {
      // Fallback if Hive fails
      emit(ThemeMode.system);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _repository.saveThemeMode(mode);
    emit(mode);
  }
}
