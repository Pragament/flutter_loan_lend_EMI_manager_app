import 'package:emi_manager/logic/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emi_manager/presentation/widgets/formatted_amount.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:emi_manager/data/models/transaction_model.dart';

import '../pages/home/logic/home_state_provider.dart';

class AmortizationSummaryTable extends ConsumerStatefulWidget {
  final List<AmortizationEntry> entries; // Full schedule for all loans/lends
  final DateTime startDate;
  final int tenureInYears;
  final String emiId;  // Add this field

  const AmortizationSummaryTable({
    super.key,
    required this.entries,
    required this.startDate,
    required this.tenureInYears,
    required this.emiId,  // Add this parameter
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
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    var transactionsBox = await Hive.openBox<Transaction>('transactions');
    setState(() {
      _transactions = transactionsBox.values
          .where((t) => t.loanLendId == widget.emiId)
          .toList()
        ..sort((a, b) => a.datetime.compareTo(b.datetime));
    });
  }

  double _calculateUpdatedPrincipal(double originalPrincipal, DateTime entryDate) {
    // Start with the original principal
    double runningBalance = originalPrincipal;
    
    // Get all transactions up to this entry's date
    var applicableTransactions = _transactions.where((t) => 
      t.datetime.isBefore(entryDate) || t.datetime.isAtSameMomentAs(entryDate)
    ).toList()..sort((a, b) => a.datetime.compareTo(b.datetime));
    
    // Apply each transaction in chronological order
    for (var transaction in applicableTransactions) {
      if (transaction.type == "CR") {
        // Credit reduces the principal (payment received)
        runningBalance = (runningBalance - transaction.amount).clamp(0.0, double.infinity);
      } else if (transaction.type == "DR") {
        // Debit increases the principal (additional loan)
        runningBalance += transaction.amount;
      }
    }
    
    return runningBalance;
  }

  double _calculateUpdatedInterest(double updatedPrincipal, double originalInterest, double originalPrincipal) {
    // Calculate the effective interest rate from the original values
    double effectiveRate = (originalInterest / originalPrincipal);
    // Apply the same rate to the updated principal
    return updatedPrincipal * effectiveRate;
  }

  void _groupDataByYear() {
    _groupedByYear.clear();
    double runningPrincipal = 0.0;
    
    // Sort entries chronologically
    var sortedEntries = List<AmortizationEntry>.from(widget.entries)
      ..sort((a, b) {
        int yearCompare = a.year.compareTo(b.year);
        if (yearCompare != 0) return yearCompare;
        return a.month.compareTo(b.month);
      });
      
    // First pass: calculate initial running principal
    if (sortedEntries.isNotEmpty) {
      runningPrincipal = sortedEntries.first.principal;
    }
    
    // Second pass: update entries with running balance
    for (var entry in sortedEntries) {
      var entryDate = DateTime(entry.year, entry.month);
      var updatedPrincipal = _calculateUpdatedPrincipal(runningPrincipal, entryDate);
      var updatedInterest = _calculateUpdatedInterest(
        updatedPrincipal,
        entry.interest,
        entry.principal
      );
      
      var updatedEntry = entry.copyWith(
        updatedPrincipal: updatedPrincipal,
        updatedInterest: updatedInterest,
      );
      
      _groupedByYear.putIfAbsent(entry.year, () => []).add(updatedEntry);
      
      // Update running principal for next month
      runningPrincipal = updatedPrincipal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allEmi = ref.watch(homeStateNotifierProvider.select((state) => state.emis));
    final currencySymbol = ref.watch(currencyProvider);

    if (allEmi.isEmpty) {
      return const Center(child: Text('No data available.'));
    }

    _groupDataByYear();

    final screenWidth = MediaQuery.of(context).size.width;
    final currentYear = DateTime.now().year;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 8.0,
        radius: const Radius.circular(10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SizedBox(
              width: screenWidth * 2.0,
              child: DataTable(
                showBottomBorder: true,
                dividerThickness: 1.5,
                columnSpacing: 20,
                horizontalMargin: 10,
                dataRowHeight: 48,
                headingRowHeight: 48,
                columns: [
                  DataColumn(
                    label: Container(
                      width: screenWidth * 0.25,
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Year/Month',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      width: screenWidth * 0.3,
                      alignment: Alignment.centerRight,
                      child: const Text(
                        'Principal (₹)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      width: screenWidth * 0.3,
                      alignment: Alignment.centerRight,
                      child: const Text(
                        'Updated\nPrincipal (₹)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      width: screenWidth * 0.3,
                      alignment: Alignment.centerRight,
                      child: const Text(
                        'Interest (₹)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      width: screenWidth * 0.3,
                      alignment: Alignment.centerRight,
                      child: const Text(
                        'Updated\nInterest (₹)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
                rows: _buildYearlyRows(currentYear),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<DataRow> _buildYearlyRows(int currentYear) {
    List<DataRow> rows = [];
    for (var year in _groupedByYear.keys) {
      final yearlyData = _groupedByYear[year] ?? [];
      final totalPrincipal = yearlyData.fold(0.0, (sum, e) => sum + e.principal);
      final updatedPrincipal = yearlyData.fold(0.0, (sum, e) => sum + (e.updatedPrincipal ?? e.principal));
      final totalInterest = yearlyData.fold(0.0, (sum, e) => sum + e.interest);
      final updatedInterest = yearlyData.fold(0.0, (sum, e) => sum + (e.updatedInterest ?? e.interest));

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
                    _expandedYear[year] == true ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue,
                    size: 20,
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
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '₹ ${totalPrincipal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '₹ ${updatedPrincipal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '₹ ${totalInterest.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '₹ ${updatedInterest.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ));

      if (_expandedYear[year] == true) {
        rows.addAll(_buildMonthlyRows(yearlyData, year, currentYear));
      }
    }
    return rows;
  }

  List<DataRow> _buildMonthlyRows(List<AmortizationEntry> yearlyData, int year, int currentYear) {
    List<DataRow> rows = [];
    final Map<int, List<AmortizationEntry>> groupedByMonth = {};
    for (var entry in yearlyData) {
      groupedByMonth.putIfAbsent(entry.month, () => []).add(entry);
    }

    for (var month in groupedByMonth.keys) {
      final monthlyData = groupedByMonth[month]!;
      final monthlyPrincipal = monthlyData.fold(0.0, (sum, e) => sum + e.principal);
      final monthlyUpdatedPrincipal = monthlyData.fold(0.0, (sum, e) => sum + (e.updatedPrincipal ?? e.principal));
      final monthlyInterest = monthlyData.fold(0.0, (sum, e) => sum + e.interest);
      final monthlyUpdatedInterest = monthlyData.fold(0.0, (sum, e) => sum + (e.updatedInterest ?? e.interest));

      final monthKey = '$year-$month';
      final bool isCurrentMonth = year == currentYear && month == DateTime.now().month;

      rows.add(DataRow(
        color: isCurrentMonth ? MaterialStateProperty.all(Colors.amber.withOpacity(0.2)) : null,
        cells: [
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    _getMonthName(month),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                IconButton(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _expandedMonth[monthKey] == true ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue,
                    size: 20,
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
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '₹ ${monthlyPrincipal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '₹ ${monthlyUpdatedPrincipal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '₹ ${monthlyInterest.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '₹ ${monthlyUpdatedInterest.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ));

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
              padding: const EdgeInsets.only(left: 48.0),
              child: Text(entry.title), // Individual loan title
            ),
          ),
          DataCell(Text('₹ ${entry.principal.toStringAsFixed(2)}')),
          DataCell(Text('₹ ${(entry.updatedPrincipal ?? entry.principal).toStringAsFixed(2)}')),
          DataCell(Text('₹ ${entry.interest.toStringAsFixed(2)}')),
          DataCell(Text('₹ ${entry.updatedInterest?.toStringAsFixed(2) ?? entry.interest.toStringAsFixed(2)}')),
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
  final double? updatedPrincipal;
  final double interest;
  final double? updatedInterest;  // Add field for updated interest
  final double totalPayment;
  final int year;
  final int month;
  final int type;

  AmortizationEntry({
    required this.title,
    required this.principal,
    this.updatedPrincipal,
    required this.interest,
    this.updatedInterest,  // Add to constructor
    required this.totalPayment,
    required this.year,
    required this.month,
    required this.type,
  });

  AmortizationEntry copyWith({
    String? title,
    double? principal,
    double? updatedPrincipal,
    double? interest,
    double? updatedInterest,  // Add to copyWith
    double? totalPayment,
    int? year,
    int? month,
    int? type,
  }) {
    return AmortizationEntry(
      title: title ?? this.title,
      principal: principal ?? this.principal,
      updatedPrincipal: updatedPrincipal ?? this.updatedPrincipal,
      interest: interest ?? this.interest,
      updatedInterest: updatedInterest ?? this.updatedInterest,  // Add to return
      totalPayment: totalPayment ?? this.totalPayment,
      year: year ?? this.year,
      month: month ?? this.month,
      type: type ?? this.type,
    );
  }
}
