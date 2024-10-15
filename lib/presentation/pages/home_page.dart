import 'package:emi_manager/data/models/emi_model.dart';
import 'package:emi_manager/logic/emis_provider.dart';
import 'package:emi_manager/presentation/constants.dart';
import 'package:emi_manager/presentation/pages/home/logic/home_state_provider.dart';
import 'package:emi_manager/presentation/pages/home/widgets/tags_strip.dart';
import 'package:emi_manager/presentation/router/routes.dart';
import 'package:emi_manager/presentation/widgets/help_selector_popup_menu.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart'; // For charting widgets
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';

import '../widgets/locale_selector_popup_menu.dart';
import '../widgets/BarGraph.dart'; // Custom BarGraph widget
import '../widgets/amorzation_table.dart'; // Custom AmortizationTable widget

class HomePage extends ConsumerStatefulWidget {
  // GlobalKey loanHelpKey, GlobalKey lendHelpKey, GlobalKey langHelpKey, GlobalKey helpHelpKey

  HomePage({super.key, this.actionCallback});

  final Function? actionCallback;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  bool _showTable = false; // Toggle for the Amortization Table
  bool noEmis = false;
  final GlobalKey loanHelpKey = GlobalKey();
  final GlobalKey lendHelpKey = GlobalKey();
  final GlobalKey langHelpKey = GlobalKey();
  final GlobalKey helpHelpKey = GlobalKey();
  final GlobalKey filterHelpKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); //for drawer

  void _showHelpOptions(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext, //parentModel context
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.home),
              title: Text('All Home Bottons'),
              onTap: () async {
                Navigator.pop(context); // Close the bumodal with current context
                //language
                if(noEmis==false)
                  {
                    _scaffoldKey.currentState?.openDrawer();
                    ShowCaseWidget.of(parentContext).startShowCase(
                        [langHelpKey]); //language help model context
                    await Future.delayed(Duration(seconds: 2));
                    ShowCaseWidget.of(parentContext).startShowCase([helpHelpKey]);
                    await Future.delayed(Duration(seconds: 2));
                  }
                if (_scaffoldKey.currentState?.isDrawerOpen ??
                    false) //if drawer open
                  Navigator.pop(parentContext); //close drawer
                ShowCaseWidget.of(parentContext).startShowCase([loanHelpKey]);
                await Future.delayed(Duration(seconds: 2));
                ShowCaseWidget.of(parentContext).startShowCase([lendHelpKey]);
              },
            ),


            if (noEmis == false)
              ListTile(
                leading: const Icon(Icons.tag),
                title: Text('Filter By Tag'),
                onTap: () {
                  Navigator.pop(context); // Close the modal
                  //if no emis present
                  if (_scaffoldKey.currentState?.isDrawerOpen ??
                      false) //if drawer open
                    Navigator.pop(parentContext); //close drawer
                  ShowCaseWidget.of(parentContext).startShowCase([filterHelpKey]);
                },
              ),

          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allEmis = ref.watch(homeStateNotifierProvider).emis;
    if (allEmis.isEmpty) {
      return ShowCaseWidget(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(l10n.appTitle),
            actions: [
              IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: () {
                    noEmis = true;
                    _showHelpOptions(context);
                  }),
            ],
          ),
          body: Center(),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Showcase(
                key: lendHelpKey,
                description: "Add New Lend from Here",
                child: FloatingActionButton.extended(
                  onPressed: () =>
                      const NewEmiRoute(emiType: 'lend').push(context),
                  heroTag: 'newLendBtn',
                  backgroundColor: lendColor(context, false),
                  label: Text(l10n.lend),
                  icon: const Icon(Icons.add),
                ),
              ),
              Showcase(
                key: loanHelpKey,
                description: "Add new Loan from Here",
                child: FloatingActionButton.extended(
                  onPressed: () =>
                      const NewEmiRoute(emiType: 'loan').push(context),
                  heroTag: 'newLoanBtn',
                  backgroundColor: loanColor(context, false),
                  label: Text(l10n.loan),
                  icon: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Collect data for the BarGraph
    List<double> principalAmounts = [];
    List<double> interestAmounts = [];
    List<double> balances = [];
    List<int> years = [];

    for (var emi in allEmis) {
      principalAmounts.add(emi.principalAmount);
      interestAmounts.add(emi.totalEmi! - emi.principalAmount);
      balances.add(emi.totalEmi!); // Assuming balances as total EMI
      years.add(emi.year); // Assuming EMI model has a 'year' field
    }
    return ShowCaseWidget(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          // Automatically shows the drawer icon on the left
          actions: [
            IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () {
                  noEmis = false;
                  _showHelpOptions(context);
                }),
          ],
        ),
        key: _scaffoldKey, //for opening drawer
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              // Move the LocaleSelectorPopupMenu inside the Drawer
              Showcase(
                key: langHelpKey,
                description: "You Can Choose Your Regional Language",
                child: ListTile(
                  title: Text('Select Language'),
                  trailing: LocaleSelectorPopupMenu(),
                ),
              ),
              Showcase(
                key: helpHelpKey,
                description: "Help Button",
                child: ListTile(
                  title: Text('Help'),
                  trailing: IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () {
                      _showHelpOptions(context);
                    },
                  ),
                ),
              ),
              // Add other items if needed
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Showcase(
                  key: filterHelpKey,
                  description: "Filter By Multiple Tags",
                  child: const TagsStrip()
              ), // Top tags

              // BarGraph Widget showing aggregate values
              Container(
                padding: const EdgeInsets.all(16.0),
                height: 300, // Adjust height if needed
                child: SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal, // Enable horizontal scrolling
                  child: SizedBox(
                    width: years.length *
                        100.0, // Adjust width based on number of years or bars
                    child: BarGraph(
                      principalAmounts: principalAmounts,
                      interestAmounts: interestAmounts,
                      balances: balances,
                      years: years,
                    ),
                  ),
                ),
              ),
              _buildLegend(context),

              // Toggle button to show/hide the Amortization Table

              // Always visible Amortization Table
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: AmortizationSummaryTable(
                    entries:
                        _groupAmortizationEntries(allEmis), // Grouped EMI data
                    startDate: DateTime.now(), // Assuming current start date
                    tenureInYears:
                        _calculateTenure(allEmis), // Provide tenure in years
                  ),
                ),
              ),

              // List of EMI cards
              ListView.builder(
                shrinkWrap:
                    true, // Ensures the list scrolls with the rest of the page
                physics:
                    const NeverScrollableScrollPhysics(), // Disable scrolling for the list, let the parent scroll
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
                    principalAmount: principalAmount,
                  );
                },
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Showcase(
              key: lendHelpKey,
              description: "Add New Lend from Here",
              targetBorderRadius: BorderRadius.circular(35),
              child: FloatingActionButton.extended(
                onPressed: () =>
                    const NewEmiRoute(emiType: 'lend').push(context),
                heroTag: 'newLendBtn',
                backgroundColor: lendColor(context, false),
                label: Text(l10n.lend),
                icon: const Icon(Icons.add),
              ),
            ),
            Showcase(
              key: loanHelpKey,
              description: "Add new Loan from Here",
              child: FloatingActionButton.extended(
                onPressed: () =>
                    const NewEmiRoute(emiType: 'loan').push(context),
                heroTag: 'newLoanBtn',
                backgroundColor: loanColor(context, false),
                label: Text(l10n.loan),
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateTenure(List<Emi> allEmis) {
    int earliestYear =
        allEmis.map((emi) => emi.year).reduce((a, b) => a < b ? a : b);
    int latestYear =
        allEmis.map((emi) => emi.year).reduce((a, b) => a > b ? a : b);
    return latestYear - earliestYear + 1;
  }

  // Group amortization entries by year for the Amortization Table
  List<AmortizationEntry> _groupAmortizationEntries(List<Emi> emis) {
    return emis
        .map((emi) => AmortizationEntry(
              loanLendName: emi.title,
              loanLendType:
                  emi.emiType == 'lend' ? LoanLendType.lend : LoanLendType.loan,
              principal: emi.principalAmount,
              interest: emi.totalEmi! - emi.principalAmount,
              year: emi.year,
              month: DateTime.now().month,
            ))
        .toList();
  }

  // Total calculations for EMI, Interest, and Amount
  double _calculateTotalEMI(List<Emi> emis) {
    return emis.fold(0.0, (sum, emi) => sum + emi.totalEmi!);
  }

  double _calculateTotalInterest(List<Emi> emis) {
    return emis.fold(
        0.0, (sum, emi) => sum + (emi.totalEmi! - emi.principalAmount));
  }

  double _calculateTotalAmount(List<Emi> emis) {
    return emis.fold(0.0, (sum, emi) => sum + emi.totalEmi!);
  }

  // Build legend for the BarGraph
  Widget _buildLegend(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _LegendItem(color: Colors.pink, label: l10n.loan),
          _LegendItem(color: Colors.blue, label: l10n.lend),
          _LegendItem(color: Colors.grey, label: l10n.aggregate),
        ],
      ),
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
        EmiDetailsRoute(emiId: emi.id).push(context);
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

// class Fab extends StatelessWidget {
//   const Fab({
//     super.key,
//     required this.l10n,
//     required this.fabLendHelpKey,
//     required this.fabLoanHelpKey,
//
//   });
//
//   final AppLocalizations l10n;
//   final GlobalKey fabLendHelpKey;
//   final GlobalKey fabLoanHelpKey;
//
//   @override
//   Widget build(BuildContext context) {
//     return ShowCaseWidget(
//       builder: (context)=> Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Showcase(
//             key: fabLendHelpKey,
//             description: "Add New Lend from Here",
//             child: FloatingActionButton.extended(
//               onPressed: () => const NewEmiRoute(emiType: 'lend').push(context),
//               heroTag: 'newLendBtn',
//               backgroundColor: lendColor(context, false),
//               label: Text(l10n.lend),
//               icon: const Icon(Icons.add),
//             ),
//           ),
//           Showcase(
//             key: fabLoanHelpKey,
//             description: "Add new Loan from Here",
//             child: FloatingActionButton.extended(
//               onPressed: () => const NewEmiRoute(emiType: 'loan').push(context),
//               heroTag: 'newLoanBtn',
//               backgroundColor: loanColor(context, false),
//               label: Text(l10n.loan),
//               icon: const Icon(Icons.add),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//}
