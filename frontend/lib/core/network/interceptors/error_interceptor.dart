import 'package:dio/dio.dart';

import '../api_exceptions.dart';

/// Interceptor that handles common HTTP errors
/// Converts Dio errors to custom API exceptions
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Convert DioException to ApiException
    final apiException = ApiExceptionFactory.fromDioError(err);

    // Create new DioException with our custom exception
    final enhancedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: apiException,
    );

    return handler.next(enhancedError);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check for error status codes in successful responses
    final statusCode = response.statusCode ?? 200;

    if (statusCode >= 400) {
      // Create API exception from response data
      final apiException = ApiExceptionFactory.fromResponseData(
        statusCode,
        response.data is Map<String, dynamic> ? response.data : null,
      );

      // Create new DioException for error responses
      final error = DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: apiException,
      );

      return handler.reject(error);
    }

    return handler.next(response);
  }
}
