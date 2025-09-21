import 'package:flutter/material.dart';

/// Theme configuration for the application
/// Provides consistent theming across the app with Material Design 3
class ThemeConfig {
  ThemeConfig._();

  /// Primary seed color for Material Design 3 color scheme generation
  static const Color primarySeed = Color(0xFF6750A4);

  /// Light theme configuration
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primarySeed,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      typography: _typography,
      textTheme: _textTheme,
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _outlinedButtonTheme(colorScheme),
      textButtonTheme: _textButtonTheme(colorScheme),
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
      cardTheme: _cardTheme,
      appBarTheme: _appBarTheme(colorScheme),
      bottomNavigationBarTheme: _bottomNavigationBarTheme(colorScheme),
      navigationRailTheme: _navigationRailTheme(colorScheme),
      chipTheme: _chipTheme(colorScheme),
      snackBarTheme: _snackBarTheme,
      dialogTheme: _dialogTheme,
      dividerTheme: _dividerTheme,
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      typography: _typography,
      textTheme: _textTheme,
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _outlinedButtonTheme(colorScheme),
      textButtonTheme: _textButtonTheme(colorScheme),
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
      cardTheme: _cardTheme,
      appBarTheme: _appBarTheme(colorScheme),
      bottomNavigationBarTheme: _bottomNavigationBarTheme(colorScheme),
      navigationRailTheme: _navigationRailTheme(colorScheme),
      chipTheme: _chipTheme(colorScheme),
      snackBarTheme: _snackBarTheme,
      dialogTheme: _dialogTheme,
      dividerTheme: _dividerTheme,
    );
  }

  /// Typography configuration
  static Typography get _typography => Typography.material2021();

  /// Text theme configuration
  static TextTheme get _textTheme {
    return const TextTheme(
      displayLarge: TextStyle(fontSize: 57, height: 64 / 57, letterSpacing: -0.25),
      displayMedium: TextStyle(fontSize: 45, height: 52 / 45),
      displaySmall: TextStyle(fontSize: 36, height: 44 / 36),
      headlineLarge: TextStyle(fontSize: 32, height: 40 / 32),
      headlineMedium: TextStyle(fontSize: 28, height: 36 / 28),
      headlineSmall: TextStyle(fontSize: 24, height: 32 / 24),
      titleLarge: TextStyle(fontSize: 22, height: 28 / 22),
      titleMedium: TextStyle(fontSize: 16, height: 24 / 16, letterSpacing: 0.15),
      titleSmall: TextStyle(fontSize: 14, height: 20 / 14, letterSpacing: 0.1),
      bodyLarge: TextStyle(fontSize: 16, height: 24 / 16, letterSpacing: 0.5),
      bodyMedium: TextStyle(fontSize: 14, height: 20 / 14, letterSpacing: 0.25),
      bodySmall: TextStyle(fontSize: 12, height: 16 / 12, letterSpacing: 0.4),
      labelLarge: TextStyle(fontSize: 14, height: 20 / 14, letterSpacing: 0.1),
      labelMedium: TextStyle(fontSize: 12, height: 16 / 12, letterSpacing: 0.5),
      labelSmall: TextStyle(fontSize: 11, height: 16 / 11, letterSpacing: 0.5),
    );
  }

  /// Elevated button theme
  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(64, 40),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  /// Outlined button theme
  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 40),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  /// Text button theme
  static TextButtonThemeData _textButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(64, 40),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  /// Input decoration theme
  static InputDecorationTheme _inputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
    );
  }

  /// Card theme
  static CardThemeData get _cardTheme {
    return CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }

  /// App bar theme
  static AppBarTheme _appBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 3,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
    );
  }

  /// Bottom navigation bar theme
  static BottomNavigationBarThemeData _bottomNavigationBarTheme(ColorScheme colorScheme) {
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      elevation: 3,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      showUnselectedLabels: true,
    );
  }

  /// Navigation rail theme
  static NavigationRailThemeData _navigationRailTheme(ColorScheme colorScheme) {
    return NavigationRailThemeData(
      elevation: 0,
      backgroundColor: colorScheme.surface,
      selectedIconTheme: IconThemeData(color: colorScheme.onSecondaryContainer),
      unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      selectedLabelTextStyle: TextStyle(color: colorScheme.onSurface),
      unselectedLabelTextStyle: TextStyle(color: colorScheme.onSurfaceVariant),
    );
  }

  /// Chip theme
  static ChipThemeData _chipTheme(ColorScheme colorScheme) {
    return ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Snack bar theme
  static SnackBarThemeData get _snackBarTheme {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Dialog theme
  static DialogThemeData get _dialogTheme {
    return DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }

  /// Divider theme
  static DividerThemeData get _dividerTheme {
    return const DividerThemeData(
      space: 1,
      thickness: 1,
    );
  }

  /// Spacing system following Material Design 3 guidelines
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space56 = 56;
  static const double space64 = 64;

  /// Border radius values
  static const double radiusSmall = 4;
  static const double radiusMedium = 8;
  static const double radiusLarge = 12;
  static const double radiusExtraLarge = 16;
  static const double radiusCircular = 100;

  /// Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
}