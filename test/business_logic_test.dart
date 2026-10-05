import 'package:flutter_test/flutter_test.dart';
import 'package:daily_cashbook/core/enums/transaction_type.dart';
import 'package:daily_cashbook/core/utils/currency_formatter.dart';
import 'package:daily_cashbook/core/utils/date_formatter.dart';
import 'package:daily_cashbook/models/summary_model.dart';
import 'package:daily_cashbook/models/transaction_model.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('Converts rupees to paise and paise to rupees accurately', () {
      expect(CurrencyFormatter.rupeesToPaisa(500.50), 50050);
      expect(CurrencyFormatter.paisaToRupees(50050), 500.50);
      expect(CurrencyFormatter.parseInputToPaisa('₹ 1,25,000'), 12500000);
      expect(CurrencyFormatter.parseInputToPaisa('300'), 30000);
    });

    test('Formats Indian currency strings correctly', () {
      expect(CurrencyFormatter.formatPaisa(50050, showDecimals: true), '₹ 500.50');
      expect(CurrencyFormatter.formatPaisa(3000000), '₹ 30,000');
      expect(CurrencyFormatter.formatPaisa(12500000), '₹ 1,25,000');
    });

    test('Handles negative amounts safely', () {
      expect(CurrencyFormatter.formatPaisa(-120000), '- ₹ 1,200');
    });
  });

  group('LedgerSummary Financial Calculations', () {
    test('Calculates Net Movement and Closing Balance correctly', () {
      const summary = LedgerSummary(
        openingBalancePaisa: 3000000, // ₹30,000
        totalCashInPaisa: 12500000, // ₹1,25,000
        totalCashOutPaisa: 7850000, // ₹78,500
        transactionCount: 15,
      );

      // Net Movement = 125000 - 78500 = 46500 (4650000 paise)
      expect(summary.netMovementPaisa, 4650000);
      expect(summary.formattedNetMovement, '₹ 46,500');

      // Closing Balance = 30000 + 46500 = 76500 (7650000 paise)
      expect(summary.closingBalancePaisa, 7650000);
      expect(summary.formattedClosingBalance, '₹ 76,500');
    });
  });

  group('TransactionModel Tests', () {
    test('Identifies transaction type and formats values', () {
      final now = DateTime.now();
      final txIn = TransactionModel(
        id: 'tx_1',
        type: TransactionType.cashIn,
        amountPaisa: 500000, // ₹5,000
        categoryId: 'cat_sales',
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(txIn.isCashIn, isTrue);
      expect(txIn.isCashOut, isFalse);
      expect(txIn.amountRupees, 5000.0);
      expect(txIn.formattedAmount, '₹ 5,000');

      final txOut = txIn.copyWith(
        type: TransactionType.cashOut,
        amountPaisa: 120000, // ₹1,200
      );

      expect(txOut.isCashOut, isTrue);
      expect(txOut.formattedAmount, '₹ 1,200');
    });
  });

  group('DateFormatter Tests', () {
    test('Checks same day comparison', () {
      final dt1 = DateTime(2026, 9, 29, 10, 30);
      final dt2 = DateTime(2026, 9, 29, 18, 45);
      final dt3 = DateTime(2026, 9, 30, 10, 30);

      expect(DateFormatter.isSameDay(dt1, dt2), isTrue);
      expect(DateFormatter.isSameDay(dt1, dt3), isFalse);
    });
  });
}
