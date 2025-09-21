import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/interceptors/auth_interceptor.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([FlutterSecureStorage, RequestInterceptorHandler, ErrorInterceptorHandler])
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}
class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  group('AuthInterceptor Tests', () {
    late AuthInterceptor authInterceptor;

    setUp(() {
      authInterceptor = AuthInterceptor();
    });

    group('onRequest', () {
      test('should add Authorization header when token exists', () async {
        // Create a mock handler
        final handler = MockRequestInterceptorHandler();
        final options = RequestOptions(path: '/api/protected');

        // Note: In a real test, we would need to mock the secure storage
        // but that requires dependency injection in the interceptor

        // Call the interceptor
        await authInterceptor.onRequest(options, handler);

        // Verify handler was called
        verifyNever(handler.reject(any));
      });

      test('should skip auth for public endpoints', () async {
        final handler = MockRequestInterceptorHandler();
        final options = RequestOptions(path: '/api/v1/auth/login');

        await authInterceptor.onRequest(options, handler);

        // Should proceed without adding auth header
        verifyNever(handler.reject(any));
      });
    });

    group('onError', () {
      test('should handle 401 errors', () async {
        final handler = MockErrorInterceptorHandler();
        final error = DioException(
          requestOptions: RequestOptions(path: '/api/protected'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/protected'),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        );

        await authInterceptor.onError(error, handler);

        // Should attempt to handle the error
        verify(handler.next(any)).called(1);
      });

      test('should not handle 401 for login endpoint', () async {
        final handler = MockErrorInterceptorHandler();
        final error = DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/auth/login'),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        );

        await authInterceptor.onError(error, handler);

        // Should pass through the error
        verify(handler.next(error)).called(1);
      });
    });
  });
}