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
    final w = MediaQuery.of(context).size.width;

    List<BarChartGroupData> barGroups = [];
    double maxPayment = principalAmounts.isNotEmpty
        ? principalAmounts.reduce((a, b) => max(a, b)) +
            interestAmounts.reduce((a, b) => max(a, b))
        : 0;

    maxPayment += maxPayment * 0.1; // Add 10% buffer

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
                BarChartRodStackItem(
                    principalAmount, totalPayment, Colors.orange),
              ],
              width: 18, // Adjust width for better spacing
              borderRadius: BorderRadius.circular(4), // Rounded corners
            ),
          ],
        ),
      );
    }
    // Changing the width according to loan tenure.
    final len = years.length;
    var prod = len < 5
        ? 0.95
        : len < 10
            ? 1.25
            : len < 15
                ? 1.75
                : 2.5;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: w * prod, // Adjust width as needed
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
          child: AspectRatio(
            aspectRatio: 1.9,
            child: BarChart(
              BarChartData(
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize:
                          45, // Adjust this value to increase left margin
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            '${(value / 1000).toStringAsFixed(0)}K',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        String title = '';

                        // Display years at intervals of 2 or 3
                        if (years.isNotEmpty &&
                            index < years.length &&
                            index % 2 == 0) {
                          title = years[index].toString();
                        }

                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Transform.rotate(
                            angle: -1.1, // Rotate to avoid overlap
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barTouchData: BarTouchData(enabled: true),
                gridData: const FlGridData(
                  show: true,
                ),
                backgroundColor: Colors.white,
                maxY: maxPayment,
                minY: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
