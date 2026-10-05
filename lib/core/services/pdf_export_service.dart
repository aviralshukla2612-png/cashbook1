import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/transaction_model.dart';
import '../../models/summary_model.dart';
import '../utils/date_formatter.dart';

class PdfExportService {
  static Future<File> generatePdf({
    required List<TransactionModel> transactions,
    required LedgerSummary summary,
    required String periodText,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Title Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DAILY CASHBOOK',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Period: $periodText',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Generated on',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                    ),
                    pw.Text(
                      DateFormatter.formatShortDate(DateTime.now()),
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 12),

            // Financial Summary Card Grid
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _summaryItem('Opening Balance', summary.formattedOpeningBalance, PdfColors.blue800),
                  _summaryItem('Total Cash In', summary.formattedTotalCashIn, PdfColors.green800),
                  _summaryItem('Total Cash Out', summary.formattedTotalCashOut, PdfColors.red800),
                  _summaryItem('Closing Balance', summary.formattedClosingBalance, PdfColors.indigo900),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Transaction Table Header
            pw.Text(
              'Ledger Entries (${transactions.length})',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),

            // Ledger Table
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Type', 'Party', 'Category', 'Amount'],
              data: transactions.map((tx) {
                final isCashIn = tx.isCashIn;
                return [
                  DateFormatter.formatShortDate(tx.transactionDate),
                  tx.type.label,
                  tx.partyName ?? '-',
                  tx.categoryName ?? 'Uncategorized',
                  '${isCashIn ? "+ " : "- "}${tx.formattedAmount}',
                ];
              }).toList(),
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo900),
              cellHeight: 25,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.centerRight,
              },
            ),
          ];
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final String fileName = 'daily_cashbook_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final File file = File('${directory.path}/$fileName');

    return await file.writeAsBytes(await pdf.save());
  }

  static pw.Widget _summaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: color),
        ),
      ],
    );
  }

  static Future<void> exportAndSharePdf({
    required List<TransactionModel> transactions,
    required LedgerSummary summary,
    required String periodText,
  }) async {
    final file = await generatePdf(
      transactions: transactions,
      summary: summary,
      periodText: periodText,
    );
    await Share.shareXFiles([XFile(file.path)], text: 'Daily Cashbook Financial Report');
  }
}
