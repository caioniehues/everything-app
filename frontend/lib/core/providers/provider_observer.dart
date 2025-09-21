import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Custom provider observer for debugging and monitoring state changes
/// Logs all provider lifecycle events in debug mode
class AppProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      debugPrint('[Provider Added] ${provider.name ?? provider.runtimeType}: $value');
    }
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      debugPrint('[Provider Updated] ${provider.name ?? provider.runtimeType}');
      debugPrint('  Previous: $previousValue');
      debugPrint('  New: $newValue');
    }
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      debugPrint('[Provider Disposed] ${provider.name ?? provider.runtimeType}');
    }
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      debugPrint('[Provider Failed] ${provider.name ?? provider.runtimeType}');
      debugPrint('  Error: $error');
      debugPrint('  Stack trace:\n$stackTrace');
    }
    // In production, send error to crash reporting service
    super.providerDidFail(provider, error, stackTrace, container);
  }
}

/// Provider observer for production with crash reporting
class ProductionProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    // Log to crash reporting service (e.g., Sentry, Crashlytics)
    _logErrorToCrashlytics(
      'Provider Error: ${provider.name ?? provider.runtimeType}',
      error,
      stackTrace,
    );
    super.providerDidFail(provider, error, stackTrace, container);
  }

  void _logErrorToCrashlytics(String message, Object error, StackTrace stackTrace) {
    // TODO: Implement crash reporting when service is configured
    // Example: Sentry.captureException(error, stackTrace: stackTrace);
    if (kDebugMode) {
      debugPrint('Would log to crash reporting: $message');
    }
  }
}

/// Factory to create appropriate observer based on environment
class ProviderObserverFactory {
  static ProviderObserver create() {
    if (kDebugMode) {
      return AppProviderObserver();
    }
    return ProductionProviderObserver();
  }
}