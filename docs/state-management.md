# State Management Architecture

## Overview

The Everything App uses **Riverpod 2.0** as its state management solution, following clean architecture principles with a provider-based reactive pattern.

## Architecture Layers

```
┌──────────────────────────────────────────────────┐
│             Presentation Layer                   │
│         (ConsumerWidgets & UI)                   │
└────────────────┬─────────────────────────────────┘
                 │ watches/reads
┌────────────────▼─────────────────────────────────┐
│             Provider Layer                       │
│     (State Providers & Notifiers)               │
└────────────────┬─────────────────────────────────┘
                 │ uses
┌────────────────▼─────────────────────────────────┐
│           Application Layer                      │
│         (Use Cases & Services)                   │
└────────────────┬─────────────────────────────────┘
                 │ calls
┌────────────────▼─────────────────────────────────┐
│            Domain Layer                          │
│      (Entities & Repositories)                   │
└──────────────────────────────────────────────────┘
```

## Core Providers

### 1. Theme Provider
**Location**: `/lib/shared/providers/theme_provider.dart`

Manages app theme with persistence to SharedPreferences.

```dart
// Usage in widgets
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = ref.watch(themeModeProvider.notifier).isDarkMode;

    // Change theme
    ref.read(themeModeProvider.notifier).toggleTheme();
  }
}
```

**Key Features**:
- Persistent theme storage
- System theme detection
- Theme toggle functionality
- Reactive theme updates

### 2. Authentication Provider
**Location**: `/lib/shared/providers/auth_provider.dart`

Manages authentication state with secure token storage.

```dart
// Usage example
class AuthScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return switch (authState) {
      AuthLoading() => CircularProgressIndicator(),
      AuthAuthenticated(:final email) => Text('Welcome $email'),
      AuthUnauthenticated() => LoginForm(),
      AuthError(:final failure) => ErrorWidget(failure),
    };
  }
}
```

**State Types**:
- `AuthInitial`: App startup state
- `AuthLoading`: During auth operations
- `AuthAuthenticated`: User logged in with tokens
- `AuthUnauthenticated`: No active session
- `AuthError`: Auth operation failed

**Token Management**:
- 15-minute access token expiry
- 7-day refresh token
- Automatic token refresh logic
- Secure storage with flutter_secure_storage

### 3. Connectivity Provider
**Location**: `/lib/shared/providers/connectivity_provider.dart`

Monitors network connectivity status.

```dart
// Usage example
class NetworkAwareWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    if (!isOnline) {
      return OfflineBanner();
    }

    return OnlineContent();
  }
}
```

**Features**:
- Real-time connectivity monitoring
- Network-aware operation support
- Retry logic for offline scenarios
- Connectivity interceptor for API calls

### 4. Cache Provider
**Location**: `/lib/shared/providers/cache_provider.dart`

Manages local data caching with Hive.

```dart
// Usage example
final cache = ref.read(cacheServiceProvider);

// Save with expiry
await cache.save(
  key: 'user_profile',
  data: userProfile,
  boxName: CacheBoxNames.user,
  expiry: CacheExpiry.mediumTerm,
);

// Get or fetch pattern
final data = await cache.getOrFetch(
  key: 'transactions',
  fetchFunction: () => apiService.getTransactions(),
  expiry: CacheExpiry.shortTerm,
);
```

**Cache Boxes**:
- `settings`: App configuration
- `user`: User profile data
- `transactions`: Financial transactions
- `categories`: Transaction categories
- `budgets`: Budget information
- `goals`: Financial goals
- `notifications`: Push notifications
- `temporary`: Short-lived cache

## Provider Patterns

### 1. State Notifier Pattern
For complex state management with business logic:

```dart
final myFeatureProvider = StateNotifierProvider<MyFeatureNotifier, MyFeatureState>((ref) {
  return MyFeatureNotifier(ref);
});

class MyFeatureNotifier extends StateNotifier<MyFeatureState> {
  final Ref _ref;

  MyFeatureNotifier(this._ref) : super(MyFeatureInitial());

  Future<void> performAction() async {
    state = MyFeatureLoading();
    try {
      final result = await _ref.read(apiServiceProvider).fetchData();
      state = MyFeatureSuccess(result);
    } catch (e) {
      state = MyFeatureError(e.toString());
    }
  }
}
```

### 2. Provider Composition
Combining multiple providers:

```dart
final compositeProvider = Provider((ref) {
  final auth = ref.watch(authStateProvider);
  final connectivity = ref.watch(connectivityProvider);

  if (auth is! AuthAuthenticated) return false;
  if (connectivity == ConnectivityStatus.offline) return false;

  return true;
});
```

### 3. Family Providers
For parameterized providers:

```dart
final userProvider = FutureProvider.family<User, String>((ref, userId) async {
  final api = ref.read(apiServiceProvider);
  return api.getUser(userId);
});

// Usage
final user = ref.watch(userProvider('user123'));
```

### 4. Auto-Dispose Providers
For cleanup when no longer needed:

```dart
final searchProvider = StateProvider.autoDispose<String>((ref) {
  // Automatically disposed when no widgets are watching
  return '';
});
```

## Code Generation

### Setup
The project uses Riverpod Generator for type-safe providers:

```dart
// Example with @riverpod annotation
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_provider.g.dart';

@riverpod
Future<List<Transaction>> transactions(TransactionsRef ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getTransactions();
}
```

### Running Code Generation
```bash
cd frontend
flutter pub run build_runner build --delete-conflicting-outputs
```

### Watch Mode
```bash
cd frontend
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Testing Providers

### Test Helpers
Located at `/test/helpers/provider_helpers.dart`

```dart
// Simple provider test
runProviderTest('should update state', (container) async {
  final notifier = container.read(myProvider.notifier);

  await notifier.updateState();

  expect(container.read(myProvider), expectedState);
});
```

### Mocking Providers
```dart
testWidgets('widget test with mock provider', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith(() => MockAuthNotifier()),
      ],
      child: MyApp(),
    ),
  );

  // Test widget behavior
});
```

## Best Practices

### 1. Provider Naming
- Use descriptive names ending with `Provider`
- Group related providers in the same file
- Export providers from a barrel file

### 2. State Management
- Keep state classes immutable
- Use sealed classes for state variants
- Implement copyWith for state updates
- Use Equatable or Freezed for equality

### 3. Performance
- Use `ref.watch` only when UI needs to rebuild
- Use `ref.read` for one-time reads
- Use `ref.listen` for side effects
- Implement proper disposal logic

### 4. Error Handling
- Always handle loading and error states
- Use custom Failure classes
- Provide user-friendly error messages
- Implement retry mechanisms

### 5. Testing
- Test providers in isolation
- Mock external dependencies
- Verify state transitions
- Test error scenarios

## Provider Observer

The app uses a custom `ProviderObserver` for debugging:

```dart
// Automatically logs all provider lifecycle events in debug mode
class AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(provider, previousValue, newValue, container) {
    debugPrint('[Provider Updated] ${provider.name}: $newValue');
  }
}
```

## Migration Guide

### From setState to Riverpod
```dart
// Before (setState)
class _MyWidgetState extends State<MyWidget> {
  bool _isLoading = false;

  void _loadData() {
    setState(() => _isLoading = true);
    // Load data...
    setState(() => _isLoading = false);
  }
}

// After (Riverpod)
final isLoadingProvider = StateProvider<bool>((ref) => false);

class MyWidget extends ConsumerWidget {
  void _loadData(WidgetRef ref) {
    ref.read(isLoadingProvider.notifier).state = true;
    // Load data...
    ref.read(isLoadingProvider.notifier).state = false;
  }
}
```

## Common Patterns

### 1. Initialization Pattern
```dart
// In main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await AppConfig.initialize();
  await CacheService.initialize();

  runApp(ProviderScope(
    observers: [AppProviderObserver()],
    child: EverythingApp(),
  ));
}
```

### 2. Auth Guard Pattern
```dart
final authGuardProvider = Provider<bool>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth is AuthAuthenticated && !auth.isTokenExpired;
});
```

### 3. Cache-First Pattern
```dart
final dataProvider = FutureProvider<Data>((ref) async {
  final cache = ref.read(cacheServiceProvider);

  return cache.getOrFetch(
    key: 'data_key',
    fetchFunction: () => ref.read(apiServiceProvider).getData(),
    expiry: Duration(minutes: 30),
  );
});
```

## Troubleshooting

### Common Issues

1. **Provider not updating**
   - Ensure using `ref.watch` not `ref.read`
   - Check if state is actually changing
   - Verify provider is not disposed

2. **Circular dependencies**
   - Avoid providers depending on each other circularly
   - Use `ref.read` for one-time dependencies

3. **Memory leaks**
   - Use `.autoDispose` for temporary providers
   - Properly dispose StreamSubscriptions
   - Clean up in `dispose()` methods

4. **Test failures**
   - Mock SharedPreferences and SecureStorage
   - Override providers in tests
   - Use `container.dispose()` in tearDown

---

Last Updated: 21/09/2025 06:28:55