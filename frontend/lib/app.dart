import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/providers/theme_provider.dart';

/// Main application widget
/// This is separated from main.dart for better testability and organization
class EverythingApp extends ConsumerWidget {
  const EverythingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode and router from providers
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // Material Design 3 theme configuration
      theme: AppTheme.createLightTheme(),
      darkTheme: AppTheme.createDarkTheme(),
      themeMode: themeMode, // Controlled by provider

      // Router configuration
      routerConfig: router,
    );
  }
}