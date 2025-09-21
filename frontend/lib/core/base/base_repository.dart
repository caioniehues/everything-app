import 'dart:async';

import '../errors/error_handler.dart';
import '../errors/failures.dart';
import '../errors/failures.dart';

/// Base repository interface for all repositories
/// Provides common functionality and error handling
abstract class BaseRepository {
  /// Execute an operation with error handling
  Future<T> execute<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      throw FailureException(ErrorHandler.handleException(error, stackTrace));
    }
  }

  /// Execute an operation and return Either-like result
  /// Returns null on failure or the result on success
  Future<T?> executeOrNull<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (_) {
      return null;
    }
  }

  /// Execute an operation with retry logic
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    dynamic lastError;

    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (error) {
        lastError = error;
        attempts++;

        if (attempts < maxAttempts) {
          await Future.delayed(delay * attempts);
        }
      }
    }

    throw lastError ?? const UnknownFailure();
  }

  /// Execute an operation with timeout
  Future<T> executeWithTimeout<T>(
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      return await operation().timeout(timeout);
    } on TimeoutException {
      throw FailureException(NetworkFailure.timeout());
    } catch (error, stackTrace) {
      throw FailureException(ErrorHandler.handleException(error, stackTrace));
    }
  }
}

/// Interface for repositories with CRUD operations
abstract class CrudRepository<T, ID> extends BaseRepository {
  /// Get all entities
  Future<List<T>> getAll();

  /// Get entity by ID
  Future<T?> getById(ID id);

  /// Create new entity
  Future<T> create(T entity);

  /// Update existing entity
  Future<T> update(ID id, T entity);

  /// Delete entity by ID
  Future<void> delete(ID id);

  /// Check if entity exists
  Future<bool> exists(ID id);

  /// Get count of entities
  Future<int> count();
}

/// Interface for repositories with pagination support
abstract class PaginatedRepository<T, ID> extends CrudRepository<T, ID> {
  /// Get paginated results
  Future<PaginatedResult<T>> getPaginated({
    int page = 0,
    int size = 20,
    String? sort,
    String? direction,
  });

  /// Search with pagination
  Future<PaginatedResult<T>> searchPaginated({
    required String query,
    int page = 0,
    int size = 20,
  });
}

/// Paginated result wrapper
class PaginatedResult<T> {
  final List<T> items;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;

  const PaginatedResult({
    required this.items,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedResult.empty() => PaginatedResult<T>(
    items: const [],
    totalItems: 0,
    totalPages: 0,
    currentPage: 0,
    pageSize: 0,
    hasNext: false,
    hasPrevious: false,
  );

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get itemCount => items.length;
}

/// Interface for repositories with caching support
abstract class CachedRepository<T, ID> extends BaseRepository {
  /// Cache duration
  Duration get cacheDuration;

  /// Get from cache or fetch
  Future<T?> getFromCacheOrFetch(ID id);

  /// Invalidate cache for ID
  Future<void> invalidateCache(ID id);

  /// Clear all cache
  Future<void> clearCache();

  /// Check if cache is valid
  Future<bool> isCacheValid(ID id);
}