import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/database_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../shared/widgets/custom_card.dart';

class RestoreScreen extends ConsumerStatefulWidget {
  const RestoreScreen({super.key});

  @override
  ConsumerState<RestoreScreen> createState() => _RestoreScreenState();
}

class _RestoreScreenState extends ConsumerState<RestoreScreen> {
  bool _isRestoring = false;

  Future<void> _onRestorePressed() async {
    // 1. Clear warning confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Overwrite Local Data?'),
          ],
        ),
        content: const Text(
          'Restoring a backup will replace all your current cashbook data and settings with the contents of the backup file.\n\nAre you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cashOut,
              foregroundColor: Colors.white,
            ),
            child: const Text('Restore Backup'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isRestoring = true);

    try {
      final service = ref.read(backupRestoreServiceProvider);
      final restored = await service.pickAndRestoreBackup();

      if (restored && mounted) {
        // Refresh Riverpod stream providers
        ref.invalidate(transactionsStreamProvider);
        ref.invalidate(categoriesStreamProvider);
        ref.invalidate(dashboardProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database restored successfully!')),
        );
        Navigator.pop(context); // pop back
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restore Data', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomCard(
              backgroundColor: AppColors.cashOutBgLight,
              borderColor: AppColors.cashOut.withOpacity(0.3),
              child: Column(
                children: [
                  const Icon(Icons.warning_rounded, size: 56, color: AppColors.cashOut),
                  const SizedBox(height: 16),
                  Text(
                    'Restore Warning',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.cashOut,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Restoring a backup will completely replace all existing transactions, custom categories, and balances on this device with data from the backup file.',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRestoring ? null : _onRestorePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cashOut,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.file_open_outlined),
                label: _isRestoring
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Select Backup File to Restore', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
