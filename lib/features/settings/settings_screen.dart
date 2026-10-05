import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/app_theme_mode.dart';
import '../../providers/settings_provider.dart';
import '../../providers/report_provider.dart';
import '../../core/services/csv_export_service.dart';
import '../../core/services/pdf_export_service.dart';
import '../../app/routes.dart';
import '../../shared/widgets/custom_card.dart';

class CurrencyOption {
  final String code;
  final String name;
  final String symbol;

  const CurrencyOption({required this.code, required this.name, required this.symbol});
}

const List<CurrencyOption> supportedCurrencies = [
  CurrencyOption(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
  CurrencyOption(code: 'USD', name: 'US Dollar', symbol: '\$'),
  CurrencyOption(code: 'EUR', name: 'Euro', symbol: '€'),
  CurrencyOption(code: 'GBP', name: 'British Pound', symbol: '£'),
  CurrencyOption(code: 'AED', name: 'UAE Dirham', symbol: 'AED'),
  CurrencyOption(code: 'CAD', name: 'Canadian Dollar', symbol: 'CA\$'),
  CurrencyOption(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$'),
  CurrencyOption(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
  CurrencyOption(code: 'PKR', name: 'Pakistani Rupee', symbol: 'Rs'),
  CurrencyOption(code: 'BDT', name: 'Bangladeshi Taka', symbol: '৳'),
  CurrencyOption(code: 'PHP', name: 'Philippine Peso', symbol: '₱'),
  CurrencyOption(code: 'SAR', name: 'Saudi Riyal', symbol: 'SAR'),
  CurrencyOption(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$'),
  CurrencyOption(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM'),
];

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showCurrencySelectorDialog(BuildContext context, WidgetRef ref) {
    final currentSymbol = ref.read(currencySymbolProvider);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Select Default Currency', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: ListView.separated(
              itemCount: supportedCurrencies.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final curr = supportedCurrencies[index];
                final isSelected = curr.symbol == currentSymbol;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? AppColors.primary : Colors.grey.shade200,
                    child: Text(
                      curr.symbol,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  title: Text('${curr.symbol} ${curr.code}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(curr.name, style: const TextStyle(fontSize: 12)),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                  onTap: () {
                    ref.read(currencySymbolProvider.notifier).setCurrencySymbol(curr.symbol);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Default currency updated to ${curr.symbol} (${curr.name})')),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showThemeSelectorDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) {
        final currentTheme = ref.read(themeModeProvider);
        return SimpleDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Choose Appearance'),
          children: AppThemeMode.values.map((mode) {
            bool isSelected = false;
            if (mode == AppThemeMode.light && currentTheme == ThemeMode.light) isSelected = true;
            if (mode == AppThemeMode.dark && currentTheme == ThemeMode.dark) isSelected = true;
            if (mode == AppThemeMode.system && currentTheme == ThemeMode.system) isSelected = true;

            return SimpleDialogOption(
              onPressed: () {
                ref.read(themeModeProvider.notifier).setThemeMode(mode);
                Navigator.pop(ctx);
              },
              child: Row(
                children: [
                  Icon(
                    mode == AppThemeMode.light
                        ? Icons.light_mode_outlined
                        : (mode == AppThemeMode.dark ? Icons.dark_mode_outlined : Icons.settings_brightness_outlined),
                    color: isSelected ? AppColors.primary : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      mode.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : null,
                      ),
                    ),
                  ),
                  if (isSelected) const Icon(Icons.check, color: AppColors.primary),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.account_balance_wallet, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Daily Cashbook'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text(
              'Daily Cashbook is an offline-first financial ledger built specifically for speed, simplicity, and total data privacy.\n\nAll your transaction records remain strictly stored on your local device SQLite database.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentSymbol = ref.watch(currencySymbolProvider);
    final activeCurrency = supportedCurrencies.firstWhere(
      (c) => c.symbol == currentSymbol,
      orElse: () => CurrencyOption(code: '', name: 'Custom Currency', symbol: currentSymbol),
    );
    final report = ref.watch(reportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: Appearance & Currency
          _sectionHeader('Appearance & Currency'),
          CustomCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined, color: AppColors.primary),
                  title: const Text('Theme / Appearance'),
                  subtitle: Text(
                    ref.watch(themeModeProvider) == ThemeMode.light
                        ? 'Light Mode'
                        : (ref.watch(themeModeProvider) == ThemeMode.dark ? 'Dark Mode' : 'System Default'),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeSelectorDialog(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.currency_exchange, color: AppColors.primary),
                  title: const Text('Default Currency'),
                  subtitle: Text('${activeCurrency.symbol} ${activeCurrency.code} (${activeCurrency.name})'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showCurrencySelectorDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 3: Categories & Customization
          _sectionHeader('Categories & Customization'),
          CustomCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.category_outlined, color: AppColors.primary),
              title: const Text('Manage Categories'),
              subtitle: const Text('Add or view custom cash income/expense categories'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, AppRoutes.categories),
            ),
          ),
          const SizedBox(height: 20),

          // Section 4: Data & Backup
          _sectionHeader('Data & Backup'),
          CustomCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup_outlined, color: AppColors.primary),
                  title: const Text('Create Local Backup'),
                  subtitle: const Text('Export JSON backup file to device or cloud storage'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.backup),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore_outlined, color: AppColors.primary),
                  title: const Text('Restore Data'),
                  subtitle: const Text('Import backup file to restore transaction history'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.restore),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.table_chart_outlined, color: AppColors.primary),
                  title: const Text('Export to CSV'),
                  onTap: () async {
                    await CsvExportService.exportAndShareCsv(report.periodTransactions);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
                  title: const Text('Export PDF Report'),
                  onTap: () async {
                    await PdfExportService.exportAndSharePdf(
                      transactions: report.periodTransactions,
                      summary: report.summary,
                      periodText: 'Complete Ledger Export',
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 5: About & Privacy
          _sectionHeader('About & Privacy'),
          CustomCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.primary),
                  title: const Text('About & Privacy'),
                  subtitle: const Text('Developer info, contact & app details'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.shield_outlined, color: Colors.green),
                  title: const Text('Privacy Policy'),
                  subtitle: const Text('Read full data safety practices'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.privacyPolicy),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
