import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/summary_model.dart';
import '../models/transaction_model.dart';
import '../core/utils/date_formatter.dart';
import 'transaction_provider.dart';
import 'settings_provider.dart';
import 'account_provider.dart';

class DashboardData {
  final LedgerSummary summary;
  final int todayCashInPaisa;
  final int todayCashOutPaisa;
  final int todayNetPaisa;
  final List<TransactionModel> recentTransactions;

  const DashboardData({
    required this.summary,
    this.todayCashInPaisa = 0,
    this.todayCashOutPaisa = 0,
    this.todayNetPaisa = 0,
    this.recentTransactions = const [],
  });
}

final dashboardProvider = Provider<DashboardData>((ref) {
  final transactionsAsync = ref.watch(transactionsStreamProvider);
  final activeAccount = ref.watch(activeAccountProvider);
  final globalOpeningBalance = ref.watch(openingBalanceStreamProvider).value ?? 0;

  final transactions = transactionsAsync.value ?? [];
  final openingBalancePaisa = activeAccount != null ? activeAccount.initialBalancePaisa : globalOpeningBalance;

  int totalIn = 0;
  int totalOut = 0;
  int todayIn = 0;
  int todayOut = 0;

  final now = DateTime.now();

  for (final tx in transactions) {
    if (tx.isCashIn) {
      totalIn += tx.amountPaisa;
      if (DateFormatter.isSameDay(tx.transactionDate, now)) {
        todayIn += tx.amountPaisa;
      }
    } else {
      totalOut += tx.amountPaisa;
      if (DateFormatter.isSameDay(tx.transactionDate, now)) {
        todayOut += tx.amountPaisa;
      }
    }
  }

  final summary = LedgerSummary(
    openingBalancePaisa: openingBalancePaisa,
    totalCashInPaisa: totalIn,
    totalCashOutPaisa: totalOut,
    transactionCount: transactions.length,
  );

  final recent = transactions.take(5).toList();

  return DashboardData(
    summary: summary,
    todayCashInPaisa: todayIn,
    todayCashOutPaisa: todayOut,
    todayNetPaisa: todayIn - todayOut,
    recentTransactions: recent,
  );
});
