/// Base exception class for all custom exceptions
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic data;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.data,
    this.stackTrace,
  });

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Network-related exceptions
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException({
    required super.message,
    super.code,
    this.statusCode,
    super.data,
    super.stackTrace,
  });

  factory NetworkException.noConnection() => const NetworkException(
    message: 'No internet connection',
    code: 'NO_CONNECTION',
  );

  factory NetworkException.timeout() => const NetworkException(
    message: 'Request timeout',
    code: 'TIMEOUT',
  );

  factory NetworkException.serverError(int statusCode, [String? message]) => NetworkException(
    message: message ?? 'Server error',
    code: 'SERVER_ERROR',
    statusCode: statusCode,
  );

  factory NetworkException.badRequest([String? message]) => NetworkException(
    message: message ?? 'Bad request',
    code: 'BAD_REQUEST',
    statusCode: 400,
  );

  factory NetworkException.unauthorized([String? message]) => NetworkException(
    message: message ?? 'Unauthorized',
    code: 'UNAUTHORIZED',
    statusCode: 401,
  );

  factory NetworkException.forbidden([String? message]) => NetworkException(
    message: message ?? 'Forbidden',
    code: 'FORBIDDEN',
    statusCode: 403,
  );

  factory NetworkException.notFound([String? message]) => NetworkException(
    message: message ?? 'Resource not found',
    code: 'NOT_FOUND',
    statusCode: 404,
  );

  factory NetworkException.conflict([String? message]) => NetworkException(
    message: message ?? 'Conflict',
    code: 'CONFLICT',
    statusCode: 409,
  );

  factory NetworkException.tooManyRequests([String? message]) => NetworkException(
    message: message ?? 'Too many requests',
    code: 'TOO_MANY_REQUESTS',
    statusCode: 429,
  );
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.data,
    super.stackTrace,
  });

  factory CacheException.notFound(String key) => CacheException(
    message: 'Cache entry not found for key: $key',
    code: 'NOT_FOUND',
    data: key,
  );

  factory CacheException.expired(String key) => CacheException(
    message: 'Cache entry expired for key: $key',
    code: 'EXPIRED',
    data: key,
  );

  factory CacheException.corrupted(String key) => CacheException(
    message: 'Cache entry corrupted for key: $key',
    code: 'CORRUPTED',
    data: key,
  );

  factory CacheException.writeError(String key, [error]) => CacheException(
    message: 'Failed to write cache for key: $key',
    code: 'WRITE_ERROR',
    data: {'key': key, 'error': error},
  );

  factory CacheException.readError(String key, [error]) => CacheException(
    message: 'Failed to read cache for key: $key',
    code: 'READ_ERROR',
    data: {'key': key, 'error': error},
  );
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    this.fieldErrors,
    super.data,
    super.stackTrace,
  });

  factory ValidationException.field(String field, String error) => ValidationException(
    message: error,
    code: 'FIELD_ERROR',
    fieldErrors: {field: [error]},
  );

  factory ValidationException.multiple(Map<String, List<String>> errors) => ValidationException(
    message: 'Validation failed',
    code: 'MULTIPLE_ERRORS',
    fieldErrors: errors,
  );
}

/// Parse exceptions
class ParseException extends AppException {
  const ParseException({
    required super.message,
    super.code,
    super.data,
    super.stackTrace,
  });

  factory ParseException.invalidJson(source, [error]) => ParseException(
    message: 'Invalid JSON format',
    code: 'INVALID_JSON',
    data: {'source': source, 'error': error},
  );

  factory ParseException.invalidFormat(String expectedFormat, source) => ParseException(
    message: 'Invalid format. Expected: $expectedFormat',
    code: 'INVALID_FORMAT',
    data: {'expected': expectedFormat, 'source': source},
  );

  factory ParseException.typeMismatch(Type expected, Type actual, value) => ParseException(
    message: 'Type mismatch. Expected $expected, got $actual',
    code: 'TYPE_MISMATCH',
    data: {'expected': expected, 'actual': actual, 'value': value},
  );

  factory ParseException.missingField(String field) => ParseException(
    message: 'Required field missing: $field',
    code: 'MISSING_FIELD',
    data: field,
  );
}

/// Storage exceptions
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.data,
    super.stackTrace,
  });

  factory StorageException.insufficientSpace() => const StorageException(
    message: 'Insufficient storage space',
    code: 'INSUFFICIENT_SPACE',
  );

  factory StorageException.fileNotFound(String path) => StorageException(
    message: 'File not found: $path',
    code: 'FILE_NOT_FOUND',
    data: path,
  );

  factory StorageException.readError(String path, [error]) => StorageException(
    message: 'Failed to read file: $path',
    code: 'READ_ERROR',
    data: {'path': path, 'error': error},
  );

  factory StorageException.writeError(String path, [error]) => StorageException(
    message: 'Failed to write file: $path',
    code: 'WRITE_ERROR',
    data: {'path': path, 'error': error},
  );

  factory StorageException.deleteError(String path, [error]) => StorageException(
    message: 'Failed to delete file: $path',
    code: 'DELETE_ERROR',
    data: {'path': path, 'error': error},
  );

  factory StorageException.permissionDenied() => const StorageException(
    message: 'Storage permission denied',
    code: 'PERMISSION_DENIED',
  );
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.data,
    super.stackTrace,
  });

  factory AuthException.invalidCredentials() => const AuthException(
    message: 'Invalid credentials',
    code: 'INVALID_CREDENTIALS',
  );

  factory AuthException.userNotFound() => const AuthException(
    message: 'User not found',
    code: 'USER_NOT_FOUND',
  );

  factory AuthException.emailAlreadyInUse() => const AuthException(
    message: 'Email already in use',
    code: 'EMAIL_IN_USE',
  );

  factory AuthException.weakPassword() => const AuthException(
    message: 'Password is too weak',
    code: 'WEAK_PASSWORD',
  );

  factory AuthException.sessionExpired() => const AuthException(
    message: 'Session expired',
    code: 'SESSION_EXPIRED',
  );

  factory AuthException.accountLocked() => const AuthException(
    message: 'Account is locked',
    code: 'ACCOUNT_LOCKED',
  );

  factory AuthException.emailNotVerified() => const AuthException(
    message: 'Email not verified',
    code: 'EMAIL_NOT_VERIFIED',
  );

  factory AuthException.invalidToken() => const AuthException(
    message: 'Invalid token',
    code: 'INVALID_TOKEN',
  );

  factory AuthException.tokenExpired() => const AuthException(
    message: 'Token expired',
    code: 'TOKEN_EXPIRED',
  );
}

/// Permission exceptions
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.data,
    super.stackTrace,
  });

  factory PermissionException.denied(String permission) => PermissionException(
    message: 'Permission denied: $permission',
    code: 'DENIED',
    data: permission,
  );

  factory PermissionException.permanentlyDenied(String permission) => PermissionException(
    message: 'Permission permanently denied: $permission',
    code: 'PERMANENTLY_DENIED',
    data: permission,
  );

  factory PermissionException.restricted(String permission) => PermissionException(
    message: 'Permission restricted: $permission',
    code: 'RESTRICTED',
    data: permission,
  );
}

/// Configuration exceptions
class ConfigurationException extends AppException {
  const ConfigurationException({
    required super.message,
    super.code,
    super.data,
    super.stackTrace,
  });

  factory ConfigurationException.missingConfig(String key) => ConfigurationException(
    message: 'Missing configuration: $key',
    code: 'MISSING_CONFIG',
    data: key,
  );

  factory ConfigurationException.invalidConfig(String key, value) => ConfigurationException(
    message: 'Invalid configuration for $key',
    code: 'INVALID_CONFIG',
    data: {'key': key, 'value': value},
  );

  factory ConfigurationException.environmentNotFound(String env) => ConfigurationException(
    message: 'Environment not found: $env',
    code: 'ENV_NOT_FOUND',
    data: env,
  );
}