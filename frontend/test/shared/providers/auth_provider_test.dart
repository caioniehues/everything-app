import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/errors/failures.dart';
import 'package:frontend/shared/providers/auth_provider.dart';
import 'package:mockito/annotations.dart';

import '../../helpers/provider_helpers.dart';

// Generate mocks
@GenerateMocks([FlutterSecureStorage])
void main() {
  group('AuthStateNotifier', () {
    test('initial state transitions from AuthInitial to AuthLoading', () async {
      final container = createContainer();

      // The constructor immediately calls checkAuthStatus()
      // which transitions the state to AuthLoading
      await Future.delayed(const Duration(milliseconds: 10));

      final authState = container.read(authStateProvider);
      // After initialization, it should be either loading or unauthenticated
      expect(authState, anyOf(isA<AuthLoading>(), isA<AuthUnauthenticated>()));
    });

    test('checkAuthStatus transitions to loading then unauthenticated', () async {
      final container = createContainer();
      final notifier = container.read(authStateProvider.notifier);

      // Should start with initial
      expect(container.read(authStateProvider), isA<AuthInitial>());

      // Check auth status
      await notifier.checkAuthStatus();

      // Should end up unauthenticated (no stored credentials in test)
      expect(container.read(authStateProvider), isA<AuthUnauthenticated>());
    });

    test('signIn updates state to authenticated', () async {
      final container = createContainer();
      final notifier = container.read(authStateProvider.notifier);

      // Sign in with test credentials
      await notifier.signIn(
        email: 'test@example.com',
        password: 'password123',
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
        userId: 'user123',
      );

      // Verify authenticated state
      final state = container.read(authStateProvider);
      expect(state, isA<AuthAuthenticated>());

      final authState = state as AuthAuthenticated;
      expect(authState.email, equals('test@example.com'));
      expect(authState.userId, equals('user123'));
      expect(authState.accessToken, equals('test_access_token'));
      expect(authState.refreshToken, equals('test_refresh_token'));
    });

    test('signOut clears credentials and returns to unauthenticated', () async {
      final container = createContainer();
      final notifier = container.read(authStateProvider.notifier);

      // First sign in
      await notifier.signIn(
        email: 'test@example.com',
        password: 'password123',
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
        userId: 'user123',
      );

      expect(container.read(authStateProvider), isA<AuthAuthenticated>());

      // Sign out
      await notifier.signOut();

      // Verify unauthenticated state
      final state = container.read(authStateProvider);
      expect(state, isA<AuthUnauthenticated>());

      final unauthState = state as AuthUnauthenticated;
      expect(unauthState.message, equals('Successfully signed out'));
    });

    test('refreshToken updates tokens in authenticated state', () async {
      final container = createContainer();
      final notifier = container.read(authStateProvider.notifier);

      // Sign in first
      await notifier.signIn(
        email: 'test@example.com',
        password: 'password123',
        accessToken: 'old_access_token',
        refreshToken: 'old_refresh_token',
        userId: 'user123',
      );

      // Refresh tokens
      await notifier.refreshToken(
        newAccessToken: 'new_access_token',
        newRefreshToken: 'new_refresh_token',
      );

      // Verify tokens updated
      final state = container.read(authStateProvider);
      expect(state, isA<AuthAuthenticated>());

      final authState = state as AuthAuthenticated;
      expect(authState.accessToken, equals('new_access_token'));
      expect(authState.refreshToken, equals('new_refresh_token'));
      expect(authState.email, equals('test@example.com')); // Unchanged
      expect(authState.userId, equals('user123')); // Unchanged
    });

    test('refreshToken does nothing when not authenticated', () async {
      final container = createContainer();
      final notifier = container.read(authStateProvider.notifier);

      // Ensure unauthenticated
      await notifier.checkAuthStatus();
      expect(container.read(authStateProvider), isA<AuthUnauthenticated>());

      // Try to refresh tokens
      await notifier.refreshToken(
        newAccessToken: 'new_access_token',
        newRefreshToken: 'new_refresh_token',
      );

      // Should still be unauthenticated
      expect(container.read(authStateProvider), isA<AuthUnauthenticated>());
    });

    test('clearError transitions from error to unauthenticated', () {
      final container = createContainer();
      final notifier = container.read(authStateProvider.notifier);

      // Set error state manually
      notifier.state = const AuthError(
        failure: CacheFailure(message: 'Test error'),
      );

      expect(container.read(authStateProvider), isA<AuthError>());

      // Clear error
      notifier.clearError();

      // Should be unauthenticated
      expect(container.read(authStateProvider), isA<AuthUnauthenticated>());
    });

    test('token expiry calculation is 15 minutes', () async {
      final container = createContainer();
      final notifier = container.read(authStateProvider.notifier);

      final beforeSignIn = DateTime.now();

      await notifier.signIn(
        email: 'test@example.com',
        password: 'password123',
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
        userId: 'user123',
      );

      final state = container.read(authStateProvider) as AuthAuthenticated;
      final expiry = state.tokenExpiry!;

      // Should be approximately 15 minutes from now
      final difference = expiry.difference(beforeSignIn);
      expect(difference.inMinutes, greaterThanOrEqualTo(14));
      expect(difference.inMinutes, lessThanOrEqualTo(16));
    });
  });

  group('Auth Helper Providers', () {
    test('isAuthenticatedProvider returns true when authenticated', () async {
      final container = createContainer();
      final notifier = container.read(authStateProvider.notifier);

      // Initially false
      expect(container.read(isAuthenticatedProvider), isFalse);

      // Sign in
      await notifier.signIn(
        email: 'test@example.com',
        password: 'password123',
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
        userId: 'user123',
      );

      // Invalidate to refresh
      container.invalidate(isAuthenticatedProvider);

      // Now true
      expect(container.read(isAuthenticatedProvider), isTrue);
    });

    test('currentUserIdProvider returns user ID when authenticated', () async {
      final container = createContainer();
      final notifier = container.read(authStateProvider.notifier);

      // Initially null
      expect(container.read(currentUserIdProvider), isNull);

      // Sign in
      await notifier.signIn(
        email: 'test@example.com',
        password: 'password123',
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
        userId: 'user123',
      );

      // Invalidate to refresh
      container.invalidate(currentUserIdProvider);

      // Returns user ID
      expect(container.read(currentUserIdProvider), equals('user123'));
    });

    test('currentUserEmailProvider returns email when authenticated', () async {
      final container = createContainer();
      final notifier = container.read(authStateProvider.notifier);

      // Initially null
      expect(container.read(currentUserEmailProvider), isNull);

      // Sign in
      await notifier.signIn(
        email: 'test@example.com',
        password: 'password123',
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
        userId: 'user123',
      );

      // Invalidate to refresh
      container.invalidate(currentUserEmailProvider);

      // Returns email
      expect(container.read(currentUserEmailProvider), equals('test@example.com'));
    });

    test('accessTokenProvider returns token when authenticated', () async {
      final container = createContainer();
      final notifier = container.read(authStateProvider.notifier);

      // Initially null
      expect(container.read(accessTokenProvider), isNull);

      // Sign in
      await notifier.signIn(
        email: 'test@example.com',
        password: 'password123',
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
        userId: 'user123',
      );

      // Invalidate to refresh
      container.invalidate(accessTokenProvider);

      // Returns access token
      expect(container.read(accessTokenProvider), equals('test_access_token'));
    });
  });

  group('AuthAuthenticated', () {
    test('isTokenExpired returns correct value', () {
      // Create authenticated state with expired token
      final expiredState = AuthAuthenticated(
        userId: 'user123',
        email: 'test@example.com',
        accessToken: 'token',
        refreshToken: 'refresh',
        tokenExpiry: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      expect(expiredState.isTokenExpired, isTrue);

      // Create authenticated state with valid token
      final validState = AuthAuthenticated(
        userId: 'user123',
        email: 'test@example.com',
        accessToken: 'token',
        refreshToken: 'refresh',
        tokenExpiry: DateTime.now().add(const Duration(minutes: 10)),
      );

      expect(validState.isTokenExpired, isFalse);

      // Create authenticated state with no expiry
      const noExpiryState = AuthAuthenticated(
        userId: 'user123',
        email: 'test@example.com',
        accessToken: 'token',
        refreshToken: 'refresh',
      );

      expect(noExpiryState.isTokenExpired, isFalse);
    });

    test('copyWith creates new instance with updated fields', () {
      const original = AuthAuthenticated(
        userId: 'user123',
        email: 'test@example.com',
        accessToken: 'token',
        refreshToken: 'refresh',
      );

      final updated = original.copyWith(
        accessToken: 'new_token',
        refreshToken: 'new_refresh',
      );

      expect(updated.accessToken, equals('new_token'));
      expect(updated.refreshToken, equals('new_refresh'));
      expect(updated.userId, equals('user123')); // Unchanged
      expect(updated.email, equals('test@example.com')); // Unchanged
    });
  });
}