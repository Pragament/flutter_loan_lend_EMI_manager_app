import 'package:flutter/material.dart';

class AmortizationSummaryTable extends StatefulWidget {
  final List<AmortizationEntry> entries;
  final DateTime startDate;
  final double totalEMI;
  final double totalInterest;
  final double totalAmount;

  const AmortizationSummaryTable({
    Key? key,
    required this.entries,
    required this.startDate,
    required this.totalEMI,
    required this.totalInterest,
    required this.totalAmount,
  }) : super(key: key);

  @override
  _AmortizationSummaryTableState createState() => _AmortizationSummaryTableState();
}

class _AmortizationSummaryTableState extends State<AmortizationSummaryTable> {
  final Map<int, List<AmortizationEntry>> _groupedByYear = {};
  int? _expandedYear; // To track which year is expanded

  @override
  void initState() {
    super.initState();
    _groupData();
  }

  void _groupData() {
    for (var entry in widget.entries) {
      _groupedByYear.putIfAbsent(entry.year, () => []).add(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entries.isEmpty) {
      return Center(child: Text('No data available.'));
    }

    List<int> years = _generateYears();

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

  List<int> _generateYears() {
    final endDate = widget.startDate.add(Duration(days: 365 * (widget.totalAmount / widget.totalEMI).toInt()));
    return List.generate(endDate.year - widget.startDate.year + 1, (index) {
      return widget.startDate.year + index;
    });
  }

  List<DataRow> _buildYearlyEntries(List<int> years) {
    List<DataRow> rows = [];

    for (var year in years) {
      final yearlyData = _groupedByYear[year] ?? [];
      final totalPrincipal = yearlyData.fold(0.0, (sum, entry) => sum + entry.principal);
      final totalInterest = yearlyData.fold(0.0, (sum, entry) => sum + entry.interest);

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
              child: Text('Loan/Lend ${entry.loanLendName} (${entry.loanLendType == LoanLendType.loan ? 'Loan' : 'Lend'})'),
            ),
          ),
          DataCell(Text('₹${entry.principal.toStringAsFixed(2)}')),
          DataCell(Text('₹${entry.interest.toStringAsFixed(2)}')),
          DataCell(
            Text(
              '(${entry.loanLendType == LoanLendType.loan ? "Pink" : "Blue"})',
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
