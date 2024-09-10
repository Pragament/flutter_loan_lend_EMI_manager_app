import 'package:collection/collection.dart';
import 'package:emi_manager/logic/emis_provider.dart';
import 'package:emi_manager/presentation/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../widgets/amortization_schedule_table.dart';
import '../widgets/bar_graph.dart';
import 'dart:math';

class EmiDetailsPage extends ConsumerWidget {
  const EmiDetailsPage({super.key, required this.emiId});

  final String emiId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emi = ref.watch(emisNotifierProvider
        .select((emis) => emis.firstWhere((emi) => emi.id == emiId)));

    final l10n = AppLocalizations.of(context)!;
    final emiTypeColor = emi.emiType == 'lend'
        ? lendColor(context, true)
        : loanColor(context, true);

    final double principalAmount = emi.principalAmount;
    final double interestAmount = emi.totalEmi != null ? emi.totalEmi! - principalAmount : 0.0;
    final double totalAmount = emi.totalEmi ?? 0.0;

    final DateTime startDate = emi.startDate;
    final DateTime? endDate = emi.endDate;
    final String tenure = _calculateTenure(l10n, startDate, endDate);
    final int tenureInYears = int.parse(tenure.split(' ')[0]);


    final List<AmortizationEntry> schedule = _generateAmortizationSchedule(
      tenureYears: tenureInYears,
      principalAmount: principalAmount,
      interestAmount: interestAmount,
      totalAmount: totalAmount,
    );


    final List<double> principalAmounts = _getPrincipalAmounts(schedule);
    final List<double> interestAmounts = _getInterestAmounts(schedule);
    final List<double> balances = _getBalances(schedule);
    final List<int> years = List.generate(
      tenureInYears,
          (index) => startDate.year + index,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(emi.title),
        backgroundColor: emiTypeColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).go('/');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmiInfoSection(context, emi, l10n, interestAmount, principalAmount, totalAmount, tenure),
              const SizedBox(height: 24),
              _buildPieChart(interestAmount, principalAmount, totalAmount),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmiInfoSection(
      BuildContext context,
      dynamic emi,
      AppLocalizations l10n,
      double interestAmount,
      double principalAmount,
      double totalAmount,
      String tenure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(l10n.emi, emi.monthlyEmi?.toStringAsFixed(2) ?? 'N/A',
            isBold: true, fontSize: 20),
        const Divider(thickness: 1, color: Colors.grey),
        _buildInfoRow(l10n.interestAmount, interestAmount.toStringAsFixed(2)),
        _buildInfoRow(l10n.totalAmount, totalAmount.toStringAsFixed(2)),
        const SizedBox(height: 16),
        _buildInfoRow(l10n.loanAmount, principalAmount.toStringAsFixed(2)),
        _buildInfoRow(l10n.tenure, tenure),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, double fontSize = 16}) {
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

  Widget _buildPieChart(
      double interestAmount, double principalAmount, double totalAmount) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.blue,
              value: interestAmount,
              title:
              '${(interestAmount / totalAmount * 100).toStringAsFixed(1)}%',
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
              title:
              '${(principalAmount / totalAmount * 100).toStringAsFixed(1)}%',
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
  }) {
    List<AmortizationEntry> schedule = [];
    DateTime startDate = DateTime.now();

    // Monthly interest rate assuming a flat interest rate model
    double monthlyInterestRate = (interestAmount / principalAmount) / (tenureYears * 12);
    int totalMonths = tenureYears * 12;

    double monthlyEmi = (principalAmount * monthlyInterestRate *
        pow(1 + monthlyInterestRate, totalMonths)) /
        (pow(1 + monthlyInterestRate, totalMonths) - 1);

    double remainingPrincipal = principalAmount;

    for (int month = 0; month < totalMonths; month++) {
      double monthlyInterest = remainingPrincipal * monthlyInterestRate;
      double monthlyPrincipal = monthlyEmi - monthlyInterest;
      remainingPrincipal -= monthlyPrincipal;

      // Calculate year and month correctly
      DateTime paymentDate = DateTime(startDate.year, startDate.month + month);
      int year = paymentDate.year;
      int monthOfYear = paymentDate.month;

      // Add amortization entry for each month
      schedule.add(AmortizationEntry(
        paymentDate: paymentDate,
        principal: monthlyPrincipal,
        interest: monthlyInterest,
        totalPayment: monthlyEmi,
        balance: remainingPrincipal,
        year: year,
        month: monthOfYear,
      ));
    }

    return schedule;
  }


  List<double> _getPrincipalAmounts(List<AmortizationEntry> schedule) {
    final groupByYear = groupBy(schedule, (AmortizationEntry entry) => entry.year);
    return groupByYear.values.map((entries) =>
        entries.fold(0.0, (prev, entry) => prev + entry.principal)).toList();
  }

  List<double> _getInterestAmounts(List<AmortizationEntry> schedule) {
    final groupByYear = groupBy(schedule, (AmortizationEntry entry) => entry.year);
    return groupByYear.values.map((entries) =>
        entries.fold(0.0, (prev, entry) => prev + entry.interest)).toList();
  }

  List<double> _getBalances(List<AmortizationEntry> schedule) {
    final groupByYear = groupBy(schedule, (AmortizationEntry entry) => entry.year);
    return groupByYear.values.map((entries) =>
        entries.fold(0.0, (prev, entry) => prev + entry.balance)).toList();
  }

  String _calculateTenure(AppLocalizations l10n, DateTime startDate, DateTime? endDate) {
    if (endDate == null) return 'Unknown';

    final int years = endDate.year - startDate.year;
    final int months = endDate.month - startDate.month;
    return '$years ${l10n.years} $months ${l10n.months}';
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    Key? key,
    required this.color,
    required this.label,
  }) : super(key: key);

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
