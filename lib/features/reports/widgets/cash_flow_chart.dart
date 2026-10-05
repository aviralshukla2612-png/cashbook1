import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/transaction_model.dart';

class CashFlowChart extends StatelessWidget {
  final List<TransactionModel> transactions;

  const CashFlowChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (transactions.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: const Text('No data for chart preview.', style: TextStyle(color: Colors.grey)),
      );
    }

    // Group transactions into daily totals (or last 7 items)
    final Map<String, double> dailyIn = {};
    final Map<String, double> dailyOut = {};

    for (final tx in transactions.reversed) {
      final dateKey = '${tx.transactionDate.day}/${tx.transactionDate.month}';
      if (tx.isCashIn) {
        dailyIn[dateKey] = (dailyIn[dateKey] ?? 0) + tx.amountRupees;
      } else {
        dailyOut[dateKey] = (dailyOut[dateKey] ?? 0) + tx.amountRupees;
      }
    }

    final dates = (dailyIn.keys.toSet()..addAll(dailyOut.keys)).toList();
    if (dates.length > 7) {
      dates.removeRange(0, dates.length - 7);
    }

    final List<BarChartGroupData> barGroups = [];
    double maxY = 100;

    for (int i = 0; i < dates.length; i++) {
      final d = dates[i];
      final inVal = dailyIn[d] ?? 0;
      final outVal = dailyOut[d] ?? 0;

      if (inVal > maxY) maxY = inVal;
      if (outVal > maxY) maxY = outVal;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: inVal,
              color: AppColors.cashIn,
              width: 10,
              borderRadius: BorderRadius.circular(4),
            ),
            BarChartRodData(
              toY: outVal,
              color: AppColors.cashOut,
              width: 10,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.only(top: 16, right: 16, left: 8, bottom: 8),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY * 1.15,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final date = dates[group.x];
                final isIn = rodIndex == 0;
                final val = rod.toY;
                return BarTooltipItem(
                  '$date\n${isIn ? "Cash In" : "Cash Out"}: ₹${val.toStringAsFixed(0)}',
                  TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < dates.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        dates[idx],
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    CurrencyFormatter.formatCompactPaisa((value * 100).toInt()),
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }
}
