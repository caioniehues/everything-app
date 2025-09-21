import '../config/app_config.dart';

/// Validation utilities for form fields and data validation
class Validators {
  Validators._();

  /// Email validation regex pattern
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Phone number validation regex (international format)
  static final RegExp _phoneRegExp = RegExp(
    r'^\+?[1-9]\d{1,14}$',
  );

  /// Validate email address
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConfig.minPasswordLength) {
      return 'Password must be at least ${AppConfig.minPasswordLength} characters';
    }
    if (!value.contains(RegExp('[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp('[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp('[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  /// Validate confirm password
  static String? Function(String?) confirmPassword(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != password) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  /// Validate required field
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validate phone number
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!_phoneRegExp.hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validate amount (financial)
  static String? amount(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (amount <= 0) {
      return 'Amount must be greater than zero';
    }
    if (min != null && amount < min) {
      return 'Amount must be at least ${_formatCurrency(min)}';
    }
    if (max != null && amount > max) {
      return 'Amount cannot exceed ${_formatCurrency(max)}';
    }
    return null;
  }

  /// Validate date
  static String? date(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }
    try {
      DateTime.parse(value);
      return null;
    } catch (_) {
      return 'Please enter a valid date';
    }
  }

  /// Validate future date
  static String? futureDate(String? value) {
    final dateError = date(value);
    if (dateError != null) return dateError;

    final inputDate = DateTime.parse(value!);
    if (inputDate.isBefore(DateTime.now())) {
      return 'Date must be in the future';
    }
    return null;
  }

  /// Validate past date
  static String? pastDate(String? value) {
    final dateError = date(value);
    if (dateError != null) return dateError;

    final inputDate = DateTime.parse(value!);
    if (inputDate.isAfter(DateTime.now())) {
      return 'Date must be in the past';
    }
    return null;
  }

  /// Validate minimum length
  static String? Function(String?) minLength(int min, [String? fieldName]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return '${fieldName ?? 'This field'} is required';
      }
      if (value.length < min) {
        return '${fieldName ?? 'Field'} must be at least $min characters';
      }
      return null;
    };
  }

  /// Validate maximum length
  static String? Function(String?) maxLength(int max, [String? fieldName]) {
    return (String? value) {
      if (value != null && value.length > max) {
        return '${fieldName ?? 'Field'} must not exceed $max characters';
      }
      return null;
    };
  }

  /// Validate URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return 'Please enter a valid URL';
      }
      return null;
    } catch (_) {
      return 'Please enter a valid URL';
    }
  }

  /// Validate credit card number (basic Luhn check)
  static String? creditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }

    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 13 || cleaned.length > 19) {
      return 'Invalid card number';
    }

    // Luhn algorithm
    int sum = 0;
    bool alternate = false;
    for (int i = cleaned.length - 1; i >= 0; i--) {
      int digit = int.parse(cleaned[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }

    if (sum % 10 != 0) {
      return 'Invalid card number';
    }
    return null;
  }

  /// Validate CVV
  static String? cvv(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }
    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
      return 'Invalid CVV';
    }
    return null;
  }

  /// Validate expiry date (MM/YY format)
  static String? expiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }

    final parts = value.split('/');
    if (parts.length != 2) {
      return 'Use MM/YY format';
    }

    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null || month < 1 || month > 12) {
      return 'Invalid expiry date';
    }

    final now = DateTime.now();
    final expiry = DateTime(2000 + year, month);

    if (expiry.isBefore(DateTime(now.year, now.month))) {
      return 'Card has expired';
    }

    return null;
  }

  /// Validate zip code (US format)
  static String? zipCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Zip code is required';
    }
    if (!RegExp(r'^\d{5}(-\d{4})?$').hasMatch(value)) {
      return 'Invalid zip code';
    }
    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Helper to format currency
  static String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}