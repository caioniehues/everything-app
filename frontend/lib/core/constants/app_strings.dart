/// Application string constants
/// Centralizes all user-facing text for easier maintenance and localization
class AppStrings {
  AppStrings._();

  /// App information
  static const String appName = 'Everything App';
  static const String appTagline = 'Your Family Financial Hub';
  static const String appDescription = 'Manage your finances together, achieve your goals faster';

  /// Authentication screens
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String register = 'Register';
  static const String signUp = 'Sign Up';
  static const String signIn = 'Sign In';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String changePassword = 'Change Password';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String welcomeBack = 'Welcome Back!';
  static const String getStarted = 'Get Started';
  static const String continueText = 'Continue';

  /// Form fields
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String currentPassword = 'Current Password';
  static const String newPassword = 'New Password';
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String fullName = 'Full Name';
  static const String phoneNumber = 'Phone Number';
  static const String dateOfBirth = 'Date of Birth';
  static const String address = 'Address';
  static const String city = 'City';
  static const String state = 'State';
  static const String zipCode = 'Zip Code';
  static const String country = 'Country';

  /// Navigation
  static const String dashboard = 'Dashboard';
  static const String accounts = 'Accounts';
  static const String transactions = 'Transactions';
  static const String budgets = 'Budgets';
  static const String goals = 'Goals';
  static const String analytics = 'Analytics';
  static const String settings = 'Settings';
  static const String profile = 'Profile';
  static const String notifications = 'Notifications';
  static const String help = 'Help';
  static const String about = 'About';

  /// Common actions
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String update = 'Update';
  static const String submit = 'Submit';
  static const String confirm = 'Confirm';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String ok = 'OK';
  static const String close = 'Close';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String finish = 'Finish';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String refresh = 'Refresh';
  static const String retry = 'Retry';
  static const String add = 'Add';
  static const String remove = 'Remove';
  static const String share = 'Share';
  static const String export = 'Export';
  static const String import = 'Import';
  static const String download = 'Download';
  static const String upload = 'Upload';
  static const String viewAll = 'View All';
  static const String seeMore = 'See More';
  static const String seeLess = 'See Less';
  static const String done = 'Done';

  /// Status messages
  static const String loading = 'Loading...';
  static const String saving = 'Saving...';
  static const String deleting = 'Deleting...';
  static const String updating = 'Updating...';
  static const String processing = 'Processing...';
  static const String pleaseWait = 'Please wait...';
  static const String noData = 'No data available';
  static const String noResults = 'No results found';
  static const String emptyList = 'Nothing to show';
  static const String comingSoon = 'Coming Soon';

  /// Success messages
  static const String success = 'Success';
  static const String savedSuccessfully = 'Saved successfully';
  static const String updatedSuccessfully = 'Updated successfully';
  static const String deletedSuccessfully = 'Deleted successfully';
  static const String operationSuccessful = 'Operation completed successfully';
  static const String loginSuccessful = 'Login successful';
  static const String registrationSuccessful = 'Registration successful';
  static const String passwordResetSuccessful = 'Password reset successful';
  static const String profileUpdated = 'Profile updated successfully';

  /// Error messages
  static const String error = 'Error';
  static const String somethingWentWrong = 'Something went wrong';
  static const String tryAgain = 'Please try again';
  static const String networkError = 'Network error. Please check your connection';
  static const String serverError = 'Server error. Please try again later';
  static const String unauthorizedError = 'Unauthorized access';
  static const String sessionExpired = 'Your session has expired. Please login again';
  static const String invalidCredentials = 'Invalid email or password';
  static const String accountLocked = 'Account locked. Too many failed attempts';
  static const String emailAlreadyExists = 'Email already registered';
  static const String weakPassword = 'Password is too weak';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String invalidEmail = 'Please enter a valid email';
  static const String fieldRequired = 'This field is required';
  static const String invalidInput = 'Invalid input';
  static const String operationFailed = 'Operation failed';
  static const String noInternetConnection = 'No internet connection';
  static const String timeoutError = 'Request timeout. Please try again';

  /// Validation messages
  static const String emailRequired = 'Email is required';
  static const String passwordRequired = 'Password is required';
  static const String invalidEmailFormat = 'Please enter a valid email address';
  static const String passwordTooShort = 'Password must be at least 8 characters';
  static const String passwordMustContainUppercase = 'Password must contain at least one uppercase letter';
  static const String passwordMustContainLowercase = 'Password must contain at least one lowercase letter';
  static const String passwordMustContainNumber = 'Password must contain at least one number';
  static const String passwordMustContainSpecialChar = 'Password must contain at least one special character';
  static const String amountRequired = 'Amount is required';
  static const String invalidAmount = 'Please enter a valid amount';
  static const String dateRequired = 'Date is required';
  static const String invalidDate = 'Please enter a valid date';
  static const String descriptionRequired = 'Description is required';
  static const String categoryRequired = 'Category is required';

  /// Confirmation dialogs
  static const String areYouSure = 'Are you sure?';
  static const String deleteConfirmation = 'Are you sure you want to delete this?';
  static const String logoutConfirmation = 'Are you sure you want to logout?';
  static const String unsavedChanges = 'You have unsaved changes. Do you want to save them?';
  static const String discardChanges = 'Discard changes?';
  static const String exitConfirmation = 'Are you sure you want to exit?';

  /// Financial terms
  static const String balance = 'Balance';
  static const String income = 'Income';
  static const String expense = 'Expense';
  static const String transfer = 'Transfer';
  static const String deposit = 'Deposit';
  static const String withdrawal = 'Withdrawal';
  static const String investment = 'Investment';
  static const String savings = 'Savings';
  static const String budget = 'Budget';
  static const String goal = 'Goal';
  static const String transaction = 'Transaction';
  static const String account = 'Account';
  static const String category = 'Category';
  static const String amount = 'Amount';
  static const String date = 'Date';
  static const String description = 'Description';
  static const String note = 'Note';
  static const String recurring = 'Recurring';
  static const String oneTime = 'One-time';
  static const String monthly = 'Monthly';
  static const String yearly = 'Yearly';
  static const String weekly = 'Weekly';
  static const String daily = 'Daily';

  /// Time periods
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String tomorrow = 'Tomorrow';
  static const String thisWeek = 'This Week';
  static const String lastWeek = 'Last Week';
  static const String thisMonth = 'This Month';
  static const String lastMonth = 'Last Month';
  static const String thisYear = 'This Year';
  static const String lastYear = 'Last Year';
  static const String allTime = 'All Time';
  static const String custom = 'Custom';
  static const String selectDateRange = 'Select Date Range';

  /// Settings
  static const String generalSettings = 'General';
  static const String accountSettings = 'Account';
  static const String notificationSettings = 'Notifications';
  static const String privacySettings = 'Privacy';
  static const String securitySettings = 'Security';
  static const String appearanceSettings = 'Appearance';
  static const String languageSettings = 'Language';
  static const String currencySettings = 'Currency';
  static const String darkMode = 'Dark Mode';
  static const String lightMode = 'Light Mode';
  static const String systemDefault = 'System Default';
  static const String enableNotifications = 'Enable Notifications';
  static const String enableBiometric = 'Enable Biometric Authentication';
  static const String exportData = 'Export Data';
  static const String deleteAccount = 'Delete Account';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';

  /// Empty states
  static const String noTransactions = 'No transactions yet';
  static const String noAccounts = 'No accounts added';
  static const String noBudgets = 'No budgets created';
  static const String noGoals = 'No goals set';
  static const String noNotifications = 'No notifications';
  static const String startAddingTransactions = 'Start by adding your first transaction';
  static const String createFirstAccount = 'Create your first account to get started';
  static const String setFirstBudget = 'Set your first budget to track expenses';
  static const String defineFirstGoal = 'Define your first financial goal';

  /// Permissions
  static const String cameraPermission = 'Camera permission is required';
  static const String storagePermission = 'Storage permission is required';
  static const String notificationPermission = 'Notification permission is required';
  static const String locationPermission = 'Location permission is required';
  static const String permissionDenied = 'Permission denied';
  static const String grantPermission = 'Grant Permission';
  static const String openSettings = 'Open Settings';
}