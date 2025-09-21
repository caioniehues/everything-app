import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/errors/failures.dart';

/// Secure storage instance for auth tokens
const _secureStorage = FlutterSecureStorage();

/// Keys for storing auth data
const String _accessTokenKey = 'access_token';
const String _refreshTokenKey = 'refresh_token';
const String _userIdKey = 'user_id';
const String _userEmailKey = 'user_email';

/// Auth state provider
/// Manages authentication state and user session
final authStateProvider = NotifierProvider<AuthStateNotifier, AuthState>(() {
  return AuthStateNotifier();
});

/// Authentication state
sealed class AuthState {
  const AuthState();
}

/// Initial state when app starts
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during authentication operations
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state with user data
class AuthAuthenticated extends AuthState {
  final String userId;
  final String email;
  final String accessToken;
  final String refreshToken;
  final DateTime? tokenExpiry;

  const AuthAuthenticated({
    required this.userId,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
    this.tokenExpiry,
  });

  /// Check if access token is expired
  bool get isTokenExpired {
    if (tokenExpiry == null) return false;
    return DateTime.now().isAfter(tokenExpiry!);
  }

  /// Create a copy with updated fields
  AuthAuthenticated copyWith({
    String? userId,
    String? email,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiry,
  }) {
    return AuthAuthenticated(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
    );
  }
}

/// Unauthenticated state
class AuthUnauthenticated extends AuthState {
  final String? message;

  const AuthUnauthenticated({this.message});
}

/// Error state during authentication
class AuthError extends AuthState {
  final Failure failure;

  const AuthError({required this.failure});
}

/// State notifier for authentication management
class AuthStateNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    checkAuthStatus();
    return const AuthInitial();
  }

  /// Check if user has valid stored credentials
  Future<void> checkAuthStatus() async {
    state = const AuthLoading();

    try {
      // Check for stored tokens
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      final userId = await _secureStorage.read(key: _userIdKey);
      final email = await _secureStorage.read(key: _userEmailKey);

      if (accessToken != null && refreshToken != null && userId != null && email != null) {
        // Tokens exist, user is authenticated
        state = AuthAuthenticated(
          userId: userId,
          email: email,
          accessToken: accessToken,
          refreshToken: refreshToken,
          tokenExpiry: _calculateTokenExpiry(),
        );
      } else {
        // No stored credentials
        state = const AuthUnauthenticated();
      }
    } catch (e) {
      state = AuthError(
        failure: CacheFailure(message: 'Failed to read auth credentials: $e'),
      );
    }
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    state = const AuthLoading();

    try {
      // Store tokens securely
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      await _secureStorage.write(key: _userIdKey, value: userId);
      await _secureStorage.write(key: _userEmailKey, value: email);

      state = AuthAuthenticated(
        userId: userId,
        email: email,
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenExpiry: _calculateTokenExpiry(),
      );
    } catch (e) {
      state = AuthError(
        failure: CacheFailure(message: 'Failed to store auth credentials: $e'),
      );
    }
  }

  /// Sign out and clear stored credentials
  Future<void> signOut() async {
    state = const AuthLoading();

    try {
      // Clear all stored auth data
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _userEmailKey);

      state = const AuthUnauthenticated(message: 'Successfully signed out');
    } catch (e) {
      state = AuthError(
        failure: CacheFailure(message: 'Failed to clear auth credentials: $e'),
      );
    }
  }

  /// Refresh the access token using refresh token
  Future<void> refreshToken({
    required String newAccessToken,
    required String newRefreshToken,
  }) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    try {
      // Update stored tokens
      await _secureStorage.write(key: _accessTokenKey, value: newAccessToken);
      await _secureStorage.write(key: _refreshTokenKey, value: newRefreshToken);

      state = currentState.copyWith(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        tokenExpiry: _calculateTokenExpiry(),
      );
    } catch (e) {
      state = AuthError(
        failure: CacheFailure(message: 'Failed to update tokens: $e'),
      );
    }
  }

  /// Calculate token expiry (15 minutes from now as per spec)
  DateTime _calculateTokenExpiry() {
    return DateTime.now().add(const Duration(minutes: 15));
  }

  /// Clear error state and return to unauthenticated
  void clearError() {
    if (state is AuthError) {
      state = const AuthUnauthenticated();
    }
  }
}

/// Provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState is AuthAuthenticated;
});

/// Provider for getting current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState is AuthAuthenticated) {
    return authState.userId;
  }
  return null;
});

/// Provider for getting current user email
final currentUserEmailProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState is AuthAuthenticated) {
    return authState.email;
  }
  return null;
});

/// Provider for getting current access token
final accessTokenProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState is AuthAuthenticated) {
    return authState.accessToken;
  }
  return null;
});