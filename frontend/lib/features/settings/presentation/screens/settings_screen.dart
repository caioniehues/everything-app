import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../shared/providers/theme_provider.dart';

/// Temporary settings screen for navigation testing
/// This will be replaced with the actual settings implementation
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RoutePaths.dashboard),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Section
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.palette),
                  title: Text(AppStrings.appearanceSettings),
                  subtitle: Text('Customize app appearance'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text(AppStrings.darkMode),
                  subtitle: Text(_getThemeModeDescription(themeMode)),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeMode,
                    onChanged: (ThemeMode? newMode) {
                      if (newMode != null) {
                        themeNotifier.setThemeMode(newMode);
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text(AppStrings.systemDefault),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text(AppStrings.lightMode),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text(AppStrings.darkMode),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Account Section
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text(AppStrings.accountSettings),
                  subtitle: const Text('Manage your account'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(RoutePaths.settingsAccount),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text(AppStrings.profile),
                  subtitle: const Text('Edit profile information'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(RoutePaths.profile),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Security Section
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text(AppStrings.securitySettings),
                  subtitle: const Text('Privacy and security'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(RoutePaths.settingsSecurity),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text(AppStrings.notificationSettings),
                  subtitle: const Text('Manage notifications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(RoutePaths.settingsNotifications),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // App Section
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text(AppStrings.about),
                  subtitle: const Text('App version and info'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: AppStrings.appName,
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2025 Everything App',
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            'Family financial management platform built with Flutter.',
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text(AppStrings.help),
                  subtitle: const Text('Get help and support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help section coming soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Logout Section
          Card(
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                AppStrings.logout,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              subtitle: const Text('Sign out of your account'),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getThemeModeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Follow system setting';
      case ThemeMode.light:
        return 'Light theme';
      case ThemeMode.dark:
        return 'Dark theme';
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text(AppStrings.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement actual logout logic
              context.go(RoutePaths.login);
            },
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }
}