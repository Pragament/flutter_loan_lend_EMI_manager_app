import 'package:flutter/material.dart';

class AmortizationEntry {
  final DateTime paymentDate;
  final double principal;
  final double interest;
  final double totalPayment;
  final double balance;
  final int year;

  AmortizationEntry({
    required this.paymentDate,
    required this.principal,
    required this.interest,
    required this.totalPayment,
    required this.balance,
    required this.year,
  });
}

class AmortizationScheduleTable extends StatelessWidget {
  final List<AmortizationEntry> schedule;

  const AmortizationScheduleTable({
    Key? key,
    required this.schedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amortization Schedule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Year')),
              DataColumn(label: Text('Principal')),
              DataColumn(label: Text('Interest')),
              DataColumn(label: Text('Total Payment')),
              DataColumn(label: Text('Balance')),
            ],
            rows: schedule.map((entry) {
              return DataRow(cells: [
                DataCell(Text(entry.year.toString())),
                DataCell(Text(entry.principal.toStringAsFixed(2))),
                DataCell(Text(entry.interest.toStringAsFixed(2))),
                DataCell(Text(entry.totalPayment.toStringAsFixed(2))),
                DataCell(Text(entry.balance.toStringAsFixed(2))),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}
