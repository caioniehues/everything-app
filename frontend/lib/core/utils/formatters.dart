import 'package:intl/intl.dart';

/// Formatting utilities for displaying data
class Formatters {
  Formatters._();

  /// Format currency with proper symbol and decimals
  static String currency(double amount, {String? symbol, int decimals = 2}) {
    final formatter = NumberFormat.currency(
      symbol: symbol ?? r'$',
      decimalDigits: decimals,
    );
    return formatter.format(amount);
  }

  /// Format currency compact (e.g., $1.2K, $1.5M)
  static String currencyCompact(double amount, {String? symbol}) {
    if (amount.abs() >= 1000000) {
      return '${symbol ?? r'$'}${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '${symbol ?? r'$'}${(amount / 1000).toStringAsFixed(1)}K';
    }
    return currency(amount, symbol: symbol);
  }

  /// Format percentage
  static String percentage(double value, {int decimals = 1, bool includeSign = true}) {
    final formatted = value.toStringAsFixed(decimals);
    final sign = includeSign && value > 0 ? '+' : '';
    return '$sign$formatted%';
  }

  /// Format date to string
  static String date(DateTime date, {String? pattern}) {
    final formatter = DateFormat(pattern ?? 'MMM dd, yyyy');
    return formatter.format(date);
  }

  /// Format date with time
  static String dateTime(DateTime dateTime, {String? pattern}) {
    final formatter = DateFormat(pattern ?? 'MMM dd, yyyy HH:mm');
    return formatter.format(dateTime);
  }

  /// Format time only
  static String time(DateTime time, {bool use24Hour = false}) {
    final pattern = use24Hour ? 'HH:mm' : 'hh:mm a';
    final formatter = DateFormat(pattern);
    return formatter.format(time);
  }

  /// Format relative time (e.g., "2 hours ago", "in 3 days")
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds.abs() < 60) {
      return 'just now';
    }

    if (difference.inMinutes.abs() < 60) {
      final minutes = difference.inMinutes.abs();
      final suffix = difference.isNegative ? 'from now' : 'ago';
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} $suffix';
    }

    if (difference.inHours.abs() < 24) {
      final hours = difference.inHours.abs();
      final suffix = difference.isNegative ? 'from now' : 'ago';
      return '$hours ${hours == 1 ? 'hour' : 'hours'} $suffix';
    }

    if (difference.inDays.abs() < 7) {
      final days = difference.inDays.abs();
      final suffix = difference.isNegative ? 'from now' : 'ago';
      return '$days ${days == 1 ? 'day' : 'days'} $suffix';
    }

    if (difference.inDays.abs() < 30) {
      final weeks = (difference.inDays.abs() / 7).round();
      final suffix = difference.isNegative ? 'from now' : 'ago';
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} $suffix';
    }

    if (difference.inDays.abs() < 365) {
      final months = (difference.inDays.abs() / 30).round();
      final suffix = difference.isNegative ? 'from now' : 'ago';
      return '$months ${months == 1 ? 'month' : 'months'} $suffix';
    }

    final years = (difference.inDays.abs() / 365).round();
    final suffix = difference.isNegative ? 'from now' : 'ago';
    return '$years ${years == 1 ? 'year' : 'years'} $suffix';
  }

  /// Format phone number
  static String phoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length == 10) {
      // US format: (555) 123-4567
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }

    if (cleaned.length == 11 && cleaned.startsWith('1')) {
      // US format with country code: +1 (555) 123-4567
      return '+1 (${cleaned.substring(1, 4)}) ${cleaned.substring(4, 7)}-${cleaned.substring(7)}';
    }

    // Return as-is if format is unknown
    return phone;
  }

  /// Format credit card number (with masking)
  static String creditCard(String cardNumber, {bool mask = true}) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (mask && cleaned.length >= 12) {
      // Show only last 4 digits: **** **** **** 1234
      final last4 = cleaned.substring(cleaned.length - 4);
      return '**** **** **** $last4';
    }

    // Format: 1234 5678 9012 3456
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  /// Format file size
  static String fileSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(size >= 10 ? 0 : 1)} ${units[unitIndex]}';
  }

  /// Format number with thousands separator
  static String number(num value, {int? decimals}) {
    if (decimals != null) {
      return NumberFormat('#,##0.${'0' * decimals}').format(value);
    }
    return NumberFormat('#,##0.##').format(value);
  }

  /// Format ordinal number (1st, 2nd, 3rd, etc.)
  static String ordinal(int number) {
    if (number >= 11 && number <= 13) {
      return '${number}th';
    }

    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  /// Format duration
  static String duration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  /// Format name (capitalize first letter of each word)
  static String name(String name) {
    return name.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Format initials from name
  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Format list to string with proper grammar
  static String list(List<String> items, {String separator = ', ', String lastSeparator = ' and '}) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items[0];
    if (items.length == 2) return '${items[0]}$lastSeparator${items[1]}';

    final allButLast = items.sublist(0, items.length - 1);
    return '${allButLast.join(separator)}$lastSeparator${items.last}';
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength, {String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Format account number (show last 4 digits)
  static String accountNumber(String account) {
    if (account.length <= 4) return account;
    final last4 = account.substring(account.length - 4);
    return '****$last4';
  }
}