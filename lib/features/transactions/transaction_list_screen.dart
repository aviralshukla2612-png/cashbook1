import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../app/routes.dart';
import '../../shared/widgets/empty_state.dart';
import 'widgets/transaction_tile.dart';
import 'widgets/transaction_filter_sheet.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<TransactionModel>> _groupTransactionsByDate(List<TransactionModel> list) {
    final Map<String, List<TransactionModel>> grouped = {};
    for (final tx in list) {
      final key = DateFormatter.formatHeaderDate(tx.transactionDate);
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(tx);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredTransactions = ref.watch(filteredTransactionsProvider);
    final dashboardData = ref.watch(dashboardProvider);
    final filterState = ref.watch(transactionFilterProvider);

    final groupedMap = _groupTransactionsByDate(filteredTransactions);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search transactions...',
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  ref.read(transactionFilterProvider.notifier).setSearchQuery(val);
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cashbook Ledger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(
                    DateFormatter.formatMonthYear(DateTime.now()),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  ref.read(transactionFilterProvider.notifier).setSearchQuery('');
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => const TransactionFilterSheet(),
                  );
                },
              ),
              if (filterState.selectedType != null ||
                  filterState.selectedCategoryId != null ||
                  filterState.dateFilter.name != 'all')
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Header summary bar (Opening & Closing balance)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Opening Balance', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(
                      dashboardData.summary.formattedOpeningBalance,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Closing Balance', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(
                      dashboardData.summary.formattedClosingBalance,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Transaction List
          Expanded(
            child: filteredTransactions.isEmpty
                ? EmptyState(
                    title: 'No cash entries found',
                    description: filterState.searchQuery.isNotEmpty
                        ? 'No transactions matched your search query.'
                        : 'Tap + below to add a transaction to your cashbook.',
                    buttonLabel: 'Add Entry',
                    onButtonPressed: () {
                      Navigator.pushNamed(context, AppRoutes.addTransaction);
                    },
                  )
                : ListView.builder(
                    itemCount: groupedMap.keys.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, dateIndex) {
                      final dateHeader = groupedMap.keys.elementAt(dateIndex);
                      final dayTransactions = groupedMap[dateHeader]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Group Date Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Text(
                                  dateHeader,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                                const Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Divider(height: 1),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Day Transactions
                          Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: dayTransactions.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFF1F5F9),
                              ),
                              itemBuilder: (context, index) {
                                return TransactionTile(
                                  transaction: dayTransactions[index],
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addTransaction);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Entry', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
