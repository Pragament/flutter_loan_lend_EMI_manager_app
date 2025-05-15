import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';
import 'package:intl/intl.dart';

class AmortizationScheduleTable extends StatefulWidget {
  final List<AmortizationEntry> schedule;
  final DateTime startDate;
  final int tenureInYears;
  final List<Transaction> transactions;

  const AmortizationScheduleTable({
    super.key,
    required this.schedule,
    required this.startDate,
    required this.tenureInYears,
    required this.transactions,
  });

  @override
  _AmortizationScheduleTableState createState() => _AmortizationScheduleTableState();
}

class _AmortizationScheduleTableState extends State<AmortizationScheduleTable> {
  final Map<int, List<AmortizationEntry>> _groupedByYear = {};
  int? _expandedYear;
  final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _groupData();
    _updatePrincipalWithTransactions();
  }

  void _groupData() {
    for (var entry in widget.schedule) {
      _groupedByYear.putIfAbsent(entry.year, () => []).add(entry);
    }
  }

  void _updatePrincipalWithTransactions() {
    // Start with original principal values
    double runningBalance = widget.schedule.first.principal;
    
    // Initialize adjusted principal with original principal
    for (var entry in widget.schedule) {
      entry.adjustedPrincipal = entry.principal;
    }

    // Sort transactions by date
    final sortedTransactions = [...widget.transactions]..sort((a, b) => a.datetime.compareTo(b.datetime));

    // For each entry, calculate the updated principal and interest considering all previous transactions
    for (var entry in widget.schedule) {
      // Apply any transactions that occurred before this payment
      for (var transaction in sortedTransactions) {
        if (transaction.datetime.isBefore(entry.paymentDate)) {
          if (transaction.type == 'CR') {
            runningBalance -= transaction.amount; // Credit reduces principal
          } else {
            runningBalance += transaction.amount; // Debit increases principal
          }
        }
      }
      entry.adjustedPrincipal = runningBalance;
      
      // Calculate adjusted interest based on the effective interest rate
      double effectiveRate = entry.interest / entry.principal; // Get original interest rate
      entry.adjustedInterest = entry.adjustedPrincipal * effectiveRate; // Apply rate to new principal
      
      runningBalance -= entry.principal; // Reduce by monthly principal payment
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.schedule.isEmpty) {
      return const Center(child: Text('No data available.'));
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Scrollbar(
      thumbVisibility: true,
      thickness: 6.0,
      radius: const Radius.circular(10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          width: screenWidth * 1.5,
          child: DataTable(
            columnSpacing: 15,
            horizontalMargin: 8,
            dataRowHeight: 48,
            headingRowHeight: 48,
            columns: [
              DataColumn(
                label: Container(
                  width: screenWidth * 0.2,
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Year/Month',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              DataColumn(
                label: Container(
                  width: screenWidth * 0.25,
                  alignment: Alignment.centerRight,
                  child: const Text(
                    'Principal (₹)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              DataColumn(
                label: Container(
                  width: screenWidth * 0.25,
                  alignment: Alignment.centerRight,
                  child: const Text(
                    'Updated\nPrincipal (₹)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              DataColumn(
                label: Container(
                  width: screenWidth * 0.25,
                  alignment: Alignment.centerRight,
                  child: const Text(
                    'Interest (₹)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              DataColumn(
                label: Container(
                  width: screenWidth * 0.25,
                  alignment: Alignment.centerRight,
                  child: const Text(
                    'Updated\nInterest (₹)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
            rows: _buildYearlyEntries(),
          ),
        ),
      ),
    );
  }

  List<DataRow> _buildYearlyEntries() {
    List<DataRow> rows = [];

    for (var year in _groupedByYear.keys) {
      final yearlyData = _groupedByYear[year] ?? [];
      final totalPrincipal = yearlyData.fold(0.0, (sum, entry) => sum + entry.principal);
      final totalAdjustedPrincipal = yearlyData.fold(0.0, (sum, entry) => sum + entry.adjustedPrincipal);
      final totalInterest = yearlyData.fold(0.0, (sum, entry) => sum + entry.interest);
      final totalAdjustedInterest = yearlyData.fold(0.0, (sum, entry) => sum + (entry.adjustedInterest ?? entry.interest));

      rows.add(DataRow(
        cells: [
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$year',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _expandedYear == year ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _expandedYear = _expandedYear == year ? null : year;
                    });
                  },
                ),
              ],
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                currencyFormat.format(totalPrincipal),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                currencyFormat.format(totalAdjustedPrincipal),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                currencyFormat.format(totalInterest),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                currencyFormat.format(totalAdjustedInterest),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ));

      if (_expandedYear == year) {
        rows.addAll(_buildMonthlyDataRows(yearlyData));
      }
    }
    return rows;
  }

  List<DataRow> _buildMonthlyDataRows(List<AmortizationEntry> yearlyData) {
    List<DataRow> rows = [];

    for (var entry in yearlyData) {
      rows.add(DataRow(
        cells: [
          DataCell(
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                _getMonthName(entry.month),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                currencyFormat.format(entry.principal),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                currencyFormat.format(entry.adjustedPrincipal),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                currencyFormat.format(entry.interest),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                currencyFormat.format(entry.adjustedInterest ?? entry.interest),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ));
    }
    return rows;
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
  double adjustedPrincipal;
  double? adjustedInterest;

  AmortizationEntry({
    required this.paymentDate,
    required this.principal,
    required this.interest,
    required this.totalPayment,
    required this.balance,
    required this.year,
    required this.month,
    this.adjustedPrincipal = 0.0,
    this.adjustedInterest,
  });
}
