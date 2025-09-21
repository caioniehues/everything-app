import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/errors/exceptions.dart';

/// Cache box names
class CacheBoxNames {
  static const String settings = 'settings';
  static const String user = 'user';
  static const String transactions = 'transactions';
  static const String categories = 'categories';
  static const String budgets = 'budgets';
  static const String goals = 'goals';
  static const String notifications = 'notifications';
  static const String temporary = 'temporary';

  // Private constructor to prevent instantiation
  const CacheBoxNames._();
}

/// Cache expiry durations
class CacheExpiry {
  static const Duration shortTerm = Duration(minutes: 5);
  static const Duration mediumTerm = Duration(minutes: 30);
  static const Duration longTerm = Duration(hours: 24);
  static const Duration permanent = Duration(days: 365);

  // Private constructor to prevent instantiation
  const CacheExpiry._();
}

/// Provider for cache service
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

/// Service for managing local cache with Hive
class CacheService {
  /// Initialize Hive and open required boxes
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Open all required boxes
    await Future.wait([
      Hive.openBox(CacheBoxNames.settings),
      Hive.openBox(CacheBoxNames.user),
      Hive.openBox(CacheBoxNames.transactions),
      Hive.openBox(CacheBoxNames.categories),
      Hive.openBox(CacheBoxNames.budgets),
      Hive.openBox(CacheBoxNames.goals),
      Hive.openBox(CacheBoxNames.notifications),
      Hive.openBox(CacheBoxNames.temporary),
    ]);
  }

  /// Get a box by name
  Box _getBox(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw CacheException(message: 'Box $boxName is not open');
    }
    return Hive.box(boxName);
  }

  /// Save data to cache with optional expiry
  Future<void> save<T>({
    required String key,
    required T data,
    String boxName = CacheBoxNames.temporary,
    Duration? expiry,
  }) async {
    try {
      final box = _getBox(boxName);

      final cacheData = CacheData<T>(
        data: data,
        timestamp: DateTime.now(),
        expiry: expiry,
      );

      await box.put(key, cacheData.toJson());
    } catch (e) {
      throw CacheException(message: 'Failed to save to cache: $e');
    }
  }

  /// Get data from cache
  T? get<T>({
    required String key,
    String boxName = CacheBoxNames.temporary,
  }) {
    try {
      final box = _getBox(boxName);
      final json = box.get(key);

      if (json == null) return null;

      final cacheData = CacheData<T>.fromJson(json);

      // Check if data has expired
      if (cacheData.isExpired) {
        box.delete(key);
        return null;
      }

      return cacheData.data;
    } catch (e) {
      throw CacheException(message: 'Failed to get from cache: $e');
    }
  }

  /// Get data or fetch if not cached
  Future<T> getOrFetch<T>({
    required String key,
    required Future<T> Function() fetchFunction,
    String boxName = CacheBoxNames.temporary,
    Duration? expiry,
  }) async {
    // Try to get from cache first
    final cached = get<T>(key: key, boxName: boxName);
    if (cached != null) {
      return cached;
    }

    // Fetch fresh data
    final freshData = await fetchFunction();

    // Save to cache
    await save<T>(
      key: key,
      data: freshData,
      boxName: boxName,
      expiry: expiry,
    );

    return freshData;
  }

  /// Delete data from cache
  Future<void> delete({
    required String key,
    String boxName = CacheBoxNames.temporary,
  }) async {
    try {
      final box = _getBox(boxName);
      await box.delete(key);
    } catch (e) {
      throw CacheException(message: 'Failed to delete from cache: $e');
    }
  }

  /// Clear entire box
  Future<void> clearBox(String boxName) async {
    try {
      final box = _getBox(boxName);
      await box.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache box: $e');
    }
  }

  /// Clear all expired data from a box
  Future<void> clearExpired(String boxName) async {
    try {
      final box = _getBox(boxName);
      final keysToDelete = <dynamic>[];

      for (final key in box.keys) {
        final json = box.get(key);
        if (json != null) {
          try {
            final cacheData = CacheData.fromJson(json);
            if (cacheData.isExpired) {
              keysToDelete.add(key);
            }
          } catch (_) {
            // If we can't parse it, delete it
            keysToDelete.add(key);
          }
        }
      }

      await box.deleteAll(keysToDelete);
    } catch (e) {
      throw CacheException(message: 'Failed to clear expired cache: $e');
    }
  }

  /// Clear all cache
  Future<void> clearAll() async {
    try {
      await Future.wait([
        clearBox(CacheBoxNames.temporary),
        clearBox(CacheBoxNames.transactions),
        clearBox(CacheBoxNames.categories),
        clearBox(CacheBoxNames.budgets),
        clearBox(CacheBoxNames.goals),
        clearBox(CacheBoxNames.notifications),
        // Don't clear settings and user boxes
      ]);
    } catch (e) {
      throw CacheException(message: 'Failed to clear all cache: $e');
    }
  }

  /// Check if key exists in cache
  bool exists({
    required String key,
    String boxName = CacheBoxNames.temporary,
  }) {
    try {
      final box = _getBox(boxName);
      return box.containsKey(key);
    } catch (e) {
      return false;
    }
  }

  /// Get cache size for a box
  int getBoxSize(String boxName) {
    try {
      final box = _getBox(boxName);
      return box.length;
    } catch (e) {
      return 0;
    }
  }
}

/// Cache data wrapper with timestamp and expiry
class CacheData<T> {
  final T data;
  final DateTime timestamp;
  final Duration? expiry;

  CacheData({
    required this.data,
    required this.timestamp,
    this.expiry,
  });

  /// Check if cache data has expired
  bool get isExpired {
    if (expiry == null) return false;

    final expiryTime = timestamp.add(expiry!);
    return DateTime.now().isAfter(expiryTime);
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'expiry': expiry?.inMilliseconds,
    };
  }

  /// Create from JSON
  factory CacheData.fromJson(Map<dynamic, dynamic> json) {
    return CacheData<T>(
      data: json['data'] as T,
      timestamp: DateTime.parse(json['timestamp'] as String),
      expiry: json['expiry'] != null
          ? Duration(milliseconds: json['expiry'] as int)
          : null,
    );
  }
}

/// Provider for cache statistics
final cacheStatsProvider = Provider<CacheStats>((ref) {
  final cache = ref.watch(cacheServiceProvider);

  return CacheStats(
    temporarySize: cache.getBoxSize(CacheBoxNames.temporary),
    transactionsSize: cache.getBoxSize(CacheBoxNames.transactions),
    categoriesSize: cache.getBoxSize(CacheBoxNames.categories),
    budgetsSize: cache.getBoxSize(CacheBoxNames.budgets),
    goalsSize: cache.getBoxSize(CacheBoxNames.goals),
    notificationsSize: cache.getBoxSize(CacheBoxNames.notifications),
  );
});

/// Cache statistics class
class CacheStats {
  final int temporarySize;
  final int transactionsSize;
  final int categoriesSize;
  final int budgetsSize;
  final int goalsSize;
  final int notificationsSize;

  const CacheStats({
    required this.temporarySize,
    required this.transactionsSize,
    required this.categoriesSize,
    required this.budgetsSize,
    required this.goalsSize,
    required this.notificationsSize,
  });

  int get totalSize =>
      temporarySize +
      transactionsSize +
      categoriesSize +
      budgetsSize +
      goalsSize +
      notificationsSize;
}

/// Provider for clearing expired cache periodically
final cacheMaintenanceProvider = Provider<CacheMaintenance>((ref) {
  final cache = ref.watch(cacheServiceProvider);
  return CacheMaintenance(cache);
});

/// Cache maintenance service
class CacheMaintenance {
  final CacheService _cacheService;

  const CacheMaintenance(this._cacheService);

  /// Run periodic cache cleanup
  Future<void> runMaintenance() async {
    // Clear expired data from all boxes
    await Future.wait([
      _cacheService.clearExpired(CacheBoxNames.temporary),
      _cacheService.clearExpired(CacheBoxNames.transactions),
      _cacheService.clearExpired(CacheBoxNames.categories),
      _cacheService.clearExpired(CacheBoxNames.budgets),
      _cacheService.clearExpired(CacheBoxNames.goals),
      _cacheService.clearExpired(CacheBoxNames.notifications),
    ]);
  }
}