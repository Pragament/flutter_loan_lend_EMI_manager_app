import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarGraph extends StatelessWidget {
  final List<double> principalAmounts;
  final List<double> interestAmounts;
  final List<double> balances;
  final int totalYears;

  const BarGraph({
    Key? key,
    required this.principalAmounts,
    required this.interestAmounts,
    required this.balances,
    required this.totalYears,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: _getMaxY(),
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: _bottomTitles,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4,
                    child: Text(
                      value.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),
          barGroups: _buildBarGroups(),
        ),
      ),
    );
  }

  double _getMaxY() {
    final double maxPrincipal = principalAmounts.isNotEmpty
        ? principalAmounts.reduce((a, b) => a > b ? a : b)
        : 0.0;
    final double maxInterest = interestAmounts.isNotEmpty
        ? interestAmounts.reduce((a, b) => a > b ? a : b)
        : 0.0;
    final double maxBalance = balances.isNotEmpty
        ? balances.reduce((a, b) => a > b ? a : b)
        : 0.0;
    return (maxPrincipal + maxInterest + maxBalance) * 1.2; // Adding 20% buffer
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    final int yearIndex = value.toInt();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        'Year ${yearIndex + 1}',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < totalYears; i++) {
      final double principal = i < principalAmounts.length
          ? principalAmounts[i]
          : 0.0;
      final double interest = i < interestAmounts.length
          ? interestAmounts[i]
          : 0.0;
      final double balance = i < balances.length
          ? balances[i]
          : 0.0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: principal,
              color: Colors.green,
              width: 12,
            ),
            BarChartRodData(
              toY: interest,
              color: Colors.orange,
              width: 12,
            ),
            BarChartRodData(
              toY: balance,
              color: Colors.red,
              width: 12,
            ),
          ],
        ),
      );
    }

    return barGroups;
  }
}
