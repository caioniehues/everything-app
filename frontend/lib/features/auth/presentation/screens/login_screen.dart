import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_paths.dart';

/// Temporary login screen for navigation testing
/// This will be replaced with the actual login implementation
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.login),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.welcomeBack,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'This is a placeholder login screen for navigation testing.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    // TODO: Implement actual login logic
                    // For now, just navigate to dashboard
                    context.go(RoutePaths.dashboard);
                  },
                  child: const Text(AppStrings.signIn),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.go(RoutePaths.register);
                  },
                  child: const Text(AppStrings.createAccount),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  context.go(RoutePaths.forgotPassword);
                },
                child: const Text(AppStrings.forgotPassword),
              ),
            ],
          ),
        ),
      ),
    );
  }
}