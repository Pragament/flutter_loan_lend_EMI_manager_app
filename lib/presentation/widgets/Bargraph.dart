import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarGraph extends StatelessWidget {
  final List<double> principalAmounts;
  final List<double> interestAmounts;
  final List<double> balances;
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
    double maxPayment = principalAmounts.isNotEmpty
        ? principalAmounts.reduce((a, b) => max(a, b)) +
        interestAmounts.reduce((a, b) => max(a, b))
        : 0;

    for (int i = 0; i < years.length; i++) {
      final double principalAmount = principalAmounts[i];
      final double interestAmount = interestAmounts[i];
      final double totalPayment = principalAmount + interestAmount;

      barGroups.add(
        BarChartGroupData(
          x: i, // Use index for x-axis
          barRods: [
            BarChartRodData(
              toY: totalPayment,
              rodStackItems: [
                BarChartRodStackItem(0, principalAmount, Colors.green),
                // Using the same green color with opacity for the interest portion
                BarChartRodStackItem(
                  principalAmount,
                  totalPayment,
                  Colors.green.withOpacity(0.5), // Interest with opacity
                ),
              ],
              width: 20,
              borderRadius: BorderRadius.zero, // Ensure bars are perfect rectangles
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
                showTitles: false, // Hide left titles
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50, // Increase reserved size
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  String title = years.isNotEmpty && index < years.length
                      ? years[index].toString()
                      : '';
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14, // Increase font size if necessary
                        ),
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
