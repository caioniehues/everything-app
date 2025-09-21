import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/widgets/error_screen.dart';
import 'route_paths.dart';

/// Global navigator key for accessing navigator from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Provider for the app router
final appRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter(ref).router;
});

/// App router configuration
class AppRouter {
  final Ref _ref;

  AppRouter(this._ref);

  /// Main router instance
  GoRouter get router => GoRouter(
        navigatorKey: navigatorKey,
        debugLogDiagnostics: kDebugMode,
        initialLocation: RoutePaths.splash,
        errorBuilder: (context, state) => ErrorScreen(
          errorMessage: state.error?.toString(),
        ),
        redirect: _handleRedirect,
        routes: _routes,
      );

  /// Handle global redirects based on authentication state
  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authStateProvider);
    final isAuthRoute = _isAuthRoute(state.fullPath ?? '');
    final isProtectedRoute = _isProtectedRoute(state.fullPath ?? '');

    // Handle splash screen redirect
    if (state.fullPath == RoutePaths.splash) {
      if (authState is AuthAuthenticated && !authState.isTokenExpired) {
        return RoutePaths.dashboard;
      } else {
        return RoutePaths.login;
      }
    }

    // Redirect authenticated users away from auth pages
    if (isAuthRoute &&
        authState is AuthAuthenticated &&
        !authState.isTokenExpired) {
      return RoutePaths.dashboard;
    }

    // Redirect unauthenticated users from protected pages
    if (isProtectedRoute) {
      if (authState is! AuthAuthenticated) {
        return RoutePaths.login;
      }
      if (authState.isTokenExpired) {
        return RoutePaths.login;
      }
    }

    return null; // No redirect needed
  }

  /// Check if route is an authentication route
  bool _isAuthRoute(String path) {
    return [
      RoutePaths.login,
      RoutePaths.register,
      RoutePaths.forgotPassword,
      RoutePaths.resetPassword,
    ].contains(path);
  }

  /// Check if route is protected
  bool _isProtectedRoute(String path) {
    return RoutePaths.isProtectedRoute(path) ||
        RoutePaths.isAdminRoute(path) ||
        path.startsWith('/settings') ||
        path.startsWith('/accounts') ||
        path.startsWith('/transactions') ||
        path.startsWith('/budgets') ||
        path.startsWith('/goals');
  }

  /// Define all app routes
  List<RouteBase> get _routes => [
        // Splash/Root route
        GoRoute(
          path: RoutePaths.splash,
          name: RoutePaths.splashName,
          builder: (context, state) => const SplashScreen(),
        ),

        // Authentication routes
        GoRoute(
          path: RoutePaths.login,
          name: RoutePaths.loginName,
          pageBuilder: (context, state) => _buildPageWithTransition(
            child: const LoginScreen(),
            state: state,
            transition: RouteTransition.slide,
          ),
        ),
        GoRoute(
          path: RoutePaths.register,
          name: RoutePaths.registerName,
          pageBuilder: (context, state) => _buildPageWithTransition(
            child: const RegisterScreen(),
            state: state,
            transition: RouteTransition.slide,
          ),
        ),

        // Main app routes
        GoRoute(
          path: RoutePaths.dashboard,
          name: RoutePaths.dashboardName,
          pageBuilder: (context, state) => _buildPageWithTransition(
            child: const DashboardScreen(),
            state: state,
          ),
        ),

        // Settings routes
        GoRoute(
          path: RoutePaths.settings,
          name: RoutePaths.settingsName,
          pageBuilder: (context, state) => _buildPageWithTransition(
            child: const SettingsScreen(),
            state: state,
            transition: RouteTransition.slide,
          ),
          routes: [
            // Settings sub-routes can be added here
            GoRoute(
              path: '/account',
              name: RoutePaths.settingsAccountName,
              builder: (context, state) => const PlaceholderScreen(
                title: 'Account Settings',
                message: 'Account settings page coming soon!',
              ),
            ),
            GoRoute(
              path: '/notifications',
              name: RoutePaths.settingsNotificationsName,
              builder: (context, state) => const PlaceholderScreen(
                title: 'Notification Settings',
                message: 'Notification settings page coming soon!',
              ),
            ),
            GoRoute(
              path: '/security',
              name: RoutePaths.settingsSecurityName,
              builder: (context, state) => const PlaceholderScreen(
                title: 'Security Settings',
                message: 'Security settings page coming soon!',
              ),
            ),
          ],
        ),

        // Feature placeholder routes
        GoRoute(
          path: RoutePaths.accounts,
          name: RoutePaths.accountsName,
          builder: (context, state) => const PlaceholderScreen(
            title: 'Accounts',
            message: 'Accounts feature coming soon!',
          ),
        ),
        GoRoute(
          path: RoutePaths.transactions,
          name: RoutePaths.transactionsName,
          builder: (context, state) => const PlaceholderScreen(
            title: 'Transactions',
            message: 'Transactions feature coming soon!',
          ),
        ),
        GoRoute(
          path: RoutePaths.budgets,
          name: RoutePaths.budgetsName,
          builder: (context, state) => const PlaceholderScreen(
            title: 'Budgets',
            message: 'Budgets feature coming soon!',
          ),
        ),
        GoRoute(
          path: RoutePaths.goals,
          name: RoutePaths.goalsName,
          builder: (context, state) => const PlaceholderScreen(
            title: 'Goals',
            message: 'Goals feature coming soon!',
          ),
        ),
        GoRoute(
          path: RoutePaths.profile,
          name: RoutePaths.profileName,
          builder: (context, state) => const PlaceholderScreen(
            title: 'Profile',
            message: 'Profile page coming soon!',
          ),
        ),

        // Error routes
        GoRoute(
          path: RoutePaths.notFound,
          name: RoutePaths.notFoundName,
          builder: (context, state) => const NotFoundScreen(),
        ),
      ];

  /// Build page with transition animation
  Page<void> _buildPageWithTransition({
    required Widget child,
    required GoRouterState state,
    RouteTransition transition = RouteTransition.fade,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    switch (transition) {
      case RouteTransition.slide:
        return CustomTransitionPage(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1, 0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: duration,
        );

      case RouteTransition.scale:
        return CustomTransitionPage(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOut;
            final tween = Tween(begin: 0.8, end: 1).chain(
              CurveTween(curve: curve),
            );

            return ScaleTransition(
              scale: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: duration,
        );

      case RouteTransition.rotation:
        return CustomTransitionPage(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOut;
            final tween = Tween(begin: 0.8, end: 1).chain(
              CurveTween(curve: curve),
            );

            return RotationTransition(
              turns: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: duration,
        );

      case RouteTransition.fade:
      default:
        return MaterialPage(
          key: state.pageKey,
          child: child,
        );
    }
  }
}

/// Temporary splash screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 120,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Everything App',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

/// Placeholder screen for unimplemented features
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String message;

  const PlaceholderScreen({
    required this.title, required this.message, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.go(RoutePaths.dashboard),
                icon: const Icon(Icons.home),
                label: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}