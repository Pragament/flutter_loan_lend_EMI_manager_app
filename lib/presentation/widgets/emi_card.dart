import 'package:emi_manager/data/models/emi_model.dart';
import 'package:emi_manager/logic/currency_provider.dart';
import 'package:emi_manager/presentation/constants.dart';
import 'package:emi_manager/presentation/router/routes.dart';
import 'package:emi_manager/presentation/widgets/formatted_amount.dart';
import 'package:emi_manager/utils/global_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:emi_manager/presentation/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EmiCardWidget extends ConsumerWidget {
  final Emi emi;
  final VoidCallback? onDelete;

  const EmiCardWidget({
    super.key,
    required this.emi,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = ref.watch(currencyProvider);
    final emiTypeColor = emi.emiType == 'lend'
        ? lendColor(context, true)
        : loanColor(context, true);

    final double principalAmount = emi.principalAmount;
    final double interestAmount = emi.totalEmi! - emi.principalAmount;
    final double totalAmount = emi.totalEmi!;

    final double interestPercentage = (interestAmount / totalAmount) * 100;
    final double principalPercentage = (principalAmount / totalAmount) * 100;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: emiTypeColor, width: 2),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Title and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      '${l10n.title}: ${emi.title}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      GoRouter.of(context).go(
                          NewEmiRoute(emiType: emi.emiType, emiId: emi.id)
                              .location);
                    } else if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text(l10n.edit),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(l10n.delete),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),

            // EMI details and chart
            Row(
              children: [
                // Left side - EMI details
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      Row(
                        children: [
                          Text('${l10n.emi}: ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          FormattedAmount(
                            amount: emi.monthlyEmi ?? 0.0,
                            currencySymbol: currencySymbol,
                            boldText: true,
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Text('${l10n.interestAmount}: '),
                          FormattedAmount(
                            amount: interestAmount,
                            currencySymbol: currencySymbol,
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Text('${l10n.totalAmount}: '),
                          FormattedAmount(
                            amount: totalAmount,
                            currencySymbol: currencySymbol,
                          ),
                        ],
                      ),
                      const Divider(),
                    ],
                  ),
                ),

                const VerticalDivider(
                    thickness: 2, color: Colors.grey, width: 2),

                // Right side - Pie chart
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          l10n.caroselHeading,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                color: Colors.blue,
                                value: interestAmount,
                                title: GlobalFormatter.formatPercentage(
                                    ref, interestPercentage),
                                radius: 60,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                color: Colors.green,
                                value: principalAmount,
                                title: GlobalFormatter.formatPercentage(
                                    ref, principalPercentage),
                                radius: 60,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildLegendItem(
                                Colors.blue, l10n.legendInterestAmount),
                            _buildLegendItem(
                                Colors.green, l10n.legendPrincipalAmount),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, color: color),
        const SizedBox(width: 2),
        Text(label),
      ],
    );
  }
}
