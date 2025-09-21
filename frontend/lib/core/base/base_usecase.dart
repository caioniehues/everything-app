import 'dart:async';

import 'package:equatable/equatable.dart';

import '../errors/error_handler.dart';
import '../errors/failures.dart';

/// Base class for all use cases in the application
/// Follows the Command pattern and enforces single responsibility
abstract class BaseUseCase<TResult, Params> {
  /// Execute the use case with given parameters
  Future<TResult> call(Params params);

  /// Execute use case with error handling
  Future<TResult> execute(Params params) async {
    try {
      return await call(params);
    } catch (error, stackTrace) {
      final failure = ErrorHandler.handleException(error, stackTrace);
      throw FailureException(failure);
    }
  }
}

/// Use case without parameters
abstract class NoParamsUseCase<TResult> {
  /// Execute the use case without parameters
  Future<TResult> call();

  /// Execute use case with error handling
  Future<TResult> execute() async {
    try {
      return await call();
    } catch (error, stackTrace) {
      final failure = ErrorHandler.handleException(error, stackTrace);
      throw FailureException(failure);
    }
  }
}

/// Synchronous use case
abstract class SyncUseCase<TResult, Params> {
  /// Execute the use case synchronously
  TResult call(Params params);

  /// Execute use case with error handling
  TResult execute(Params params) {
    try {
      return call(params);
    } catch (error, stackTrace) {
      final failure = ErrorHandler.handleException(error, stackTrace);
      throw FailureException(failure);
    }
  }
}

/// Stream-based use case for reactive operations
abstract class StreamUseCase<TResult, Params> {
  /// Execute the use case and return a stream
  Stream<TResult> call(Params params);

  /// Execute use case with error handling
  Stream<TResult> execute(Params params) {
    return call(params).handleError((error, stackTrace) {
      final failure = ErrorHandler.handleException(error, stackTrace);
      throw FailureException(failure);
    });
  }
}

/// Base class for use case parameters
/// Extends Equatable for value equality
abstract class UseCaseParams extends Equatable {
  const UseCaseParams();
}

/// Empty parameters for use cases that don't need input
class NoParams extends UseCaseParams {
  const NoParams();

  @override
  List<Object?> get props => [];
}

/// Pagination parameters
class PaginationParams extends UseCaseParams {
  final int page;
  final int size;
  final String? sort;
  final String? direction;

  const PaginationParams({
    this.page = 0,
    this.size = 20,
    this.sort,
    this.direction,
  });

  @override
  List<Object?> get props => [page, size, sort, direction];
}

/// Search parameters
class SearchParams extends UseCaseParams {
  final String query;
  final int page;
  final int size;
  final Map<String, dynamic>? filters;

  const SearchParams({
    required this.query,
    this.page = 0,
    this.size = 20,
    this.filters,
  });

  @override
  List<Object?> get props => [query, page, size, filters];
}

/// ID parameter for entity operations
class IdParams extends UseCaseParams {
  final String id;

  const IdParams({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Date range parameters
class DateRangeParams extends UseCaseParams {
  final DateTime startDate;
  final DateTime endDate;

  const DateRangeParams({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Use case result wrapper with success/failure states
class UseCaseResult<T> {
  final T? data;
  final Failure? failure;

  const UseCaseResult.success(this.data) : failure = null;
  const UseCaseResult.failure(this.failure) : data = null;

  bool get isSuccess => data != null;
  bool get isFailure => failure != null;

  /// Map result to another type
  UseCaseResult<R> map<R>(R Function(T data) mapper) {
    if (isSuccess) {
      return UseCaseResult.success(mapper(data as T));
    }
    return UseCaseResult.failure(failure);
  }

  /// Execute function based on success or failure
  R fold<R>({
    required R Function(Failure failure) onFailure,
    required R Function(T data) onSuccess,
  }) {
    if (isFailure) {
      return onFailure(failure!);
    }
    return onSuccess(data as T);
  }
}

/// Composite use case for executing multiple use cases
abstract class CompositeUseCase<TResult, Params> extends BaseUseCase<TResult, Params> {
  /// List of use cases to execute
  List<BaseUseCase> get useCases;

  /// Execute all use cases in sequence
  Future<List<dynamic>> executeAll(List<Params> paramsList) async {
    final results = <dynamic>[];

    for (int i = 0; i < useCases.length && i < paramsList.length; i++) {
      try {
        final result = await useCases[i].call(paramsList[i]);
        results.add(result);
      } catch (error) {
        results.add(error);
      }
    }

    return results;
  }

  /// Execute all use cases in parallel
  Future<List<dynamic>> executeAllParallel(List<Params> paramsList) async {
    final futures = <Future<dynamic>>[];

    for (int i = 0; i < useCases.length && i < paramsList.length; i++) {
      futures.add(useCases[i].call(paramsList[i]));
    }

    return Future.wait(futures);
  }
}

/// Transaction use case for operations that must be atomic
abstract class TransactionUseCase<TResult, Params> extends BaseUseCase<TResult, Params> {
  /// Begin transaction
  Future<void> beginTransaction();

  /// Commit transaction
  Future<void> commitTransaction();

  /// Rollback transaction
  Future<void> rollbackTransaction();

  /// Execute with transaction
  @override
  Future<TResult> execute(Params params) async {
    await beginTransaction();

    try {
      final result = await call(params);
      await commitTransaction();
      return result;
    } catch (error) {
      await rollbackTransaction();
      rethrow;
    }
  }
}