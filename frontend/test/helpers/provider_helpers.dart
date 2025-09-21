import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates a ProviderContainer for testing with optional overrides
ProviderContainer createContainer({
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(
    overrides: overrides,
  );
  addTearDown(container.dispose);
  return container;
}

/// Creates a widget for testing with providers
Widget createTestWidget({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: child,
    ),
  );
}

/// Helper to test notifier providers
class NotifierTest<N extends Notifier<T>, T> {
  final ProviderContainer container;
  final NotifierProvider<N, T> provider;

  NotifierTest({
    required this.container,
    required this.provider,
  });

  /// Get current state
  T get state => container.read(provider);

  /// Get the notifier
  N get notifier => container.read(provider.notifier);

  /// Listen to state changes
  void listen(void Function(T? previous, T next) listener) {
    container.listen(provider, listener, fireImmediately: true);
  }

  /// Verify state matches expected
  void expectState(T expected) {
    expect(state, equals(expected));
  }

  /// Verify state type
  void expectStateType<S>() {
    expect(state, isA<S>());
  }
}

/// Test helper for async providers
class AsyncProviderTest<T> {
  final ProviderContainer container;
  final FutureProvider<T> provider;

  AsyncProviderTest({
    required this.container,
    required this.provider,
  });

  /// Get current async value
  AsyncValue<T> get state => container.read(provider);

  /// Wait for loading to complete
  Future<T> waitForData() async {
    while (state.isLoading) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    return state.when(
      data: (data) => data,
      loading: () => throw StateError('Still loading'),
      error: (error, stack) => throw error,
    );
  }

  /// Expect loading state
  void expectLoading() {
    expect(state.isLoading, isTrue);
  }

  /// Expect data state with value
  void expectData(T expected) {
    expect(state.hasValue, isTrue);
    expect(state.value, equals(expected));
  }

  /// Expect error state
  void expectError() {
    expect(state.hasError, isTrue);
  }
}

/// Mock override helper
class MockProviderOverride<T> {
  final Provider<T> provider;
  final T value;

  MockProviderOverride({
    required this.provider,
    required this.value,
  });

  Override get override => provider.overrideWithValue(value);
}

/// Helper to run provider tests with automatic cleanup
Future<void> runProviderTest<T>(
  String description,
  Future<void> Function(ProviderContainer container) test, {
  List<Override> overrides = const [],
}) async {
  testWidgets(description, (tester) async {
    final container = createContainer(overrides: overrides);
    await test(container);
  });
}

/// Helper for testing widgets with providers
Future<void> runWidgetProviderTest(
  String description,
  Future<void> Function(WidgetTester tester, ProviderContainer container) test, {
  required Widget widget, List<Override> overrides = const [],
}) async {
  testWidgets(description, (tester) async {
    final container = createContainer(overrides: overrides);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: widget),
      ),
    );

    await test(tester, container);
  });
}