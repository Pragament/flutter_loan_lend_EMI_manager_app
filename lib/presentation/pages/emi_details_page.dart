import 'package:emi_manager/logic/emis_provider.dart';
import 'package:emi_manager/presentation/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

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
    final double interestAmount =
        emi.totalEmi != null ? emi.totalEmi! - principalAmount : 0.0;
    final double totalAmount = emi.totalEmi ?? 0.0;

    // Calculate Tenure in Years and Months
    final DateTime startDate = emi.startDate;
    final DateTime? endDate = emi.endDate;
    final String tenure = _calculateTenure(l10n, startDate, endDate);

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmiInfoSection(context, emi, l10n, interestAmount,
                principalAmount, totalAmount, tenure),
            const SizedBox(height: 24),
            _buildPieChart(interestAmount, principalAmount, totalAmount),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(width: 150,
                  child: Column(
                    
                    children: [
                      _LegendItem(
                          color: Colors.blue, label: l10n.legendInterestAmount),
                      _LegendItem(
                          color: Colors.green, label: l10n.legendPrincipalAmount),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build EMI Info Section
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
        const SizedBox(height: 16),
        _buildInfoRow(
            l10n.interestRate, '${emi.interestRate.toStringAsFixed(2)}%'),
        _buildInfoRow(
            l10n.startDate, emi.startDate.toLocal().toString().split(' ')[0]),
        _buildInfoRow(
            l10n.endDate,
            emi.endDate != null
                ? emi.endDate!.toLocal().toString().split(' ')[0]
                : 'N/A'),
        const SizedBox(height: 16),
        _buildInfoRow(l10n.contactPersonName, emi.contactPersonName),
        _buildInfoRow(l10n.contactPersonEmail, emi.contactPersonEmail),
        _buildInfoRow(l10n.contactPersonPhone, emi.contactPersonPhone),
      ],
    );
  }

  // Widget to build Pie Chart
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

  // Widget to build Info Row
  Widget _buildInfoRow(String label, String value,
      {bool isBold = false, double fontSize = 16}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
             
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              
            ),
          ),
        ],
      ),
    );
  }

  // Method to calculate tenure in years and months
  String _calculateTenure(
      AppLocalizations l10n, DateTime startDate, DateTime? endDate) {
    if (endDate == null) {
      return 'N/A';
    }

    int years = endDate.year - startDate.year;
    int months = endDate.month - startDate.month;

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    String yearsStr =
        years > 0 ? '$years ${years == 1 ? l10n.year : l10n.years}' : '';
    String monthsStr =
        months > 0 ? '$months ${months == 1 ? l10n.month : l10n.months}' : '';

    if (years > 0 && months > 0) {
      return '$yearsStr and $monthsStr';
    } else if (years > 0) {
      return yearsStr;
    } else if (months > 0) {
      return monthsStr;
    } else {
      return '0 ${l10n.months}';
    }
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          color: color,
        ),
        const SizedBox(width: 2),
        Text(label),
      ],
    );
  }
}
