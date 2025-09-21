# Navigation & Theming Implementation Guide

## Overview

This document provides comprehensive guidance on the navigation and theming system implemented in the Everything App. The system uses **go_router** for navigation and **Material Design 3** for theming, with full responsive support across all platforms.

## Navigation System

### Architecture

The navigation system is built on **go_router** with the following key components:

- **AppRouter** (`/lib/core/router/app_router.dart`) - Main router configuration
- **RoutePaths** (`/lib/core/router/route_paths.dart`) - Centralized route definitions
- **RouteGuards** (`/lib/core/router/route_guards.dart`) - Authentication and authorization guards
- **Responsive Navigation** - Adaptive navigation patterns for different screen sizes

### Route Structure

#### Public Routes (No Authentication Required)
- `/` - Splash screen with automatic redirect
- `/login` - User login page
- `/register` - User registration page

#### Protected Routes (Authentication Required)
- `/dashboard` - Main dashboard
- `/accounts` - Account management
- `/transactions` - Transaction history
- `/budgets` - Budget management
- `/settings/*` - Settings and preferences

#### Special Routes
- `/404` - Error page for unknown routes

### Navigation Guards

#### AuthGuard
Prevents unauthorized access to protected routes:

```dart
// Automatically redirects unauthenticated users to login
final authGuard = AuthGuard();

// Usage in route configuration
GoRoute(
  path: '/dashboard',
  builder: (context, state) => const DashboardScreen(),
  redirect: authGuard.canActivate,
)
```

#### Redirect Logic
Handles automatic routing based on authentication state:

```dart
// Redirect authenticated users away from auth pages
// Redirect unauthenticated users from protected pages
// Handle token expiration gracefully
```

### Deep Linking Support

Deep linking is fully supported with:

- **Web URLs**: `https://app.example.com/dashboard`
- **Mobile App Links**: `yourapp://dashboard`
- **Parameter Support**: `/settings/account?tab=security`
- **Nested Routes**: `/settings/account`, `/settings/security`

### Route Transitions

The system includes multiple transition types:

```dart
enum RouteTransition {
  fade,        // Default smooth fade
  slide,       // Left-to-right slide
  scale,       // Scale with fade effect
  rotation,    // Rotation effect
}

GoRoute(
  path: '/login',
  pageBuilder: (context, state) => _buildPageWithTransition(
    child: const LoginScreen(),
    transition: RouteTransition.slide,
  ),
)
```

## Theming System

### Material Design 3 Implementation

The app uses Material Design 3 (Material You) with:

- **Dynamic Color Schemes** - Adapts to user's wallpaper colors
- **Consistent Typography** - Proper text scaling across devices
- **Component-Based Theming** - Every UI component properly themed
- **Dark Mode Support** - Full dark theme implementation

### Color System

#### Light Theme Colors
```dart
// Primary brand colors
primary: Color(0xFF0066CC),        // Main brand color
onPrimary: Color(0xFFFFFFFF),      // Text on primary
primaryContainer: Color(0xFFD4E3FF), // Light primary variant

// Surface colors
surface: Color(0xFFFEFEFE),        // Main background
onSurface: Color(0xFF1A1C1E),      // Text on surface
surfaceVariant: Color(0xFFE7E0EC),  // Secondary backgrounds
```

#### Dark Theme Colors
```dart
// Dark theme adaptations with proper contrast
primary: Color(0xFF9ACBFF),        // Lighter primary for dark mode
surface: Color(0xFF121212),        // Dark background
onSurface: Color(0xFFE6E1E5),      // Light text on dark surface
```

### Typography System

#### Font Hierarchy
```dart
// Display styles for large headers
displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400)

// Headline styles for section headers
headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400)

// Body styles for content
bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)
bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)

// Label styles for UI elements
labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)
```

#### Responsive Typography
Font sizes adapt based on screen size and user preferences:
- **Mobile**: Standard sizes for touch interaction
- **Tablet**: Slightly larger for better readability
- **Desktop**: Optimal sizes for mouse/keyboard interaction

### Component Theming

#### Button System
```dart
// Filled Button (Primary Action)
FilledButtonThemeData(
  style: FilledButton.styleFrom(
    backgroundColor: colorScheme.primary,
    foregroundColor: colorScheme.onPrimary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
)

// Outlined Button (Secondary Action)
OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    foregroundColor: colorScheme.primary,
    side: BorderSide(color: colorScheme.outline),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
)
```

#### Input Fields
```dart
InputDecorationTheme(
  filled: true,
  fillColor: colorScheme.surfaceContainerHighest,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: colorScheme.outline),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: colorScheme.primary, width: 2),
  ),
)
```

#### Cards and Surfaces
```dart
CardTheme(
  elevation: 1,
  color: colorScheme.surfaceContainer,
  surfaceTintColor: colorScheme.surfaceTint,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
)
```

## Responsive Design System

### Breakpoint System
```dart
class Breakpoints {
  static const double mobile = 600;    // Phones (portrait)
  static const double tablet = 840;    // Tablets and phones (landscape)
  static const double desktop = 1200;  // Desktops
  static const double large = 1600;    // Large desktops
  static const double extraLarge = 2000; // Extra large screens
}
```

### Device Detection
```dart
// Automatic device type detection
enum DeviceType { mobile, tablet, desktop }

DeviceType getDeviceType(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final orientation = MediaQuery.of(context).orientation;

  final shortestSide = orientation == Orientation.portrait ? size.width : size.height;

  if (shortestSide < Breakpoints.mobile) {
    return DeviceType.mobile;
  } else if (shortestSide < Breakpoints.desktop) {
    return DeviceType.tablet;
  } else {
    return DeviceType.desktop;
  }
}
```

### Responsive Widgets

#### ResponsiveBuilder
Main widget for responsive layouts:

```dart
ResponsiveBuilder(
  builder: (context, screenSize) {
    // Common layout for all devices
    return Container();
  },
  mobileBuilder: (context, screenSize) {
    // Mobile-specific layout
    return MobileLayout();
  },
  tabletBuilder: (context, screenSize) {
    // Tablet-specific layout
    return TabletLayout();
  },
  desktopBuilder: (context, screenSize) {
    // Desktop-specific layout
    return DesktopLayout();
  },
)
```

#### AdaptiveScaffold
Platform-adaptive navigation:

```dart
AdaptiveScaffold(
  destinations: AppNavigationDestinations.main,
  body: MyContent(),
)
// Automatically provides:
// - Bottom navigation on mobile
// - Navigation rail on tablet/desktop
```

#### ResponsiveGrid
Adaptive grid layouts:

```dart
ResponsiveGrid(
  children: myItems,
  mobileColumns: 1,
  tabletColumns: 2,
  desktopColumns: 3,
)
```

## Usage Examples

### Basic Navigation

```dart
// Navigate to a route
context.go('/dashboard');

// Navigate with parameters
context.go('/settings/account?tab=security');

// Replace current route
context.go('/login');

// Go back
context.pop();

// Check current route
final currentRoute = GoRouterState.of(context).matchedLocation;
```

### Themed Components

```dart
// Using branded loading indicator
BrandedLoadingIndicator(
  message: 'Loading your data...',
  size: 48,
)

// Using themed snackbar
ThemedSnackbar.showSuccess(
  context: context,
  message: 'Operation completed successfully!',
)

// Using responsive padding
ResponsivePadding(
  mobile: EdgeInsets.all(16),
  tablet: EdgeInsets.all(24),
  desktop: EdgeInsets.all(32),
  child: MyWidget(),
)
```

### Theme Switching

```dart
// Read current theme
final themeMode = ref.watch(themeModeProvider);

// Change theme
ref.read(themeModeProvider.notifier).state = ThemeMode.dark;

// Toggle theme
final currentTheme = ref.read(themeModeProvider);
final newTheme = currentTheme == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
ref.read(themeModeProvider.notifier).state = newTheme;
```

## Testing

### Navigation Tests

```bash
# Run navigation tests
flutter test test/navigation/

# Run with coverage
flutter test test/navigation/ --coverage
```

### Theme Tests

```bash
# Run theme tests
flutter test test/theme/

# Test on specific device sizes
flutter test test/responsive/ -d chrome --web-browser-flag="--window-size=400,800"
```

### Manual Testing Checklist

- [ ] Test navigation on mobile (portrait/landscape)
- [ ] Test navigation on tablet (portrait/landscape)
- [ ] Test navigation on desktop (various window sizes)
- [ ] Verify dark mode theming on all platforms
- [ ] Test deep linking functionality
- [ ] Verify route guards working correctly
- [ ] Check responsive layouts at all breakpoints
- [ ] Test theme switching functionality

## Best Practices

### Navigation

1. **Use Named Routes**: Always use named routes for better maintainability
2. **Handle Deep Links**: Ensure all routes support deep linking
3. **Route Guards**: Always protect sensitive routes with appropriate guards
4. **Error Handling**: Always provide fallback routes for unknown URLs
5. **Loading States**: Show loading indicators during navigation

### Theming

1. **Consistent Colors**: Use theme colors consistently across all components
2. **Proper Contrast**: Ensure text has sufficient contrast on all backgrounds
3. **Responsive Typography**: Use appropriate font sizes for each device type
4. **Component Theming**: Theme all interactive components consistently
5. **Dark Mode Support**: Always implement dark mode for better accessibility

### Responsive Design

1. **Test All Breakpoints**: Test layouts at mobile, tablet, and desktop sizes
2. **Orientation Support**: Handle both portrait and landscape orientations
3. **Touch Targets**: Ensure touch targets are appropriately sized for mobile
4. **Content Priority**: Prioritize important content on smaller screens
5. **Progressive Enhancement**: Start with mobile-first design

## Troubleshooting

### Common Issues

#### Navigation Problems
- **Route Not Found**: Check route paths in `RoutePaths`
- **Guard Redirects**: Verify authentication state in route guards
- **Deep Link Issues**: Ensure URL schemes are properly configured

#### Theming Issues
- **Color Not Applied**: Check that components use theme colors
- **Dark Mode Problems**: Verify theme provider is working
- **Typography Issues**: Ensure text styles are properly defined

#### Responsive Issues
- **Layout Breaks**: Test at different screen sizes
- **Touch Target Size**: Ensure buttons are large enough on mobile
- **Text Readability**: Check font sizes on different devices

### Debug Tools

```dart
// Enable debug logging for navigation
GoRouter(
  debugLogDiagnostics: true,
  // ... other configuration
)

// Check current theme
print('Current theme: ${Theme.of(context).brightness}');

// Check screen size
print('Screen size: ${MediaQuery.of(context).size}');
print('Device type: ${ResponsiveUtils.getDeviceType(context)}');
```

## Performance Considerations

### Navigation Performance
- **Lazy Loading**: Only load routes when needed
- **Preloading**: Preload frequently used routes
- **Route Caching**: Cache route configurations
- **Transition Optimization**: Use efficient transition animations

### Theming Performance
- **Theme Caching**: Cache computed theme values
- **Minimal Rebuilds**: Only rebuild when theme actually changes
- **Color Computation**: Pre-compute color values when possible

### Responsive Performance
- **Layout Caching**: Cache layout calculations
- **Breakpoint Optimization**: Use efficient breakpoint detection
- **Adaptive Loading**: Load appropriate resources for screen size

## Future Enhancements

### Planned Features
- **Custom Route Transitions**: More sophisticated transition animations
- **Nested Navigation**: Support for nested route structures
- **Dynamic Theming**: Runtime theme customization
- **Advanced Responsive Features**: Container queries, viewport units
- **Internationalization**: Multi-language support for themes
- **Accessibility Enhancements**: Better screen reader support

### Migration Notes
- **Material Design 2 → 3**: All components updated to Material 3
- **Provider → Riverpod**: State management migrated to Riverpod 2.0
- **Navigator 1.0 → go_router**: Improved navigation with better type safety

---

**Last Updated**: 21/09/2025 19:00:00
**Version**: 1.0.0
**Status**: Complete ✅

This implementation provides a solid foundation for navigation and theming that scales across all platforms and screen sizes while maintaining excellent user experience and developer productivity.
