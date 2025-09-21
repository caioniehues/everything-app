import 'package:flutter/material.dart';

/// Breakpoint constants following Material Design guidelines
class Breakpoints {
  Breakpoints._();

  /// Phone screens (portrait)
  static const double mobile = 600;

  /// Tablets (portrait) and phones (landscape)
  static const double tablet = 840;

  /// Tablets (landscape) and desktops
  static const double desktop = 1200;

  /// Large desktops
  static const double large = 1600;

  /// Extra large screens
  static const double extraLarge = 2000;
}

/// Screen size categories
enum ScreenSize {
  mobile,
  tablet,
  desktop,
  large,
  extraLarge,
}

/// Device type based on screen characteristics
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Responsive breakpoint utilities
class ResponsiveUtils {
  ResponsiveUtils._();

  /// Get screen size category based on width
  static ScreenSize getScreenSize(double width) {
    if (width < Breakpoints.mobile) {
      return ScreenSize.mobile;
    } else if (width < Breakpoints.tablet) {
      return ScreenSize.tablet;
    } else if (width < Breakpoints.desktop) {
      return ScreenSize.desktop;
    } else if (width < Breakpoints.large) {
      return ScreenSize.large;
    } else {
      return ScreenSize.extraLarge;
    }
  }

  /// Get device type based on screen size and orientation
  static DeviceType getDeviceType(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final width = size.width;
    final height = size.height;

    // Consider orientation for better device detection
    final shortestSide = orientation == Orientation.portrait ? width : height;
    final longestSide = orientation == Orientation.portrait ? height : width;

    if (shortestSide < Breakpoints.mobile) {
      return DeviceType.mobile;
    } else if (shortestSide < Breakpoints.desktop && longestSide < 1400) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenSize = getScreenSize(MediaQuery.of(context).size.width);

    switch (screenSize) {
      case ScreenSize.mobile:
        return const EdgeInsets.all(16);
      case ScreenSize.tablet:
        return const EdgeInsets.all(24);
      case ScreenSize.desktop:
        return const EdgeInsets.all(32);
      case ScreenSize.large:
        return const EdgeInsets.all(40);
      case ScreenSize.extraLarge:
        return const EdgeInsets.all(48);
    }
  }

  /// Get responsive margin based on screen size
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    final screenSize = getScreenSize(MediaQuery.of(context).size.width);

    switch (screenSize) {
      case ScreenSize.mobile:
        return const EdgeInsets.all(8);
      case ScreenSize.tablet:
        return const EdgeInsets.all(12);
      case ScreenSize.desktop:
        return const EdgeInsets.all(16);
      case ScreenSize.large:
        return const EdgeInsets.all(20);
      case ScreenSize.extraLarge:
        return const EdgeInsets.all(24);
    }
  }

  /// Get maximum content width for readability
  static double getMaxContentWidth(BuildContext context) {
    final screenSize = getScreenSize(MediaQuery.of(context).size.width);

    switch (screenSize) {
      case ScreenSize.mobile:
        return double.infinity;
      case ScreenSize.tablet:
        return 720;
      case ScreenSize.desktop:
        return 1200;
      case ScreenSize.large:
        return 1400;
      case ScreenSize.extraLarge:
        return 1600;
    }
  }

  /// Get responsive grid column count
  static int getGridColumns(BuildContext context) {
    final screenSize = getScreenSize(MediaQuery.of(context).size.width);

    switch (screenSize) {
      case ScreenSize.mobile:
        return 1;
      case ScreenSize.tablet:
        return 2;
      case ScreenSize.desktop:
        return 3;
      case ScreenSize.large:
        return 4;
      case ScreenSize.extraLarge:
        return 5;
    }
  }

  /// Get responsive aspect ratio for cards
  static double getCardAspectRatio(BuildContext context) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return 1.5; // Taller cards for mobile
      case DeviceType.tablet:
        return 1.2;
      case DeviceType.desktop:
        return 1; // Square-ish cards for desktop
    }
  }
}

/// Responsive builder widget that rebuilds based on screen size changes
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize screenSize) builder;
  final Widget Function(BuildContext context, ScreenSize screenSize)? mobileBuilder;
  final Widget Function(BuildContext context, ScreenSize screenSize)? tabletBuilder;
  final Widget Function(BuildContext context, ScreenSize screenSize)? desktopBuilder;

  const ResponsiveBuilder({
    required this.builder, super.key,
    this.mobileBuilder,
    this.tabletBuilder,
    this.desktopBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = ResponsiveUtils.getScreenSize(constraints.maxWidth);
        final deviceType = ResponsiveUtils.getDeviceType(context);

        // Use specific builder if available
        switch (deviceType) {
          case DeviceType.mobile:
            if (mobileBuilder != null) {
              return mobileBuilder!(context, screenSize);
            }
            break;
          case DeviceType.tablet:
            if (tabletBuilder != null) {
              return tabletBuilder!(context, screenSize);
            }
            break;
          case DeviceType.desktop:
            if (desktopBuilder != null) {
              return desktopBuilder!(context, screenSize);
            }
            break;
        }

        // Fall back to general builder
        return builder(context, screenSize);
      },
    );
  }
}

/// Widget that adapts its child based on device type
class AdaptiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const AdaptiveWidget({
    required this.mobile, super.key,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobile;
  final EdgeInsets? tablet;
  final EdgeInsets? desktop;

  const ResponsivePadding({
    required this.child, super.key,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    EdgeInsets padding;

    switch (deviceType) {
      case DeviceType.mobile:
        padding = mobile ?? ResponsiveUtils.getResponsivePadding(context);
        break;
      case DeviceType.tablet:
        padding = tablet ?? mobile ?? ResponsiveUtils.getResponsivePadding(context);
        break;
      case DeviceType.desktop:
        padding = desktop ?? tablet ?? mobile ?? ResponsiveUtils.getResponsivePadding(context);
        break;
    }

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Responsive margin widget
class ResponsiveMargin extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobile;
  final EdgeInsets? tablet;
  final EdgeInsets? desktop;

  const ResponsiveMargin({
    required this.child, super.key,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    EdgeInsets margin;

    switch (deviceType) {
      case DeviceType.mobile:
        margin = mobile ?? ResponsiveUtils.getResponsiveMargin(context);
        break;
      case DeviceType.tablet:
        margin = tablet ?? mobile ?? ResponsiveUtils.getResponsiveMargin(context);
        break;
      case DeviceType.desktop:
        margin = desktop ?? tablet ?? mobile ?? ResponsiveUtils.getResponsiveMargin(context);
        break;
    }

    return Container(
      margin: margin,
      child: child,
    );
  }
}

/// Responsive center widget with max width constraint
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const ResponsiveCenter({
    required this.child, super.key,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? ResponsiveUtils.getMaxContentWidth(context);
    final effectivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        padding: effectivePadding,
        child: child,
      ),
    );
  }
}

/// Responsive grid widget
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double? spacing;
  final double? runSpacing;
  final double? childAspectRatio;

  const ResponsiveGrid({
    required this.children, super.key,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.spacing,
    this.runSpacing,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    int columns;

    switch (deviceType) {
      case DeviceType.mobile:
        columns = mobileColumns ?? 1;
        break;
      case DeviceType.tablet:
        columns = tabletColumns ?? mobileColumns ?? 2;
        break;
      case DeviceType.desktop:
        columns = desktopColumns ?? tabletColumns ?? mobileColumns ?? 3;
        break;
    }

    final effectiveSpacing = spacing ?? 16.0;
    final effectiveRunSpacing = runSpacing ?? 16.0;
    final effectiveAspectRatio = childAspectRatio ?? ResponsiveUtils.getCardAspectRatio(context);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: effectiveSpacing,
      mainAxisSpacing: effectiveRunSpacing,
      childAspectRatio: effectiveAspectRatio,
      children: children,
    );
  }
}

/// Extensions for easier responsive access
extension ResponsiveExtensions on BuildContext {
  /// Get screen size
  ScreenSize get screenSize => ResponsiveUtils.getScreenSize(MediaQuery.of(this).size.width);

  /// Get device type
  DeviceType get deviceType => ResponsiveUtils.getDeviceType(this);

  /// Check if mobile
  bool get isMobile => ResponsiveUtils.isMobile(this);

  /// Check if tablet
  bool get isTablet => ResponsiveUtils.isTablet(this);

  /// Check if desktop
  bool get isDesktop => ResponsiveUtils.isDesktop(this);

  /// Get responsive padding
  EdgeInsets get responsivePadding => ResponsiveUtils.getResponsivePadding(this);

  /// Get responsive margin
  EdgeInsets get responsiveMargin => ResponsiveUtils.getResponsiveMargin(this);

  /// Get max content width
  double get maxContentWidth => ResponsiveUtils.getMaxContentWidth(this);

  /// Get grid columns
  int get gridColumns => ResponsiveUtils.getGridColumns(this);

  /// Get card aspect ratio
  double get cardAspectRatio => ResponsiveUtils.getCardAspectRatio(this);
}