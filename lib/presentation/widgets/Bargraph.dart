import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarGraph extends StatelessWidget {
  final List<double> principalAmounts; // Loan amounts
  final List<double> interestAmounts;  // Lend amounts
  final List<double> balances;         // Aggregate amounts (Loan + Lend)
  final List<int> years;

  const BarGraph({
    super.key,
    required this.principalAmounts,
    required this.interestAmounts,
    required this.balances,
    required this.years,
  });

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = [];
    double maxPayment = (principalAmounts + interestAmounts + balances).reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < years.length; i++) {
      final double loanAmount = principalAmounts[i];
      final double lendAmount = interestAmounts[i];
      final double aggregateAmount = balances[i];

      barGroups.add(
        BarChartGroupData(
          x: i, // Index for x-axis
          barRods: [
            // Loan bar (pink)
            BarChartRodData(
              toY: loanAmount,
              color: Colors.pink,
              width: 12, // Width of each bar
              borderRadius: BorderRadius.zero, // Rectangular bar
            ),
            // Lend bar (blue)
            BarChartRodData(
              toY: lendAmount,
              color: Colors.blue,
              width: 12,
              borderRadius: BorderRadius.zero,
            ),
            // Aggregate bar (green)
            BarChartRodData(
              toY: aggregateAmount,
              color: Colors.deepOrangeAccent,
              width: 12,
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  String title = years.isNotEmpty && index < years.length
                      ? years[index].toString()
                      : '';
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false), // Hide top titles
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barTouchData: BarTouchData(enabled: true),
          gridData: FlGridData(show: true),
          backgroundColor: Colors.white, // Set background color to white
          maxY: maxPayment,
          minY: 0,
        ),
      ),
    );
  }
}
