import 'package:emi_manager/logic/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emi_manager/presentation/widgets/formatted_amount.dart';

import '../pages/home/logic/home_state_provider.dart';

class AmortizationSummaryTable extends ConsumerStatefulWidget {
  final List<AmortizationEntry> entries; // Full schedule for all loans/lends
  final DateTime startDate;
  final int tenureInYears;
  final void Function(AmortizationEntry)? onDeleteEntry; // ADD THIS LINE

  const AmortizationSummaryTable({
    super.key,
    required this.entries,
    required this.startDate,
    required this.tenureInYears,
    this.onDeleteEntry, // ADD THIS LINE
  });

  @override
  _AmortizationSummaryTableState createState() =>
      _AmortizationSummaryTableState();
}

class _AmortizationSummaryTableState
    extends ConsumerState<AmortizationSummaryTable> {
  final Map<int, List<AmortizationEntry>> _groupedByYear = {};
  final Map<int, bool> _expandedYear = {}; // Track expanded year states
  final Map<String, bool> _expandedMonth = {}; // Track expanded month states

  void _groupDataByYear() {
    for (var entry in widget.entries) {
      _groupedByYear.putIfAbsent(entry.year, () => []).add(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allEmi =
        ref.watch(homeStateNotifierProvider.select((state) => state.emis));
    final currencySymbol = ref.watch(currencyProvider);

    if (allEmi.isEmpty) {
      return const Center(child: Text('No data available.'));
    }

    _groupedByYear.clear();
    _groupDataByYear();

    final currentYear = DateTime.now().year;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text(' Year/Month')),
          DataColumn(label: Text('Principal ($currencySymbol)')),
          DataColumn(label: Text('Interest ($currencySymbol)')),
          DataColumn(label: Text('Total Payment ($currencySymbol)')),
          // ADD THIS COLUMN IF YOU WANT DELETE BUTTONS
          if (widget.onDeleteEntry != null)
            const DataColumn(label: Text('Actions')),
        ],
        rows: _buildYearlyRows(currentYear),
      ),
    );
  }

  List<DataRow> _buildYearlyRows(int currentYear) {
    List<DataRow> rows = [];
    for (var year in _groupedByYear.keys) {
      final yearlyData = _groupedByYear[year] ?? [];
      final totalPrincipal =
          yearlyData.fold(0.0, (sum, e) => sum + e.principal);
      final totalInterest = yearlyData.fold(0.0, (sum, e) => sum + e.interest);
      final totalPayment =
          yearlyData.fold(0.0, (sum, e) => sum + e.totalPayment);

      rows.add(DataRow(
        cells: [
          DataCell(
            Row(
              children: [
                Expanded(child: Text('$year')),
                IconButton(
                  icon: Icon(
                    _expandedYear[year] == true
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    setState(() {
                      _expandedYear[year] = !(_expandedYear[year] ?? false);
                    });
                  },
                ),
              ],
            ),
          ),
          DataCell(FormattedAmount(amount: totalPrincipal)),
          DataCell(FormattedAmount(amount: totalInterest)),
          DataCell(FormattedAmount(amount: totalPayment)),
          // ADD THIS CELL IF YOU WANT DELETE BUTTONS
          if (widget.onDeleteEntry != null)
            const DataCell(SizedBox.shrink()), // Empty cell for year rows
        ],
      ));

      // Add month rows if this year is expanded
      if (_expandedYear[year] == true) {
        rows.addAll(_buildMonthlyRows(yearlyData, year, currentYear));
      }
    }
    return rows;
  }

  List<DataRow> _buildMonthlyRows(
      List<AmortizationEntry> yearlyData, int year, int currentYear) {
    List<DataRow> rows = [];

    // Group monthly data for the selected year
    final Map<int, List<AmortizationEntry>> groupedByMonth = {};
    for (var entry in yearlyData) {
      groupedByMonth.putIfAbsent(entry.month, () => []).add(entry);
    }

    for (var month in groupedByMonth.keys) {
      final monthlyData = groupedByMonth[month]!;
      final monthlyPrincipal =
          monthlyData.fold(0.0, (sum, e) => sum + e.principal);
      final monthlyInterest =
          monthlyData.fold(0.0, (sum, e) => sum + e.interest);
      final monthlyPayment =
          monthlyData.fold(0.0, (sum, e) => sum + e.totalPayment);

      final monthKey = '$year-$month'; // Unique key for each month
      final bool isCurrentMonth =
          year == currentYear && month == DateTime.now().month;

      rows.add(DataRow(
        color: isCurrentMonth
            ? WidgetStateProperty.all(Colors.amber.withOpacity(0.2))
            : null,
        cells: [
          DataCell(
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(_getMonthName(month)),
                ),
                IconButton(
                  icon: Icon(
                    _expandedMonth[monthKey] == true
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    setState(() {
                      _expandedMonth[monthKey] =
                          !(_expandedMonth[monthKey] ?? false);
                    });
                  },
                ),
              ],
            ),
          ),
          DataCell(FormattedAmount(amount: monthlyPrincipal)),
          DataCell(FormattedAmount(amount: monthlyInterest)),
          DataCell(FormattedAmount(amount: monthlyPayment)),
          // ADD THIS CELL IF YOU WANT DELETE BUTTONS
          if (widget.onDeleteEntry != null)
            const DataCell(SizedBox.shrink()), // Empty cell for month rows
        ],
      ));

      // Add individual loan rows if this month is expanded
      if (_expandedMonth[monthKey] == true) {
        rows.addAll(_buildLoanRows(monthlyData));
      }
    }
    return rows;
  }

  List<DataRow> _buildLoanRows(List<AmortizationEntry> monthlyData) {
    return monthlyData.map((entry) {
      return DataRow(
        cells: [
          DataCell(
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Text(entry.title), // Individual loan title
            ),
          ),
          DataCell(FormattedAmount(amount: entry.principal)),
          DataCell(FormattedAmount(amount: entry.interest)),
          DataCell(FormattedAmount(amount: entry.totalPayment)),
          // ADD THIS CELL FOR DELETE BUTTON ON INDIVIDUAL ENTRIES
          if (widget.onDeleteEntry != null)
            DataCell(
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => widget.onDeleteEntry!(entry),
              ),
            ),
        ],
      );
    }).toList();
  }

  // Utility function to get month name from month number
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

// Model for amortization entry
class AmortizationEntry {
  final String title; // Individual loan title
  final double principal;
  final double interest;
  final double totalPayment;
  final int year;
  final int month;
  final int type;
  final String emiId; // ADD THIS LINE

  AmortizationEntry({
    required this.title,
    required this.principal,
    required this.interest,
    required this.totalPayment,
    required this.year,
    required this.month,
    required this.type,
    required this.emiId, // ADD THIS LINE
  });
}
