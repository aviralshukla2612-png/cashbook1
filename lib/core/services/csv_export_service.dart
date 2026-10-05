import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/transaction_model.dart';
import '../utils/date_formatter.dart';

class CsvExportService {
  static String _convertToCsv(List<List<dynamic>> rows) {
    return rows.map((row) {
      return row.map((cell) {
        final str = cell.toString().replaceAll('"', '""');
        if (str.contains(',') || str.contains('"') || str.contains('\n')) {
          return '"$str"';
        }
        return str;
      }).join(',');
    }).join('\n');
  }

  static Future<File> generateCsv(List<TransactionModel> transactions) async {
    final List<List<dynamic>> rows = [];

    // Header row
    rows.add([
      'Date',
      'Time',
      'Type',
      'Amount (INR)',
      'Party Name',
      'Category',
      'Description',
    ]);

    for (final tx in transactions) {
      rows.add([
        DateFormatter.formatShortDate(tx.transactionDate),
        DateFormatter.formatTime(tx.transactionDate),
        tx.type.label,
        tx.amountRupees.toStringAsFixed(2),
        tx.partyName ?? '',
        tx.categoryName ?? 'Uncategorized',
        tx.description ?? '',
      ]);
    }

    final String csvData = _convertToCsv(rows);

    final directory = await getTemporaryDirectory();
    final String fileName =
        'daily_cashbook_export_${DateTime.now().millisecondsSinceEpoch}.csv';
    final File file = File('${directory.path}/$fileName');

    return await file.writeAsString(csvData);
  }

  static Future<void> exportAndShareCsv(List<TransactionModel> transactions) async {
    final file = await generateCsv(transactions);
    await Share.shareXFiles([XFile(file.path)], text: 'Daily Cashbook CSV Export');
  }
}
