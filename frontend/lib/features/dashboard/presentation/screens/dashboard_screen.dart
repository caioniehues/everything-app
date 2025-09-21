import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../shared/widgets/adaptive_scaffold.dart';
import '../../../../shared/widgets/responsive_builder.dart';

/// Dashboard screen with adaptive layout for different screen sizes
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveScaffold(
      title: AppStrings.dashboard,
      destinations: AppNavigationDestinations.main,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => context.go(RoutePaths.settings),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            // TODO: Implement logout logic
            context.go(RoutePaths.login);
          },
        ),
      ],
      body: AdaptivePage(
        centerContent: true,
        child: _buildDashboardContent(context),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final theme = Theme.of(context);

    return ResponsiveBuilder(
      builder: (context, screenSize) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            AdaptiveContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.waving_hand,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Welcome to Everything App!',
                          style: theme.textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your family finances with comprehensive tools and insights.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Quick Actions
            Text(
              'Quick Actions',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ResponsiveGrid(
                mobileColumns: 1,
                tabletColumns: 2,
                desktopColumns: 3,
                spacing: 16,
                runSpacing: 16,
                childAspectRatio: ResponsiveUtils.getCardAspectRatio(context),
                children: [
                  _QuickActionCard(
                    icon: Icons.account_balance_wallet_outlined,
                    selectedIcon: Icons.account_balance_wallet,
                    title: AppStrings.accounts,
                    subtitle: 'Manage your accounts',
                    color: const Color(0xFF4CAF50),
                    onTap: () => context.go(RoutePaths.accounts),
                  ),
                  _QuickActionCard(
                    icon: Icons.receipt_long_outlined,
                    selectedIcon: Icons.receipt_long,
                    title: AppStrings.transactions,
                    subtitle: 'View transactions',
                    color: const Color(0xFF2196F3),
                    onTap: () => context.go(RoutePaths.transactions),
                  ),
                  _QuickActionCard(
                    icon: Icons.pie_chart_outline,
                    selectedIcon: Icons.pie_chart,
                    title: AppStrings.budgets,
                    subtitle: 'Track your budgets',
                    color: const Color(0xFFFF9800),
                    onTap: () => context.go(RoutePaths.budgets),
                  ),
                  _QuickActionCard(
                    icon: Icons.trending_up_outlined,
                    selectedIcon: Icons.trending_up,
                    title: AppStrings.goals,
                    subtitle: 'Financial goals',
                    color: const Color(0xFF9C27B0),
                    onTap: () => context.go(RoutePaths.goals),
                  ),
                  _QuickActionCard(
                    icon: Icons.analytics_outlined,
                    selectedIcon: Icons.analytics,
                    title: 'Reports',
                    subtitle: 'View insights and reports',
                    color: const Color(0xFFE91E63),
                    onTap: () => context.go(RoutePaths.reports),
                  ),
                  _QuickActionCard(
                    icon: Icons.family_restroom_outlined,
                    selectedIcon: Icons.family_restroom,
                    title: 'Family',
                    subtitle: 'Manage family members',
                    color: const Color(0xFF795548),
                    onTap: () => context.go(RoutePaths.family),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title, required this.subtitle, required this.color, required this.onTap, this.selectedIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AdaptiveContainer(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}