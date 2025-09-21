import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'color_schemes.dart';
import 'typography.dart';

/// Material Design 3 theme configuration for Everything App
/// Provides comprehensive theming following Material You guidelines
class AppTheme {
  AppTheme._();

  /// Create light theme
  static ThemeData createLightTheme({
    String? fontFamily,
    String? displayFontFamily,
  }) {
    const colorScheme = AppColorSchemes.lightColorScheme;
    final textTheme = AppTypography.createTextTheme(
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      displayFontFamily: displayFontFamily,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // Visual density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Typography
      typography: Typography.material2021(),

      // App bar theme
      appBarTheme: _createAppBarTheme(colorScheme, textTheme),

      // Card theme
      cardTheme: _createCardTheme(colorScheme),

      // Elevated button theme
      elevatedButtonTheme: _createElevatedButtonTheme(colorScheme, textTheme),

      // Filled button theme
      filledButtonTheme: _createFilledButtonTheme(colorScheme, textTheme),

      // Outlined button theme
      outlinedButtonTheme: _createOutlinedButtonTheme(colorScheme, textTheme),

      // Text button theme
      textButtonTheme: _createTextButtonTheme(colorScheme, textTheme),

      // Floating action button theme
      floatingActionButtonTheme: _createFABTheme(colorScheme),

      // Input decoration theme
      inputDecorationTheme: _createInputDecorationTheme(colorScheme, textTheme),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: _createBottomNavTheme(colorScheme, textTheme),

      // Navigation bar theme (Material 3)
      navigationBarTheme: _createNavigationBarTheme(colorScheme, textTheme),

      // Drawer theme
      drawerTheme: _createDrawerTheme(colorScheme),

      // Dialog theme
      dialogTheme: _createDialogTheme(colorScheme, textTheme),

      // Bottom sheet theme
      bottomSheetTheme: _createBottomSheetTheme(colorScheme),

      // Divider theme
      dividerTheme: _createDividerTheme(colorScheme),

      // Icon theme
      iconTheme: _createIconTheme(colorScheme),

      // Primary icon theme
      primaryIconTheme: _createPrimaryIconTheme(colorScheme),

      // List tile theme
      listTileTheme: _createListTileTheme(colorScheme, textTheme),

      // Switch theme
      switchTheme: _createSwitchTheme(colorScheme),

      // Checkbox theme
      checkboxTheme: _createCheckboxTheme(colorScheme),

      // Radio theme
      radioTheme: _createRadioTheme(colorScheme),

      // Slider theme
      sliderTheme: _createSliderTheme(colorScheme),

      // Progress indicator theme
      progressIndicatorTheme: _createProgressIndicatorTheme(colorScheme),

      // Chip theme
      chipTheme: _createChipTheme(colorScheme, textTheme),

      // Tab bar theme
      tabBarTheme: _createTabBarTheme(colorScheme, textTheme),

      // Snack bar theme
      snackBarTheme: _createSnackBarTheme(colorScheme, textTheme),

      // Expansion tile theme
      expansionTileTheme: _createExpansionTileTheme(colorScheme),

      // Page transitions
      pageTransitionsTheme: _createPageTransitionsTheme(),

      // Scrollbar theme
      scrollbarTheme: _createScrollbarTheme(colorScheme),

      // Tooltip theme
      tooltipTheme: _createTooltipTheme(colorScheme, textTheme),
    );
  }

  /// Create dark theme
  static ThemeData createDarkTheme({
    String? fontFamily,
    String? displayFontFamily,
  }) {
    const colorScheme = AppColorSchemes.darkColorScheme;
    final textTheme = AppTypography.createTextTheme(
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      displayFontFamily: displayFontFamily,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // Visual density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Typography
      typography: Typography.material2021(),

      // App bar theme
      appBarTheme: _createAppBarTheme(colorScheme, textTheme),

      // Card theme
      cardTheme: _createCardTheme(colorScheme),

      // Elevated button theme
      elevatedButtonTheme: _createElevatedButtonTheme(colorScheme, textTheme),

      // Filled button theme
      filledButtonTheme: _createFilledButtonTheme(colorScheme, textTheme),

      // Outlined button theme
      outlinedButtonTheme: _createOutlinedButtonTheme(colorScheme, textTheme),

      // Text button theme
      textButtonTheme: _createTextButtonTheme(colorScheme, textTheme),

      // Floating action button theme
      floatingActionButtonTheme: _createFABTheme(colorScheme),

      // Input decoration theme
      inputDecorationTheme: _createInputDecorationTheme(colorScheme, textTheme),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: _createBottomNavTheme(colorScheme, textTheme),

      // Navigation bar theme (Material 3)
      navigationBarTheme: _createNavigationBarTheme(colorScheme, textTheme),

      // Drawer theme
      drawerTheme: _createDrawerTheme(colorScheme),

      // Dialog theme
      dialogTheme: _createDialogTheme(colorScheme, textTheme),

      // Bottom sheet theme
      bottomSheetTheme: _createBottomSheetTheme(colorScheme),

      // Divider theme
      dividerTheme: _createDividerTheme(colorScheme),

      // Icon theme
      iconTheme: _createIconTheme(colorScheme),

      // Primary icon theme
      primaryIconTheme: _createPrimaryIconTheme(colorScheme),

      // List tile theme
      listTileTheme: _createListTileTheme(colorScheme, textTheme),

      // Switch theme
      switchTheme: _createSwitchTheme(colorScheme),

      // Checkbox theme
      checkboxTheme: _createCheckboxTheme(colorScheme),

      // Radio theme
      radioTheme: _createRadioTheme(colorScheme),

      // Slider theme
      sliderTheme: _createSliderTheme(colorScheme),

      // Progress indicator theme
      progressIndicatorTheme: _createProgressIndicatorTheme(colorScheme),

      // Chip theme
      chipTheme: _createChipTheme(colorScheme, textTheme),

      // Tab bar theme
      tabBarTheme: _createTabBarTheme(colorScheme, textTheme),

      // Snack bar theme
      snackBarTheme: _createSnackBarTheme(colorScheme, textTheme),

      // Expansion tile theme
      expansionTileTheme: _createExpansionTileTheme(colorScheme),

      // Page transitions
      pageTransitionsTheme: _createPageTransitionsTheme(),

      // Scrollbar theme
      scrollbarTheme: _createScrollbarTheme(colorScheme),

      // Tooltip theme
      tooltipTheme: _createTooltipTheme(colorScheme, textTheme),
    );
  }

  // Component theme creators

  static AppBarTheme _createAppBarTheme(ColorScheme colorScheme, TextTheme textTheme) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 3,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      foregroundColor: colorScheme.onSurface,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      centerTitle: false,
      systemOverlayStyle: colorScheme.brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
    );
  }

  static CardThemeData _createCardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      elevation: 1,
      color: colorScheme.surfaceContainer,
      surfaceTintColor: colorScheme.surfaceTint,
      shadowColor: colorScheme.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(4),
    );
  }

  static ElevatedButtonThemeData _createElevatedButtonTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 1,
        backgroundColor: colorScheme.surfaceContainer,
        foregroundColor: colorScheme.primary,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: colorScheme.surfaceTint,
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(0, 40),
      ),
    );
  }

  static FilledButtonThemeData _createFilledButtonTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(0, 40),
      ),
    );
  }

  static OutlinedButtonThemeData _createOutlinedButtonTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.outline),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(0, 40),
      ),
    );
  }

  static TextButtonThemeData _createTextButtonTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        elevation: 0,
        foregroundColor: colorScheme.primary,
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(0, 40),
      ),
    );
  }

  static FloatingActionButtonThemeData _createFABTheme(ColorScheme colorScheme) {
    return FloatingActionButtonThemeData(
      elevation: 6,
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  static InputDecorationTheme _createInputDecorationTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      helperStyle: textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      errorStyle: textTheme.bodySmall?.copyWith(
        color: colorScheme.error,
      ),
    );
  }

  static BottomNavigationBarThemeData _createBottomNavTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      selectedLabelStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      elevation: 3,
    );
  }

  static NavigationBarThemeData _createNavigationBarTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return NavigationBarThemeData(
      height: 80,
      elevation: 3,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          );
        }
        return textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: colorScheme.onSecondaryContainer);
        }
        return IconThemeData(color: colorScheme.onSurfaceVariant);
      }),
    );
  }

  // Additional component themes continued...

  static DrawerThemeData _createDrawerTheme(ColorScheme colorScheme) {
    return DrawerThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
    );
  }

  static DialogThemeData _createDialogTheme(ColorScheme colorScheme, TextTheme textTheme) {
    return DialogThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        color: colorScheme.onSurface,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  static BottomSheetThemeData _createBottomSheetTheme(ColorScheme colorScheme) {
    return BottomSheetThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }

  static DividerThemeData _createDividerTheme(ColorScheme colorScheme) {
    return DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
      space: 1,
    );
  }

  static IconThemeData _createIconTheme(ColorScheme colorScheme) {
    return IconThemeData(
      color: colorScheme.onSurface,
      size: 24,
    );
  }

  static IconThemeData _createPrimaryIconTheme(ColorScheme colorScheme) {
    return IconThemeData(
      color: colorScheme.onPrimary,
      size: 24,
    );
  }

  static ListTileThemeData _createListTileTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: colorScheme.secondaryContainer,
      iconColor: colorScheme.onSurfaceVariant,
      selectedColor: colorScheme.onSecondaryContainer,
      textColor: colorScheme.onSurface,
      titleTextStyle: textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      subtitleTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      leadingAndTrailingTextStyle: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Continue with remaining component themes...

  static SwitchThemeData _createSwitchTheme(ColorScheme colorScheme) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.onPrimary;
        }
        return colorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.surfaceContainerHighest;
      }),
    );
  }

  static CheckboxThemeData _createCheckboxTheme(ColorScheme colorScheme) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
      side: BorderSide(color: colorScheme.outline, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  static RadioThemeData _createRadioTheme(ColorScheme colorScheme) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.outline;
      }),
    );
  }

  static SliderThemeData _createSliderTheme(ColorScheme colorScheme) {
    return SliderThemeData(
      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.surfaceContainerHighest,
      thumbColor: colorScheme.primary,
      overlayColor: colorScheme.primary.withValues(alpha: 0.12),
      valueIndicatorColor: colorScheme.inverseSurface,
      valueIndicatorTextStyle: TextStyle(
        color: colorScheme.onInverseSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static ProgressIndicatorThemeData _createProgressIndicatorTheme(ColorScheme colorScheme) {
    return ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: colorScheme.surfaceContainerHighest,
      circularTrackColor: colorScheme.surfaceContainerHighest,
    );
  }

  static ChipThemeData _createChipTheme(ColorScheme colorScheme, TextTheme textTheme) {
    return ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      deleteIconColor: colorScheme.onSurfaceVariant,
      disabledColor: colorScheme.onSurface.withValues(alpha: 0.12),
      selectedColor: colorScheme.secondaryContainer,
      secondarySelectedColor: colorScheme.secondaryContainer,
      labelStyle: textTheme.labelLarge?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      secondaryLabelStyle: textTheme.labelLarge?.copyWith(
        color: colorScheme.onSecondaryContainer,
      ),
      side: BorderSide(color: colorScheme.outline),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  static TabBarThemeData _createTabBarTheme(ColorScheme colorScheme, TextTheme textTheme) {
    return TabBarThemeData(
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: colorScheme.primary, width: 3),
        borderRadius: BorderRadius.circular(3),
      ),
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      labelStyle: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: textTheme.titleSmall,
      overlayColor: WidgetStateProperty.all(
        colorScheme.primary.withValues(alpha: 0.08),
      ),
    );
  }

  static SnackBarThemeData _createSnackBarTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return SnackBarThemeData(
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onInverseSurface,
      ),
      actionTextColor: colorScheme.inversePrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    );
  }

  static ExpansionTileThemeData _createExpansionTileTheme(ColorScheme colorScheme) {
    return ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      iconColor: colorScheme.onSurfaceVariant,
      collapsedIconColor: colorScheme.onSurfaceVariant,
      textColor: colorScheme.onSurface,
      collapsedTextColor: colorScheme.onSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static PageTransitionsTheme _createPageTransitionsTheme() {
    return const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    );
  }

  static ScrollbarThemeData _createScrollbarTheme(ColorScheme colorScheme) {
    return ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(
        colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
      trackColor: WidgetStateProperty.all(
        colorScheme.surfaceContainerHighest,
      ),
      radius: const Radius.circular(4),
      thickness: WidgetStateProperty.all(8),
      minThumbLength: 48,
    );
  }

  static TooltipThemeData _createTooltipTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: textTheme.bodySmall?.copyWith(
        color: colorScheme.onInverseSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.all(8),
    );
  }
}