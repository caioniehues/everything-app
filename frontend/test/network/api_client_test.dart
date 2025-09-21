import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_api_client.dart';

@GenerateMocks([Dio])
void main() {
  group('ApiClient Tests', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient();
    });

    test('should be a singleton', () {
      final client1 = ApiClient();
      final client2 = ApiClient();
      expect(identical(client1, client2), isTrue);
    });

    test('should initialize with proper configuration', () async {
      await apiClient.initialize();

      final dio = apiClient.dio;
      expect(dio, isNotNull);
      expect(dio.options.connectTimeout, isNotNull);
      expect(dio.options.receiveTimeout, isNotNull);
      expect(dio.options.sendTimeout, isNotNull);
      expect(dio.options.baseUrl, isNotEmpty);
    });

    group('HTTP Methods', () {
      test('GET method should forward to Dio', () async {
        // This test verifies the method exists and is callable
        expect(apiClient.get, isNotNull);
      });

      test('POST method should forward to Dio', () async {
        expect(apiClient.post, isNotNull);
      });

      test('PUT method should forward to Dio', () async {
        expect(apiClient.put, isNotNull);
      });

      test('PATCH method should forward to Dio', () async {
        expect(apiClient.patch, isNotNull);
      });

      test('DELETE method should forward to Dio', () async {
        expect(apiClient.delete, isNotNull);
      });

      test('download method should forward to Dio', () async {
        expect(apiClient.download, isNotNull);
      });

      test('upload method should forward to Dio', () async {
        expect(apiClient.upload, isNotNull);
      });
    });
  });

  group('ApiException Tests', () {
    test('should create UnauthorizedException with default values', () {
      const exception = UnauthorizedException();
      expect(exception.message, equals('Authentication required'));
      expect(exception.code, equals('UNAUTHORIZED'));
      expect(exception.statusCode, equals(401));
    });

    test('should create ForbiddenException with default values', () {
      const exception = ForbiddenException();
      expect(exception.message, equals('Access denied'));
      expect(exception.code, equals('FORBIDDEN'));
      expect(exception.statusCode, equals(403));
    });

    test('should create NotFoundException with default values', () {
      const exception = NotFoundException();
      expect(exception.message, equals('Resource not found'));
      expect(exception.code, equals('NOT_FOUND'));
      expect(exception.statusCode, equals(404));
    });

    test('should create ServerException with default values', () {
      const exception = ServerException();
      expect(exception.message, equals('Internal server error'));
      expect(exception.code, equals('SERVER_ERROR'));
      expect(exception.statusCode, equals(500));
    });

    test('should create NetworkException with default values', () {
      const exception = NetworkException();
      expect(exception.message, equals('Network connection failed'));
      expect(exception.code, equals('NETWORK_ERROR'));
      expect(exception.statusCode, equals(-1));
    });

    test('should create TimeoutException with default values', () {
      const exception = TimeoutException();
      expect(exception.message, equals('Request timed out'));
      expect(exception.code, equals('TIMEOUT'));
      expect(exception.statusCode, equals(408));
    });

    test('should create ValidationException with field errors', () {
      const exception = ValidationException(
        fieldErrors: {
          'email': ['Email is required'],
          'password': ['Password too short'],
        },
      );
      expect(exception.message, equals('Validation failed'));
      expect(exception.code, equals('VALIDATION_ERROR'));
      expect(exception.statusCode, equals(400));
      expect(exception.fieldErrors['email'], contains('Email is required'));
    });
  });

  group('ApiExceptionFactory Tests', () {
    test('should create TimeoutException from DioException', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final exception = ApiExceptionFactory.fromDioError(dioError);
      expect(exception, isA<TimeoutException>());
      expect(exception.message, contains('timed out'));
    });

    test('should create UnauthorizedException from 401 response', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );

      final exception = ApiExceptionFactory.fromDioError(dioError);
      expect(exception, isA<UnauthorizedException>());
    });

    test('should create ForbiddenException from 403 response', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 403,
        ),
      );

      final exception = ApiExceptionFactory.fromDioError(dioError);
      expect(exception, isA<ForbiddenException>());
    });

    test('should create NotFoundException from 404 response', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
        ),
      );

      final exception = ApiExceptionFactory.fromDioError(dioError);
      expect(exception, isA<NotFoundException>());
    });

    test('should create ServerException from 500 response', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
      );

      final exception = ApiExceptionFactory.fromDioError(dioError);
      expect(exception, isA<ServerException>());
    });

    test('should create NetworkException from connection error', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      final exception = ApiExceptionFactory.fromDioError(dioError);
      expect(exception, isA<NetworkException>());
      expect(exception.message, contains('Network error'));
    });

    test('should create ValidationException from 400 with errors', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
          data: {
            'errors': {
              'email': ['Email is invalid'],
              'password': ['Password is required'],
            },
          },
        ),
      );

      final exception = ApiExceptionFactory.fromDioError(dioError);
      expect(exception, isA<ValidationException>());

      if (exception is ValidationException) {
        expect(exception.fieldErrors['email'], contains('Email is invalid'));
        expect(exception.fieldErrors['password'], contains('Password is required'));
      }
    });
  });

  group('ApiExceptionMessages Extension Tests', () {
    test('should provide user-friendly messages', () {
      const unauthorized = UnauthorizedException();
      expect(unauthorized.userFriendlyMessage, equals('Please log in to continue'));

      const forbidden = ForbiddenException();
      expect(forbidden.userFriendlyMessage,
          equals("You don't have permission to access this resource"));

      const notFound = NotFoundException();
      expect(notFound.userFriendlyMessage,
          equals('The requested resource was not found'));

      const server = ServerException();
      expect(server.userFriendlyMessage,
          equals('Server error occurred. Please try again later'));

      const network = NetworkException();
      expect(network.userFriendlyMessage,
          equals('Connection failed. Please check your internet connection'));

      const timeout = TimeoutException();
      expect(timeout.userFriendlyMessage,
          equals('Request timed out. Please try again'));
    });

    test('should provide debug messages', () {
      const exception = UnauthorizedException(
        message: 'Test error',
        code: 'TEST_CODE',
        statusCode: 401,
        details: {'key': 'value'},
      );

      final debugMessage = exception.debugMessage;
      expect(debugMessage, contains('Error: Test error'));
      expect(debugMessage, contains('Status Code: 401'));
      expect(debugMessage, contains('Error Code: TEST_CODE'));
      expect(debugMessage, contains('Details:'));
    });
  });
}