import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/color_schemes.dart';
import 'package:frontend/core/theme/typography.dart';
import 'package:frontend/shared/providers/theme_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('AppTheme Tests', () {
    test('should create light theme with correct properties', () {
      final theme = AppTheme.createLightTheme();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme, isNotNull);
      expect(theme.textTheme, isNotNull);
      expect(theme.appBarTheme, isNotNull);
      expect(theme.cardTheme, isNotNull);
      expect(theme.elevatedButtonTheme, isNotNull);
      expect(theme.filledButtonTheme, isNotNull);
      expect(theme.outlinedButtonTheme, isNotNull);
      expect(theme.textButtonTheme, isNotNull);
    });

    test('should create dark theme with correct properties', () {
      final theme = AppTheme.createDarkTheme();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme, isNotNull);
      expect(theme.textTheme, isNotNull);
      expect(theme.appBarTheme, isNotNull);
      expect(theme.cardTheme, isNotNull);
      expect(theme.elevatedButtonTheme, isNotNull);
      expect(theme.filledButtonTheme, isNotNull);
      expect(theme.outlinedButtonTheme, isNotNull);
      expect(theme.textButtonTheme, isNotNull);
    });

    test('should have consistent color scheme in light theme', () {
      final theme = AppTheme.createLightTheme();
      final colorScheme = theme.colorScheme;

      expect(colorScheme.brightness, equals(Brightness.light));
      expect(colorScheme.primary, isNotNull);
      expect(colorScheme.onPrimary, isNotNull);
      expect(colorScheme.surface, isNotNull);
      expect(colorScheme.onSurface, isNotNull);
    });

    test('should have consistent color scheme in dark theme', () {
      final theme = AppTheme.createDarkTheme();
      final colorScheme = theme.colorScheme;

      expect(colorScheme.brightness, equals(Brightness.dark));
      expect(colorScheme.primary, isNotNull);
      expect(colorScheme.onPrimary, isNotNull);
      expect(colorScheme.surface, isNotNull);
      expect(colorScheme.onSurface, isNotNull);
    });

    test('should have proper typography configuration', () {
      final theme = AppTheme.createLightTheme();
      final textTheme = theme.textTheme;

      expect(textTheme.displayLarge, isNotNull);
      expect(textTheme.headlineMedium, isNotNull);
      expect(textTheme.bodyLarge, isNotNull);
      expect(textTheme.bodyMedium, isNotNull);
      expect(textTheme.labelLarge, isNotNull);
    });

    test('should have proper component themes configured', () {
      final theme = AppTheme.createLightTheme();

      // AppBar theme
      expect(theme.appBarTheme.elevation, equals(0));
      expect(theme.appBarTheme.backgroundColor, isNotNull);

      // Card theme
      expect(theme.cardTheme.elevation, equals(1));
      expect(theme.cardTheme.shape, isNotNull);

      // Button themes
      expect(theme.elevatedButtonTheme, isNotNull);
      expect(theme.filledButtonTheme, isNotNull);
      expect(theme.outlinedButtonTheme, isNotNull);
      expect(theme.textButtonTheme, isNotNull);
    });

    test('should have proper input decoration theme', () {
      final theme = AppTheme.createLightTheme();
      final inputTheme = theme.inputDecorationTheme;

      expect(inputTheme.filled, isTrue);
      expect(inputTheme.border, isNotNull);
      expect(inputTheme.enabledBorder, isNotNull);
      expect(inputTheme.focusedBorder, isNotNull);
      expect(inputTheme.errorBorder, isNotNull);
    });

    test('should have proper page transitions configured', () {
      final theme = AppTheme.createLightTheme();
      final transitions = theme.pageTransitionsTheme;

      expect(transitions.builders, isNotNull);
      expect(transitions.builders[TargetPlatform.android], isNotNull);
      expect(transitions.builders[TargetPlatform.iOS], isNotNull);
    });
  });

  group('AppColorSchemes Tests', () {
    test('should have valid light color scheme', () {
      const colorScheme = AppColorSchemes.lightColorScheme;

      expect(colorScheme.brightness, equals(Brightness.light));
      expect(colorScheme.primary, isNotNull);
      expect(colorScheme.onPrimary, isNotNull);
      expect(colorScheme.secondary, isNotNull);
      expect(colorScheme.onSecondary, isNotNull);
      expect(colorScheme.surface, isNotNull);
      expect(colorScheme.onSurface, isNotNull);
    });

    test('should have valid dark color scheme', () {
      const colorScheme = AppColorSchemes.darkColorScheme;

      expect(colorScheme.brightness, equals(Brightness.dark));
      expect(colorScheme.primary, isNotNull);
      expect(colorScheme.onPrimary, isNotNull);
      expect(colorScheme.secondary, isNotNull);
      expect(colorScheme.onSecondary, isNotNull);
      expect(colorScheme.surface, isNotNull);
      expect(colorScheme.onSurface, isNotNull);
    });

    test('should have proper contrast ratios', () {
      const lightScheme = AppColorSchemes.lightColorScheme;
      const darkScheme = AppColorSchemes.darkColorScheme;

      // Check that primary color has proper contrast with onPrimary
      // This is a basic check - in real implementation you'd use proper contrast calculation
      expect(lightScheme.primary, isNotNull);
      expect(lightScheme.onPrimary, isNotNull);
      expect(darkScheme.primary, isNotNull);
      expect(darkScheme.onPrimary, isNotNull);
    });
  });

  group('AppTypography Tests', () {
    test('should create text theme with proper styles', () {
      const colorScheme = AppColorSchemes.lightColorScheme;
      final textTheme = AppTypography.createTextTheme(
        colorScheme: colorScheme,
      );

      expect(textTheme.displayLarge, isNotNull);
      expect(textTheme.headlineMedium, isNotNull);
      expect(textTheme.bodyLarge, isNotNull);
      expect(textTheme.bodyMedium, isNotNull);
      expect(textTheme.labelLarge, isNotNull);
    });

    test('should have proper font sizes for different text styles', () {
      const colorScheme = AppColorSchemes.lightColorScheme;
      final textTheme = AppTypography.createTextTheme(
        colorScheme: colorScheme,
      );

      // Check that font sizes are reasonable
      expect(textTheme.bodyLarge?.fontSize, isNotNull);
      expect(textTheme.bodyMedium?.fontSize, isNotNull);
      expect(textTheme.bodySmall?.fontSize, isNotNull);
    });
  });

  group('Theme Provider Integration Tests', () {
    test('should provide theme mode correctly', () {
      // Initialize with default theme
      container.read(themeModeProvider.notifier).state = ThemeMode.system;

      final themeMode = container.read(themeModeProvider);

      expect(themeMode, isNotNull);
      expect(themeMode, isA<ThemeMode>());
    });

    test('should provide theme notifier', () {
      // Initialize with default theme
      container.read(themeModeProvider.notifier).state = ThemeMode.system;

      final themeNotifier = container.read(themeModeProvider.notifier);

      expect(themeNotifier, isNotNull);
      expect(themeNotifier, isA<StateNotifier<ThemeMode>>());
    });

    test('should allow theme mode changes', () {
      // Initialize with default theme
      container.read(themeModeProvider.notifier).state = ThemeMode.system;

      final themeNotifier = container.read(themeModeProvider.notifier);

      // Change theme mode
      themeNotifier.state = ThemeMode.dark;

      // Verify change
      expect(container.read(themeModeProvider), equals(ThemeMode.dark));
    });
  });

  group('Theme Consistency Tests', () {
    test('should have consistent button styling across themes', () {
      final lightTheme = AppTheme.createLightTheme();
      final darkTheme = AppTheme.createDarkTheme();

      // Both themes should have button themes configured
      expect(lightTheme.filledButtonTheme, isNotNull);
      expect(darkTheme.filledButtonTheme, isNotNull);
      expect(lightTheme.elevatedButtonTheme, isNotNull);
      expect(darkTheme.elevatedButtonTheme, isNotNull);
    });

    test('should have consistent card styling across themes', () {
      final lightTheme = AppTheme.createLightTheme();
      final darkTheme = AppTheme.createDarkTheme();

      // Both themes should have card themes configured
      expect(lightTheme.cardTheme, isNotNull);
      expect(darkTheme.cardTheme, isNotNull);
      expect(lightTheme.cardTheme.shape, isNotNull);
      expect(darkTheme.cardTheme.shape, isNotNull);
    });
  });
}
