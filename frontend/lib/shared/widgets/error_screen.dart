import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/router/route_paths.dart';

/// Error screen for 404 and other navigation errors
class ErrorScreen extends StatelessWidget {
  final String? errorMessage;
  final String? errorCode;

  const ErrorScreen({
    super.key,
    this.errorMessage,
    this.errorCode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 120,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                errorCode ?? '404',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage ?? 'Page Not Found',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'The page you are looking for might have been removed, had its name changed, or is temporarily unavailable.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.go(RoutePaths.dashboard),
                icon: const Icon(Icons.home),
                label: const Text('Go to Dashboard'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text(AppStrings.back),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Specific 404 Not Found screen
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ErrorScreen(
      errorCode: '404',
      errorMessage: 'Page Not Found',
    );
  }
}

/// Generic error screen for other errors
class GenericErrorScreen extends StatelessWidget {
  final String? message;

  const GenericErrorScreen({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorScreen(
      errorCode: 'Error',
      errorMessage: message ?? AppStrings.somethingWentWrong,
    );
  }
}