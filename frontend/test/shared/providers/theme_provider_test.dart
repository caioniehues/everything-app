import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/provider_helpers.dart';

void main() {
  group('ThemeModeNotifier', () {
    late Map<String, Object> mockPreferences;

    setUp(() {
      mockPreferences = {};
      SharedPreferences.setMockInitialValues(mockPreferences);
    });

    test('initial state is system theme', () async {
      final container = createContainer();
      final themeMode = container.read(themeModeProvider);

      expect(themeMode, equals(ThemeMode.system));
    });

    test('loads saved theme mode from SharedPreferences', () async {
      // Set up mock preferences with dark theme
      mockPreferences['themeMode'] = 'dark';
      SharedPreferences.setMockInitialValues(mockPreferences);

      final container = createContainer();

      // Wait for async initialization to complete
      await Future.delayed(const Duration(milliseconds: 200));

      final themeMode = container.read(themeModeProvider);
      expect(themeMode, equals(ThemeMode.dark));
    });

    test('setThemeMode changes theme and persists', () async {
      final container = createContainer();
      final notifier = container.read(themeModeProvider.notifier);

      // Set to dark theme
      await notifier.setThemeMode(ThemeMode.dark);

      // Verify state changed
      expect(container.read(themeModeProvider), equals(ThemeMode.dark));

      // Verify persisted to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('themeMode'), equals('dark'));
    });

    test('toggleTheme switches between light and dark', () async {
      final container = createContainer();
      final notifier = container.read(themeModeProvider.notifier);

      // Set initial theme to light
      await notifier.setThemeMode(ThemeMode.light);
      expect(container.read(themeModeProvider), equals(ThemeMode.light));

      // Toggle to dark
      await notifier.toggleTheme();
      expect(container.read(themeModeProvider), equals(ThemeMode.dark));

      // Toggle back to light
      await notifier.toggleTheme();
      expect(container.read(themeModeProvider), equals(ThemeMode.light));
    });

    test('toggleTheme from system defaults to light', () async {
      final container = createContainer();
      final notifier = container.read(themeModeProvider.notifier);

      // Ensure system theme is set
      await notifier.setThemeMode(ThemeMode.system);
      expect(container.read(themeModeProvider), equals(ThemeMode.system));

      // Toggle should go to light
      await notifier.toggleTheme();
      expect(container.read(themeModeProvider), equals(ThemeMode.light));
    });

    test('isDarkMode returns correct value for each theme mode', () async {
      final container = createContainer();
      final notifier = container.read(themeModeProvider.notifier);

      // Test light mode
      await notifier.setThemeMode(ThemeMode.light);
      expect(notifier.isDarkMode, isFalse);

      // Test dark mode
      await notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.isDarkMode, isTrue);

      // Test system mode (depends on platform)
      await notifier.setThemeMode(ThemeMode.system);
      // isDarkMode will depend on the test platform's brightness
      expect(notifier.isDarkMode, isA<bool>());
    });
  });

  group('Theme Providers', () {
    test('currentThemeProvider returns correct theme based on mode', () async {
      final container = createContainer();
      final notifier = container.read(themeModeProvider.notifier);

      // Set to light mode
      await notifier.setThemeMode(ThemeMode.light);
      var theme = container.read(currentThemeProvider);
      expect(theme.brightness, equals(Brightness.light));

      // Set to dark mode
      await notifier.setThemeMode(ThemeMode.dark);
      // Refresh provider to get updated value
      container.invalidate(currentThemeProvider);
      theme = container.read(currentThemeProvider);
      expect(theme.brightness, equals(Brightness.dark));
    });

    test('primaryColorProvider returns primary color from theme', () {
      final container = createContainer();

      final primaryColor = container.read(primaryColorProvider);
      expect(primaryColor, isA<Color>());
      expect(primaryColor, isNotNull);
    });

    test('backgroundColorProvider returns surface color from theme', () {
      final container = createContainer();

      final backgroundColor = container.read(backgroundColorProvider);
      expect(backgroundColor, isA<Color>());
      expect(backgroundColor, isNotNull);
    });

    test('textColorProvider returns onSurface color from theme', () {
      final container = createContainer();

      final textColor = container.read(textColorProvider);
      expect(textColor, isA<Color>());
      expect(textColor, isNotNull);
    });
  });

  group('SharedPreferences Provider', () {
    test('sharedPreferencesProvider returns SharedPreferences instance', () async {
      SharedPreferences.setMockInitialValues({});
      final container = createContainer();

      // Get the future provider
      final prefsFuture = container.read(sharedPreferencesProvider.future);
      final prefs = await prefsFuture;

      expect(prefs, isA<SharedPreferences>());
    });

    test('sharedPreferencesProvider caches instance', () async {
      SharedPreferences.setMockInitialValues({});
      final container = createContainer();

      // Get instance twice
      final prefs1 = await container.read(sharedPreferencesProvider.future);
      final prefs2 = await container.read(sharedPreferencesProvider.future);

      // Should be the same instance (cached)
      expect(identical(prefs1, prefs2), isTrue);
    });
  });
}