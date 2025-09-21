import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor that logs HTTP requests and responses
/// Only active in debug mode to avoid performance impact in production
class LoggingInterceptor extends Interceptor {
  static const String _tag = 'API';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _logRequest(options);
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _logResponse(response);
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _logError(err);
    }
    return handler.next(err);
  }

  void _logRequest(RequestOptions options) {
    final message = StringBuffer()
      ..writeln('🚀 $_tag REQUEST:')
      ..writeln('  ${options.method.toUpperCase()} ${options.uri}')
      ..writeln('  Headers: ${options.headers}')
      ..writeln('  Query Parameters: ${options.queryParameters}');

    if (options.data != null) {
      _logRequestBody(options.data);
    }

    _printLog(message.toString());
  }

  void _logRequestBody(data) {
    final message = StringBuffer()..writeln('  Body:');

    try {
      if (data is FormData) {
        message.writeln('    [FormData with ${data.fields.length} fields]');
        for (final field in data.fields) {
          message.writeln('    - ${field.key}: ${field.value}');
        }
        if (data.files.isNotEmpty) {
          message.writeln('    [Files: ${data.files.length}]');
        }
      } else if (data is Map<String, dynamic>) {
        _logJsonData(data, message, indent: 4);
      } else if (data is String) {
        message.writeln('    $data');
      } else {
        message.writeln('    ${_sanitizeData(data.toString())}');
      }
    } catch (e) {
      message.writeln('    [Error logging body: $e]');
    }

    _printLog(message.toString());
  }

  void _logJsonData(Map<String, dynamic> data, StringBuffer buffer, {int indent = 2}) {
    final encoder = JsonEncoder.withIndent('  ' * (indent ~/ 2));
    final sanitizedData = _sanitizeJsonData(data);
    buffer.writeln(encoder.convert(sanitizedData));
  }

  Map<String, dynamic> _sanitizeJsonData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      // Sanitize sensitive fields
      if (_isSensitiveField(key)) {
        sanitized[key] = '***REDACTED***';
      } else if (value is Map<String, dynamic>) {
        sanitized[key] = _sanitizeJsonData(value);
      } else if (value is List) {
        sanitized[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return _sanitizeJsonData(item);
          }
          return _isSensitiveField(key) ? '***REDACTED***' : item;
        }).toList();
      } else {
        sanitized[key] = value;
      }
    }

    return sanitized;
  }

  bool _isSensitiveField(String key) {
    final sensitiveKeys = [
      'password',
      'token',
      'authorization',
      'refresh_token',
      'access_token',
      'api_key',
      'secret',
      'key',
      'credit_card',
      'ssn',
      'social_security',
    ];

    final lowerKey = key.toLowerCase();
    return sensitiveKeys.any(lowerKey.contains);
  }

  void _logResponse(Response response) {
    final message = StringBuffer()
      ..writeln('✅ $_tag RESPONSE:')
      ..writeln('  ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}')
      ..writeln('  Status: ${response.statusCode}')
      ..writeln('  Duration: ${response.headers.value('X-Response-Time') ?? 'N/A'}ms')
      ..writeln('  Headers: ${response.headers.map}');

    if (response.data != null) {
      _logResponseBody(response.data);
    }

    _printLog(message.toString());
  }

  void _logResponseBody(data) {
    final message = StringBuffer()..writeln('  Body:');

    try {
      if (data is Map<String, dynamic>) {
        _logJsonData(data, message, indent: 4);
      } else if (data is String) {
        message.writeln('    $data');
      } else {
        message.writeln('    ${_sanitizeData(data.toString())}');
      }
    } catch (e) {
      message.writeln('    [Error logging body: $e]');
    }

    _printLog(message.toString());
  }

  void _logError(DioException err) {
    final message = StringBuffer()
      ..writeln('❌ $_tag ERROR:')
      ..writeln('  ${err.requestOptions.method.toUpperCase()} ${err.requestOptions.uri}')
      ..writeln('  Error Type: ${err.type}')
      ..writeln('  Status Code: ${err.response?.statusCode ?? 'N/A'}')
      ..writeln('  Message: ${err.message}');

    if (err.response?.data != null) {
      final data = err.response?.data;
      if (data is Map<String, dynamic>) {
        message.writeln('  Response Body:');
        _logJsonData(data, message, indent: 4);
      } else {
        message.writeln('  Response Body: $data');
      }
    }

    _printLog(message.toString());
  }

  String _sanitizeData(String data) {
    // Basic sanitization for logs
    return data.replaceAll('\n', ' ').replaceAll('\r', ' ');
  }

  void _printLog(String message) {
    // Use debugPrint for better handling of long messages
    debugPrint(message);
  }
}
