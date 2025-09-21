import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor that handles request retries with exponential backoff
/// Useful for handling temporary network issues and server errors
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration baseDelay;
  final List<int> retryableStatusCodes;

  RetryInterceptor({
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 1000),
    this.retryableStatusCodes = const [500, 502, 503, 504, 408, 429],
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final retryCount = (requestOptions.extra['retry_count'] as int?) ?? 0;

    // Check if we should retry this request
    if (retryCount < maxRetries && _shouldRetry(err)) {
      final nextRetryCount = retryCount + 1;

      // Calculate delay with exponential backoff and jitter
      final delay = _calculateDelay(retryCount);

      if (kDebugMode) {
        print('🔄 API RETRY: Attempt $nextRetryCount/$maxRetries after ${delay.inMilliseconds}ms delay');
      }

      // Wait for the calculated delay
      await Future.delayed(delay);

      // Update request options with new retry count
      final newOptions = requestOptions.copyWith(
        extra: {...requestOptions.extra, 'retry_count': nextRetryCount},
      );

      try {
        // Retry the request
        final response = await Dio().fetch(newOptions);
        return handler.resolve(response);
      } catch (retryError) {
        // If retry also fails, continue with error handling
        final enhancedError = DioException(
          requestOptions: newOptions,
          response: (retryError as DioException).response,
          type: retryError.type,
          error: retryError.error,
        );
        return handler.next(enhancedError);
      }
    }

    // Don't retry, pass error to next handler
    return handler.next(err);
  }

  /// Check if the error should trigger a retry
  bool _shouldRetry(DioException err) {
    // Don't retry if it's a cancellation
    if (err.type == DioExceptionType.cancel) {
      return false;
    }

    // Retry on network errors
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    // Retry on specific status codes
    final statusCode = err.response?.statusCode;
    if (statusCode != null && retryableStatusCodes.contains(statusCode)) {
      return true;
    }

    return false;
  }

  /// Calculate delay with exponential backoff and jitter
  Duration _calculateDelay(int retryCount) {
    final exponentialDelay = baseDelay * (1 << retryCount); // 2^retryCount
    final jitter = (exponentialDelay.inMilliseconds * 0.1 * _random.nextDouble()).toInt();
    return Duration(milliseconds: exponentialDelay.inMilliseconds + jitter);
  }

  // Random number generator for jitter
  final _random = Random();
}

/// Configuration for different retry strategies
class RetryConfig {
  const RetryConfig._();

  /// Standard retry configuration for most API calls
  static const standard = RetryInterceptor(
    
  );

  /// Aggressive retry configuration for critical operations
  static const aggressive = RetryInterceptor(
    maxRetries: 5,
    baseDelay: Duration(milliseconds: 500),
    retryableStatusCodes: [500, 502, 503, 504, 408, 429, 403],
  );

  /// Conservative retry configuration for non-critical operations
  static const conservative = RetryInterceptor(
    maxRetries: 2,
    baseDelay: Duration(milliseconds: 2000),
    retryableStatusCodes: [500, 502, 503, 504],
  );

  /// No retry configuration (useful for disabling retries)
  static const none = RetryInterceptor(
    maxRetries: 0,
    baseDelay: Duration.zero,
    retryableStatusCodes: [],
  );
}
