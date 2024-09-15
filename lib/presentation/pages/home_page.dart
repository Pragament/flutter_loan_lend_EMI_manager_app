import 'package:emi_manager/data/models/emi_model.dart';
import 'package:emi_manager/logic/emis_provider.dart';
import 'package:emi_manager/presentation/constants.dart';
import 'package:emi_manager/presentation/pages/home/logic/home_state_provider.dart';
import 'package:emi_manager/presentation/pages/home/widgets/tags_strip.dart';
import 'package:emi_manager/presentation/router/routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart
import 'package:go_router/go_router.dart';

import '../widgets/locale_selector_popup_menu.dart';
import '../widgets/BarGraph.dart'; // Import the BarGraph widget

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, this.actionCallback});

  final Function? actionCallback; // Optional callback

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allEmis = ref.watch(homeStateNotifierProvider).emis;

    // Prepare data for the BarGraph
    List<double> principalAmounts = [];
    List<double> interestAmounts = [];
    List<double> balances = [];
    List<int> years = [];

    for (var emi in allEmis) {
      principalAmounts.add(emi.principalAmount);
      interestAmounts.add(emi.totalEmi! - emi.principalAmount);
      balances.add(emi.totalEmi!); // Assuming balances is the total amount
      years.add(emi.year); // Assuming EMI model has a year field
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: const [
          LocaleSelectorPopupMenu(),
        ],
      ),
      body: Column(
        children: [
          const TagsStrip(),
          // Add the BarGraph widget here
          Container(
            padding: const EdgeInsets.all(16.0),
            height: 300, // Adjust the height as needed
            child: BarGraph(
              principalAmounts: principalAmounts,
              interestAmounts: interestAmounts,
              balances: balances,
              years: years,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allEmis.length,
              itemBuilder: (context, index) {
                final emi = allEmis.elementAt(index);

                final emiTypeColor = emi.emiType == 'lend'
                    ? lendColor(context, true)
                    : loanColor(context, true);

                final double principalAmount = emi.principalAmount;
                final double interestAmount =
                    emi.totalEmi! - emi.principalAmount;
                final double totalAmount = emi.totalEmi!;

                return EmiCard(
                    emiTypeColor: emiTypeColor,
                    l10n: l10n,
                    emi: emi,
                    interestAmount: interestAmount,
                    totalAmount: totalAmount,
                    principalAmount: principalAmount);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Fab(l10n: l10n),
    );
  }
}

class EmiCard extends ConsumerWidget {
  const EmiCard({
    super.key,
    required this.emiTypeColor,
    required this.l10n,
    required this.emi,
    required this.interestAmount,
    required this.totalAmount,
    required this.principalAmount,
  });

  final Color emiTypeColor;
  final AppLocalizations l10n;
  final Emi emi;
  final double interestAmount;
  final double totalAmount;
  final double principalAmount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double totalAmount = interestAmount + principalAmount;
    final double interestPercentage = (interestAmount / totalAmount) * 100;
    final double principalPercentage = (principalAmount / totalAmount) * 100;

    return InkWell(
      onTap: () {
        GoRouter.of(context).go('/emiDetails/${emi.id}');
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: emiTypeColor, width: 2), // Outline color and width
          borderRadius:
              BorderRadius.circular(borderRadius), // Card corner radius
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Title and Popup Menu
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
                        final emiId = emi
                            .id; // Assume emi is your EMI object and you have an id field
                        final emiType = emi
                            .emiType; // Assuming emiType is part of the EMI object
                        GoRouter.of(context).go(
                            NewEmiRoute(emiType: emiType, emiId: emiId)
                                .location);
                      } else if (value == 'delete') {
                        _deleteEmi(context, ref, emi);
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
              // Row for EMI details and Pie Chart
              Row(
                children: [
                  // Left Column: EMI details
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        Text(
                          '${l10n.emi}: ${emi.monthlyEmi?.toStringAsFixed(2) ?? l10n.enterAmount}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Divider(), // Add a divider after the first text
                        Text(
                          '${l10n.interestAmount}: ${interestAmount.toStringAsFixed(2)}',
                        ),
                        const Divider(), // Add a divider after the second text
                        Text(
                          '${l10n.totalAmount}: ${totalAmount.toStringAsFixed(2)}',
                        ),
                        const Divider()
                      ],
                    ),
                  ),
                  const VerticalDivider(
                    thickness: 2,
                    color: Colors.grey,
                    width: 2,
                  ),
                  // Right Pie Chart
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            l10n.caroselHeading, // Replacing with localized string for "EMI Breakdown"
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
                                  title:
                                      '${interestPercentage.toStringAsFixed(1)}%',
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
                                  title:
                                      '${principalPercentage.toStringAsFixed(1)}%',
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
                              _LegendItem(
                                  color: Colors.blue,
                                  label: l10n.legendInterestAmount),
                              _LegendItem(
                                  color: Colors.green,
                                  label: l10n.legendPrincipalAmount),
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
      ),
    );
  }

  void _deleteEmi(BuildContext context, WidgetRef ref, Emi emi) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.areYouSure),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      ref.read(emisNotifierProvider.notifier).remove(emi);
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

class Fab extends StatelessWidget {
  const Fab({
    super.key,
    required this.l10n,
  });

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          onPressed: () => const NewEmiRoute(emiType: 'lend').push(context),
          heroTag: 'newLendBtn',
          backgroundColor: lendColor(context, false),
          label: Text(l10n.lend),
          icon: const Icon(Icons.add),
        ),
        FloatingActionButton.extended(
          onPressed: () => const NewEmiRoute(emiType: 'loan').push(context),
          heroTag: 'newLoanBtn',
          backgroundColor: loanColor(context, false),
          label: Text(l10n.loan),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
