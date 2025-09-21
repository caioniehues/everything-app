import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

/// Generic API response wrapper
@Freezed(genericArgumentFactories: true)
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required bool success,
    required String message,
    T? data,
    Map<String, dynamic>? meta,
    @Default([]) List<String> errors,
    DateTime? timestamp,
  }) = _ApiResponse<T>;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  /// Create a successful response
  factory ApiResponse.success({
    required String message,
    T? data,
    Map<String, dynamic>? meta,
  }) =>
      ApiResponse(
        success: true,
        message: message,
        data: data,
        meta: meta,
        timestamp: DateTime.now(),
      );

  /// Create an error response
  factory ApiResponse.error({
    required String message,
    List<String> errors = const [],
    Map<String, dynamic>? meta,
  }) =>
      ApiResponse(
        success: false,
        message: message,
        errors: errors,
        meta: meta,
        timestamp: DateTime.now(),
      );
}

/// Pagination meta data for API responses
@freezed
class PaginationMeta with _$PaginationMeta {
  const factory PaginationMeta({
    required int page,
    required int size,
    required int totalElements,
    required int totalPages,
    required bool hasNext,
    required bool hasPrevious,
    required bool isFirst,
    required bool isLast,
  }) = _PaginationMeta;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);
}

/// Paginated API response wrapper
@Freezed(genericArgumentFactories: true)
class PaginatedApiResponse<T> with _$PaginatedApiResponse<T> {
  const factory PaginatedApiResponse({
    required bool success,
    required String message,
    required List<T> data,
    required PaginationMeta pagination,
    @Default([]) List<String> errors,
    DateTime? timestamp,
  }) = _PaginatedApiResponse<T>;

  factory PaginatedApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$PaginatedApiResponseFromJson(json, fromJsonT);
}
