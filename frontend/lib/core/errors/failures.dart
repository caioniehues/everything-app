import 'package:equatable/equatable.dart';

/// Exception that wraps a Failure for proper throwing
class FailureException implements Exception {
  final Failure failure;

  const FailureException(this.failure);

  @override
  String toString() => 'FailureException: ${failure.message}';
}

/// Abstract class representing a failure in the application
/// Used for expected errors that should be handled gracefully
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic data;

  const Failure({
    required this.message,
    this.code,
    this.data,
  });

  @override
  List<Object?> get props => [message, code, data];

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.data,
  });

  factory NetworkFailure.noConnection() => const NetworkFailure(
    message: 'No internet connection available',
    code: 'NO_CONNECTION',
  );

  factory NetworkFailure.timeout() => const NetworkFailure(
    message: 'Request timeout. Please try again',
    code: 'TIMEOUT',
  );

  factory NetworkFailure.serverError([String? details]) => NetworkFailure(
    message: details ?? 'Server error occurred',
    code: 'SERVER_ERROR',
  );

  factory NetworkFailure.badRequest([String? details]) => NetworkFailure(
    message: details ?? 'Bad request',
    code: 'BAD_REQUEST',
  );
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.data,
  });

  factory CacheFailure.notFound() => const CacheFailure(
    message: 'Data not found in cache',
    code: 'NOT_FOUND',
  );

  factory CacheFailure.expired() => const CacheFailure(
    message: 'Cached data has expired',
    code: 'EXPIRED',
  );

  factory CacheFailure.corrupted() => const CacheFailure(
    message: 'Cached data is corrupted',
    code: 'CORRUPTED',
  );
}

/// Validation failures
class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors,
    super.data,
  });

  factory ValidationFailure.invalidInput(String field, String error) => ValidationFailure(
    message: error,
    code: 'INVALID_INPUT',
    fieldErrors: {field: [error]},
  );

  factory ValidationFailure.multipleErrors(Map<String, List<String>> errors) => ValidationFailure(
    message: 'Validation failed',
    code: 'VALIDATION_ERROR',
    fieldErrors: errors,
  );

  @override
  List<Object?> get props => [message, code, fieldErrors, data];
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.data,
  });

  factory AuthFailure.invalidCredentials() => const AuthFailure(
    message: 'Invalid email or password',
    code: 'INVALID_CREDENTIALS',
  );

  factory AuthFailure.unauthorized() => const AuthFailure(
    message: 'Unauthorized access',
    code: 'UNAUTHORIZED',
  );

  factory AuthFailure.sessionExpired() => const AuthFailure(
    message: 'Your session has expired. Please login again',
    code: 'SESSION_EXPIRED',
  );

  factory AuthFailure.accountLocked() => const AuthFailure(
    message: 'Account locked due to multiple failed attempts',
    code: 'ACCOUNT_LOCKED',
  );

  factory AuthFailure.emailNotVerified() => const AuthFailure(
    message: 'Please verify your email before logging in',
    code: 'EMAIL_NOT_VERIFIED',
  );

  factory AuthFailure.userNotFound() => const AuthFailure(
    message: 'User not found',
    code: 'USER_NOT_FOUND',
  );

  factory AuthFailure.emailAlreadyInUse() => const AuthFailure(
    message: 'Email address is already in use',
    code: 'EMAIL_IN_USE',
  );

  factory AuthFailure.weakPassword() => const AuthFailure(
    message: 'Password is too weak',
    code: 'WEAK_PASSWORD',
  );
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
    super.data,
  });

  factory PermissionFailure.denied(String permission) => PermissionFailure(
    message: '$permission permission is required',
    code: 'PERMISSION_DENIED',
    data: permission,
  );

  factory PermissionFailure.permanentlyDenied(String permission) => PermissionFailure(
    message: '$permission permission is permanently denied. Please enable it in settings',
    code: 'PERMISSION_PERMANENTLY_DENIED',
    data: permission,
  );
}

/// Storage failures
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
    super.data,
  });

  factory StorageFailure.insufficientSpace() => const StorageFailure(
    message: 'Insufficient storage space',
    code: 'INSUFFICIENT_SPACE',
  );

  factory StorageFailure.fileNotFound() => const StorageFailure(
    message: 'File not found',
    code: 'FILE_NOT_FOUND',
  );

  factory StorageFailure.writeError() => const StorageFailure(
    message: 'Failed to write data',
    code: 'WRITE_ERROR',
  );

  factory StorageFailure.readError() => const StorageFailure(
    message: 'Failed to read data',
    code: 'READ_ERROR',
  );
}

/// Business logic failures
class BusinessFailure extends Failure {
  const BusinessFailure({
    required super.message,
    super.code,
    super.data,
  });

  factory BusinessFailure.insufficientFunds() => const BusinessFailure(
    message: 'Insufficient funds for this transaction',
    code: 'INSUFFICIENT_FUNDS',
  );

  factory BusinessFailure.limitExceeded(String limitType) => BusinessFailure(
    message: '$limitType limit exceeded',
    code: 'LIMIT_EXCEEDED',
    data: limitType,
  );

  factory BusinessFailure.duplicateEntry() => const BusinessFailure(
    message: 'This entry already exists',
    code: 'DUPLICATE_ENTRY',
  );

  factory BusinessFailure.invalidOperation() => const BusinessFailure(
    message: 'This operation is not allowed',
    code: 'INVALID_OPERATION',
  );

  factory BusinessFailure.resourceNotFound(String resource) => BusinessFailure(
    message: '$resource not found',
    code: 'RESOURCE_NOT_FOUND',
    data: resource,
  );

  factory BusinessFailure.invalidState() => const BusinessFailure(
    message: 'Invalid state for this operation',
    code: 'INVALID_STATE',
  );
}

/// Parse failures
class ParseFailure extends Failure {
  const ParseFailure({
    required super.message,
    super.code,
    super.data,
  });

  factory ParseFailure.invalidFormat(String expectedFormat) => ParseFailure(
    message: 'Invalid format. Expected: $expectedFormat',
    code: 'INVALID_FORMAT',
    data: expectedFormat,
  );

  factory ParseFailure.invalidJson() => const ParseFailure(
    message: 'Invalid JSON format',
    code: 'INVALID_JSON',
  );

  factory ParseFailure.typeMismatch(String expected, String actual) => ParseFailure(
    message: 'Type mismatch. Expected $expected, got $actual',
    code: 'TYPE_MISMATCH',
    data: {'expected': expected, 'actual': actual},
  );
}

/// Unknown or unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred',
    super.code = 'UNKNOWN',
    super.data,
  });

  factory UnknownFailure.fromError(error) => UnknownFailure(
    message: error.toString(),
    data: error,
  );
}