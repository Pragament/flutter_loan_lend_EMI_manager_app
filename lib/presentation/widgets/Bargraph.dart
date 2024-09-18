import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarGraph extends StatelessWidget {
  final List<double> principalAmounts; // Loan amounts
  final List<double> interestAmounts;  // Lend amounts
  final List<double> balances;         // Aggregate amounts (Loan - EMI)
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
    double maxPayment = (principalAmounts + interestAmounts + balances)
        .reduce((a, b) => a > b ? a : b); // Find max value for graph scaling

    for (int i = 0; i < years.length; i++) {
      final double loanAmount = principalAmounts[i];
      final double lendAmount = interestAmounts.isNotEmpty ? interestAmounts[i] : 0.0;
      final double aggregateAmount = balances[i];

      // Add bars for Loan, Lend, and Aggregate
      List<BarChartRodData> barRods = [
        // Loan bar (pink)
        BarChartRodData(
          toY: loanAmount,
          color: Colors.pink,
          width: 12,
          borderRadius: BorderRadius.zero, // Rectangular bar
        ),
        // Only add lend bar if lends exist
        if (interestAmounts.isNotEmpty)
          BarChartRodData(
            toY: lendAmount,
            color: Colors.blue,
            width: 12,
            borderRadius: BorderRadius.zero,
          ),
        // Aggregate bar (green)
        BarChartRodData(
          toY: aggregateAmount,
          color: Colors.grey,
          width: 12,
          borderRadius: BorderRadius.zero,
        ),
      ];

      barGroups.add(BarChartGroupData(
        x: i, // Index for x-axis
        barRods: barRods,
      ));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the total width needed for the bars
        double availableWidth = constraints.maxWidth;
        double barWidth = 60; // Each bar group width (including padding)
        double totalWidth = barGroups.length * barWidth;

        // Check if scrolling is needed
        bool isScrollable = totalWidth > availableWidth;

        return SizedBox(
          height: 300, // Adjust graph height as needed
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: isScrollable ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: isScrollable ? totalWidth : availableWidth,
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
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: true),
                  gridData: FlGridData(show: true),
                  backgroundColor: Colors.white, // Set background color to white
                  maxY: maxPayment,
                  minY: 0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
