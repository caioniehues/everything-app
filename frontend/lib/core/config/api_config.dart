import 'package:dio/dio.dart';
import 'app_config.dart';

/// API configuration and endpoint management
class ApiConfig {
  ApiConfig._();

  /// Base URL for API requests
  static String get baseUrl => AppConfig.apiBaseUrl;
  
  /// Connection timeout duration
  static Duration get connectTimeout => Duration(milliseconds: AppConfig.apiTimeout);
  
  /// Receive timeout duration  
  static Duration get receiveTimeout => Duration(milliseconds: AppConfig.apiTimeout);
  
  /// Send timeout duration
  static Duration get sendTimeout => Duration(milliseconds: AppConfig.apiTimeout);

  /// Base options for Dio HTTP client
  static BaseOptions get dioBaseOptions => BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: Duration(milliseconds: AppConfig.apiTimeout),
    receiveTimeout: Duration(milliseconds: AppConfig.apiTimeout),
    sendTimeout: Duration(milliseconds: AppConfig.apiTimeout),
    headers: defaultHeaders,
    validateStatus: (status) => status! < 500,
  );

  /// Default headers for all API requests
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-App-Version': AppConfig.appVersion,
    'X-Platform': 'flutter',
  };

  /// Add authorization header with bearer token
  static Map<String, String> authorizationHeader(String token) => {
    'Authorization': 'Bearer $token',
  };

  /// API version prefix
  static const String apiVersion = 'v1';

  /// Authentication endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';

  /// User endpoints
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String changePassword = '/users/change-password';
  static const String deleteAccount = '/users/delete';
  static const String uploadAvatar = '/users/avatar';

  /// Account endpoints (financial accounts)
  static const String accounts = '/accounts';
  static String accountById(String id) => '/accounts/$id';
  static const String accountTypes = '/accounts/types';
  static String accountTransactions(String id) => '/accounts/$id/transactions';
  static String accountBalance(String id) => '/accounts/$id/balance';

  /// Transaction endpoints
  static const String transactions = '/transactions';
  static String transactionById(String id) => '/transactions/$id';
  static const String transactionCategories = '/transactions/categories';
  static const String transactionStats = '/transactions/stats';
  static const String recurringTransactions = '/transactions/recurring';

  /// Budget endpoints
  static const String budgets = '/budgets';
  static String budgetById(String id) => '/budgets/$id';
  static const String budgetCategories = '/budgets/categories';
  static String budgetProgress(String id) => '/budgets/$id/progress';

  /// Analytics endpoints
  static const String analytics = '/analytics';
  static const String analyticsSummary = '/analytics/summary';
  static const String analyticsSpending = '/analytics/spending';
  static const String analyticsIncome = '/analytics/income';
  static const String analyticsTrends = '/analytics/trends';
  static const String analyticsForecasts = '/analytics/forecasts';

  /// Goal endpoints
  static const String goals = '/goals';
  static String goalById(String id) => '/goals/$id';
  static String goalProgress(String id) => '/goals/$id/progress';
  static String goalContributions(String id) => '/goals/$id/contributions';

  /// Notification endpoints
  static const String notifications = '/notifications';
  static String notificationById(String id) => '/notifications/$id';
  static const String notificationSettings = '/notifications/settings';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';

  /// Export endpoints
  static const String exportPdf = '/export/pdf';
  static const String exportCsv = '/export/csv';
  static const String exportExcel = '/export/excel';

  /// Import endpoints
  static const String importCsv = '/import/csv';
  static const String importBankStatement = '/import/bank-statement';
  static const String importStatus = '/import/status';

  /// External service endpoints
  static const String plaidLink = '/external/plaid/link';
  static const String plaidAccounts = '/external/plaid/accounts';
  static const String exchangeRates = '/external/exchange-rates';

  /// Health check endpoint
  static const String health = '/health';
  static const String healthReady = '/health/ready';
  static const String healthLive = '/health/live';

  /// Rate limiting configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const int rateLimitPerMinute = 60;

  /// Pagination defaults
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  /// File upload limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'csv', 'xls', 'xlsx'];

  /// Cache durations
  static const Duration shortCache = Duration(minutes: 5);
  static const Duration mediumCache = Duration(minutes: 15);
  static const Duration longCache = Duration(hours: 1);
  static const Duration permanentCache = Duration(days: 7);

  /// Build query parameters for pagination
  static Map<String, dynamic> paginationParams({
    int page = 0,
    int size = defaultPageSize,
    String? sort,
    String? direction = 'ASC',
  }) => {
    'page': page,
    'size': size.clamp(1, maxPageSize),
    if (sort != null) 'sort': sort,
    if (direction != null) 'direction': direction,
  };

  /// Build query parameters for date range
  static Map<String, dynamic> dateRangeParams({
    DateTime? startDate,
    DateTime? endDate,
  }) => {
    if (startDate != null) 'startDate': startDate.toIso8601String(),
    if (endDate != null) 'endDate': endDate.toIso8601String(),
  };

  /// Build query parameters for filtering
  static Map<String, dynamic> filterParams({
    String? search,
    String? category,
    String? status,
    List<String>? tags,
  }) => {
    if (search != null && search.isNotEmpty) 'search': search,
    if (category != null) 'category': category,
    if (status != null) 'status': status,
    if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
  };
}