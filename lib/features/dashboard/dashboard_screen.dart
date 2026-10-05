import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/transaction_type.dart';
import '../../app/routes.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/account_provider.dart';
import '../../shared/widgets/empty_state.dart';
import 'widgets/balance_card.dart';
import 'widgets/quick_stats_card.dart';
import '../transactions/widgets/transaction_tile.dart';

class DashboardScreen extends ConsumerWidget {
  final VoidCallback onViewAllTap;

  const DashboardScreen({super.key, required this.onViewAllTap});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dashboardData = ref.watch(dashboardProvider);
    final activeAccount = ref.watch(activeAccountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.account_balance_wallet, size: 28),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal),
                ),
                const Text(
                  'Daily Cashbook',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_accounts_outlined),
            tooltip: 'Customer Accounts',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.accounts),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About & Privacy',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.about),
          ),
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'App Lock',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.pin),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.backup),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(dashboardProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Account / User Switcher Banner
              InkWell(
                onTap: () => Navigator.pushNamed(context, AppRoutes.accounts),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: AppColors.primary,
                        child: const Icon(Icons.person, size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ACTIVE CUSTOMER ACCOUNT',
                              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                            Text(
                              activeAccount?.name ?? 'Aviral',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Switch',
                              style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.unfold_more, size: 16, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Current Balance Card
              BalanceCard(summary: dashboardData.summary),
              const SizedBox(height: 16),

              // Today's Activity Quick Stats
              QuickStatsCard(
                todayInPaisa: dashboardData.todayCashInPaisa,
                todayOutPaisa: dashboardData.todayCashOutPaisa,
                todayNetPaisa: dashboardData.todayNetPaisa,
              ),
              const SizedBox(height: 20),

              // Quick Action Buttons Row: [ + Cash In ]  [ - Cash Out ]
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.addTransaction,
                          arguments: {'initialType': TransactionType.cashIn},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cashIn,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.add_circle, size: 20),
                      label: const Text(
                        'Cash In',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.addTransaction,
                          arguments: {'initialType': TransactionType.cashOut},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cashOut,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.remove_circle, size: 20),
                      label: const Text(
                        'Cash Out',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: onViewAllTap,
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Recent Transactions List
              if (dashboardData.recentTransactions.isEmpty)
                EmptyState(
                  title: 'No transactions yet',
                  description: 'Tap + Cash In or - Cash Out to start.',
                  buttonLabel: 'Add First Entry',
                  onButtonPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.addTransaction,
                      arguments: {'initialType': TransactionType.cashIn},
                    );
                  },
                )
              else
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dashboardData.recentTransactions.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    ),
                    itemBuilder: (context, index) {
                      final tx = dashboardData.recentTransactions[index];
                      return TransactionTile(transaction: tx);
                    },
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
