import 'package:flutter/material.dart';
import 'formatters.dart';

/// Extension methods for String
extension StringExtension on String {
  /// Check if string is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Check if string is not null or empty
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize first letter of each word
  String get capitalizeWords {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Convert to title case
  String get toTitleCase => capitalizeWords;

  /// Remove all whitespace
  String get removeAllWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Check if string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);
  }

  /// Check if string is a valid URL
  bool get isValidUrl {
    try {
      final uri = Uri.parse(this);
      return uri.hasScheme && uri.hasAuthority;
    } catch (_) {
      return false;
    }
  }

  /// Check if string contains only digits
  bool get isNumeric => RegExp(r'^\d+$').hasMatch(this);

  /// Convert string to int or return null
  int? get toIntOrNull => int.tryParse(this);

  /// Convert string to double or return null
  double? get toDoubleOrNull => double.tryParse(this);

  /// Get initials from name
  String get initials => Formatters.initials(this);

  /// Truncate string with ellipsis
  String truncate(int maxLength) => Formatters.truncate(this, maxLength);

  /// Convert to snake_case
  String get toSnakeCase {
    return replaceAllMapped(RegExp('[A-Z]'), (match) {
      return '_${match.group(0)!.toLowerCase()}';
    }).replaceFirst(RegExp('^_'), '');
  }

  /// Convert to kebab-case
  String get toKebabCase => toSnakeCase.replaceAll('_', '-');

  /// Mask sensitive data (show only last n characters)
  String mask({int visibleChars = 4, String maskChar = '*'}) {
    if (length <= visibleChars) return this;
    final maskedLength = length - visibleChars;
    return maskChar * maskedLength + substring(maskedLength);
  }
}

/// Extension methods for String? (nullable)
extension NullableStringExtension on String? {
  /// Check if string is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// Return empty string if null
  String get orEmpty => this ?? '';
}

/// Extension methods for DateTime
extension DateTimeExtension on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Get start of day
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Get start of month
  DateTime get startOfMonth => DateTime(year, month);

  /// Get end of month
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  /// Format to string using default format
  String get formatted => Formatters.date(this);

  /// Format to string with time
  String get formattedWithTime => Formatters.dateTime(this);

  /// Format as relative time
  String get relativeTime => Formatters.relativeTime(this);

  /// Get age in years
  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  /// Check if same day as another date
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Add business days (excluding weekends)
  DateTime addBusinessDays(int days) {
    DateTime date = this;
    int addedDays = 0;

    while (addedDays < days) {
      date = date.add(const Duration(days: 1));
      if (date.weekday != DateTime.saturday && date.weekday != DateTime.sunday) {
        addedDays++;
      }
    }

    return date;
  }
}

/// Extension methods for num (int and double)
extension NumExtension on num {
  /// Format as currency
  String get asCurrency => Formatters.currency(toDouble());

  /// Format as compact currency
  String get asCompactCurrency => Formatters.currencyCompact(toDouble());

  /// Format as percentage
  String asPercentage({int decimals = 1}) => Formatters.percentage(toDouble(), decimals: decimals);

  /// Format with thousands separator
  String get formatted => Formatters.number(this);

  /// Check if number is between min and max (inclusive)
  bool between(num min, num max) => this >= min && this <= max;

  /// Clamp number between min and max
  num clampBetween(num min, num max) => clamp(min, max);
}

/// Extension methods for Duration
extension DurationExtension on Duration {
  /// Format duration as readable string
  String get formatted => Formatters.duration(this);

  /// Get duration in minutes and seconds
  String get inMinutesAndSeconds {
    final minutes = inMinutes;
    final seconds = inSeconds.remainder(60);
    return '${minutes}m ${seconds}s';
  }

  /// Check if duration is zero
  bool get isZero => inMicroseconds == 0;

  /// Check if duration is positive
  bool get isPositive => inMicroseconds > 0;
}

/// Extension methods for List
extension ListExtension<T> on List<T> {
  /// Get first element or null
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last element or null
  T? get lastOrNull => isEmpty ? null : last;

  /// Get element at index or null
  T? getOrNull(int index) => index >= 0 && index < length ? this[index] : null;

  /// Separate list into chunks
  List<List<T>> chunk(int chunkSize) {
    final chunks = <List<T>>[];
    for (int i = 0; i < length; i += chunkSize) {
      final end = (i + chunkSize < length) ? i + chunkSize : length;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }

  /// Remove duplicates while preserving order
  List<T> get distinct => toSet().toList();
}

/// Extension methods for BuildContext
extension ContextExtension on BuildContext {
  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Get media query
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => mediaQuery.size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => mediaQuery.viewInsets.bottom > 0;

  /// Get safe area padding
  EdgeInsets get safeAreaPadding => mediaQuery.padding;

  /// Check if dark mode is enabled
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Check if device is mobile
  bool get isMobile => screenWidth < 600;

  /// Check if device is tablet
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;

  /// Check if device is desktop
  bool get isDesktop => screenWidth >= 900;

  /// Show snackbar with message
  void showSnackBar(String message, {SnackBarAction? action, Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
      ),
    );
  }

  /// Show success snackbar
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Navigate to route
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Navigate back
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  /// Navigate to route and remove all previous routes
  Future<T?> pushAndRemoveAll<T>(Widget page) {
    return Navigator.of(this).pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }
}