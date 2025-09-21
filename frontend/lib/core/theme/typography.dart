import 'package:flutter/material.dart';

/// Material Design 3 typography system for the Everything App
/// Implements the latest Material You typography guidelines
class AppTypography {
  AppTypography._();

  /// Base font family
  static const String fontFamily = 'Roboto';
  static const String displayFontFamily = 'Roboto';

  /// Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  /// Create Material Design 3 text theme
  static TextTheme createTextTheme({
    required ColorScheme colorScheme,
    String? fontFamily,
    String? displayFontFamily,
  }) {
    final baseTextTheme = Typography.material2021().black;
    final String bodyFont = fontFamily ?? AppTypography.fontFamily;
    final String displayFont = displayFontFamily ?? AppTypography.displayFontFamily;

    return baseTextTheme.copyWith(
      // Display styles (largest)
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontFamily: displayFont,
        fontSize: 57,
        fontWeight: regular,
        letterSpacing: -0.25,
        height: 1.12,
        color: colorScheme.onSurface,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontFamily: displayFont,
        fontSize: 45,
        fontWeight: regular,
        letterSpacing: 0,
        height: 1.16,
        color: colorScheme.onSurface,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontFamily: displayFont,
        fontSize: 36,
        fontWeight: regular,
        letterSpacing: 0,
        height: 1.22,
        color: colorScheme.onSurface,
      ),

      // Headline styles
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontFamily: displayFont,
        fontSize: 32,
        fontWeight: regular,
        letterSpacing: 0,
        height: 1.25,
        color: colorScheme.onSurface,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontFamily: displayFont,
        fontSize: 28,
        fontWeight: regular,
        letterSpacing: 0,
        height: 1.29,
        color: colorScheme.onSurface,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontFamily: displayFont,
        fontSize: 24,
        fontWeight: regular,
        letterSpacing: 0,
        height: 1.33,
        color: colorScheme.onSurface,
      ),

      // Title styles
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontFamily: bodyFont,
        fontSize: 22,
        fontWeight: regular,
        letterSpacing: 0,
        height: 1.27,
        color: colorScheme.onSurface,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontFamily: bodyFont,
        fontSize: 16,
        fontWeight: medium,
        letterSpacing: 0.15,
        height: 1.50,
        color: colorScheme.onSurface,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontFamily: bodyFont,
        fontSize: 14,
        fontWeight: medium,
        letterSpacing: 0.1,
        height: 1.43,
        color: colorScheme.onSurface,
      ),

      // Body styles
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontFamily: bodyFont,
        fontSize: 16,
        fontWeight: regular,
        letterSpacing: 0.5,
        height: 1.50,
        color: colorScheme.onSurface,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontFamily: bodyFont,
        fontSize: 14,
        fontWeight: regular,
        letterSpacing: 0.25,
        height: 1.43,
        color: colorScheme.onSurface,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontFamily: bodyFont,
        fontSize: 12,
        fontWeight: regular,
        letterSpacing: 0.4,
        height: 1.33,
        color: colorScheme.onSurfaceVariant,
      ),

      // Label styles
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontFamily: bodyFont,
        fontSize: 14,
        fontWeight: medium,
        letterSpacing: 0.1,
        height: 1.43,
        color: colorScheme.onSurface,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontFamily: bodyFont,
        fontSize: 12,
        fontWeight: medium,
        letterSpacing: 0.5,
        height: 1.33,
        color: colorScheme.onSurface,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontFamily: bodyFont,
        fontSize: 11,
        fontWeight: medium,
        letterSpacing: 0.5,
        height: 1.45,
        color: colorScheme.onSurface,
      ),
    );
  }
}

/// Custom text styles for specific use cases
class CustomTextStyles {
  CustomTextStyles._();

  /// Financial amount styling
  static TextStyle amount({
    required ColorScheme colorScheme,
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 0,
      height: 1.2,
      color: color ?? colorScheme.onSurface,
      fontFeatures: const [FontFeature.tabularFigures()], // Monospace numbers
    );
  }

  /// Currency display
  static TextStyle currency({
    required ColorScheme colorScheme,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 0.1,
      height: 1.3,
      color: color ?? colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Card title styling
  static TextStyle cardTitle({
    required ColorScheme colorScheme,
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 0,
      height: 1.33,
      color: colorScheme.onSurface,
    );
  }

  /// Card subtitle styling
  static TextStyle cardSubtitle({
    required ColorScheme colorScheme,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 0.25,
      height: 1.43,
      color: colorScheme.onSurfaceVariant,
    );
  }

  /// Button text styling
  static TextStyle button({
    required ColorScheme colorScheme,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 0.1,
      height: 1.43,
      color: color,
    );
  }

  /// Caption with error styling
  static TextStyle error({
    required ColorScheme colorScheme,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 0.4,
      height: 1.33,
      color: colorScheme.error,
    );
  }

  /// Success message styling
  static TextStyle success({
    required ColorScheme colorScheme,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 0.4,
      height: 1.33,
      color: const Color(0xFF4CAF50), // Success color
    );
  }

  /// Overline text (for sections, categories, etc.)
  static TextStyle overline({
    required ColorScheme colorScheme,
    double fontSize = 10,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 1.5,
      height: 1.6,
      color: colorScheme.onSurfaceVariant,
    );
  }

  /// Navigation label styling
  static TextStyle navigationLabel({
    required ColorScheme colorScheme,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w500,
    bool isSelected = false,
  }) {
    return TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 0.5,
      height: 1.33,
      color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
    );
  }
}

/// Responsive text scaling
class ResponsiveTypography {
  ResponsiveTypography._();

  /// Get scale factor based on screen size
  static double getScaleFactor(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    if (width < 600) {
      return 0.9; // Mobile - slightly smaller
    } else if (width < 1200) {
      return 1; // Tablet - standard
    } else {
      return 1.1; // Desktop - slightly larger
    }
  }

  /// Apply responsive scaling to text theme
  static TextTheme scaleTextTheme(TextTheme textTheme, double scaleFactor) {
    return textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(
        fontSize: (textTheme.displayLarge?.fontSize ?? 57) * scaleFactor,
      ),
      displayMedium: textTheme.displayMedium?.copyWith(
        fontSize: (textTheme.displayMedium?.fontSize ?? 45) * scaleFactor,
      ),
      displaySmall: textTheme.displaySmall?.copyWith(
        fontSize: (textTheme.displaySmall?.fontSize ?? 36) * scaleFactor,
      ),
      headlineLarge: textTheme.headlineLarge?.copyWith(
        fontSize: (textTheme.headlineLarge?.fontSize ?? 32) * scaleFactor,
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontSize: (textTheme.headlineMedium?.fontSize ?? 28) * scaleFactor,
      ),
      headlineSmall: textTheme.headlineSmall?.copyWith(
        fontSize: (textTheme.headlineSmall?.fontSize ?? 24) * scaleFactor,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontSize: (textTheme.titleLarge?.fontSize ?? 22) * scaleFactor,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontSize: (textTheme.titleMedium?.fontSize ?? 16) * scaleFactor,
      ),
      titleSmall: textTheme.titleSmall?.copyWith(
        fontSize: (textTheme.titleSmall?.fontSize ?? 14) * scaleFactor,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(
        fontSize: (textTheme.bodyLarge?.fontSize ?? 16) * scaleFactor,
      ),
      bodyMedium: textTheme.bodyMedium?.copyWith(
        fontSize: (textTheme.bodyMedium?.fontSize ?? 14) * scaleFactor,
      ),
      bodySmall: textTheme.bodySmall?.copyWith(
        fontSize: (textTheme.bodySmall?.fontSize ?? 12) * scaleFactor,
      ),
      labelLarge: textTheme.labelLarge?.copyWith(
        fontSize: (textTheme.labelLarge?.fontSize ?? 14) * scaleFactor,
      ),
      labelMedium: textTheme.labelMedium?.copyWith(
        fontSize: (textTheme.labelMedium?.fontSize ?? 12) * scaleFactor,
      ),
      labelSmall: textTheme.labelSmall?.copyWith(
        fontSize: (textTheme.labelSmall?.fontSize ?? 11) * scaleFactor,
      ),
    );
  }

  /// Get responsive text theme
  static TextTheme getResponsiveTextTheme({
    required BuildContext context,
    required ColorScheme colorScheme,
    String? fontFamily,
    String? displayFontFamily,
  }) {
    final baseTheme = AppTypography.createTextTheme(
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      displayFontFamily: displayFontFamily,
    );

    final scaleFactor = getScaleFactor(context);
    return scaleTextTheme(baseTheme, scaleFactor);
  }
}

/// Text theme extensions
extension TextThemeExtensions on TextTheme {
  /// Get financial amount style
  TextStyle get amountLarge => const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.2,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  TextStyle get amountMedium => const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.2,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  TextStyle get amountSmall => const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.2,
        fontFeatures: [FontFeature.tabularFigures()],
      );
}