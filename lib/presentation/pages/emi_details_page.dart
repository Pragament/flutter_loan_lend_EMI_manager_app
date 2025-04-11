// ignore_for_file: unused_local_variable

import 'package:collection/collection.dart';
import 'package:emi_manager/data/models/emi_model.dart';
import 'package:emi_manager/logic/currency_provider.dart';
import 'package:emi_manager/logic/emis_provider.dart';
import 'package:emi_manager/logic/transaction_provider.dart';
import 'package:emi_manager/logic/rounding_provider.dart';
import 'package:emi_manager/presentation/constants.dart';
import 'package:emi_manager/presentation/pages/new_transaction_page.dart';
import 'package:emi_manager/utils/global_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emi_manager/presentation/l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import '../../data/models/transaction_model.dart';
import '../widgets/amortization_schedule_table.dart';
import '../widgets/bar_graph.dart';
import 'dart:math';

import 'home/transaction_details_page.dart';

class EmiDetailsPage extends ConsumerStatefulWidget {
  const EmiDetailsPage({super.key, required this.emiId});
  final String emiId;

  @override
  _EmiDetailsPageState createState() => _EmiDetailsPageState();
}

class _EmiDetailsPageState extends ConsumerState<EmiDetailsPage> {
  bool _showLottie = false; // State variable to control Lottie visibility

  @override
  Widget build(BuildContext context) {
    final emi = ref.watch(emisNotifierProvider
        .select((emis) => emis.firstWhere((emi) => emi.id == widget.emiId)));

    final List<Transaction> transactions = ref
        .watch(transactionsNotifierProvider)
        .where((transaction) => transaction.loanLendId == widget.emiId)
        .toList();

    final l10n = AppLocalizations.of(context)!;
    final emiTypeColor = emi.emiType == 'lend'
        ? lendColor(context, true)
        : loanColor(context, true);

    final double principalAmount = emi.principalAmount;
    final double interestAmount =
        emi.totalEmi != null ? emi.totalEmi! - principalAmount : 0.0;
    final double totalAmount = emi.totalEmi ?? 0.0;

    final DateTime startDate = emi.startDate;
    final DateTime? endDate = emi.endDate;

    // Get the exact tenure values from the EMI object
    final String tenure = _calculateTenure(l10n, emi);

    // Correctly parse the tenure for years
    final int tenureInYears;
    if (emi.selectedYears != null) {
      tenureInYears = emi.selectedYears!.toInt();
    } else {
      final parts = tenure.split(' ');
      tenureInYears = int.parse(parts[0]);
    }

    final List<AmortizationEntry> schedule = _generateAmortizationSchedule(
      tenureYears: tenureInYears,
      principalAmount: principalAmount,
      interestAmount: emi.interestRate,
      totalAmount: totalAmount,
      startDate: startDate,
    );

    final List<double> principalAmounts = _getPrincipalAmounts(schedule);
    final List<double> interestAmounts = _getInterestAmounts(schedule);
    final List<double> balances = _getBalances(schedule);
    final List<int> years = List.generate(
      tenureInYears,
      (index) => startDate.year + index,
    );

    final settings = ref.watch(roundingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(emi.title),
        backgroundColor: emiTypeColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Use Navigator instead of GoRouter
          },
        ),
      ),
      floatingActionButton: emi.emiType == 'lend'
          ? Stack(
              children: [
                if (_showLottie)
                  Positioned(
                    bottom: 80, // Adjust this value as needed
                    left: MediaQuery.of(context).size.width / 2 - 50,
                    child: Lottie.asset(
                      'assets/animations/arrow_down.json', // Your Lottie arrow animation
                      width: 100,
                      height: 100,
                      repeat: false, // Play only once
                      onLoaded: (composition) {
                        Future.delayed(composition.duration, () {
                          if (mounted) {
                            setState(() {
                              _showLottie = false;
                            });
                          }
                        });
                      },
                    ),
                  ),
                FloatingActionButton(
                  heroTag: 'CR',
                  backgroundColor: Colors.green,
                  onPressed: () {
                    setState(() {
                      _showLottie = true; // Show animation on button press
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => NewTransactionPage(
                              type: "CR", emiId: widget.emiId)),
                    );
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.indigo[900],
                  ),
                ),
              ],
            )
          : FloatingActionButton(
              heroTag: 'DR',
              backgroundColor: Colors.red,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          NewTransactionPage(type: "DR", emiId: widget.emiId)),
                );
              },
              child: Icon(
                Icons.remove,
                color: Colors.indigo[900],
              ),
            ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmiInfoSection(context, ref, emi, l10n, interestAmount,
                  principalAmount, totalAmount, tenure),
              const SizedBox(height: 24),
              _buildPieChart(ref, interestAmount, principalAmount, totalAmount),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    width: 150,
                    child: Column(
                      children: [
                        _LegendItem(
                          color: Colors.green,
                          label: l10n.legendPrincipalAmount,
                        ),
                        _LegendItem(
                          color: Colors.orange,
                          label: l10n.legendInterestAmount,
                        ),
                        _LegendItem(
                          color: Colors.red,
                          label: l10n.legendBalanceAmount,
                        ),
                        Lottie.asset(
                          'assets/animations/chart_growing.json', // Ensure the correct file path
                          width: 250,
                          height: 150,
                          repeat: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              BarGraph(
                principalAmounts: principalAmounts,
                interestAmounts: interestAmounts,
                balances: balances,
                years: years,
              ),
              const SizedBox(height: 24),
              AmortizationScheduleTable(
                schedule: schedule,
                startDate: startDate,
                tenureInYears: tenureInYears,
              ),
              _buildTransactionList(context, transactions),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(
      BuildContext context, List<Transaction> transactions) {
    return ListView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling to integrate with the main scroll view
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isCredit = transaction.type == 'CR';
        final amountColor = isCredit ? Colors.green : Colors.red;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          child: Material(
            borderRadius: BorderRadius.circular(10),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                title: Text(
                  transaction.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text(
                  transaction.datetime.toLocal().toString().substring(0, 16),
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Text(
                  "${isCredit ? '+' : '-'}₹${GlobalFormatter.formatNumber(ref, transaction.amount)}",
                  style: TextStyle(
                      fontSize: 16.0,
                      color: amountColor,
                      fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TransactionDetailsPage(transaction: transaction),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmiInfoSection(
      BuildContext context,
      WidgetRef ref,
      dynamic emi,
      AppLocalizations l10n,
      double interestAmount,
      double principalAmount,
      double totalAmount,
      String tenure) {
    final currencySymbol = ref.watch(currencyProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(ref, l10n.emi,
            '$currencySymbol${emi.monthlyEmi != null ? GlobalFormatter.formatNumber(ref, emi.monthlyEmi!) : 'N/A'}',
            isBold: true, fontSize: 20),
        const Divider(thickness: 1, color: Colors.grey),
        _buildInfoRow(ref, l10n.interestAmount,
            '$currencySymbol${GlobalFormatter.formatNumber(ref, interestAmount)}'),
        _buildInfoRow(ref, l10n.totalAmount,
            '$currencySymbol${GlobalFormatter.formatNumber(ref, totalAmount)}'),
        const SizedBox(height: 16),
        _buildInfoRow(ref, l10n.loanAmount,
            '$currencySymbol${GlobalFormatter.formatNumber(ref, principalAmount)}'),
        _buildInfoRow(ref, l10n.tenure, tenure),
        _buildInfoRow(ref, l10n.tenure, tenure),
      ],
    );
  }

  Widget _buildInfoRow(WidgetRef ref, String label, String value,
      {bool isBold = false, double fontSize = 16}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(WidgetRef ref, double interestAmount,
      double principalAmount, double totalAmount) {
    final interestPercent = totalAmount > 0
        ? GlobalFormatter.roundNumber(ref, (interestAmount / totalAmount * 100))
        : 0.0;
    final principalPercent = totalAmount > 0
        ? GlobalFormatter.roundNumber(
            ref, (principalAmount / totalAmount * 100))
        : 0.0;

    return SizedBox(
      width: double.infinity,
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.blue,
              value: interestAmount,
              title: '$interestPercent%',
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: Colors.green,
              value: principalAmount,
              title: '$principalPercent%',
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          borderData: FlBorderData(show: false),
          sectionsSpace: 4,
          centerSpaceRadius: 0,
        ),
      ),
    );
  }

  List<AmortizationEntry> _generateAmortizationSchedule({
    required int tenureYears,
    required double principalAmount,
    required double interestAmount,
    required double totalAmount,
    required DateTime startDate, // Use start date from EMI details
  }) {
    List<AmortizationEntry> schedule = [];
    DateTime paymentDate = startDate;

    double monthlyInterestRate = interestAmount / (12 * 100);
    int totalMonths = tenureYears * 12;

    double monthlyEmi = GlobalFormatter.roundNumber(
        ref,
        (principalAmount *
                monthlyInterestRate *
                pow(1 + monthlyInterestRate, totalMonths)) /
            (pow(1 + monthlyInterestRate, totalMonths) - 1));

    double remainingPrincipal = principalAmount;

    for (int month = 0; month < totalMonths; month++) {
      double monthlyInterest = GlobalFormatter.roundNumber(
          ref, remainingPrincipal * monthlyInterestRate);
      double monthlyPrincipal =
          GlobalFormatter.roundNumber(ref, monthlyEmi - monthlyInterest);
      remainingPrincipal = GlobalFormatter.roundNumber(
          ref, remainingPrincipal - monthlyPrincipal);

      DateTime currentMonth =
          DateTime(paymentDate.year, paymentDate.month + month);

      schedule.add(AmortizationEntry(
        paymentDate: currentMonth,
        principal: monthlyPrincipal,
        interest: monthlyInterest,
        totalPayment: monthlyEmi,
        balance: remainingPrincipal,
        year: currentMonth.year,
        month: currentMonth.month,
      ));
    }

    return schedule;
  }

  List<double> _getPrincipalAmounts(List<AmortizationEntry> schedule) {
    final groupByYear =
        groupBy(schedule, (AmortizationEntry entry) => entry.year);
    return groupByYear.values
        .map((entries) => GlobalFormatter.roundNumber(
            ref, entries.fold(0.0, (prev, entry) => prev + entry.principal)))
        .toList();
  }

  List<double> _getInterestAmounts(List<AmortizationEntry> schedule) {
    final groupByYear =
        groupBy(schedule, (AmortizationEntry entry) => entry.year);
    return groupByYear.values
        .map((entries) => GlobalFormatter.roundNumber(
            ref, entries.fold(0.0, (prev, entry) => prev + entry.interest)))
        .toList();
  }

  List<double> _getBalances(List<AmortizationEntry> schedule) {
    final groupByYear =
        groupBy(schedule, (AmortizationEntry entry) => entry.year);
    return groupByYear.values
        .map((entries) => GlobalFormatter.roundNumber(
            ref,
            entries.fold(0.0, (prev, entry) => prev + entry.balance) /
                entries.length))
        .toList();
  }

  String _calculateTenure(AppLocalizations l10n, Emi emi) {
    // Check if we have the originally selected values
    if (emi.selectedYears != null && emi.selectedMonths != null) {
      final int years = emi.selectedYears!.toInt();
      final int months = emi.selectedMonths!.toInt();
      return '$years ${l10n.years} $months ${l10n.months}';
    }

    // Fallback to calculation from dates if no selected values are stored
    if (emi.endDate == null) return 'Unknown';

    final int years = emi.endDate!.year - emi.startDate.year;
    final int months = emi.endDate!.month - emi.startDate.month;

    // Adjust for negative months (if end month is earlier in the year than start month)
    if (months < 0) {
      return '${years - 1} ${l10n.years} ${months + 12} ${l10n.months}';
    }

    return '$years ${l10n.years} $months ${l10n.months}';
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
          margin: const EdgeInsets.only(right: 8.0),
        ),
        Text(label),
      ],
    );
  }
}
