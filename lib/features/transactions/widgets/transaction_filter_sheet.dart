import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/enums/transaction_type.dart';
import '../../../core/enums/date_filter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/category_provider.dart';

class TransactionFilterSheet extends ConsumerStatefulWidget {
  const TransactionFilterSheet({super.key});

  @override
  ConsumerState<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends ConsumerState<TransactionFilterSheet> {
  late DateFilterOption _selectedDateFilter;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  TransactionType? _selectedType;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(transactionFilterProvider);
    _selectedDateFilter = filter.dateFilter;
    _customStartDate = filter.customStartDate;
    _customEndDate = filter.customEndDate;
    _selectedType = filter.selectedType;
    _selectedCategoryId = filter.selectedCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Transactions',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  ref.read(transactionFilterProvider.notifier).resetFilters();
                  Navigator.pop(context);
                },
                child: const Text('Reset All'),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),

          // Date Filter Section
          const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: DateFilterOption.values.map((option) {
              final isSelected = _selectedDateFilter == option;
              return ChoiceChip(
                label: Text(option.label),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedDateFilter = option;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Transaction Type Section
          const Text('Transaction Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedType == null,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = null);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Cash In'),
                  selected: _selectedType == TransactionType.cashIn,
                  selectedColor: AppColors.cashInBgLight,
                  onSelected: (selected) {
                    setState(() => _selectedType = selected ? TransactionType.cashIn : null);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Cash Out'),
                  selected: _selectedType == TransactionType.cashOut,
                  selectedColor: AppColors.cashOutBgLight,
                  onSelected: (selected) {
                    setState(() => _selectedType = selected ? TransactionType.cashOut : null);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category Dropdown
          const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          categoriesAsync.when(
            data: (categories) {
              return DropdownButtonFormField<String?>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  hintText: 'All Categories',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Categories'),
                  ),
                  ...categories.map((c) => DropdownMenuItem<String?>(
                        value: c.id,
                        child: Text(c.name),
                      )),
                ],
                onChanged: (val) {
                  setState(() => _selectedCategoryId = val);
                },
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final notifier = ref.read(transactionFilterProvider.notifier);
                notifier.setDateFilter(_selectedDateFilter, start: _customStartDate, end: _customEndDate);
                notifier.setTransactionType(_selectedType);
                notifier.setCategory(_selectedCategoryId);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
