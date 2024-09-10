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
  final Map<int, List<AmortizationEntry>> _groupedByMonth = {};
  int? _expandedYear;

  @override
  void initState() {
    super.initState();
    _groupData();
  }

  void _groupData() {
    for (var entry in widget.schedule) {
      _groupedByYear.putIfAbsent(entry.year, () => []).add(entry);
      _groupedByMonth.putIfAbsent(entry.year, () => []).add(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.schedule.isEmpty) {
      return Center(child: Text('No data available.'));
    }

    List<int> years = List.generate(widget.tenureInYears + 1, (index) {
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
        rows: _buildYearlyEntries(years),
      ),
    );
  }

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
                      _expandedYear = _expandedYear == year ? null : year;
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
        rows.addAll(
          _buildMonthlyDataRows(yearlyData),
        );
      }
    }

    return rows;
  }

  List<DataRow> _buildMonthlyDataRows(List<AmortizationEntry> entries) {
    final startMonth = widget.startDate.month;
    final startYear = widget.startDate.year;
    List<DataRow> rows = [];

    for (var entry in entries) {
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
