import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity state enum
enum ConnectivityStatus {
  online,
  offline,
  checking,
}

/// Provider for monitoring network connectivity
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
  return ConnectivityNotifier();
});

/// State notifier for connectivity management
class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  late final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ConnectivityNotifier() : super(ConnectivityStatus.checking) {
    _connectivity = Connectivity();
    _initConnectivity();
    _monitorConnectivity();
  }

  /// Initialize connectivity check
  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      state = ConnectivityStatus.offline;
    }
  }

  /// Monitor connectivity changes
  void _monitorConnectivity() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
      onError: (error) {
        state = ConnectivityStatus.offline;
      },
    );
  }

  /// Update connection status based on connectivity results
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      state = ConnectivityStatus.offline;
    } else {
      state = ConnectivityStatus.online;
    }
  }

  /// Check if currently online
  bool get isOnline => state == ConnectivityStatus.online;

  /// Check if currently offline
  bool get isOffline => state == ConnectivityStatus.offline;

  /// Manually refresh connectivity status
  Future<void> checkConnectivity() async {
    state = ConnectivityStatus.checking;
    await _initConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

/// Provider for checking if app is online
final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity == ConnectivityStatus.online;
});

/// Provider for checking if app is offline
final isOfflineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity == ConnectivityStatus.offline;
});

/// Provider for connectivity message
final connectivityMessageProvider = Provider<String>((ref) {
  final connectivity = ref.watch(connectivityProvider);

  switch (connectivity) {
    case ConnectivityStatus.online:
      return 'Connected to the internet';
    case ConnectivityStatus.offline:
      return 'No internet connection';
    case ConnectivityStatus.checking:
      return 'Checking connectivity...';
  }
});

/// Provider for network-aware operations
/// Use this to wrap API calls that should only execute when online
final networkAwareProvider = Provider.family<bool, bool>((ref, requireNetwork) {
  if (!requireNetwork) return true;

  final isOnline = ref.watch(isOnlineProvider);
  return isOnline;
});

/// Connectivity interceptor data class
/// Use with API client to handle offline scenarios
class ConnectivityInterceptorData {
  final bool isOnline;
  final bool shouldRetry;
  final Duration retryDelay;

  const ConnectivityInterceptorData({
    required this.isOnline,
    this.shouldRetry = false,
    this.retryDelay = const Duration(seconds: 3),
  });
}

/// Provider for connectivity interceptor data
/// Use this with Dio interceptor for automatic retry logic
final connectivityInterceptorProvider = Provider<ConnectivityInterceptorData>((ref) {
  final isOnline = ref.watch(isOnlineProvider);

  return ConnectivityInterceptorData(
    isOnline: isOnline,
    shouldRetry: !isOnline,
  );
});