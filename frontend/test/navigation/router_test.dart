import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/router/route_guards.dart';
import 'package:frontend/core/router/route_paths.dart';
import 'package:frontend/shared/providers/auth_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('AppRouter Tests', () {
    test('should create router with correct configuration', () {
      final router = container.read(appRouterProvider);

      expect(router, isNotNull);
      expect(router.routeInformationProvider, isNotNull);
      expect(router.routeInformationParser, isNotNull);
      expect(router.routerDelegate, isNotNull);
    });
  });

  group('Route Paths Tests', () {
    test('should have all required route paths', () {
      expect(RoutePaths.splash, equals('/'));
      expect(RoutePaths.login, equals('/login'));
      expect(RoutePaths.register, equals('/register'));
      expect(RoutePaths.dashboard, equals('/dashboard'));
      expect(RoutePaths.settings, equals('/settings'));
      expect(RoutePaths.notFound, equals('/404'));
    });

    test('should identify protected routes correctly', () {
      expect(RoutePaths.isProtectedRoute('/dashboard'), isTrue);
      expect(RoutePaths.isProtectedRoute('/settings'), isTrue);
      expect(RoutePaths.isProtectedRoute('/login'), isFalse);
      expect(RoutePaths.isProtectedRoute('/register'), isFalse);
    });

    test('should identify admin routes correctly', () {
      expect(RoutePaths.isAdminRoute('/admin'), isTrue);
      expect(RoutePaths.isAdminRoute('/admin/users'), isTrue);
      expect(RoutePaths.isAdminRoute('/dashboard'), isFalse);
    });
  });

  group('AuthGuard Tests', () {
    test('should allow access to protected routes when authenticated', () async {
      const guard = AuthGuard();

      // Set authenticated state
      container.read(authStateProvider.notifier).state = const AuthAuthenticated(
        userId: 'user123',
        email: 'test@example.com',
        accessToken: 'token123',
        refreshToken: 'refresh123',
      );

      final result = await guard.canAccess(
        ref: container,
        path: '/dashboard',
      );

      expect(result.canAccess, isTrue);
      expect(result.redirectPath, isNull);
    });

    test('should redirect unauthenticated users from protected routes', () async {
      const guard = AuthGuard();

      final result = await guard.canAccess(
        ref: container,
        path: '/dashboard',
      );

      expect(result.canAccess, isFalse);
      expect(result.redirectPath, equals('/login'));
      expect(result.reason, equals('User not authenticated'));
    });

    test('should redirect users with expired tokens', () async {
      const guard = AuthGuard();

      // Set expired token state
      container.read(authStateProvider.notifier).state = const AuthAuthenticated(
        userId: 'user123',
        email: 'test@example.com',
        accessToken: 'token123',
        refreshToken: 'refresh123',
      );

      final result = await guard.canAccess(
        ref: container,
        path: '/dashboard',
      );

      expect(result.canAccess, isFalse);
      expect(result.redirectPath, equals('/login'));
      expect(result.reason, equals('Token expired'));
    });
  });

  group('GuestGuard Tests', () {
    test('should redirect authenticated users from auth pages', () async {
      const guard = GuestGuard();

      // Set authenticated state
      container.read(authStateProvider.notifier).state = const AuthAuthenticated(
        userId: 'user123',
        email: 'test@example.com',
        accessToken: 'token123',
        refreshToken: 'refresh123',
      );

      final result = await guard.canAccess(
        ref: container,
        path: '/login',
      );

      expect(result.canAccess, isFalse);
      expect(result.redirectPath, equals('/dashboard'));
      expect(result.reason, equals('User already authenticated'));
    });

    test('should allow unauthenticated users to auth pages', () async {
      const guard = GuestGuard();

      final result = await guard.canAccess(
        ref: container,
        path: '/login',
      );

      expect(result.canAccess, isTrue);
      expect(result.redirectPath, isNull);
    });
  });

  group('CompositeGuard Tests', () {
    test('should require all guards to pass when requireAll is true', () async {
      const guard = CompositeGuard(guards: [
        AuthGuard(),
        GuestGuard(), // This will fail for authenticated users
      ]);

      // Set authenticated state
      container.read(authStateProvider.notifier).state = const AuthAuthenticated(
        userId: 'user123',
        email: 'test@example.com',
        accessToken: 'token123',
        refreshToken: 'refresh123',
      );

      final result = await guard.canAccess(
        ref: container,
        path: '/dashboard',
      );

      expect(result.canAccess, isFalse);
    });
  });

  group('Route Guard Factory Tests', () {
    test('should create AuthGuard for protected routes', () {
      final guard = RouteGuardFactory.createGuard('/dashboard');

      expect(guard, isA<AuthGuard>());
    });

    test('should create GuestGuard for auth routes', () {
      final guard = RouteGuardFactory.createGuard('/login');

      expect(guard, isA<GuestGuard>());
    });

    test('should create CompositeGuard for admin routes', () {
      final guard = RouteGuardFactory.createGuard('/admin');

      expect(guard, isA<CompositeGuard>());
    });

    test('should return null for unguarded routes', () {
      final guard = RouteGuardFactory.createGuard('/');

      expect(guard, isNull);
    });
  });
}