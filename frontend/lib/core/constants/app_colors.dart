import 'package:flutter/material.dart';

/// Application color palette
/// Defines all colors used throughout the app for consistency
class AppColors {
  AppColors._();

  /// Primary brand colors
  static const Color primary = Color(0xFF6750A4);
  static const Color primaryLight = Color(0xFF9A82DB);
  static const Color primaryDark = Color(0xFF4A3C76);
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Secondary brand colors
  static const Color secondary = Color(0xFF625B71);
  static const Color secondaryLight = Color(0xFF8B839C);
  static const Color secondaryDark = Color(0xFF463F52);
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// Tertiary accent colors
  static const Color tertiary = Color(0xFF7D5260);
  static const Color tertiaryLight = Color(0xFFA67685);
  static const Color tertiaryDark = Color(0xFF5A3A45);
  static const Color onTertiary = Color(0xFFFFFFFF);

  /// Semantic colors - Success
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF80E27E);
  static const Color successDark = Color(0xFF087F23);
  static const Color onSuccess = Color(0xFFFFFFFF);

  /// Semantic colors - Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorLight = Color(0xFFFF5449);
  static const Color errorDark = Color(0xFF7F0000);
  static const Color onError = Color(0xFFFFFFFF);

  /// Semantic colors - Warning
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFD95B);
  static const Color warningDark = Color(0xFFC77800);
  static const Color onWarning = Color(0xFF000000);

  /// Semantic colors - Info
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF6EC6FF);
  static const Color infoDark = Color(0xFF0069C0);
  static const Color onInfo = Color(0xFFFFFFFF);

  /// Neutral colors
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral10 = Color(0xFFFAFAFA);
  static const Color neutral20 = Color(0xFFF5F5F5);
  static const Color neutral30 = Color(0xFFE0E0E0);
  static const Color neutral40 = Color(0xFFBDBDBD);
  static const Color neutral50 = Color(0xFF9E9E9E);
  static const Color neutral60 = Color(0xFF757575);
  static const Color neutral70 = Color(0xFF616161);
  static const Color neutral80 = Color(0xFF424242);
  static const Color neutral90 = Color(0xFF212121);
  static const Color neutral100 = Color(0xFF000000);

  /// Surface colors
  static const Color surface = Color(0xFFFEF7FF);
  static const Color surfaceVariant = Color(0xFFE7E0EC);
  static const Color surfaceTint = Color(0xFF6750A4);
  static const Color inverseSurface = Color(0xFF313033);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceVariant = Color(0xFF49454F);

  /// Background colors
  static const Color background = Color(0xFFFEF7FF);
  static const Color onBackground = Color(0xFF1C1B1F);

  /// Outline colors
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);

  /// Shadow color
  static const Color shadow = Color(0xFF000000);

  /// Transparent
  static const Color transparent = Colors.transparent;

  /// Chart colors for data visualization
  static const List<Color> chartColors = [
    Color(0xFF6750A4), // Primary
    Color(0xFF625B71), // Secondary
    Color(0xFF7D5260), // Tertiary
    Color(0xFF4CAF50), // Success/Green
    Color(0xFF2196F3), // Info/Blue
    Color(0xFFFFA726), // Warning/Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFCDDC39), // Lime
    Color(0xFF795548), // Brown
  ];

  /// Income color (positive transactions)
  static const Color income = Color(0xFF4CAF50);
  static const Color incomeLight = Color(0xFFE8F5E9);

  /// Expense color (negative transactions)
  static const Color expense = Color(0xFFE91E63);
  static const Color expenseLight = Color(0xFFFCE4EC);

  /// Investment color
  static const Color investment = Color(0xFF2196F3);
  static const Color investmentLight = Color(0xFFE3F2FD);

  /// Savings color
  static const Color savings = Color(0xFFFFC107);
  static const Color savingsLight = Color(0xFFFFF8E1);

  /// Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successLight, success],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [errorLight, error],
  );

  /// Opacity levels
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.60;
  static const double opacityHigh = 0.87;
  static const double opacityFull = 1;

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity.clamp(0.0, 1.0));
  }

  /// Get color for amount (positive = green, negative = red)
  static Color getAmountColor(double amount) {
    if (amount > 0) return income;
    if (amount < 0) return expense;
    return neutral60;
  }

  /// Get color for percentage change
  static Color getPercentageColor(double percentage) {
    if (percentage > 0) return success;
    if (percentage < 0) return error;
    return neutral60;
  }
}