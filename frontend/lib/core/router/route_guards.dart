import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/providers/auth_provider.dart';
import 'route_paths.dart';

/// Route guard result indicating where navigation should go
class GuardResult {
  final bool canAccess;
  final String? redirectPath;
  final String? reason;

  const GuardResult.allow()
      : canAccess = true,
        redirectPath = null,
        reason = null;

  const GuardResult.deny({
    required this.redirectPath,
    this.reason,
  }) : canAccess = false;

  bool get shouldRedirect => !canAccess && redirectPath != null;
}

/// Base class for all route guards
abstract class RouteGuard {
  const RouteGuard();

  /// Check if access should be granted to the route
  Future<GuardResult> canAccess({
    required WidgetRef ref,
    required String path,
    Map<String, String>? params,
    Map<String, String>? query,
  });

  /// Optional method to handle guard failure
  void onAccessDenied({
    required String path,
    required String? reason,
  }) {
    if (kDebugMode) {
      debugPrint('Route access denied: $path - Reason: $reason');
    }
  }
}

/// Guard that checks if user is authenticated
class AuthGuard extends RouteGuard {
  const AuthGuard();

  @override
  Future<GuardResult> canAccess({
    required WidgetRef ref,
    required String path,
    Map<String, String>? params,
    Map<String, String>? query,
  }) async {
    final authState = ref.read(authStateProvider);

    // Allow access if user is authenticated
    if (authState is AuthAuthenticated) {
      // Check if token is expired
      if (authState.isTokenExpired) {
        return const GuardResult.deny(
          redirectPath: RoutePaths.login,
          reason: 'Token expired',
        );
      }
      return const GuardResult.allow();
    }

    // Deny access and redirect to login
    return const GuardResult.deny(
      redirectPath: RoutePaths.login,
      reason: 'User not authenticated',
    );
  }
}

/// Guard that redirects authenticated users away from auth pages
class GuestGuard extends RouteGuard {
  const GuestGuard();

  @override
  Future<GuardResult> canAccess({
    required WidgetRef ref,
    required String path,
    Map<String, String>? params,
    Map<String, String>? query,
  }) async {
    final authState = ref.read(authStateProvider);

    // If user is authenticated, redirect to dashboard
    if (authState is AuthAuthenticated && !authState.isTokenExpired) {
      return const GuardResult.deny(
        redirectPath: RoutePaths.dashboard,
        reason: 'User already authenticated',
      );
    }

    // Allow access for non-authenticated users
    return const GuardResult.allow();
  }
}

/// Guard that checks for admin privileges
class AdminGuard extends RouteGuard {
  const AdminGuard();

  @override
  Future<GuardResult> canAccess({
    required WidgetRef ref,
    required String path,
    Map<String, String>? params,
    Map<String, String>? query,
  }) async {
    final authState = ref.read(authStateProvider);

    // First check authentication
    if (authState is! AuthAuthenticated) {
      return const GuardResult.deny(
        redirectPath: RoutePaths.login,
        reason: 'User not authenticated',
      );
    }

    // Check token expiry
    if (authState.isTokenExpired) {
      return const GuardResult.deny(
        redirectPath: RoutePaths.login,
        reason: 'Token expired',
      );
    }

    // TODO: Add actual admin role check when user roles are implemented
    // For now, we'll allow access (this would typically check user.isAdmin)

    // Placeholder for admin check - uncomment when roles are implemented:
    // if (!user.hasRole('admin')) {
    //   return const GuardResult.deny(
    //     redirectPath: RoutePaths.dashboard,
    //     reason: 'Insufficient permissions',
    //   );
    // }

    return const GuardResult.allow();
  }
}

/// Guard that checks for specific permissions
class PermissionGuard extends RouteGuard {
  final List<String> requiredPermissions;

  const PermissionGuard({required this.requiredPermissions});

  @override
  Future<GuardResult> canAccess({
    required WidgetRef ref,
    required String path,
    Map<String, String>? params,
    Map<String, String>? query,
  }) async {
    final authState = ref.read(authStateProvider);

    // Check authentication first
    if (authState is! AuthAuthenticated) {
      return const GuardResult.deny(
        redirectPath: RoutePaths.login,
        reason: 'User not authenticated',
      );
    }

    // Check token expiry
    if (authState.isTokenExpired) {
      return const GuardResult.deny(
        redirectPath: RoutePaths.login,
        reason: 'Token expired',
      );
    }

    // TODO: Add actual permission check when user permissions are implemented
    // For now, we'll allow access

    // Placeholder for permission check:
    // final userPermissions = user.permissions;
    // final hasAllPermissions = requiredPermissions.every(
    //   (permission) => userPermissions.contains(permission),
    // );
    //
    // if (!hasAllPermissions) {
    //   return const GuardResult.deny(
    //     redirectPath: RoutePaths.dashboard,
    //     reason: 'Missing required permissions: ${requiredPermissions.join(', ')}',
    //   );
    // }

    return const GuardResult.allow();
  }
}

/// Guard for onboarding flow
class OnboardingGuard extends RouteGuard {
  const OnboardingGuard();

  @override
  Future<GuardResult> canAccess({
    required WidgetRef ref,
    required String path,
    Map<String, String>? params,
    Map<String, String>? query,
  }) async {
    // TODO: Check if user has completed onboarding
    // This would typically check a flag in user preferences or app state

    // For now, we'll allow access to onboarding
    // In a real app, you might check:
    // final hasCompletedOnboarding = ref.read(onboardingStatusProvider);
    // if (hasCompletedOnboarding) {
    //   return const GuardResult.deny(
    //     redirectPath: RoutePaths.dashboard,
    //     reason: 'Onboarding already completed',
    //   );
    // }

    return const GuardResult.allow();
  }
}

/// Composite guard that applies multiple guards
class CompositeGuard extends RouteGuard {
  final List<RouteGuard> guards;
  final bool requireAll;

  const CompositeGuard({
    required this.guards,
    this.requireAll = true,
  });

  @override
  Future<GuardResult> canAccess({
    required WidgetRef ref,
    required String path,
    Map<String, String>? params,
    Map<String, String>? query,
  }) async {
    for (final guard in guards) {
      final result = await guard.canAccess(
        ref: ref,
        path: path,
        params: params,
        query: query,
      );

      if (!result.canAccess) {
        if (requireAll) {
          // Fail fast if any guard fails and we require all
          return result;
        }
      } else {
        if (!requireAll) {
          // Pass fast if any guard passes and we don't require all
          return result;
        }
      }
    }

    // If requireAll=true and we get here, all guards passed
    // If requireAll=false and we get here, all guards failed
    return requireAll
        ? const GuardResult.allow()
        : const GuardResult.deny(
            redirectPath: RoutePaths.login,
            reason: 'All guards failed',
          );
  }
}

/// Factory for creating route guards
class RouteGuardFactory {
  RouteGuardFactory._();

  /// Create appropriate guard for a route
  static RouteGuard? createGuard(String path) {
    // Public routes that should redirect authenticated users
    if (RoutePaths.isPublicRoute(path) &&
        [RoutePaths.login, RoutePaths.register].contains(path)) {
      return const GuestGuard();
    }

    // Protected routes that require authentication
    if (RoutePaths.isProtectedRoute(path)) {
      return const AuthGuard();
    }

    // Admin routes that require authentication and admin role
    if (RoutePaths.isAdminRoute(path)) {
      return const CompositeGuard(guards: [
        AuthGuard(),
        AdminGuard(),
      ]);
    }

    // Special cases
    switch (path) {
      case RoutePaths.onboarding:
        return const OnboardingGuard();
      default:
        return null; // No guard needed
    }
  }

  /// Create guard with specific permissions
  static RouteGuard createPermissionGuard(List<String> permissions) {
    return CompositeGuard(guards: [
      const AuthGuard(),
      PermissionGuard(requiredPermissions: permissions),
    ]);
  }
}

/// Extension to integrate guards with GoRouter
extension GoRouterGuards on GoRouter {
  /// Apply route guard to a route transition
  static Future<String?> applyGuard({
    required RouteGuard? guard,
    required WidgetRef ref,
    required String path,
    Map<String, String>? params,
    Map<String, String>? query,
  }) async {
    if (guard == null) return null;

    final result = await guard.canAccess(
      ref: ref,
      path: path,
      params: params,
      query: query,
    );

    if (result.shouldRedirect) {
      guard.onAccessDenied(
        path: path,
        reason: result.reason,
      );
      return result.redirectPath;
    }

    return null;
  }
}