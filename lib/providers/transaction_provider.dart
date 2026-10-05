import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import '../core/enums/transaction_type.dart';
import '../core/enums/date_filter.dart';
import '../core/utils/date_formatter.dart';
import '../repositories/transaction_repository.dart';
import 'database_provider.dart';
import 'account_provider.dart';

final transactionsStreamProvider = StreamProvider<List<TransactionModel>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  final activeAccountId = ref.watch(activeAccountIdProvider);
  return repo.watchTransactions(accountId: activeAccountId);
});

class TransactionFilterState {
  final String searchQuery;
  final DateFilterOption dateFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final TransactionType? selectedType;
  final String? selectedCategoryId;

  const TransactionFilterState({
    this.searchQuery = '',
    this.dateFilter = DateFilterOption.all,
    this.customStartDate,
    this.customEndDate,
    this.selectedType,
    this.selectedCategoryId,
  });

  TransactionFilterState copyWith({
    String? searchQuery,
    DateFilterOption? dateFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
    TransactionType? selectedType,
    bool clearType = false,
    String? selectedCategoryId,
    bool clearCategory = false,
  }) {
    return TransactionFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      dateFilter: dateFilter ?? this.dateFilter,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
    );
  }
}

class TransactionFilterNotifier extends Notifier<TransactionFilterState> {
  @override
  TransactionFilterState build() => const TransactionFilterState();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setDateFilter(DateFilterOption option, {DateTime? start, DateTime? end}) {
    state = state.copyWith(
      dateFilter: option,
      customStartDate: start,
      customEndDate: end,
    );
  }

  void setTransactionType(TransactionType? type) {
    state = state.copyWith(selectedType: type, clearType: type == null);
  }

  void setCategory(String? categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId, clearCategory: categoryId == null);
  }

  void resetFilters() {
    state = const TransactionFilterState();
  }
}

final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilterState>(TransactionFilterNotifier.new);

final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final filter = ref.watch(transactionFilterProvider);

  return transactionsAsync.when(
    data: (transactions) {
      return transactions.where((tx) {
        if (filter.selectedType != null && tx.type != filter.selectedType) {
          return false;
        }

        if (filter.selectedCategoryId != null && tx.categoryId != filter.selectedCategoryId) {
          return false;
        }

        if (filter.searchQuery.trim().isNotEmpty) {
          final q = filter.searchQuery.toLowerCase().trim();
          final party = (tx.partyName ?? '').toLowerCase();
          final desc = (tx.description ?? '').toLowerCase();
          final cat = (tx.categoryName ?? '').toLowerCase();
          final amount = tx.formattedAmount.toLowerCase();
          final match = party.contains(q) || desc.contains(q) || cat.contains(q) || amount.contains(q);
          if (!match) return false;
        }

        final now = DateTime.now();
        final txDate = tx.transactionDate;

        switch (filter.dateFilter) {
          case DateFilterOption.today:
            return DateFormatter.isSameDay(txDate, now);

          case DateFilterOption.yesterday:
            final yesterday = now.subtract(const Duration(days: 1));
            return DateFormatter.isSameDay(txDate, yesterday);

          case DateFilterOption.thisWeek:
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            final weekStart = DateFormatter.startOfDay(startOfWeek);
            return txDate.isAfter(weekStart.subtract(const Duration(milliseconds: 1)));

          case DateFilterOption.thisMonth:
            return txDate.year == now.year && txDate.month == now.month;

          case DateFilterOption.custom:
            if (filter.customStartDate != null && filter.customEndDate != null) {
              final start = DateFormatter.startOfDay(filter.customStartDate!);
              final end = DateFormatter.endOfDay(filter.customEndDate!);
              return txDate.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
                     txDate.isBefore(end.add(const Duration(milliseconds: 1)));
            }
            return true;

          case DateFilterOption.all:
          default:
            return true;
        }
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
