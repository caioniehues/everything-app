import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

/// Mock API client for testing
/// Provides controlled responses and error simulation
@GenerateMocks([ApiClient])
class MockApiClient extends Mock implements ApiClient {}

/// Mock Dio instance for testing
@GenerateMocks([Dio])
class MockDio extends Mock implements Dio {}

/// Mock Response for testing
@GenerateMocks([Response])
class MockResponse extends Mock implements Response {}

/// Mock RequestOptions for testing
@GenerateMocks([RequestOptions])
class MockRequestOptions extends Mock implements RequestOptions {}

/// Mock DioException for testing
@GenerateMocks([DioException])
class MockDioException extends Mock implements DioException {}

/// Test data factory for creating mock responses
class TestDataFactory {
  /// Create a successful API response
  static Response<T> createSuccessResponse<T>({
    required T data,
    int statusCode = 200,
    String? message,
    Map<String, dynamic>? headers,
  }) {
    final responseData = {
      'success': true,
      'message': message ?? 'Success',
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return Response<T>(
      data: responseData as T?,
      statusCode: statusCode,
      headers: Headers.fromMap(headers?.map((k, v) => MapEntry(k, [v.toString()])) ?? {}),
      requestOptions: RequestOptions(path: '/test'),
    );
  }

  /// Create an error API response
  static Response<T> createErrorResponse<T>({
    required String message,
    int statusCode = 400,
    String? code,
    List<String>? errors,
    Map<String, List<String>>? fieldErrors,
  }) {
    final responseData = {
      'success': false,
      'message': message,
      'code': code ?? 'ERROR',
      'errors': errors ?? [],
      'fieldErrors': fieldErrors,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return Response<T>(
      data: responseData as T?,
      statusCode: statusCode,
      requestOptions: RequestOptions(path: '/test'),
    );
  }

  /// Create a DioException for testing
  static DioException createDioException({
    required DioExceptionType type,
    String? message,
    int? statusCode,
    Map<String, dynamic>? responseData,
  }) {
    final requestOptions = RequestOptions(path: '/test');
    
    Response? response;
    if (statusCode != null) {
      response = Response(
        data: responseData,
        statusCode: statusCode,
        requestOptions: requestOptions,
      );
    }

    return DioException(
      requestOptions: requestOptions,
      response: response,
      type: type,
      error: message ?? 'Test error',
    );
  }

  /// Create a network timeout exception
  static DioException createTimeoutException() {
    return createDioException(
      type: DioExceptionType.connectionTimeout,
      message: 'Connection timeout',
    );
  }

  /// Create a network error exception
  static DioException createNetworkException() {
    return createDioException(
      type: DioExceptionType.connectionError,
      message: 'Network error',
    );
  }

  /// Create a 401 Unauthorized exception
  static DioException createUnauthorizedException() {
    return createDioException(
      type: DioExceptionType.badResponse,
      statusCode: 401,
      message: 'Unauthorized',
      responseData: {
        'message': 'Authentication required',
        'code': 'UNAUTHORIZED',
      },
    );
  }

  /// Create a 403 Forbidden exception
  static DioException createForbiddenException() {
    return createDioException(
      type: DioExceptionType.badResponse,
      statusCode: 403,
      message: 'Forbidden',
      responseData: {
        'message': 'Access denied',
        'code': 'FORBIDDEN',
      },
    );
  }

  /// Create a 404 Not Found exception
  static DioException createNotFoundException() {
    return createDioException(
      type: DioExceptionType.badResponse,
      statusCode: 404,
      message: 'Not found',
      responseData: {
        'message': 'Resource not found',
        'code': 'NOT_FOUND',
      },
    );
  }

  /// Create a 500 Server Error exception
  static DioException createServerException() {
    return createDioException(
      type: DioExceptionType.badResponse,
      statusCode: 500,
      message: 'Server error',
      responseData: {
        'message': 'Internal server error',
        'code': 'SERVER_ERROR',
      },
    );
  }

  /// Create a validation error exception
  static DioException createValidationException() {
    return createDioException(
      type: DioExceptionType.badResponse,
      statusCode: 400,
      message: 'Validation failed',
      responseData: {
        'message': 'Validation failed',
        'code': 'VALIDATION_ERROR',
        'fieldErrors': {
          'email': ['Email is required', 'Email format is invalid'],
          'password': ['Password must be at least 8 characters'],
        },
      },
    );
  }

  /// Create a rate limit exception
  static DioException createRateLimitException() {
    return createDioException(
      type: DioExceptionType.badResponse,
      statusCode: 429,
      message: 'Rate limit exceeded',
      responseData: {
        'message': 'Too many requests',
        'code': 'RATE_LIMITED',
      },
    );
  }

  /// Create sample user data
  static Map<String, dynamic> createUserData() {
    return {
      'id': '123e4567-e89b-12d3-a456-426614174000',
      'email': 'test@example.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'isEmailVerified': true,
      'createdAt': '2025-01-20T10:30:00Z',
      'updatedAt': '2025-01-20T10:30:00Z',
    };
  }

  /// Create sample account data
  static Map<String, dynamic> createAccountData() {
    return {
      'id': '123e4567-e89b-12d3-a456-426614174001',
      'name': 'Checking Account',
      'type': 'CHECKING',
      'balance': 1500.00,
      'currency': 'USD',
      'isActive': true,
      'createdAt': '2025-01-20T10:30:00Z',
      'updatedAt': '2025-01-20T10:30:00Z',
    };
  }

  /// Create sample transaction data
  static Map<String, dynamic> createTransactionData() {
    return {
      'id': '123e4567-e89b-12d3-a456-426614174002',
      'accountId': '123e4567-e89b-12d3-a456-426614174001',
      'amount': -25.50,
      'description': 'Coffee shop purchase',
      'category': 'FOOD',
      'date': '2025-01-20T14:30:00Z',
      'type': 'EXPENSE',
      'createdAt': '2025-01-20T14:30:00Z',
      'updatedAt': '2025-01-20T14:30:00Z',
    };
  }

  /// Create sample auth response
  static Map<String, dynamic> createAuthResponse() {
    return {
      'accessToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
      'refreshToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
      'expiresIn': 900, // 15 minutes
      'tokenType': 'Bearer',
      'user': createUserData(),
    };
  }

  /// Create sample paginated response
  static Map<String, dynamic> createPaginatedResponse<T>(List<T> data) {
    return {
      'success': true,
      'message': 'Success',
      'data': data,
      'pagination': {
        'page': 0,
        'size': 20,
        'totalElements': data.length,
        'totalPages': 1,
        'hasNext': false,
        'hasPrevious': false,
        'isFirst': true,
        'isLast': true,
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Mock server configuration for integration tests
class MockServerConfig {
  static const String baseUrl = 'http://localhost:3000';
  static const Duration responseDelay = Duration(milliseconds: 100);
  
  /// Mock endpoints for testing
  static const Map<String, String> endpoints = {
    'login': '/api/v1/auth/login',
    'register': '/api/v1/auth/register',
    'refresh': '/api/v1/auth/refresh',
    'profile': '/api/v1/users/profile',
    'accounts': '/api/v1/accounts',
    'transactions': '/api/v1/transactions',
  };
}

/// Helper class for setting up mock behaviors
class MockSetupHelper {
  /// Setup successful GET request mock
  static void setupSuccessfulGet<T>(
    MockApiClient mockClient,
    String path,
    T data, {
    int statusCode = 200,
  }) {
    when(mockClient.get<T>(path)).thenAnswer(
      (_) async => TestDataFactory.createSuccessResponse<T>(
        data: data,
        statusCode: statusCode,
      ),
    );
  }

  /// Setup successful POST request mock
  static void setupSuccessfulPost<T>(
    MockApiClient mockClient,
    String path,
    T data, {
    int statusCode = 201,
  }) {
    when(mockClient.post<T>(path)).thenAnswer(
      (_) async => TestDataFactory.createSuccessResponse<T>(
        data: data,
        statusCode: statusCode,
      ),
    );
  }

  /// Setup error response mock
  static void setupErrorResponse<T>(
    MockApiClient mockClient,
    String path,
    DioException exception,
  ) {
    when(mockClient.get<T>(path)).thenThrow(exception);
    when(mockClient.post<T>(path)).thenThrow(exception);
    when(mockClient.put<T>(path)).thenThrow(exception);
    when(mockClient.delete<T>(path)).thenThrow(exception);
  }

  /// Setup timeout mock
  static void setupTimeout<T>(
    MockApiClient mockClient,
    String path,
  ) {
    final timeoutException = TestDataFactory.createTimeoutException();
    setupErrorResponse<T>(mockClient, path, timeoutException);
  }

  /// Setup network error mock
  static void setupNetworkError<T>(
    MockApiClient mockClient,
    String path,
  ) {
    final networkException = TestDataFactory.createNetworkException();
    setupErrorResponse<T>(mockClient, path, networkException);
  }
}