import 'package:flutter/material.dart';

/// Material Design 3 color schemes for the Everything App
/// Based on the brand colors and Material You guidelines
class AppColorSchemes {
  AppColorSchemes._();

  /// Everything App brand colors
  static const Color brandPrimary = Color(0xFF6750A4);
  static const Color brandSecondary = Color(0xFF625B71);
  static const Color brandTertiary = Color(0xFF7D5260);

  /// Light color scheme following Material Design 3
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,

    // Primary colors
    primary: Color(0xFF6750A4),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFEADDFF),
    onPrimaryContainer: Color(0xFF21005D),
    primaryFixed: Color(0xFFEADDFF),
    onPrimaryFixed: Color(0xFF21005D),
    primaryFixedDim: Color(0xFFD0BCFF),
    onPrimaryFixedVariant: Color(0xFF4F378B),

    // Secondary colors
    secondary: Color(0xFF625B71),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE8DEF8),
    onSecondaryContainer: Color(0xFF1D192B),
    secondaryFixed: Color(0xFFE8DEF8),
    onSecondaryFixed: Color(0xFF1D192B),
    secondaryFixedDim: Color(0xFFCCC2DC),
    onSecondaryFixedVariant: Color(0xFF4A4458),

    // Tertiary colors
    tertiary: Color(0xFF7D5260),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFD8E4),
    onTertiaryContainer: Color(0xFF31111D),
    tertiaryFixed: Color(0xFFFFD8E4),
    onTertiaryFixed: Color(0xFF31111D),
    tertiaryFixedDim: Color(0xFFEFB8C8),
    onTertiaryFixedVariant: Color(0xFF633B48),

    // Error colors
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),

    // Surface colors
    surface: Color(0xFFFEF7FF),
    onSurface: Color(0xFF1D1B20),
    surfaceDim: Color(0xFFDED8E1),
    surfaceBright: Color(0xFFFEF7FF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF7F2FA),
    surfaceContainer: Color(0xFFF3EDF7),
    surfaceContainerHigh: Color(0xFFECE6F0),
    surfaceContainerHighest: Color(0xFFE6E0E9),

    // Outline colors
    outline: Color(0xFF79747E),
    outlineVariant: Color(0xFFCAC4D0),

    // Shadow and scrim
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),

    // Inverse colors
    inverseSurface: Color(0xFF322F35),
    onInverseSurface: Color(0xFFF5EFF7),
    inversePrimary: Color(0xFFD0BCFF),

    // Surface tint
    surfaceTint: Color(0xFF6750A4),
  );

  /// Dark color scheme following Material Design 3
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,

    // Primary colors
    primary: Color(0xFFD0BCFF),
    onPrimary: Color(0xFF371E73),
    primaryContainer: Color(0xFF4F378B),
    onPrimaryContainer: Color(0xFFEADDFF),
    primaryFixed: Color(0xFFEADDFF),
    onPrimaryFixed: Color(0xFF21005D),
    primaryFixedDim: Color(0xFFD0BCFF),
    onPrimaryFixedVariant: Color(0xFF4F378B),

    // Secondary colors
    secondary: Color(0xFFCCC2DC),
    onSecondary: Color(0xFF332D41),
    secondaryContainer: Color(0xFF4A4458),
    onSecondaryContainer: Color(0xFFE8DEF8),
    secondaryFixed: Color(0xFFE8DEF8),
    onSecondaryFixed: Color(0xFF1D192B),
    secondaryFixedDim: Color(0xFFCCC2DC),
    onSecondaryFixedVariant: Color(0xFF4A4458),

    // Tertiary colors
    tertiary: Color(0xFFEFB8C8),
    onTertiary: Color(0xFF492532),
    tertiaryContainer: Color(0xFF633B48),
    onTertiaryContainer: Color(0xFFFFD8E4),
    tertiaryFixed: Color(0xFFFFD8E4),
    onTertiaryFixed: Color(0xFF31111D),
    tertiaryFixedDim: Color(0xFFEFB8C8),
    onTertiaryFixedVariant: Color(0xFF633B48),

    // Error colors
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),

    // Surface colors
    surface: Color(0xFF141218),
    onSurface: Color(0xFFE6E0E9),
    surfaceDim: Color(0xFF141218),
    surfaceBright: Color(0xFF3B383E),
    surfaceContainerLowest: Color(0xFF0F0D13),
    surfaceContainerLow: Color(0xFF1D1B20),
    surfaceContainer: Color(0xFF211F26),
    surfaceContainerHigh: Color(0xFF2B2930),
    surfaceContainerHighest: Color(0xFF36343B),

    // Outline colors
    outline: Color(0xFF938F99),
    outlineVariant: Color(0xFF49454F),

    // Shadow and scrim
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),

    // Inverse colors
    inverseSurface: Color(0xFFE6E0E9),
    onInverseSurface: Color(0xFF322F35),
    inversePrimary: Color(0xFF6750A4),

    // Surface tint
    surfaceTint: Color(0xFFD0BCFF),
  );

  /// Semantic colors for financial app context
  static const Color success = Color(0xFF4CAF50);
  static const Color successContainer = Color(0xFFE8F5E8);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onSuccessContainer = Color(0xFF2E7D2E);

  static const Color warning = Color(0xFFFF9800);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color onWarningContainer = Color(0xFFE65100);

  static const Color info = Color(0xFF2196F3);
  static const Color infoContainer = Color(0xFFE3F2FD);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color onInfoContainer = Color(0xFF0D47A1);

  /// Financial semantic colors
  static const Color income = Color(0xFF4CAF50);
  static const Color expense = Color(0xFFF44336);
  static const Color neutral = Color(0xFF9E9E9E);

  /// Transaction category colors
  static const List<Color> categoryColors = [
    Color(0xFF6750A4), // Primary
    Color(0xFF625B71), // Secondary
    Color(0xFF7D5260), // Tertiary
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFFE91E63), // Pink
    Color(0xFF009688), // Teal
  ];

  /// Get category color by index
  static Color getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }

  /// Create custom color scheme for specific themes
  static ColorScheme createCustomColorScheme({
    required Color seedColor,
    required Brightness brightness,
  }) {
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
  }

  /// Gradient collections for charts and visualizations
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6750A4), Color(0xFF4F378B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF2E7D2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFF44336), Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient radialGradient = RadialGradient(
    colors: [Color(0xFF6750A4), Color(0xFF21005D)],
    radius: 1,
  );

  /// Color utilities
  static Color getContrastColor(Color backgroundColor) {
    // Calculate luminance
    final luminance = backgroundColor.computeLuminance();

    // Return black for light backgrounds, white for dark backgrounds
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Get appropriate surface color based on elevation
  static Color getSurfaceColor({
    required ColorScheme colorScheme,
    required int elevation,
  }) {
    switch (elevation) {
      case 0:
        return colorScheme.surface;
      case 1:
        return colorScheme.surfaceContainerLow;
      case 2:
        return colorScheme.surfaceContainer;
      case 3:
        return colorScheme.surfaceContainerHigh;
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }

  /// Create color scheme from brand colors
  static ColorScheme createBrandColorScheme(Brightness brightness) {
    return ColorScheme.fromSeed(
      seedColor: brandPrimary,
      brightness: brightness,
      secondary: brandSecondary,
      tertiary: brandTertiary,
    );
  }
}