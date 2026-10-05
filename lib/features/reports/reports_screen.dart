import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/date_filter.dart';
import '../../core/services/csv_export_service.dart';
import '../../core/services/pdf_export_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/report_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../shared/widgets/custom_card.dart';
import 'widgets/cash_flow_chart.dart';
import 'widgets/category_pie_chart.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateFilterOption _period = DateFilterOption.thisMonth;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionFilterProvider.notifier).setDateFilter(DateFilterOption.thisMonth);
    });
  }

  void _onPeriodChanged(DateFilterOption option) {
    setState(() => _period = option);
    if (option == DateFilterOption.custom) {
      _selectCustomDateRange();
    } else {
      ref.read(transactionFilterProvider.notifier).setDateFilter(option);
    }
  }

  Future<void> _selectCustomDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    );

    if (range != null) {
      ref.read(transactionFilterProvider.notifier).setDateFilter(
        DateFilterOption.custom,
        start: range.start,
        end: range.end,
      );
    }
  }

  Future<void> _exportPdf(ReportData report) async {
    setState(() => _isExporting = true);
    try {
      await PdfExportService.exportAndSharePdf(
        transactions: report.periodTransactions,
        summary: report.summary,
        periodText: _period.label,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF Export error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportCsv(ReportData report) async {
    setState(() => _isExporting = true);
    try {
      await CsvExportService.exportAndShareCsv(report.periodTransactions);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV Export error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final report = ref.watch(reportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export PDF',
            onPressed: _isExporting ? null : () => _exportPdf(report),
          ),
          IconButton(
            icon: const Icon(Icons.table_chart_outlined),
            tooltip: 'Export CSV',
            onPressed: _isExporting ? null : () => _exportCsv(report),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPeriodChip(DateFilterOption.today, 'Daily'),
                  const SizedBox(width: 8),
                  _buildPeriodChip(DateFilterOption.thisWeek, 'Weekly'),
                  const SizedBox(width: 8),
                  _buildPeriodChip(DateFilterOption.thisMonth, 'Monthly'),
                  const SizedBox(width: 8),
                  _buildPeriodChip(DateFilterOption.all, 'All Time'),
                  const SizedBox(width: 8),
                  _buildPeriodChip(DateFilterOption.custom, 'Custom'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Summary Metrics Card
            CustomCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _metricBox(
                        'Total Cash In',
                        report.summary.formattedTotalCashIn,
                        AppColors.cashIn,
                      ),
                      _metricBox(
                        'Total Cash Out',
                        report.summary.formattedTotalCashOut,
                        AppColors.cashOut,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _metricBox(
                        'Net Movement',
                        report.summary.formattedNetMovement,
                        report.summary.netMovementPaisa >= 0 ? AppColors.cashIn : AppColors.cashOut,
                      ),
                      _metricBox(
                        'Avg Transaction',
                        CurrencyFormatter.formatPaisa(report.summary.averageTransactionPaisa.toInt()),
                        AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Highlights Card (Highest Expense & Highest Income Category)
            CustomCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Top Expense', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          report.summary.topExpenseCategory ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (report.summary.topExpenseAmountPaisa > 0)
                          Text(
                            CurrencyFormatter.formatPaisa(report.summary.topExpenseAmountPaisa),
                            style: const TextStyle(fontSize: 12, color: AppColors.cashOut),
                          ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Top Income', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          report.summary.topIncomeCategory ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (report.summary.topIncomeAmountPaisa > 0)
                          Text(
                            CurrencyFormatter.formatPaisa(report.summary.topIncomeAmountPaisa),
                            style: const TextStyle(fontSize: 12, color: AppColors.cashIn),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cash Flow Chart Section
            Text(
              'Cash Flow Over Time',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CustomCard(
              child: CashFlowChart(transactions: report.periodTransactions),
            ),
            const SizedBox(height: 24),

            // Category Distribution Section
            Text(
              'Category Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CustomCard(
              child: CategoryPieChart(
                title: 'Expense Categories',
                categories: report.expenseCategories,
              ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: CategoryPieChart(
                title: 'Income Categories',
                categories: report.incomeCategories,
              ),
            ),
            const SizedBox(height: 24),

            // Export Actions Bottom Bar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isExporting ? null : () => _exportCsv(report),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Export CSV'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : () => _exportPdf(report),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export PDF'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(DateFilterOption option, String label) {
    final isSelected = _period == option;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) _onPeriodChanged(option);
      },
    );
  }

  Widget _metricBox(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
