/// Central location for all route path constants
/// Provides type-safe route navigation throughout the app
class RoutePaths {
  RoutePaths._();

  /// Root/Landing Routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  /// Authentication Routes (Public)
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  /// Main App Routes (Protected)
  static const String dashboard = '/dashboard';
  static const String accounts = '/accounts';
  static const String transactions = '/transactions';
  static const String budgets = '/budgets';
  static const String budget = '/budget'; // Alias for consistency
  static const String goals = '/goals';
  static const String analytics = '/analytics';
  static const String reports = '/reports'; // Alias for analytics
  static const String categories = '/categories';
  static const String family = '/family';
  static const String settings = '/settings';
  static const String profile = '/profile';

  /// Nested Routes
  static const String accountDetails = '/accounts/:accountId';
  static const String transactionDetails = '/transactions/:transactionId';
  static const String budgetDetails = '/budgets/:budgetId';
  static const String goalDetails = '/goals/:goalId';

  /// Settings Sub-routes
  static const String settingsAccount = '/settings/account';
  static const String settingsNotifications = '/settings/notifications';
  static const String settingsPrivacy = '/settings/privacy';
  static const String settingsSecurity = '/settings/security';
  static const String settingsAppearance = '/settings/appearance';

  /// Admin Routes (Future)
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminReports = '/admin/reports';

  /// Error Routes
  static const String notFound = '/404';
  static const String error = '/error';

  /// Deep Link Routes
  static const String inviteAccept = '/invite/:token';
  static const String emailVerify = '/verify/:token';
  static const String passwordResetConfirm = '/reset/:token';

  /// Route Names (for navigation)
  static const String splashName = 'splash';
  static const String onboardingName = 'onboarding';
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String forgotPasswordName = 'forgotPassword';
  static const String resetPasswordName = 'resetPassword';
  static const String dashboardName = 'dashboard';
  static const String accountsName = 'accounts';
  static const String transactionsName = 'transactions';
  static const String budgetsName = 'budgets';
  static const String budgetName = 'budget';
  static const String goalsName = 'goals';
  static const String analyticsName = 'analytics';
  static const String reportsName = 'reports';
  static const String categoriesName = 'categories';
  static const String familyName = 'family';
  static const String settingsName = 'settings';
  static const String profileName = 'profile';
  static const String accountDetailsName = 'accountDetails';
  static const String transactionDetailsName = 'transactionDetails';
  static const String budgetDetailsName = 'budgetDetails';
  static const String goalDetailsName = 'goalDetails';
  static const String settingsAccountName = 'settingsAccount';
  static const String settingsNotificationsName = 'settingsNotifications';
  static const String settingsPrivacyName = 'settingsPrivacy';
  static const String settingsSecurityName = 'settingsSecurity';
  static const String settingsAppearanceName = 'settingsAppearance';
  static const String adminName = 'admin';
  static const String adminUsersName = 'adminUsers';
  static const String adminReportsName = 'adminReports';
  static const String notFoundName = 'notFound';
  static const String errorName = 'error';
  static const String inviteAcceptName = 'inviteAccept';
  static const String emailVerifyName = 'emailVerify';
  static const String passwordResetConfirmName = 'passwordResetConfirm';

  /// Route Groups for easier management
  static const List<String> publicRoutes = [
    splash,
    onboarding,
    login,
    register,
    forgotPassword,
    resetPassword,
    inviteAccept,
    emailVerify,
    passwordResetConfirm,
    notFound,
    error,
  ];

  static const List<String> protectedRoutes = [
    dashboard,
    accounts,
    transactions,
    budgets,
    budget,
    goals,
    analytics,
    reports,
    categories,
    family,
    settings,
    profile,
    accountDetails,
    transactionDetails,
    budgetDetails,
    goalDetails,
    settingsAccount,
    settingsNotifications,
    settingsPrivacy,
    settingsSecurity,
    settingsAppearance,
  ];

  static const List<String> adminRoutes = [
    admin,
    adminUsers,
    adminReports,
  ];

  /// Helper methods for route validation
  static bool isPublicRoute(String path) => publicRoutes.contains(path);
  static bool isProtectedRoute(String path) => protectedRoutes.contains(path);
  static bool isAdminRoute(String path) => adminRoutes.contains(path);

  /// Get initial route based on auth state
  static String getInitialRoute({
    required bool isAuthenticated,
    required bool isFirstLaunch,
  }) {
    if (isFirstLaunch) return onboarding;
    if (isAuthenticated) return dashboard;
    return login;
  }

  /// Extract route parameters helper
  static Map<String, String> extractParams(String path, String route) {
    final pathSegments = path.split('/');
    final routeSegments = route.split('/');

    final params = <String, String>{};

    for (int i = 0; i < routeSegments.length; i++) {
      if (routeSegments[i].startsWith(':')) {
        final paramName = routeSegments[i].substring(1);
        if (i < pathSegments.length) {
          params[paramName] = pathSegments[i];
        }
      }
    }

    return params;
  }

  /// Build route with parameters
  static String buildRoute(String route, Map<String, String> params) {
    String result = route;
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value);
    });
    return result;
  }
}

/// Route transitions enum
enum RouteTransition {
  slide,
  fade,
  scale,
  rotation,
  custom,
}

/// Route configuration class
class RouteConfig {
  final String path;
  final String name;
  final bool requiresAuth;
  final bool requiresAdmin;
  final RouteTransition transition;
  final Duration transitionDuration;

  const RouteConfig({
    required this.path,
    required this.name,
    this.requiresAuth = false,
    this.requiresAdmin = false,
    this.transition = RouteTransition.fade,
    this.transitionDuration = const Duration(milliseconds: 300),
  });
}

/// Predefined route configurations
class AppRouteConfigs {
  AppRouteConfigs._();

  static const List<RouteConfig> configs = [
    // Public routes
    RouteConfig(
      path: RoutePaths.splash,
      name: RoutePaths.splashName,
    ),
    RouteConfig(
      path: RoutePaths.login,
      name: RoutePaths.loginName,
      transition: RouteTransition.slide,
    ),
    RouteConfig(
      path: RoutePaths.register,
      name: RoutePaths.registerName,
      transition: RouteTransition.slide,
    ),

    // Protected routes
    RouteConfig(
      path: RoutePaths.dashboard,
      name: RoutePaths.dashboardName,
      requiresAuth: true,
    ),
    RouteConfig(
      path: RoutePaths.accounts,
      name: RoutePaths.accountsName,
      requiresAuth: true,
      transition: RouteTransition.slide,
    ),
    RouteConfig(
      path: RoutePaths.settings,
      name: RoutePaths.settingsName,
      requiresAuth: true,
      transition: RouteTransition.slide,
    ),

    // Admin routes
    RouteConfig(
      path: RoutePaths.admin,
      name: RoutePaths.adminName,
      requiresAuth: true,
      requiresAdmin: true,
      transition: RouteTransition.scale,
    ),
  ];

  /// Get config for a route
  static RouteConfig? getConfig(String path) {
    try {
      return configs.firstWhere((config) => config.path == path);
    } catch (e) {
      return null;
    }
  }
}