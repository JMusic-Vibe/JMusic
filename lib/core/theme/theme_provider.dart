import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmusic/core/services/preferences_service.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return ThemeModeNotifier(prefs);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final PreferencesService _prefs;

  ThemeModeNotifier(this._prefs) : super(_stringToThemeMode(_prefs.themeMode)) {
    // 监听偏好设置的变 
    _loadThemeMode();
  }

  static ThemeMode _stringToThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }

  Future<void> _loadThemeMode() async {
    final mode = _stringToThemeMode(_prefs.themeMode);
    state = mode;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setThemeMode(_themeModeToString(mode));
  }
}

