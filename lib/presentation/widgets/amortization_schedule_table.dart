import 'package:flutter/material.dart';

class AmortizationScheduleTable extends StatefulWidget {
  final List<AmortizationEntry> schedule;

  const AmortizationScheduleTable({
    Key? key,
    required this.schedule,
  }) : super(key: key);

  @override
  _AmortizationScheduleTableState createState() => _AmortizationScheduleTableState();
}

class _AmortizationScheduleTableState extends State<AmortizationScheduleTable> {
  @override
  Widget build(BuildContext context) {
    // Debugging: Ensure schedule is not empty
    if (widget.schedule.isEmpty) {
      return Center(child: Text('No data available.'));
    }

    final Map<int, List<AmortizationEntry>> groupedByYear = {};
    for (var entry in widget.schedule) {
      groupedByYear.putIfAbsent(entry.year, () => []).add(entry);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Allows horizontal scrolling
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Year')),
          DataColumn(label: Text('Month')),
          DataColumn(label: Text('Principal')),
          DataColumn(label: Text('Interest')),
          DataColumn(label: Text('Total Payment')),
          DataColumn(label: Text('Balance')),
        ],
        rows: groupedByYear.entries.expand((yearEntry) {
          final int year = yearEntry.key;
          final List<AmortizationEntry> monthlyEntries = yearEntry.value;

          // Summarize year data
          final double yearPrincipal = monthlyEntries.fold(0.0, (sum, entry) => sum + entry.principal);
          final double yearInterest = monthlyEntries.fold(0.0, (sum, entry) => sum + entry.interest);
          final double yearTotalPayment = monthlyEntries.fold(0.0, (sum, entry) => sum + entry.totalPayment);
          final double yearBalance = monthlyEntries.isNotEmpty ? monthlyEntries.last.balance : 0.0;

          return [
            DataRow(cells: [
              DataCell(Text('$year', style: TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text('')),
              DataCell(Text('Principal: ${yearPrincipal.toStringAsFixed(2)}')),
              DataCell(Text('Interest: ${yearInterest.toStringAsFixed(2)}')),
              DataCell(Text('Total Payment: ${yearTotalPayment.toStringAsFixed(2)}')),
              DataCell(Text('Balance: ${yearBalance.toStringAsFixed(2)}')),
            ]),
            ..._buildMonthlyEntries(monthlyEntries),
          ];
        }).toList(),
      ),
    );
  }

  List<DataRow> _buildMonthlyEntries(List<AmortizationEntry> entries) {
    return entries.map((entry) {
      return DataRow(cells: [
        DataCell(Text('')),
        DataCell(Text(_getMonthName(entry.month))),
        DataCell(Text(entry.principal.toStringAsFixed(2))),
        DataCell(Text(entry.interest.toStringAsFixed(2))),
        DataCell(Text(entry.totalPayment.toStringAsFixed(2))),
        DataCell(Text(entry.balance.toStringAsFixed(2))),
      ]);
    }).toList();
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

class AmortizationEntry {
  final DateTime paymentDate;
  final double principal;
  final double interest;
  final double totalPayment;
  final double balance;
  final int year;
  final int month;

  AmortizationEntry({
    required this.paymentDate,
    required this.principal,
    required this.interest,
    required this.totalPayment,
    required this.balance,
    required this.year,
    required this.month,
  });
}
