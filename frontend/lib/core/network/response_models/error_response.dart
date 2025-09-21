import 'package:freezed_annotation/freezed_annotation.dart';

part 'error_response.freezed.dart';
part 'error_response.g.dart';

/// API error response structure
@freezed
class ErrorResponse with _$ErrorResponse {
  const factory ErrorResponse({
    required String message,
    required String code,
    @Default([]) List<String> errors,
    Map<String, List<String>>? fieldErrors,
    String? timestamp,
    String? path,
    int? status,
    String? traceId,
  }) = _ErrorResponse;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  /// Check if error has validation errors
  bool get hasValidationErrors => 
      fieldErrors != null && fieldErrors!.isNotEmpty;

  /// Get all error messages as a single list
  List<String> get allErrors {
    final List<String> allErrorsList = [...errors];
    
    if (fieldErrors != null) {
      for (final fieldErrorList in fieldErrors!.values) {
        allErrorsList.addAll(fieldErrorList);
      }
    }
    
    return allErrorsList;
  }

  /// Get formatted error message for display
  String get displayMessage {
    if (hasValidationErrors) {
      return fieldErrors!.entries
          .map((e) => '${e.key}: ${e.value.join(', ')}')
          .join('\n');
    }
    return message;
  }
}

/// Common error codes used across the API
class ApiErrorCodes {
  static const String unauthorized = 'UNAUTHORIZED';
  static const String forbidden = 'FORBIDDEN';
  static const String notFound = 'NOT_FOUND';
  static const String validationError = 'VALIDATION_ERROR';
  static const String serverError = 'SERVER_ERROR';
  static const String networkError = 'NETWORK_ERROR';
  static const String timeout = 'TIMEOUT';
  static const String conflict = 'CONFLICT';
  static const String rateLimited = 'RATE_LIMITED';
  static const String badRequest = 'BAD_REQUEST';
  static const String serviceUnavailable = 'SERVICE_UNAVAILABLE';
  static const String unknownError = 'UNKNOWN_ERROR';
}

/// Error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case ErrorSeverity.low:
        return 'Low';
      case ErrorSeverity.medium:
        return 'Medium';
      case ErrorSeverity.high:
        return 'High';
      case ErrorSeverity.critical:
        return 'Critical';
    }
  }
}
