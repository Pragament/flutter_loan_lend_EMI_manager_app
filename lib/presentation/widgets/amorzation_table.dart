import 'package:flutter/material.dart';

class AmortizationTable extends StatefulWidget {
  final List<AmortizationEntry> schedule;
  final DateTime startDate;
  final int tenureInYears;

  const AmortizationTable({
    Key? key,
    required this.schedule,
    required this.startDate,
    required this.tenureInYears,
  }) : super(key: key);

  @override
  _AmortizationTableState createState() => _AmortizationTableState();
}

class _AmortizationTableState extends State<AmortizationTable> {
  final Map<int, List<AmortizationEntry>> _groupedByYear = {};
  int? _expandedYear;

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
          DataColumn(label: Text('Detailed Data')),
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
          DataCell(Text('₹${totalPrincipal.toStringAsFixed(2)}')),
          DataCell(Text('₹${totalInterest.toStringAsFixed(2)}')),
          DataCell(Text('')),
        ],
      ));

      // Add loan/lend details if this year is expanded
      if (_expandedYear == year) {
        rows.addAll(_buildLoanLendDetails(yearlyData));
      }
    }

    return rows;
  }

  List<DataRow> _buildLoanLendDetails(List<AmortizationEntry> yearlyData) {
    List<DataRow> rows = [];

    for (var entry in yearlyData) {
      rows.add(DataRow(
        cells: [
          DataCell(
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Text('Loan/Lend ${entry.loanLendName}'),
            ),
          ),
          DataCell(Text('₹${entry.principal.toStringAsFixed(2)}')),
          DataCell(Text('₹${entry.interest.toStringAsFixed(2)}')),
          DataCell(
            Text(
              '${entry.loanLendType == LoanLendType.loan ? "(Pink)" : "(Blue)"}',
              style: TextStyle(
                color: entry.loanLendType == LoanLendType.loan ? Colors.pink : Colors.blue,
              ),
            ),
          ),
        ],
      ));
    }

    return rows;
  }
}

// Model for amortization entry
class AmortizationEntry {
  final String loanLendName;
  final LoanLendType loanLendType; // Loan or Lend
  final double principal;
  final double interest;
  final int year;
  final int month;

  AmortizationEntry({
    required this.loanLendName,
    required this.loanLendType,
    required this.principal,
    required this.interest,
    required this.year,
    required this.month,
  });
}

enum LoanLendType { loan, lend }
