import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/transaction_model.dart';
import '../../providers/database_provider.dart';
import '../../app/routes.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Transaction?'),
          content: const Text('Are you sure you want to delete this transaction record? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final repo = ref.read(transactionRepositoryProvider);
                await repo.deleteTransaction(transaction.id);
                if (ctx.mounted) Navigator.pop(ctx); // pop dialog
                if (context.mounted) Navigator.pop(context); // pop detail screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cashOut,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCashIn = transaction.isCashIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.addTransaction,
                arguments: {'transaction': transaction},
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.cashOut),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Amount Card Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isCashIn
                    ? (isDark ? AppColors.cashInBgDark : AppColors.cashInBgLight)
                    : (isDark ? AppColors.cashOutBgDark : AppColors.cashOutBgLight),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCashIn ? AppColors.cashIn.withOpacity(0.3) : AppColors.cashOut.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCashIn ? AppColors.cashIn : AppColors.cashOut,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      transaction.type.label.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${isCashIn ? "+ " : "- "}${transaction.formattedAmount}',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isCashIn ? AppColors.cashIn : AppColors.cashOut,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Detail Fields Group Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      label: 'Party Name',
                      value: transaction.partyName?.isNotEmpty == true ? transaction.partyName! : 'None',
                      icon: Icons.person_outline,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      context,
                      label: 'Category',
                      value: transaction.categoryName ?? 'Uncategorized',
                      icon: transaction.categoryIcon ?? Icons.category_outlined,
                      iconColor: transaction.categoryColor,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      context,
                      label: 'Date & Time',
                      value: DateFormatter.formatDateTime(transaction.transactionDate),
                      icon: Icons.calendar_today_outlined,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      context,
                      label: 'Description / Remarks',
                      value: transaction.description?.isNotEmpty == true ? transaction.description! : 'No remarks',
                      icon: Icons.notes_outlined,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      context,
                      label: 'Created At',
                      value: DateFormatter.formatDateTime(transaction.createdAt),
                      icon: Icons.access_time_outlined,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Edit & Delete Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.addTransaction,
                        arguments: {'transaction': transaction},
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Entry'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmDelete(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cashOut,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Entry'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor ?? AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
