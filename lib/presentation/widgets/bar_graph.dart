import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'amortization_schedule_table.dart'; // Assuming the table is defined in this file

class EmiDetailsPage extends StatelessWidget {
  final double principalAmount;
  final double interestAmount;
  final double totalPayment;
  final int tenure;
  final List<AmortizationEntry> amortizationEntries;

  EmiDetailsPage({
    required this.principalAmount,
    required this.interestAmount,
    required this.totalPayment,
    required this.tenure,
    required this.amortizationEntries,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EMI Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Displaying the bar graph with line graph for remaining balance
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 300,
                child: BarGraphWithLineChart(
                  principalAmount: principalAmount,
                  interestAmount: interestAmount,
                  remainingBalance: totalPayment - principalAmount,
                  tenure: tenure,
                  amortizationEntries: amortizationEntries, // Pass amortization data for balance
                ),
              ),
            ),
            // Amortization Table with scrollable content
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AmortizationScheduleTable(
                entries: amortizationEntries,
                tenure: tenure,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BarGraphWithLineChart extends StatelessWidget {
  final double principalAmount;
  final double interestAmount;
  final double remainingBalance;
  final int tenure;
  final List<AmortizationEntry> amortizationEntries;

  BarGraphWithLineChart({
    required this.principalAmount,
    required this.interestAmount,
    required this.remainingBalance,
    required this.tenure,
    required this.amortizationEntries,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: totalPayment(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final int year = value.toInt() + 2023; // Start year of tenure
                return Text('$year');
              },
            ),
          ),
        ),
        barGroups: List.generate(tenure, (index) {
          final AmortizationEntry entry = amortizationEntries[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.totalPayment, // Total payment (Principal + Interest)
                rodStackItems: [
                  BarChartRodStackItem(0, entry.principal, Colors.green),
                  BarChartRodStackItem(entry.principal, entry.totalPayment, Colors.orange),
                ],
                width: 20, // Square bar width
                borderRadius: BorderRadius.zero, // No curved edges
              ),
            ],
          );
        }),
        gridData: FlGridData(show: false), // Remove background lines
        borderData: FlBorderData(show: false),
      ),
      swapAnimationDuration: const Duration(milliseconds: 250),
      swapAnimationCurve: Curves.linear,
    );
  }

  // Function to calculate total payment (Principal + Interest)
  double totalPayment() {
    return principalAmount + interestAmount;
  }

  // Adding the line chart for the remaining balance
  Widget buildLineChart() {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(tenure, (index) {
              final AmortizationEntry entry = amortizationEntries[index];
              return FlSpot(index.toDouble(), entry.balance); // Remaining balance at each year
            }),
            isCurved: true,
            color: Colors.red,
            barWidth: 2,
            isStrokeCapRound: true,
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final int year = value.toInt() + 2023; // Adjusted year display
                return Text('$year');
              },
            ),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

// Assuming AmortizationEntry is a data model containing fields for principal, interest, totalPayment, and balance
class AmortizationEntry {
  final int year;
  final double principal;
  final double interest;
  final double totalPayment;
  final double balance;
  final DateTime paymentDate;

  AmortizationEntry({
    required this.year,
    required this.principal,
    required this.interest,
    required this.totalPayment,
    required this.balance,
    required this.paymentDate,
  });
}

class AmortizationScheduleTable extends StatelessWidget {
  final List<AmortizationEntry> entries;
  final int tenure;

  AmortizationScheduleTable({required this.entries, required this.tenure});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: entries.map((entry) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${entry.year}'),
            Text('${entry.principal.toStringAsFixed(2)}'),
            Text('${entry.interest.toStringAsFixed(2)}'),
            Text('${entry.totalPayment.toStringAsFixed(2)}'),
            Text('${entry.balance.toStringAsFixed(2)}'),
          ],
        );
      }).toList(),
    );
  }
}
