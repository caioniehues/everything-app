import 'package:flutter/material.dart';

/// Application dimension constants
/// Provides consistent spacing, sizing, and layout values
class AppDimensions {
  AppDimensions._();

  /// Spacing constants following Material Design 3 spacing system
  static const double space0 = 0;
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
  static const double space72 = 72;
  static const double space80 = 80;
  static const double space96 = 96;
  static const double space128 = 128;

  /// Padding values
  static const double paddingXSmall = 4;
  static const double paddingSmall = 8;
  static const double paddingMedium = 16;
  static const double paddingLarge = 24;
  static const double paddingXLarge = 32;
  static const double paddingXXLarge = 48;

  /// Margin values
  static const double marginXSmall = 4;
  static const double marginSmall = 8;
  static const double marginMedium = 16;
  static const double marginLarge = 24;
  static const double marginXLarge = 32;
  static const double marginXXLarge = 48;

  /// Border radius values
  static const double radiusNone = 0;
  static const double radiusXSmall = 4;
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 24;
  static const double radiusXXLarge = 32;
  static const double radiusCircular = 100;
  static const double radiusPill = 999;

  /// BorderRadius objects for convenience
  static final BorderRadius borderRadiusXSmall = BorderRadius.circular(radiusXSmall);
  static final BorderRadius borderRadiusSmall = BorderRadius.circular(radiusSmall);
  static final BorderRadius borderRadiusMedium = BorderRadius.circular(radiusMedium);
  static final BorderRadius borderRadiusLarge = BorderRadius.circular(radiusLarge);
  static final BorderRadius borderRadiusXLarge = BorderRadius.circular(radiusXLarge);
  static final BorderRadius borderRadiusXXLarge = BorderRadius.circular(radiusXXLarge);
  static final BorderRadius borderRadiusCircular = BorderRadius.circular(radiusCircular);

  /// Icon sizes
  static const double iconXSmall = 12;
  static const double iconSmall = 16;
  static const double iconMedium = 24;
  static const double iconLarge = 32;
  static const double iconXLarge = 48;
  static const double iconXXLarge = 64;
  static const double iconHuge = 96;

  /// Avatar sizes
  static const double avatarXSmall = 24;
  static const double avatarSmall = 32;
  static const double avatarMedium = 40;
  static const double avatarLarge = 56;
  static const double avatarXLarge = 72;
  static const double avatarXXLarge = 96;
  static const double avatarHuge = 128;

  /// Button heights
  static const double buttonHeightSmall = 32;
  static const double buttonHeightMedium = 40;
  static const double buttonHeightLarge = 48;
  static const double buttonHeightXLarge = 56;

  /// Text field heights
  static const double textFieldHeightSmall = 40;
  static const double textFieldHeightMedium = 48;
  static const double textFieldHeightLarge = 56;

  /// App bar heights
  static const double appBarHeightSmall = 48;
  static const double appBarHeightMedium = 56;
  static const double appBarHeightLarge = 64;
  static const double appBarHeightExtended = 128;

  /// Bottom navigation bar height
  static const double bottomNavBarHeight = 56;
  static const double bottomNavBarHeightWithLabel = 72;

  /// Card elevation
  static const double elevationNone = 0;
  static const double elevationXSmall = 1;
  static const double elevationSmall = 2;
  static const double elevationMedium = 4;
  static const double elevationLarge = 8;
  static const double elevationXLarge = 12;
  static const double elevationXXLarge = 16;

  /// Border width
  static const double borderNone = 0;
  static const double borderThin = 1;
  static const double borderMedium = 2;
  static const double borderThick = 3;
  static const double borderXThick = 4;

  /// Content width constraints
  static const double minContentWidth = 320;
  static const double maxContentWidth = 1200;
  static const double maxContentWidthSmall = 600;
  static const double maxContentWidthMedium = 900;
  static const double maxContentWidthLarge = 1200;

  /// Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double wideScreenBreakpoint = 1600;

  /// List tile heights
  static const double listTileHeightSmall = 48;
  static const double listTileHeightMedium = 56;
  static const double listTileHeightLarge = 72;
  static const double listTileHeightXLarge = 88;

  /// Drawer width
  static const double drawerWidthCompact = 56;
  static const double drawerWidthNormal = 280;
  static const double drawerWidthWide = 360;

  /// Navigation rail width
  static const double navigationRailWidthCompact = 72;
  static const double navigationRailWidthExpanded = 256;

  /// FAB sizes
  static const double fabSizeSmall = 40;
  static const double fabSizeMedium = 56;
  static const double fabSizeLarge = 96;

  /// Chip heights
  static const double chipHeightSmall = 24;
  static const double chipHeightMedium = 32;
  static const double chipHeightLarge = 40;

  /// Progress indicator sizes
  static const double progressSizeSmall = 16;
  static const double progressSizeMedium = 24;
  static const double progressSizeLarge = 48;
  static const double progressSizeXLarge = 64;

  /// Animation durations
  static const Duration animationInstant = Duration(milliseconds: 100);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationXSlow = Duration(milliseconds: 800);
  static const Duration animationPageTransition = Duration(milliseconds: 300);

  /// Grid spacing
  static const double gridSpacingSmall = 8;
  static const double gridSpacingMedium = 16;
  static const double gridSpacingLarge = 24;

  /// Aspect ratios
  static const double aspectRatioSquare = 1;
  static const double aspectRatio4x3 = 4 / 3;
  static const double aspectRatio16x9 = 16 / 9;
  static const double aspectRatio2x1 = 2;
  static const double aspectRatioGolden = 1.618;

  /// Maximum widths for different components
  static const double maxWidthDialog = 560;
  static const double maxWidthSnackBar = 600;
  static const double maxWidthTooltip = 320;
  static const double maxWidthPopup = 400;

  /// Z-index values (for Stack widgets)
  static const double zIndexDefault = 0;
  static const double zIndexDropdown = 1000;
  static const double zIndexSticky = 1020;
  static const double zIndexFixed = 1030;
  static const double zIndexModalBackdrop = 1040;
  static const double zIndexModal = 1050;
  static const double zIndexPopover = 1060;
  static const double zIndexTooltip = 1070;
  static const double zIndexNotification = 1080;

  /// Helper methods for responsive design
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static bool isWideScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= wideScreenBreakpoint;

  /// Get responsive value based on screen size
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// EdgeInsets helpers
  static const EdgeInsets paddingAllSmall = EdgeInsets.all(paddingSmall);
  static const EdgeInsets paddingAllMedium = EdgeInsets.all(paddingMedium);
  static const EdgeInsets paddingAllLarge = EdgeInsets.all(paddingLarge);

  static const EdgeInsets paddingHorizontalSmall = EdgeInsets.symmetric(horizontal: paddingSmall);
  static const EdgeInsets paddingHorizontalMedium = EdgeInsets.symmetric(horizontal: paddingMedium);
  static const EdgeInsets paddingHorizontalLarge = EdgeInsets.symmetric(horizontal: paddingLarge);

  static const EdgeInsets paddingVerticalSmall = EdgeInsets.symmetric(vertical: paddingSmall);
  static const EdgeInsets paddingVerticalMedium = EdgeInsets.symmetric(vertical: paddingMedium);
  static const EdgeInsets paddingVerticalLarge = EdgeInsets.symmetric(vertical: paddingLarge);
}