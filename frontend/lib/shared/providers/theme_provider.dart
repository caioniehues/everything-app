import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/theme_config.dart';

/// Key for storing theme mode in SharedPreferences
const String _themeModeKey = 'themeMode';

/// Provider for SharedPreferences instance
/// This is cached and only initialized once
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// Theme mode provider with persistence
/// Manages the app's theme (light/dark/system) and persists the preference
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

/// State notifier for theme mode management
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadThemeMode();
    return ThemeMode.system;
  }

  /// Load saved theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final savedThemeMode = prefs.getString(_themeModeKey);

    if (savedThemeMode != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedThemeMode,
        orElse: () => ThemeMode.system,
      );
    }
  }

  /// Set theme mode and persist to SharedPreferences
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;

    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_themeModeKey, mode.name);
  }

  /// Toggle between light and dark theme
  /// If system theme is active, switches to light
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Check if dark mode is currently active
  bool get isDarkMode {
    if (state == ThemeMode.system) {
      // Check system brightness
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return state == ThemeMode.dark;
  }
}

/// Provider for accessing theme data based on current theme mode
final currentThemeProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  final isDark = ref.watch(themeModeProvider.notifier).isDarkMode;

  return isDark ? ThemeConfig.darkTheme : ThemeConfig.lightTheme;
});

/// Provider for primary color based on current theme
final primaryColorProvider = Provider<Color>((ref) {
  final theme = ref.watch(currentThemeProvider);
  return theme.colorScheme.primary;
});

/// Provider for background color based on current theme
final backgroundColorProvider = Provider<Color>((ref) {
  final theme = ref.watch(currentThemeProvider);
  return theme.colorScheme.surface;
});

/// Provider for text color based on current theme
final textColorProvider = Provider<Color>((ref) {
  final theme = ref.watch(currentThemeProvider);
  return theme.colorScheme.onSurface;
});