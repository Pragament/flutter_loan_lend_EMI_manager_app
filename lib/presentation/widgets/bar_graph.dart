import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarGraph extends StatelessWidget {
  final List<double> principalAmounts; // Monthly principal payments
  final List<double> interestAmounts; // Monthly interest payments
  final List<double> balances; // Remaining balances (if available)
  final List<int> years; // List of years

  const BarGraph({
    Key? key,
    required this.principalAmounts,
    required this.interestAmounts,
    required this.balances,
    required this.years,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double maxY = _getMaxY(); // Calculate dynamic maxY based on bar values

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          Container(
            color: Colors.white, // Set background color to white
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            _formatTitle(value),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false, // Hide right titles for clarity
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < years.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              years[index].toString(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _createBarGroups(),
                gridData: FlGridData(show: false),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LineChart(
                LineChartData(
                  minX: -0.5,
                  maxX: years.length.toDouble() - 0.5,
                  minY: 0,
                  maxY: maxY,
                  lineTouchData: LineTouchData(enabled: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        balances.length,
                            (index) => FlSpot(index.toDouble(), balances[index]),
                      ),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups() {
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < years.length; i++) {
      final year = years[i];
      final totalPayment = principalAmounts[i];

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: totalPayment,
              rodStackItems: [
                BarChartRodStackItem(0, principalAmounts[i], Colors.green),
                BarChartRodStackItem(principalAmounts[i], totalPayment, Colors.orange),
              ],
              width: 20,
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
      );
    }

    return barGroups;
  }

  double _getMaxY() {
    double maxY = 0;
    for (int i = 0; i < balances.length; i++) {
      final totalPayment = principalAmounts[i] + interestAmounts[i];
      maxY = [maxY, totalPayment, balances[i]].reduce((a, b) => a > b ? a : b);
    }
    return maxY * 1.1; // Add 10% padding for better visualization
  }

  String _formatTitle(double value) {
    if (value >= 1e6) {
      return '${(value / 1e6).toStringAsFixed(0)}M';
    } else if (value >= 1e3) {
      return '${(value / 1e3).toStringAsFixed(0)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}
