import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../config/api_config.dart';
import '../api_endpoints.dart';

/// Interceptor that handles JWT authentication
/// Automatically adds tokens to requests and handles token refresh
class AuthInterceptor extends Interceptor {
  
  AuthInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Check if this is a public endpoint that doesn't require auth
    if (ApiEndpointGroups.publicEndpoints.contains(options.path)) {
      return handler.next(options);
    }

    try {
      // Get access token from secure storage directly
      final accessToken = await _getAccessToken();

      // Check if user is authenticated
      if (accessToken != null) {
        // Add authorization header
        options.headers['Authorization'] = 'Bearer $accessToken';
      } else {
        // User is not authenticated, reject the request
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 401,
              data: {'message': 'Authentication required'},
            ),
          ),
        );
      }
    } catch (e) {
      // Handle any errors during auth check
      return handler.reject(
        DioException(
          requestOptions: options,
          error: e,
        ),
      );
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;

    // Handle 401 errors (token might be invalid)
    if (statusCode == 401 && err.requestOptions.path != ApiEndpoints.login) {
      // Try to refresh token
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry the original request with new token
        try {
          final response = await Dio().fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (retryError) {
          return handler.next(retryError as DioException);
        }
      }
    }

    return handler.next(err);
  }

  /// Get access token from secure storage
  Future<String?> _getAccessToken() async {
    try {
      const secureStorage = FlutterSecureStorage();
      return await secureStorage.read(key: 'access_token');
    } catch (e) {
      return null;
    }
  }

  /// Get refresh token from secure storage  
  Future<String?> _getRefreshToken() async {
    try {
      const secureStorage = FlutterSecureStorage();
      return await secureStorage.read(key: 'refresh_token');
    } catch (e) {
      return null;
    }
  }

  /// Refresh the access token using refresh token
  Future<bool> _refreshToken() async {
    try {
      // Create a new Dio instance for refresh (without auth interceptor)
      final dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: ApiConfig.defaultHeaders,
      ));

      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      // Make refresh request
      final response = await dio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final newAccessToken = data['accessToken'] as String?;
          final newRefreshToken = data['refreshToken'] as String?;

          if (newAccessToken != null && newRefreshToken != null) {
            // Store new tokens in secure storage
            const secureStorage = FlutterSecureStorage();
            await secureStorage.write(key: 'access_token', value: newAccessToken);
            await secureStorage.write(key: 'refresh_token', value: newRefreshToken);

            return true;
          }
        }
      }
    } catch (e) {
      // Token refresh failed, clear stored tokens
      await _clearTokens();
    }

    return false;
  }

  /// Clear stored tokens
  Future<void> _clearTokens() async {
    try {
      const secureStorage = FlutterSecureStorage();
      await secureStorage.delete(key: 'access_token');
      await secureStorage.delete(key: 'refresh_token');
      await secureStorage.delete(key: 'user_id');
      await secureStorage.delete(key: 'user_email');
    } catch (e) {
      // Ignore clear errors
    }
  }
}

