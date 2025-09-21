import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../constants/app_strings.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Centralized error handler for the application
/// Converts exceptions to failures and provides error messages
class ErrorHandler {
  ErrorHandler._();

  /// Handle exceptions and convert them to failures
  static Failure handleException(Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }

    // Handle custom exceptions
    if (error is AppException) {
      return _handleAppException(error);
    }

    // Handle Dio errors
    if (error is DioException) {
      return _handleDioException(error);
    }

    // Handle platform exceptions
    if (error is PlatformException) {
      return _handlePlatformException(error);
    }

    // Handle socket exceptions
    if (error is SocketException) {
      return NetworkFailure.noConnection();
    }

    // Handle timeout exceptions
    if (error is TimeoutException) {
      return NetworkFailure.timeout();
    }

    // Handle format exceptions
    if (error is FormatException) {
      return ParseFailure.invalidFormat(error.message);
    }

    // Handle type errors
    if (error is TypeError) {
      return ParseFailure.typeMismatch('Unknown', error.toString());
    }

    // Default to unknown failure
    return UnknownFailure.fromError(error);
  }

  /// Handle custom app exceptions
  static Failure _handleAppException(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return _handleNetworkException(exception as NetworkException);
      case CacheException:
        return _handleCacheException(exception as CacheException);
      case ValidationException:
        return _handleValidationException(exception as ValidationException);
      case AuthException:
        return _handleAuthException(exception as AuthException);
      case PermissionException:
        return _handlePermissionException(exception as PermissionException);
      case StorageException:
        return _handleStorageException(exception as StorageException);
      case ParseException:
        return _handleParseException(exception as ParseException);
      default:
        return UnknownFailure(message: exception.message, code: exception.code, data: exception.data);
    }
  }

  /// Handle network exceptions
  static Failure _handleNetworkException(NetworkException exception) {
    return NetworkFailure(
      message: exception.message,
      code: exception.code ?? 'NETWORK_ERROR',
      data: {'statusCode': exception.statusCode},
    );
  }

  /// Handle cache exceptions
  static Failure _handleCacheException(CacheException exception) {
    return CacheFailure(
      message: exception.message,
      code: exception.code ?? 'CACHE_ERROR',
      data: exception.data,
    );
  }

  /// Handle validation exceptions
  static Failure _handleValidationException(ValidationException exception) {
    return ValidationFailure(
      message: exception.message,
      code: exception.code ?? 'VALIDATION_ERROR',
      fieldErrors: exception.fieldErrors,
      data: exception.data,
    );
  }

  /// Handle auth exceptions
  static Failure _handleAuthException(AuthException exception) {
    return AuthFailure(
      message: exception.message,
      code: exception.code ?? 'AUTH_ERROR',
      data: exception.data,
    );
  }

  /// Handle permission exceptions
  static Failure _handlePermissionException(PermissionException exception) {
    return PermissionFailure(
      message: exception.message,
      code: exception.code ?? 'PERMISSION_ERROR',
      data: exception.data,
    );
  }

  /// Handle storage exceptions
  static Failure _handleStorageException(StorageException exception) {
    return StorageFailure(
      message: exception.message,
      code: exception.code ?? 'STORAGE_ERROR',
      data: exception.data,
    );
  }

  /// Handle parse exceptions
  static Failure _handleParseException(ParseException exception) {
    return ParseFailure(
      message: exception.message,
      code: exception.code ?? 'PARSE_ERROR',
      data: exception.data,
    );
  }

  /// Handle Dio exceptions
  static Failure _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure.timeout();

      case DioExceptionType.connectionError:
        return NetworkFailure.noConnection();

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      case DioExceptionType.cancel:
        return const NetworkFailure(
          message: 'Request cancelled',
          code: 'CANCELLED',
        );

      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          message: 'Certificate verification failed',
          code: 'BAD_CERTIFICATE',
        );

      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          return NetworkFailure.noConnection();
        }
        return NetworkFailure(
          message: error.message ?? AppStrings.somethingWentWrong,
          code: 'UNKNOWN_NETWORK_ERROR',
        );
    }
  }

  /// Handle bad response from server
  static Failure _handleBadResponse(Response? response) {
    if (response == null) {
      return NetworkFailure.serverError();
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    // Try to extract error message from response
    String? message;
    if (data is Map) {
      message = data['message'] ?? data['error'] ?? data['detail'];
    } else if (data is String) {
      message = data;
    }

    switch (statusCode) {
      case 400:
        return NetworkFailure.badRequest(message);
      case 401:
        return AuthFailure.unauthorized();
      case 403:
        return const PermissionFailure(
          message: 'Access forbidden',
          code: 'FORBIDDEN',
        );
      case 404:
        return BusinessFailure.resourceNotFound('Resource');
      case 409:
        return BusinessFailure.duplicateEntry();
      case 422:
        // Handle validation errors
        if (data is Map && data.containsKey('errors')) {
          final errors = data['errors'];
          if (errors is Map) {
            final fieldErrors = <String, List<String>>{};
            errors.forEach((key, value) {
              if (value is List) {
                fieldErrors[key] = value.map((e) => e.toString()).toList();
              } else {
                fieldErrors[key] = [value.toString()];
              }
            });
            return ValidationFailure.multipleErrors(fieldErrors);
          }
        }
        return ValidationFailure(message: message ?? 'Validation failed');
      case 429:
        return BusinessFailure.limitExceeded('Rate limit');
      case 500:
      case 502:
      case 503:
      case 504:
        return NetworkFailure.serverError(message);
      default:
        return NetworkFailure(
          message: message ?? 'Server error',
          code: 'HTTP_$statusCode',
          data: statusCode,
        );
    }
  }

  /// Handle platform exceptions
  static Failure _handlePlatformException(PlatformException error) {
    return UnknownFailure(
      message: error.message ?? AppStrings.somethingWentWrong,
      code: error.code,
      data: error.details,
    );
  }

  /// Get user-friendly error message from failure
  static String getErrorMessage(Failure failure) {
    // Return the failure message if it's user-friendly
    if (failure.message.isNotEmpty && !failure.message.contains('Exception')) {
      return failure.message;
    }

    // Provide specific messages based on failure type
    switch (failure.runtimeType) {
      case NetworkFailure:
        return _getNetworkErrorMessage(failure as NetworkFailure);
      case AuthFailure:
        return _getAuthErrorMessage(failure as AuthFailure);
      case ValidationFailure:
        return _getValidationErrorMessage(failure as ValidationFailure);
      case CacheFailure:
        return AppStrings.somethingWentWrong;
      case StorageFailure:
        return _getStorageErrorMessage(failure as StorageFailure);
      case BusinessFailure:
        return failure.message;
      case PermissionFailure:
        return failure.message;
      case ParseFailure:
        return AppStrings.somethingWentWrong;
      default:
        return AppStrings.somethingWentWrong;
    }
  }

  /// Get network error message
  static String _getNetworkErrorMessage(NetworkFailure failure) {
    switch (failure.code) {
      case 'NO_CONNECTION':
        return AppStrings.noInternetConnection;
      case 'TIMEOUT':
        return AppStrings.timeoutError;
      case 'SERVER_ERROR':
        return AppStrings.serverError;
      default:
        return failure.message.isNotEmpty ? failure.message : AppStrings.networkError;
    }
  }

  /// Get auth error message
  static String _getAuthErrorMessage(AuthFailure failure) {
    switch (failure.code) {
      case 'INVALID_CREDENTIALS':
        return AppStrings.invalidCredentials;
      case 'SESSION_EXPIRED':
        return AppStrings.sessionExpired;
      case 'ACCOUNT_LOCKED':
        return AppStrings.accountLocked;
      case 'EMAIL_IN_USE':
        return AppStrings.emailAlreadyExists;
      case 'WEAK_PASSWORD':
        return AppStrings.weakPassword;
      default:
        return failure.message.isNotEmpty ? failure.message : AppStrings.unauthorizedError;
    }
  }

  /// Get validation error message
  static String _getValidationErrorMessage(ValidationFailure failure) {
    if (failure.fieldErrors != null && failure.fieldErrors!.isNotEmpty) {
      final errors = <String>[];
      failure.fieldErrors!.forEach((field, messages) {
        errors.addAll(messages);
      });
      return errors.join('\n');
    }
    return failure.message.isNotEmpty ? failure.message : AppStrings.invalidInput;
  }

  /// Get storage error message
  static String _getStorageErrorMessage(StorageFailure failure) {
    switch (failure.code) {
      case 'INSUFFICIENT_SPACE':
        return 'Insufficient storage space available';
      case 'FILE_NOT_FOUND':
        return 'File not found';
      default:
        return failure.message.isNotEmpty ? failure.message : AppStrings.somethingWentWrong;
    }
  }

  /// Execute function with error handling
  static Future<T> guard<T>(Future<T> Function() function) async {
    try {
      return await function();
    } catch (error, stackTrace) {
      throw FailureException(handleException(error, stackTrace));
    }
  }

  /// Execute function with error handling and return Either
  static Future<T?> guardOrNull<T>(Future<T> Function() function) async {
    try {
      return await function();
    } catch (_) {
      return null;
    }
  }
}