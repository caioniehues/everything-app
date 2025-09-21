/// API endpoints for the Everything App backend
/// All endpoints are versioned and follow REST conventions
class ApiEndpoints {
  ApiEndpoints._();

  // Base paths
  static const String base = '/api';
  static const String version = '/v1';

  // Authentication endpoints
  static const String auth = '$base$version/auth';
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String logout = '$auth/logout';
  static const String refresh = '$auth/refresh';
  static const String profile = '$auth/profile';

  // User management endpoints
  static const String users = '$base$version/users';
  static const String userById = '$users/{id}';

  // Account management endpoints
  static const String accounts = '$base$version/accounts';
  static const String accountById = '$accounts/{id}';
  static const String accountBalance = '$accounts/{id}/balance';
  static const String accountTransactions = '$accounts/{id}/transactions';

  // Transaction endpoints
  static const String transactions = '$base$version/transactions';
  static const String transactionById = '$transactions/{id}';

  // Category endpoints
  static const String categories = '$base$version/categories';
  static const String categoryById = '$categories/{id}';

  // Budget endpoints
  static const String budgets = '$base$version/budgets';
  static const String budgetById = '$budgets/{id}';
  static const String budgetProgress = '$budgets/{id}/progress';

  // Analytics and reporting endpoints
  static const String reports = '$base$version/reports';
  static const String analytics = '$base$version/analytics';
  static const String dashboard = '$analytics/dashboard';
  static const String spendingAnalysis = '$analytics/spending';

  // File upload endpoints
  static const String upload = '$base$version/upload';
  static const String import = '$base$version/import';

  // Settings and preferences endpoints
  static const String settings = '$base$version/settings';
  static const String preferences = '$base$version/preferences';
}

/// Helper class to build URLs with parameters
class ApiUrlBuilder {
  ApiUrlBuilder._();

  /// Replace path parameters in URL
  /// Example: replaceParams('/users/{id}', {'id': '123'}) => '/users/123'
  static String replaceParams(String url, Map<String, String> params) {
    var result = url;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  /// Build query string from parameters
  /// Example: buildQuery({'page': '1', 'limit': '10'}) => '?page=1&limit=10'
  static String buildQuery(Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return '';

    final queryParams = <String>[];
    params.forEach((key, value) {
      if (value != null) {
        queryParams.add('$key=${Uri.encodeQueryComponent(value.toString())}');
      }
    });

    return queryParams.isEmpty ? '' : '?${queryParams.join('&')}';
  }

  /// Build complete URL with path parameters and query string
  static String buildUrl(
    String endpoint, {
    Map<String, String>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    var url = pathParams != null ? replaceParams(endpoint, pathParams) : endpoint;
    url += buildQuery(queryParams);
    return url;
  }
}

/// Endpoint groups for easier organization
class ApiEndpointGroups {
  ApiEndpointGroups._();

  /// Authentication related endpoints
  static const List<String> authEndpoints = [
    ApiEndpoints.login,
    ApiEndpoints.register,
    ApiEndpoints.logout,
    ApiEndpoints.refresh,
    ApiEndpoints.profile,
  ];

  /// Public endpoints that don't require authentication
  static const List<String> publicEndpoints = [
    ApiEndpoints.login,
    ApiEndpoints.register,
    ApiEndpoints.refresh,
  ];

  /// Protected endpoints that require authentication
  static const List<String> protectedEndpoints = [
    ApiEndpoints.profile,
    ApiEndpoints.users,
    ApiEndpoints.accounts,
    ApiEndpoints.transactions,
    ApiEndpoints.categories,
    ApiEndpoints.budgets,
    ApiEndpoints.reports,
    ApiEndpoints.analytics,
    ApiEndpoints.settings,
    ApiEndpoints.upload,
    ApiEndpoints.import,
  ];

  /// Endpoints that support file uploads
  static const List<String> uploadEndpoints = [
    ApiEndpoints.upload,
    ApiEndpoints.import,
  ];

  /// Endpoints that return large datasets (may need pagination)
  static const List<String> paginatedEndpoints = [
    ApiEndpoints.transactions,
    ApiEndpoints.users,
    ApiEndpoints.accounts,
    ApiEndpoints.categories,
  ];
}

/// HTTP methods for each endpoint
class HttpMethods {
  HttpMethods._();

  static const Map<String, String> methodMap = {
    ApiEndpoints.login: 'POST',
    ApiEndpoints.register: 'POST',
    ApiEndpoints.logout: 'POST',
    ApiEndpoints.refresh: 'POST',
    ApiEndpoints.profile: 'GET',
    ApiEndpoints.users: 'GET',
    ApiEndpoints.userById: 'GET',
    ApiEndpoints.accounts: 'GET',
    ApiEndpoints.accountById: 'GET',
    ApiEndpoints.accountBalance: 'GET',
    ApiEndpoints.accountTransactions: 'GET',
    ApiEndpoints.transactions: 'GET',
    ApiEndpoints.transactionById: 'GET',
    ApiEndpoints.categories: 'GET',
    ApiEndpoints.categoryById: 'GET',
    ApiEndpoints.budgets: 'GET',
    ApiEndpoints.budgetById: 'GET',
    ApiEndpoints.budgetProgress: 'GET',
    ApiEndpoints.reports: 'GET',
    ApiEndpoints.analytics: 'GET',
    ApiEndpoints.dashboard: 'GET',
    ApiEndpoints.spendingAnalysis: 'GET',
    ApiEndpoints.upload: 'POST',
    ApiEndpoints.import: 'POST',
    ApiEndpoints.settings: 'GET',
    ApiEndpoints.preferences: 'GET',
  };

  /// Get HTTP method for an endpoint
  static String getMethod(String endpoint) {
    return methodMap[endpoint] ?? 'GET';
  }

  /// Check if endpoint supports GET method
  static bool isGetMethod(String endpoint) {
    return getMethod(endpoint) == 'GET';
  }

  /// Check if endpoint supports POST method
  static bool isPostMethod(String endpoint) {
    return getMethod(endpoint) == 'POST';
  }

  /// Check if endpoint supports PUT method
  static bool isPutMethod(String endpoint) {
    return getMethod(endpoint) == 'PUT';
  }

  /// Check if endpoint supports DELETE method
  static bool isDeleteMethod(String endpoint) {
    return getMethod(endpoint) == 'DELETE';
  }

  /// Check if endpoint supports PATCH method
  static bool isPatchMethod(String endpoint) {
    return getMethod(endpoint) == 'PATCH';
  }
}
