import 'package:dio/dio.dart';

/// Base exception for all API-related errors
abstract class ApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const ApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => 'ApiException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Generic API exception for unspecified errors
class GenericApiException extends ApiException {
  const GenericApiException({
    required super.message,
    super.code,
    super.statusCode,
    super.details,
  });
}

/// Exception thrown when the API request is unauthorized
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Authentication required',
    String? code,
    int? statusCode,
    super.details,
  }) : super(
          code: code ?? 'UNAUTHORIZED',
          statusCode: statusCode ?? 401,
        );
}

/// Exception thrown when access to a resource is forbidden
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'Access denied',
    String? code,
    int? statusCode,
    super.details,
  }) : super(
          code: code ?? 'FORBIDDEN',
          statusCode: statusCode ?? 403,
        );
}

/// Exception thrown when a requested resource is not found
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Resource not found',
    String? code,
    int? statusCode,
    super.details,
  }) : super(
          code: code ?? 'NOT_FOUND',
          statusCode: statusCode ?? 404,
        );
}

/// Exception thrown when there are validation errors
class ValidationException extends ApiException {
  final Map<String, List<String>> fieldErrors;

  const ValidationException({
    required this.fieldErrors,
    super.message = 'Validation failed',
    String? code,
    int? statusCode,
    super.details,
  }) : super(
          code: code ?? 'VALIDATION_ERROR',
          statusCode: statusCode ?? 400,
        );

  @override
  String toString() {
    final errors = fieldErrors.entries
        .map((e) => '${e.key}: ${e.value.join(', ')}')
        .join('; ');
    return 'ValidationException: $message - $errors';
  }
}

/// Exception thrown when the server encounters an error
class ServerException extends ApiException {
  const ServerException({
    super.message = 'Internal server error',
    String? code,
    int? statusCode,
    super.details,
  }) : super(
          code: code ?? 'SERVER_ERROR',
          statusCode: statusCode ?? 500,
        );
}

/// Exception thrown when there's a network connectivity issue
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Network connection failed',
    String? code,
    int? statusCode,
    super.details,
  }) : super(
          code: code ?? 'NETWORK_ERROR',
          statusCode: statusCode ?? -1,
        );
}

/// Exception thrown when a request times out
class TimeoutException extends ApiException {
  const TimeoutException({
    super.message = 'Request timed out',
    String? code,
    int? statusCode,
    super.details,
  }) : super(
          code: code ?? 'TIMEOUT',
          statusCode: statusCode ?? 408,
        );
}

/// Exception thrown when there's a conflict with the current state
class ConflictException extends ApiException {
  const ConflictException({
    super.message = 'Resource conflict',
    String? code,
    int? statusCode,
    super.details,
  }) : super(
          code: code ?? 'CONFLICT',
          statusCode: statusCode ?? 409,
        );
}

/// Exception thrown when rate limits are exceeded
class RateLimitException extends ApiException {
  const RateLimitException({
    super.message = 'Rate limit exceeded',
    String? code,
    int? statusCode,
    super.details,
  }) : super(
          code: code ?? 'RATE_LIMITED',
          statusCode: statusCode ?? 429,
        );
}

/// Factory to create exceptions from Dio errors
class ApiExceptionFactory {
  static ApiException fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Request timed out. Please check your connection.',
          details: {'originalError': error.toString()},
        );

      case DioExceptionType.badResponse:
        final response = error.response;
        if (response == null) {
          return NetworkException(
            message: 'No response received from server',
            details: {'originalError': error.toString()},
          );
        }

        final statusCode = response.statusCode ?? -1;
        final data = response.data;

        switch (statusCode) {
          case 400:
            if (data is Map<String, dynamic> && data.containsKey('errors')) {
              final fieldErrors = <String, List<String>>{};
              final errors = data['errors'] as Map<String, dynamic>;
              errors.forEach((field, messages) {
                if (messages is List) {
                  fieldErrors[field] = messages.map((e) => e.toString()).toList();
                }
              });
              return ValidationException(
                fieldErrors: fieldErrors,
                details: data,
              );
            }
            return GenericApiException(
              message: 'Bad request',
              statusCode: statusCode,
              details: data,
            );

          case 401:
            return UnauthorizedException(
              details: data,
            );

          case 403:
            return ForbiddenException(
              details: data,
            );

          case 404:
            return NotFoundException(
              details: data,
            );

          case 409:
            return ConflictException(
              details: data,
            );

          case 429:
            return RateLimitException(
              message: 'Too many requests',
              details: data,
            );

          case 500:
          case 502:
          case 503:
          case 504:
            return ServerException(
              message: 'Server error occurred',
              details: data,
            );

          default:
            return GenericApiException(
              message: 'HTTP error occurred',
              statusCode: statusCode,
              details: data,
            );
        }

      case DioExceptionType.cancel:
        return GenericApiException(
          message: 'Request was cancelled',
          code: 'CANCELLED',
          details: {'originalError': error.toString()},
        );

      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
      default:
        return NetworkException(
          message: 'Network error occurred. Please check your connection.',
          details: {'originalError': error.toString()},
        );
    }
  }

  /// Create exception from response data
  static ApiException fromResponseData(
    int statusCode,
    Map<String, dynamic>? data,
  ) {
    switch (statusCode) {
      case 400:
        if (data != null && data.containsKey('errors')) {
          final fieldErrors = <String, List<String>>{};
          final errors = data['errors'] as Map<String, dynamic>;
          errors.forEach((field, messages) {
            if (messages is List) {
              fieldErrors[field] = messages.map((e) => e.toString()).toList();
            }
          });
          return ValidationException(
            fieldErrors: fieldErrors,
            details: data,
          );
        }
        return GenericApiException(
          message: 'Bad request',
          statusCode: statusCode,
          details: data,
        );

      case 401:
        return UnauthorizedException(details: data);

      case 403:
        return ForbiddenException(details: data);

      case 404:
        return NotFoundException(details: data);

      case 409:
        return ConflictException(details: data);

      case 429:
        return RateLimitException(details: data);

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(details: data);

      default:
        return GenericApiException(
          message: 'API error occurred',
          statusCode: statusCode,
          details: data,
        );
    }
  }
}

/// Extension to get user-friendly error messages
extension ApiExceptionMessages on ApiException {
  String get userFriendlyMessage {
    switch (runtimeType) {
      case UnauthorizedException:
        return 'Please log in to continue';
      case ForbiddenException:
        return "You don't have permission to access this resource";
      case NotFoundException:
        return 'The requested resource was not found';
      case ValidationException:
        return 'Please check your input and try again';
      case ServerException:
        return 'Server error occurred. Please try again later';
      case NetworkException:
        return 'Connection failed. Please check your internet connection';
      case TimeoutException:
        return 'Request timed out. Please try again';
      case ConflictException:
        return 'This action conflicts with the current state';
      case RateLimitException:
        return 'Too many requests. Please wait a moment before trying again';
      default:
        return message;
    }
  }

  /// Get detailed error message for debugging
  String get debugMessage {
    final buffer = StringBuffer()
      ..writeln('Error: $message')
      ..writeln('Status Code: $statusCode')
      ..writeln('Error Code: $code');

    if (details != null) {
      buffer.writeln('Details: $details');
    }

    if (this is ValidationException) {
      final validationException = this as ValidationException;
      buffer.writeln('Field Errors: ${validationException.fieldErrors}');
    }

    return buffer.toString();
  }
}
