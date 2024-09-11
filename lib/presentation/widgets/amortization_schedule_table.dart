import 'package:flutter/material.dart';

class AmortizationScheduleTable extends StatefulWidget {
  final List<AmortizationEntry> schedule;
  final DateTime startDate;
  final int tenureInYears;

  const AmortizationScheduleTable({
    Key? key,
    required this.schedule,
    required this.startDate,
    required this.tenureInYears,
  }) : super(key: key);

  @override
  _AmortizationScheduleTableState createState() => _AmortizationScheduleTableState();
}

class _AmortizationScheduleTableState extends State<AmortizationScheduleTable> {
  final Map<int, List<AmortizationEntry>> _groupedByYear = {};
  int? _expandedYear; // To track which year is expanded

  @override
  void initState() {
    super.initState();
    _groupData();
  }

  void _groupData() {
    for (var entry in widget.schedule) {
      // Group amortization data by year
      _groupedByYear.putIfAbsent(entry.year, () => []).add(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.schedule.isEmpty) {
      return Center(child: Text('No data available.'));
    }

    // Generate years dynamically based on tenure and startDate
    List<int> years = List.generate(widget.tenureInYears, (index) {
      return widget.startDate.year + index;
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Year')),
          DataColumn(label: Text('Principal')),
          DataColumn(label: Text('Interest')),
          DataColumn(label: Text('Total Payment')),
          DataColumn(label: Text('Balance')),
        ],
        rows: _buildYearlyEntries(years), // Build rows dynamically
      ),
    );
  }

  // Build yearly entries for the table, and handle expansion for months
  List<DataRow> _buildYearlyEntries(List<int> years) {
    List<DataRow> rows = [];

    for (var year in years) {
      final yearlyData = _groupedByYear[year] ?? [];
      final totalPrincipal = yearlyData.fold(0.0, (sum, entry) => sum + entry.principal);
      final totalInterest = yearlyData.fold(0.0, (sum, entry) => sum + entry.interest);
      final totalPayment = yearlyData.fold(0.0, (sum, entry) => sum + entry.totalPayment);
      final totalBalance = yearlyData.isNotEmpty ? yearlyData.last.balance : 0.0;

      // Add year row
      rows.add(DataRow(
        cells: [
          DataCell(
            Row(
              children: [
                Expanded(child: Text('$year')),
                IconButton(
                  icon: Icon(
                    _expandedYear == year ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    setState(() {
                      _expandedYear = _expandedYear == year ? null : year; // Toggle expanded state
                    });
                  },
                ),
              ],
            ),
          ),
          DataCell(Text(totalPrincipal.toStringAsFixed(2))),
          DataCell(Text(totalInterest.toStringAsFixed(2))),
          DataCell(Text(totalPayment.toStringAsFixed(2))),
          DataCell(Text(totalBalance.toStringAsFixed(2))),
        ],
      ));

      // Add month rows if this year is expanded
      if (_expandedYear == year) {
        rows.addAll(_buildMonthlyDataRows(yearlyData, year));
      }
    }

    return rows;
  }

  // Build monthly rows for expanded year
  List<DataRow> _buildMonthlyDataRows(List<AmortizationEntry> yearlyData, int year) {
    List<DataRow> rows = [];

    final startMonth = widget.startDate.month;
    final startYear = widget.startDate.year;

    for (var entry in yearlyData) {
      // Ensure entries are only shown starting from the start date's month/year
      if (entry.year > startYear || (entry.year == startYear && entry.month >= startMonth)) {
        rows.add(DataRow(
          cells: [
            DataCell(
              Padding(
                padding: const EdgeInsets.only(left: 32.0), // Indent month rows
                child: Text(_getMonthName(entry.month)),
              ),
            ),
            DataCell(Text(entry.principal.toStringAsFixed(2))),
            DataCell(Text(entry.interest.toStringAsFixed(2))),
            DataCell(Text(entry.totalPayment.toStringAsFixed(2))),
            DataCell(Text(entry.balance.toStringAsFixed(2))),
          ],
        ));
      }
    }

    return rows;
  }

  // Utility function to get month name from month number
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

// Model for amortization entry
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
