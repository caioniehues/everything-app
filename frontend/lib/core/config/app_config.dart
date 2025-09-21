import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration class that manages environment settings
/// and feature flags across the application
class AppConfig {
  AppConfig._();

  /// Current environment the app is running in
  static Environment get environment {
    final envString = dotenv.env['ENVIRONMENT'] ?? 'development';
    return Environment.values.firstWhere(
      (e) => e.name == envString,
      orElse: () => Environment.development,
    );
  }

  /// Base URL for API requests
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1';

  /// API request timeout in milliseconds
  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;

  /// Application name
  static String get appName =>
      dotenv.env['APP_NAME'] ?? 'Everything App';

  /// Application version
  static String get appVersion =>
      dotenv.env['APP_VERSION'] ?? '1.0.0';

  /// JWT token expiration in minutes
  static int get jwtExpirationMinutes =>
      int.tryParse(dotenv.env['JWT_EXPIRATION_MINUTES'] ?? '15') ?? 15;

  /// Refresh token expiration in days
  static int get refreshTokenExpirationDays =>
      int.tryParse(dotenv.env['REFRESH_TOKEN_EXPIRATION_DAYS'] ?? '7') ?? 7;

  /// Minimum password length requirement
  static int get minPasswordLength =>
      int.tryParse(dotenv.env['MIN_PASSWORD_LENGTH'] ?? '8') ?? 8;

  /// Maximum login attempts before lockout
  static int get maxLoginAttempts =>
      int.tryParse(dotenv.env['MAX_LOGIN_ATTEMPTS'] ?? '5') ?? 5;

  /// Feature Flags
  static bool get isDebugMode =>
      dotenv.env['ENABLE_DEBUG_MODE']?.toLowerCase() == 'true';

  static bool get isAnalyticsEnabled =>
      dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';

  static bool get isCrashReportingEnabled =>
      dotenv.env['ENABLE_CRASH_REPORTING']?.toLowerCase() == 'true';

  /// Check if the app is in production
  static bool get isProduction => environment == Environment.production;

  /// Check if the app is in development
  static bool get isDevelopment => environment == Environment.development;

  /// Initialize app configuration by loading environment variables
  /// Gracefully handles missing .env file (e.g., in web builds)
  static Future<void> initialize() async {
    try {
      await dotenv.load();
    } catch (e) {
      // .env file not found (common in web builds)
      // Use default values instead
      // ignore: avoid_print
      print('Warning: .env file not found, using default configuration values');
    }
  }

  /// Get configuration summary for debugging
  static Map<String, dynamic> toJson() => {
    'environment': environment.name,
    'apiBaseUrl': apiBaseUrl,
    'apiTimeout': apiTimeout,
    'appName': appName,
    'appVersion': appVersion,
    'isDebugMode': isDebugMode,
    'isAnalyticsEnabled': isAnalyticsEnabled,
    'isCrashReportingEnabled': isCrashReportingEnabled,
  };
}

/// Enum representing different application environments
enum Environment {
  development,
  staging,
  production,
}

/// Extension methods for Environment enum
extension EnvironmentExtension on Environment {
  /// Human-readable name for the environment
  String get displayName {
    switch (this) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  /// Check if this is a test environment (dev or staging)
  bool get isTestEnvironment => this != Environment.production;
}