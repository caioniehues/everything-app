import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_paths.dart';
import 'responsive_builder.dart';

/// App navigation destination data
class AppNavigationDestination {
  final String route;
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const AppNavigationDestination({
    required this.route,
    required this.icon,
    required this.label, this.selectedIcon,
  });
}

/// Adaptive scaffold that provides platform-specific navigation patterns
/// - Mobile: Bottom navigation bar
/// - Tablet: Navigation rail (collapsed)
/// - Desktop: Navigation rail (extended)
class AdaptiveScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final List<AppNavigationDestination> destinations;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;

  const AdaptiveScaffold({
    required this.body, super.key,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.destinations = const [],
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final deviceType = ResponsiveUtils.getDeviceType(context);

        switch (deviceType) {
          case DeviceType.mobile:
            return _buildMobileLayout(context);
          case DeviceType.tablet:
            return _buildTabletLayout(context);
          case DeviceType.desktop:
            return _buildDesktopLayout(context);
        }
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: body,
      bottomNavigationBar: destinations.isNotEmpty
          ? _buildBottomNavigationBar(context)
          : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (destinations.isNotEmpty)
            _buildNavigationRail(context, extended: false),
          Expanded(
            child: Column(
              children: [
                if (title != null || actions != null)
                  _buildAppBar(context) ?? const SizedBox.shrink(),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (destinations.isNotEmpty)
            _buildNavigationRail(context, extended: true),
          Expanded(
            child: Column(
              children: [
                if (title != null || actions != null)
                  _buildAppBar(context) ?? const SizedBox.shrink(),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (title == null && (actions == null || actions!.isEmpty)) {
      return null;
    }

    return AppBar(
      title: title != null ? Text(title!) : null,
      actions: actions,
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: drawer != null,
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getCurrentIndex(currentRoute);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        context.go(destinations[index].route);
      },
      destinations: destinations.map((destination) {
        return NavigationDestination(
          icon: Icon(destination.icon),
          selectedIcon: destination.selectedIcon != null
              ? Icon(destination.selectedIcon)
              : null,
          label: destination.label,
        );
      }).toList(),
    );
  }

  Widget _buildNavigationRail(BuildContext context, {required bool extended}) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getCurrentIndex(currentRoute);

    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        context.go(destinations[index].route);
      },
      extended: extended,
      destinations: destinations.map((destination) {
        return NavigationRailDestination(
          icon: Icon(destination.icon),
          selectedIcon: destination.selectedIcon != null
              ? Icon(destination.selectedIcon)
              : null,
          label: Text(destination.label),
        );
      }).toList(),
    );
  }

  int _getCurrentIndex(String currentRoute) {
    for (int i = 0; i < destinations.length; i++) {
      if (currentRoute.startsWith(destinations[i].route)) {
        return i;
      }
    }
    return 0;
  }
}

/// Predefined navigation destinations for the Everything App
class AppNavigationDestinations {
  AppNavigationDestinations._();

  static const List<AppNavigationDestination> main = [
    AppNavigationDestination(
      route: RoutePaths.dashboard,
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    AppNavigationDestination(
      route: RoutePaths.transactions,
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      label: 'Transactions',
    ),
    AppNavigationDestination(
      route: RoutePaths.budget,
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
      label: 'Budget',
    ),
    AppNavigationDestination(
      route: RoutePaths.reports,
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      label: 'Reports',
    ),
    AppNavigationDestination(
      route: RoutePaths.profile,
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
    ),
  ];
}

/// Adaptive page layout that adjusts content based on screen size
class AdaptivePage extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool centerContent;
  final double? maxWidth;

  const AdaptivePage({
    required this.child, super.key,
    this.padding,
    this.centerContent = false,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        Widget content = child;

        // Apply responsive padding
        final effectivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
        content = Padding(
          padding: effectivePadding,
          child: content,
        );

        // Apply max width constraint for larger screens
        if (maxWidth != null || centerContent) {
          final effectiveMaxWidth = maxWidth ?? ResponsiveUtils.getMaxContentWidth(context);
          content = Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
              child: content,
            ),
          );
        }

        return content;
      },
    );
  }
}

/// Adaptive container that adjusts its properties based on screen size
class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final BorderRadius? borderRadius;

  const AdaptiveContainer({
    required this.child, super.key,
    this.color,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final theme = Theme.of(context);
        final deviceType = ResponsiveUtils.getDeviceType(context);

        // Adaptive elevation based on device type
        double effectiveElevation = elevation ?? 0;
        if (elevation == null) {
          switch (deviceType) {
            case DeviceType.mobile:
              effectiveElevation = 1;
              break;
            case DeviceType.tablet:
              effectiveElevation = 2;
              break;
            case DeviceType.desktop:
              effectiveElevation = 4;
              break;
          }
        }

        // Adaptive border radius
        final BorderRadius effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);

        return Container(
          padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
          margin: margin ?? ResponsiveUtils.getResponsiveMargin(context),
          decoration: BoxDecoration(
            color: color ?? theme.colorScheme.surface,
            borderRadius: effectiveBorderRadius,
            boxShadow: effectiveElevation > 0
                ? [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withOpacity(0.1),
                      blurRadius: effectiveElevation * 2,
                      offset: Offset(0, effectiveElevation),
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
    );
  }
}

/// Adaptive list view that adjusts spacing and layout
class AdaptiveListView extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const AdaptiveListView({
    required this.children, super.key,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final deviceType = ResponsiveUtils.getDeviceType(context);

        // Adaptive spacing between items
        double itemSpacing;
        switch (deviceType) {
          case DeviceType.mobile:
            itemSpacing = 8;
            break;
          case DeviceType.tablet:
            itemSpacing = 12;
            break;
          case DeviceType.desktop:
            itemSpacing = 16;
            break;
        }

        // Create spaced children
        final spacedChildren = <Widget>[];
        for (int i = 0; i < children.length; i++) {
          spacedChildren.add(children[i]);
          if (i < children.length - 1) {
            spacedChildren.add(SizedBox(height: itemSpacing));
          }
        }

        return ListView(
          controller: controller,
          padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
          shrinkWrap: shrinkWrap,
          physics: physics,
          children: spacedChildren,
        );
      },
    );
  }
}