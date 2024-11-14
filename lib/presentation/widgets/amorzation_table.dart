// import 'package:flutter/material.dart';
//
// class AmortizationSummaryTable extends StatefulWidget {
//   final List<AmortizationEntry> entries;
//   final DateTime startDate;
//   final int tenureInYears;
//
//   const AmortizationSummaryTable({
//     Key? key,
//     required this.entries,
//     required this.startDate,
//     required this.tenureInYears,
//   }) : super(key: key);
//
//   @override
//   _AmortizationSummaryTableState createState() => _AmortizationSummaryTableState();
// }
//
// class _AmortizationSummaryTableState extends State<AmortizationSummaryTable> {
//   final Map<int, List<AmortizationEntry>> _groupedByYear = {};
//   int? _expandedYear; // To track which year is expanded
//
//   @override
//   void initState() {
//     super.initState();
//     _groupData();
//   }
//
//   // Group amortization entries by year
//   void _groupData() {
//     for (var entry in widget.entries) {
//       _groupedByYear.putIfAbsent(entry.year, () => []).add(entry);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.entries.isEmpty) {
//       return Center(child: Text('No data available.'));
//     }
//
//     // Generate the list of years based on the tenure
//     List<int> years = List.generate(widget.tenureInYears, (index) {
//       return widget.startDate.year + index;
//     });
//
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: DataTable(
//         columns: const [
//           DataColumn(label: Text('Year')),
//           DataColumn(label: Text('Principal')),
//           DataColumn(label: Text('Interest')),
//           DataColumn(label: Text('Details')),
//         ],
//         rows: _buildYearlyEntries(years),
//       ),
//     );
//   }
//
//   // Build yearly entries and handle expansion for loans/lends details
//   List<DataRow> _buildYearlyEntries(List<int> years) {
//     List<DataRow> rows = [];
//
//     for (var year in years) {
//       final yearlyData = _groupedByYear[year] ?? [];
//       final totalPrincipal = yearlyData.fold(0.0, (sum, entry) => sum + entry.principal);
//       final totalInterest = yearlyData.fold(0.0, (sum, entry) => sum + entry.interest);
//
//       // Add the year row
//       rows.add(DataRow(
//         cells: [
//           DataCell(
//             Row(
//               children: [
//                 Expanded(child: Text('$year')),
//                 IconButton(
//                   icon: Icon(
//                     _expandedYear == year ? Icons.expand_less : Icons.expand_more,
//                     color: Colors.blue,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _expandedYear = _expandedYear == year ? null : year; // Toggle expanded state
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ),
//           DataCell(Text('₹${totalPrincipal.toStringAsFixed(2)}')),
//           DataCell(Text('₹${totalInterest.toStringAsFixed(2)}')),
//           DataCell(Text('')),
//         ],
//       ));
//
//       // Show loan/lend details if the year is expanded
//       if (_expandedYear == year) {
//         rows.addAll(_buildLoanLendDetails(yearlyData));
//       }
//     }
//
//     return rows;
//   }
//
//   // Build loan/lend details for the expanded year
//   List<DataRow> _buildLoanLendDetails(List<AmortizationEntry> yearlyData) {
//     List<DataRow> rows = [];
//
//     for (var entry in yearlyData) {
//       rows.add(DataRow(
//         cells: [
//           DataCell(
//             Padding(
//               padding: const EdgeInsets.only(left: 32.0), // Indent for loan/lend details
//               child: Text(
//                 '${entry.loanLendName} (${entry.loanLendType == LoanLendType.loan ? 'Loan' : 'Lend'})',
//                 style: TextStyle(
//                   color: entry.loanLendType == LoanLendType.loan ? Colors.pink : Colors.blue,
//                 ),
//               ),
//             ),
//           ),
//           DataCell(Text('₹${entry.principal.toStringAsFixed(2)}')),
//           DataCell(Text('₹${entry.interest.toStringAsFixed(2)}')),
//           DataCell(Text(
//             '${entry.loanLendType == LoanLendType.loan ? 'Pink' : 'Blue'}',
//             style: TextStyle(
//               color: entry.loanLendType == LoanLendType.loan ? Colors.pink : Colors.blue,
//             ),
//           )),
//         ],
//       ));
//     }
//
//     return rows;
//   }
// }
//
// // Model for amortization entry
// class AmortizationEntry {
//   final String loanLendName;
//   final LoanLendType loanLendType; // Loan or Lend
//   final double principal;
//   final double interest;
//   final int year;
//   final int month;
//
//   AmortizationEntry({
//     required this.loanLendName,
//     required this.loanLendType,
//     required this.principal,
//     required this.interest,
//     required this.year,
//     required this.month,
//   });
// }
//
// enum LoanLendType { loan, lend }

import 'package:emi_manager/logic/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/home/logic/home_state_provider.dart';

class AmortizationSummaryTable extends ConsumerStatefulWidget {
  final List<AmortizationEntry> entries; // Full schedule for all loans/lends
  final DateTime startDate;
  final int tenureInYears;

  const AmortizationSummaryTable({
    Key? key,
    required this.entries,
    required this.startDate,
    required this.tenureInYears,
  }) : super(key: key);

  @override
  _AmortizationSummaryTableState createState() => _AmortizationSummaryTableState();
}

class _AmortizationSummaryTableState extends ConsumerState<AmortizationSummaryTable> {
  final Map<int, List<AmortizationEntry>> _groupedByYear = {};
  final Map<int, bool> _expandedYear = {}; // Track expanded year states
  final Map<String, bool> _expandedMonth = {}; // Track expanded month states


  void _groupDataByYear() {
    // print(widget.entries.length.toString());
    for (var entry in widget.entries) {
      _groupedByYear.putIfAbsent(entry.year, () => []).add(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allEmi = ref.watch(homeStateNotifierProvider.select((state) => state.emis));
    final currencySymbol = ref.watch(currencyProvider);
    print("EMI: ${allEmi.length}");
    // print(widget.entries.length.toString());
    if (allEmi.isEmpty) {
      return Center(child: Text('No data available.'));
    }

    _groupedByYear.clear();
    _groupDataByYear();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns:  [
          DataColumn(label: Text(' Year/Month')),
          DataColumn(label: Text('Principal ($currencySymbol)')),
          DataColumn(label: Text('Interest ($currencySymbol)')),
          DataColumn(label: Text('Total Payment ($currencySymbol)')),
        ],
        rows: _buildYearlyRows(),
      ),
    );
  }

  List<DataRow> _buildYearlyRows() {

    List<DataRow> rows = [];
    for (var year in _groupedByYear.keys) {
      final yearlyData = _groupedByYear[year] ?? [];
      final totalPrincipal = yearlyData.fold(0.0, (sum, e) => sum + e.principal);
      final totalInterest = yearlyData.fold(0.0, (sum, e) => sum + e.interest);
      final totalPayment = yearlyData.fold(0.0, (sum, e) => sum + e.totalPayment);

      rows.add(DataRow(
        cells: [
          DataCell(
            Row(
              children: [
                Expanded(child: Text('$year')),
                IconButton(
                  icon: Icon(
                    _expandedYear[year] == true ? Icons.expand_less : Icons.expand_more,
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
          DataCell(Text(
       totalPrincipal.toStringAsFixed(2),
            style: TextStyle(color: totalPrincipal < 0 ? Colors.red : Colors.blue),
          )),
          DataCell(Text(
            totalInterest.toStringAsFixed(2),
            style: TextStyle(color: totalInterest < 0 ? Colors.red : Colors.blue),
          )),
          DataCell(Text(
            totalPayment.toStringAsFixed(2),
            style: TextStyle(color: totalPayment < 0 ? Colors.red : Colors.blue),
          )),
        ],
      ));

      // Add month rows if this year is expanded
      if (_expandedYear[year] == true) {
        rows.addAll(_buildMonthlyRows(yearlyData, year));
      }
    }
    return rows;
  }

  List<DataRow> _buildMonthlyRows(List<AmortizationEntry> yearlyData, int year) {
    List<DataRow> rows = [];

    // Group monthly data for the selected year
    final Map<int, List<AmortizationEntry>> groupedByMonth = {};
    for (var entry in yearlyData) {
      groupedByMonth.putIfAbsent(entry.month, () => []).add(entry);
    }

    for (var month in groupedByMonth.keys) {
      final monthlyData = groupedByMonth[month]!;
      final monthlyPrincipal = monthlyData.fold(0.0, (sum, e) => sum + e.principal);
      final monthlyInterest = monthlyData.fold(0.0, (sum, e) => sum + e.interest);
      final monthlyPayment = monthlyData.fold(0.0, (sum, e) => sum + e.totalPayment);

      final monthKey = '$year-$month'; // Unique key for each month

      rows.add(DataRow(
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
                    _expandedMonth[monthKey] == true ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    setState(() {
                      _expandedMonth[monthKey] = !(_expandedMonth[monthKey] ?? false);
                    });
                  },
                ),
              ],
            ),
          ),
          DataCell(Text(
            monthlyPrincipal.toStringAsFixed(2),
            style: TextStyle(color: monthlyPrincipal < 0 ? Colors.red : Colors.blue),
          )),
          DataCell(Text(
            monthlyInterest.toStringAsFixed(2),
            style: TextStyle(color: monthlyInterest < 0 ? Colors.red : Colors.blue),
          )),
          DataCell(Text(
            monthlyPayment.toStringAsFixed(2),
            style: TextStyle(color: monthlyPayment < 0 ? Colors.red : Colors.blue),
          )),
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
          DataCell(Text(
            entry.principal.toStringAsFixed(2),
            style: TextStyle(color: entry.principal < 0 ? Colors.red : Colors.blue),
          )),
          DataCell(Text(
            entry.interest.toStringAsFixed(2),
            style: TextStyle(color: entry.interest < 0 ? Colors.red : Colors.blue),
          )),
          DataCell(Text(
            entry.totalPayment.toStringAsFixed(2),
            style: TextStyle(color: entry.totalPayment < 0 ? Colors.red : Colors.blue),
          )),
        ],
      );
    }).toList();
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
  final String title; // Individual loan title
  final double principal;
  final double interest;
  final double totalPayment;
  final int year;
  final int month;
  final int type;

  AmortizationEntry({
    required this.title,
    required this.principal,
    required this.interest,
    required this.totalPayment,
    required this.year,
    required this.month,
    required this.type,
  });
}
