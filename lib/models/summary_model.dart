import '../core/utils/currency_formatter.dart';

class LedgerSummary {
  final int openingBalancePaisa;
  final int totalCashInPaisa;
  final int totalCashOutPaisa;
  final int transactionCount;
  final String? topExpenseCategory;
  final int topExpenseAmountPaisa;
  final String? topIncomeCategory;
  final int topIncomeAmountPaisa;

  const LedgerSummary({
    this.openingBalancePaisa = 0,
    this.totalCashInPaisa = 0,
    this.totalCashOutPaisa = 0,
    this.transactionCount = 0,
    this.topExpenseCategory,
    this.topExpenseAmountPaisa = 0,
    this.topIncomeCategory,
    this.topIncomeAmountPaisa = 0,
  });

  /// Net Movement = Total Cash In - Total Cash Out
  int get netMovementPaisa => totalCashInPaisa - totalCashOutPaisa;

  /// Closing Balance / Current Balance = Opening Balance + Total Cash In - Total Cash Out
  int get closingBalancePaisa => openingBalancePaisa + totalCashInPaisa - totalCashOutPaisa;

  int get currentBalancePaisa => closingBalancePaisa;

  double get averageTransactionPaisa =>
      transactionCount == 0 ? 0 : (totalCashInPaisa + totalCashOutPaisa) / transactionCount;

  String get formattedOpeningBalance => CurrencyFormatter.formatPaisa(openingBalancePaisa);
  String get formattedTotalCashIn => CurrencyFormatter.formatPaisa(totalCashInPaisa);
  String get formattedTotalCashOut => CurrencyFormatter.formatPaisa(totalCashOutPaisa);
  String get formattedNetMovement => CurrencyFormatter.formatPaisa(netMovementPaisa);
  String get formattedClosingBalance => CurrencyFormatter.formatPaisa(closingBalancePaisa);
  String get formattedCurrentBalance => CurrencyFormatter.formatPaisa(currentBalancePaisa);
}
