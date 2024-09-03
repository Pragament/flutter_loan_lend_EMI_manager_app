import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EmiPie extends StatelessWidget {
  const EmiPie({
    super.key,
    required this.loanAmount,
    required this.interestAmount,
  });

  final double loanAmount;
  final double interestAmount;

  @override
  Widget build(BuildContext context) {
    double total = loanAmount + interestAmount;
    double loanPercentage = (loanAmount / total) * 100;
    double interestPercentage = (interestAmount / total) * 100;

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: Colors.green,
            value: loanAmount,
            title:
                '${loanPercentage.toStringAsFixed(1)}%', // Display as percentage
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.orange,
            value: interestAmount,
            title:
                '${interestPercentage.toStringAsFixed(1)}%', // Display as percentage
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
        sectionsSpace: 4,
        centerSpaceRadius: 0,
      ),
    );
  }
}
