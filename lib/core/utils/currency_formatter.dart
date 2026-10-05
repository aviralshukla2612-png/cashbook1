import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String defaultSymbol = '₹';

  /// Converts paise (integer minor units) to double rupees
  static double paisaToRupees(int paisa) {
    return paisa / 100.0;
  }

  /// Converts double rupees to paise (integer minor units)
  static int rupeesToPaisa(double rupees) {
    return (rupees * 100).round();
  }

  /// Formats integer paise to currency string (e.g. ₹ 1,25,000.00 or ₹ 500)
  static String formatPaisa(
    int paisa, {
    bool includeSymbol = true,
    String? symbol,
    bool showDecimals = false,
  }) {
    final double rupees = paisaToRupees(paisa);
    return formatRupees(
      rupees,
      includeSymbol: includeSymbol,
      symbol: symbol ?? defaultSymbol,
      showDecimals: showDecimals,
    );
  }

  /// Formats double rupees to formatted currency string
  static String formatRupees(
    double rupees, {
    bool includeSymbol = true,
    String? symbol,
    bool showDecimals = false,
  }) {
    final activeSymbol = symbol ?? defaultSymbol;
    final isNegative = rupees < 0;
    final absRupees = rupees.abs();

    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: includeSymbol ? '$activeSymbol ' : '',
      decimalDigits: showDecimals || (absRupees % 1 != 0) ? 2 : 0,
    );

    final formattedStr = formatter.format(absRupees);
    return isNegative ? '- $formattedStr' : formattedStr;
  }

  /// Formats integer paise for compact view (e.g. ₹ 1.2L)
  static String formatCompactPaisa(int paisa, {String? symbol}) {
    final double rupees = paisaToRupees(paisa);
    final activeSymbol = symbol ?? defaultSymbol;
    if (rupees.abs() < 1000) {
      return formatRupees(rupees, symbol: activeSymbol);
    }
    final compactFormatter = NumberFormat.compactCurrency(
      locale: 'en_IN',
      symbol: activeSymbol,
      decimalDigits: 1,
    );
    return compactFormatter.format(rupees);
  }

  /// Parses user string input to integer paise. Returns null if invalid.
  static int? parseInputToPaisa(String input) {
    final clean = input.replaceAll('₹', '').replaceAll(',', '').trim();
    if (clean.isEmpty) return null;
    final val = double.tryParse(clean);
    if (val == null || val < 0 || val.isNaN || val.isInfinite) return null;
    return rupeesToPaisa(val);
  }
}
