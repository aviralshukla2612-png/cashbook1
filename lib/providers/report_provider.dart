import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/summary_model.dart';
import '../models/transaction_model.dart';
import 'transaction_provider.dart';

class CategoryChartData {
  final String categoryName;
  final int totalPaisa;
  final Color color;
  final double percentage;

  const CategoryChartData({
    required this.categoryName,
    required this.totalPaisa,
    required this.color,
    required this.percentage,
  });
}

class ReportData {
  final LedgerSummary summary;
  final List<TransactionModel> periodTransactions;
  final List<CategoryChartData> expenseCategories;
  final List<CategoryChartData> incomeCategories;

  const ReportData({
    required this.summary,
    required this.periodTransactions,
    required this.expenseCategories,
    required this.incomeCategories,
  });
}

final reportProvider = Provider<ReportData>((ref) {
  final filteredTxs = ref.watch(filteredTransactionsProvider);

  int totalIn = 0;
  int totalOut = 0;
  final Map<String, int> expenseByCat = {};
  final Map<String, Color> expenseCatColor = {};

  final Map<String, int> incomeByCat = {};
  final Map<String, Color> incomeCatColor = {};

  for (final tx in filteredTxs) {
    final catName = tx.categoryName ?? 'Other';
    final catColor = tx.categoryColor ?? Colors.grey;

    if (tx.isCashIn) {
      totalIn += tx.amountPaisa;
      incomeByCat[catName] = (incomeByCat[catName] ?? 0) + tx.amountPaisa;
      incomeCatColor[catName] = catColor;
    } else {
      totalOut += tx.amountPaisa;
      expenseByCat[catName] = (expenseByCat[catName] ?? 0) + tx.amountPaisa;
      expenseCatColor[catName] = catColor;
    }
  }

  // Find highest expense category
  String? topExpenseCat;
  int topExpenseAmt = 0;
  expenseByCat.forEach((cat, amt) {
    if (amt > topExpenseAmt) {
      topExpenseAmt = amt;
      topExpenseCat = cat;
    }
  });

  // Find highest income category
  String? topIncomeCat;
  int topIncomeAmt = 0;
  incomeByCat.forEach((cat, amt) {
    if (amt > topIncomeAmt) {
      topIncomeAmt = amt;
      topIncomeCat = cat;
    }
  });

  final summary = LedgerSummary(
    openingBalancePaisa: 0, // In range reports, opening balance is computed based on earlier transactions if needed
    totalCashInPaisa: totalIn,
    totalCashOutPaisa: totalOut,
    transactionCount: filteredTxs.length,
    topExpenseCategory: topExpenseCat,
    topExpenseAmountPaisa: topExpenseAmt,
    topIncomeCategory: topIncomeCat,
    topIncomeAmountPaisa: topIncomeAmt,
  );

  // Build expense chart data
  final expenseChartList = expenseByCat.entries.map((e) {
    final pct = totalOut > 0 ? (e.value / totalOut) * 100 : 0.0;
    return CategoryChartData(
      categoryName: e.key,
      totalPaisa: e.value,
      color: expenseCatColor[e.key] ?? Colors.red,
      percentage: pct,
    );
  }).toList();
  expenseChartList.sort((a, b) => b.totalPaisa.compareTo(a.totalPaisa));

  // Build income chart data
  final incomeChartList = incomeByCat.entries.map((e) {
    final pct = totalIn > 0 ? (e.value / totalIn) * 100 : 0.0;
    return CategoryChartData(
      categoryName: e.key,
      totalPaisa: e.value,
      color: incomeCatColor[e.key] ?? Colors.green,
      percentage: pct,
    );
  }).toList();
  incomeChartList.sort((a, b) => b.totalPaisa.compareTo(a.totalPaisa));

  return ReportData(
    summary: summary,
    periodTransactions: filteredTxs,
    expenseCategories: expenseChartList,
    incomeCategories: incomeChartList,
  );
});
