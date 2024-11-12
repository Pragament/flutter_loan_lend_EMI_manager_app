import 'dart:math';

import 'package:emi_manager/data/models/emi_model.dart';
import 'package:emi_manager/logic/emis_provider.dart';
import 'package:emi_manager/presentation/constants.dart';
import 'package:emi_manager/presentation/pages/home/logic/home_state_provider.dart';
import 'package:emi_manager/presentation/pages/home/widgets/tags_strip.dart';
import 'package:emi_manager/presentation/router/routes.dart';
import 'package:emi_manager/presentation/widgets/home_bar_graph.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart'; // For charting widgets
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';

import '../widgets/locale_selector_popup_menu.dart';
import '../widgets/BarGraph.dart'; // Custom BarGraph widget
import '../widgets/amorzation_table.dart';


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

  // @override
  // Widget build(BuildContext context) {
  //   final l10n = AppLocalizations.of(context)!;
  //   final allEmis = ref.watch(homeStateNotifierProvider).emis;
  //   List<AmortizationEntry> schedule = _generateSampleSchedule();
  //
  //   if (allEmis.isEmpty) {
  //     return ShowCaseWidget(
  //       builder: (context) => Scaffold(
  //         appBar: AppBar(
  //           title: Text(l10n.appTitle),
  //           actions: [
  //             IconButton(
  //                 icon: const Icon(Icons.help_outline),
  //                 onPressed: () {
  //                   noEmis = true;
  //                   _showHelpOptions(context);
  //                 }),
  //           ],
  //         ),
  //         body: Center(),
  //         floatingActionButton: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           crossAxisAlignment: CrossAxisAlignment.end,
  //           children: [
  //             Showcase(
  //               key: lendHelpKey,
  //               description: "Add New Lend from Here",
  //               child: FloatingActionButton.extended(
  //                 onPressed: () =>
  //                     const NewEmiRoute(emiType: 'lend').push(context),
  //                 heroTag: 'newLendBtn',
  //                 backgroundColor: lendColor(context, false),
  //                 label: Text(l10n.lend),
  //                 icon: const Icon(Icons.add),
  //               ),
  //             ),
  //             Showcase(
  //               key: loanHelpKey,
  //               description: "Add new Loan from Here",
  //               child: FloatingActionButton.extended(
  //                 onPressed: () =>
  //                     const NewEmiRoute(emiType: 'loan').push(context),
  //                 heroTag: 'newLoanBtn',
  //                 backgroundColor: loanColor(context, false),
  //                 label: Text(l10n.loan),
  //                 icon: const Icon(Icons.add),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  //
  //   // Collect data for the BarGraph
  //   List<double> principalAmounts = [];
  //   List<double> interestAmounts = [];
  //   List<double> balances = [];
  //   List<int> years = [];
  //
  //   for (var emi in allEmis) {
  //     principalAmounts.add(emi.principalAmount);
  //     interestAmounts.add(emi.totalEmi! - emi.principalAmount);
  //     balances.add(emi.totalEmi!); // Assuming balances as total EMI
  //     years.add(emi.year); // Assuming EMI model has a 'year' field
  //   }
  //   return ShowCaseWidget(
  //     builder: (context) => Scaffold(
  //       appBar: AppBar(
  //         title: Text(l10n.appTitle),
  //         // Automatically shows the drawer icon on the left
  //         actions: [
  //           IconButton(
  //               icon: const Icon(Icons.help_outline),
  //               onPressed: () {
  //                 noEmis = false;
  //                 _showHelpOptions(context);
  //               }),
  //         ],
  //       ),
  //       key: _scaffoldKey, //for opening drawer
  //       drawer: Drawer(
  //         child: ListView(
  //           padding: EdgeInsets.zero,
  //           children: <Widget>[
  //             DrawerHeader(
  //               decoration: BoxDecoration(
  //                 color: Colors.blue,
  //               ),
  //               child: Text(
  //                 'Menu',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 24,
  //                 ),
  //               ),
  //             ),
  //             // Move the LocaleSelectorPopupMenu inside the Drawer
  //             Showcase(
  //               key: langHelpKey,
  //               description: "You Can Choose Your Regional Language",
  //               child: ListTile(
  //                 title: Text('Select Language'),
  //                 trailing: LocaleSelectorPopupMenu(),
  //               ),
  //             ),
  //             Showcase(
  //               key: helpHelpKey,
  //               description: "Help Button",
  //               child: ListTile(
  //                 title: Text('Help'),
  //                 trailing: IconButton(
  //                   icon: const Icon(Icons.help_outline),
  //                   onPressed: () {
  //                     _showHelpOptions(context);
  //                   },
  //                 ),
  //               ),
  //             ),
  //             // Add other items if needed
  //           ],
  //         ),
  //       ),
  //       body: SingleChildScrollView(
  //         child: Column(
  //           children: [
  //             Showcase(
  //                 key: filterHelpKey,
  //                 description: "Filter By Multiple Tags",
  //                 child: const TagsStrip()
  //             ), // Top tags
  //
  //             // BarGraph Widget showing aggregate values
  //             Container(
  //               padding: const EdgeInsets.all(5.0),
  //               margin: const EdgeInsets.symmetric(vertical: 20),
  //               // height: 500, // Adjust height if needed
  //               child: SizedBox(
  //                 // child: BarGraph(
  //                 //   principalAmounts: principalAmounts,
  //                 //   interestAmounts: interestAmounts,
  //                 //   balances: balances,
  //                 //   years: years,
  //                 // ),
  //                 child: HomeBarGraph(allEmis: allEmis),
  //
  //               ),
  //             ),
  //             _buildLegend(context),
  //
  //             // Toggle button to show/hide the Amortization Table
  //
  //             // Always visible Amortization Table
  //             Padding(
  //               padding: const EdgeInsets.all(16.0),
  //               child: SingleChildScrollView(
  //                 scrollDirection: Axis.horizontal,
  //                 // child: AmortizationSummaryTable(
  //                 //   entries:
  //                 //       _groupAmortizationEntries(allEmis), // Grouped EMI data
  //                 //   startDate: DateTime.now(), // Assuming current start date
  //                 //   tenureInYears:
  //                 //       _calculateTenure(allEmis), // Provide tenure in years
  //                 // ),
  //                 child: AmortizationSummaryTable(
  //                   schedule: schedule,
  //                   startDate: DateTime.now(),
  //                 ),
  //               ),
  //             ),
  //
  //
  //
  //
  //             // List of EMI cards
  //             ListView.builder(
  //               shrinkWrap:
  //                   true, // Ensures the list scrolls with the rest of the page
  //               physics:
  //                   const NeverScrollableScrollPhysics(), // Disable scrolling for the list, let the parent scroll
  //               itemCount: allEmis.length,
  //               itemBuilder: (context, index) {
  //                 final emi = allEmis.elementAt(index);
  //                 final emiTypeColor = emi.emiType == 'lend'
  //                     ? lendColor(context, true)
  //                     : loanColor(context, true);
  //
  //                 final double principalAmount = emi.principalAmount;
  //                 final double interestAmount =
  //                     emi.totalEmi! - emi.principalAmount;
  //                 final double totalAmount = emi.totalEmi!;
  //
  //                 return EmiCard(
  //                   emiTypeColor: emiTypeColor,
  //                   l10n: l10n,
  //                   emi: emi,
  //                   interestAmount: interestAmount,
  //                   totalAmount: totalAmount,
  //                   principalAmount: principalAmount,
  //                 );
  //               },
  //             ),
  //           ],
  //         ),
  //       ),
  //       floatingActionButton: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         crossAxisAlignment: CrossAxisAlignment.end,
  //         children: [
  //           Showcase(
  //             key: lendHelpKey,
  //             description: "Add New Lend from Here",
  //             targetBorderRadius: BorderRadius.circular(35),
  //             child: FloatingActionButton.extended(
  //               onPressed: () =>
  //                   const NewEmiRoute(emiType: 'lend').push(context),
  //               heroTag: 'newLendBtn',
  //               backgroundColor: lendColor(context, false),
  //               label: Text(l10n.lend),
  //               icon: const Icon(Icons.add),
  //             ),
  //           ),
  //           Showcase(
  //             key: loanHelpKey,
  //             description: "Add new Loan from Here",
  //             child: FloatingActionButton.extended(
  //               onPressed: () =>
  //                   const NewEmiRoute(emiType: 'loan').push(context),
  //               heroTag: 'newLoanBtn',
  //               backgroundColor: loanColor(context, false),
  //               label: Text(l10n.loan),
  //               icon: const Icon(Icons.add),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // final allEmis = ref.watch(homeStateNotifierProvider).emis;

    final allEmis = ref.watch(homeStateNotifierProvider.select((state) => state.emis));

    // Check if there are any EMIs in the database
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
                },
              ),
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

    // Collect data for the BarGraph using actual EMIs from the database
    List<double> principalAmounts = allEmis.map((emi) => emi.principalAmount).toList();
    List<double> interestAmounts = allEmis.map((emi) => emi.totalEmi! - emi.principalAmount).toList();
    List<double> balances = allEmis.map((emi) => emi.totalEmi!).toList();
    List<int> years = allEmis.map((emi) => emi.year).toSet().toList(); // Unique years for grouping

    return ShowCaseWidget(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                noEmis = false;
                _showHelpOptions(context);
              },
            ),
          ],
        ),
        key: _scaffoldKey,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              Showcase(
                key: filterHelpKey,
                description: "Filter By Multiple Tags",
                child: const TagsStrip(),
              ),

              // Updated BarGraph widget with actual database data
              Container(
                padding: const EdgeInsets.all(5.0),
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: HomeBarGraph(allEmis: allEmis),
              ),
              _buildLegend(context),

              // Amortization Summary Table with actual EMI data
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: AmortizationSummaryTable(
                    entries: _groupAmortizationEntries(allEmis),
                    startDate: DateTime.now(),
                    tenureInYears: _calculateTenure(allEmis),
                  ),
                ),
              ),

              // List of EMI cards using database data
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allEmis.length,
                itemBuilder: (context, index) {
                  final emi = allEmis.elementAt(index);
                  final emiTypeColor = emi.emiType == 'lend'
                      ? lendColor(context, true)
                      : loanColor(context, true);

                  final double principalAmount = emi.principalAmount;
                  final double interestAmount = emi.totalEmi! - emi.principalAmount;
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
              child: FloatingActionButton.extended(
                onPressed: () => const NewEmiRoute(emiType: 'lend').push(context),
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
                onPressed: () => const NewEmiRoute(emiType: 'loan').push(context),
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
  // List<AmortizationEntry> _groupAmortizationEntries(List<Emi> emis) {
  //   return emis
  //       .map((emi) => AmortizationEntry(
  //             loanLendName: emi.title,
  //             loanLendType:
  //                 emi.emiType == 'lend' ? LoanLendType.lend : LoanLendType.loan,
  //             principal: emi.principalAmount,
  //             interest: emi.totalEmi! - emi.principalAmount,
  //             year: emi.year,
  //             month: DateTime.now().month,
  //           ))
  //       .toList();
  // }

  // List<AmortizationEntry> _groupAmortizationEntries(List<Emi> allEmis) {
  //   List<AmortizationEntry> amortizationEntries = [];
  //
  //   for (var emi in allEmis) {
  //     int currentYear = DateTime.now().year;
  //     int currentMonth = DateTime.now().month;
  //
  //     // Calculate the number of months remaining for this EMI
  //     // Start adding entries from the year
  //     for (int month = currentMonth; month <= 12; month++) {
  //       amortizationEntries.add(
  //         AmortizationEntry(
  //           title: emi.title,
  //           principal: emi.principalAmount,
  //           interest: (emi.totalEmi! - emi.principalAmount),
  //           totalPayment: emi.totalEmi!,
  //           year: currentYear,
  //           month: month,
  //         ),
  //       );
  //     }
  //
  //     // final int tenureYears = (emi.endDate?.year ?? 0) - (emi.startDate.year ?? 0);
  //     // print("Years: ${emi.endDate?.year} ${emi.startDate.year} $tenureYears");
  //     // If the EMI has a tenure longer than one year,
  //     // we should add entries for the following years as well
  //     for (int yearOffset = 1; yearOffset < 5; yearOffset++) {
  //       for (int month = 1; month <= 12; month++) {
  //         amortizationEntries.add(
  //           AmortizationEntry(
  //             title: emi.title,
  //             principal: emi.principalAmount,
  //             interest: (emi.totalEmi! - emi.principalAmount),
  //             totalPayment: emi.totalEmi!,
  //             year: currentYear + yearOffset,
  //             month: month,
  //           ),
  //         );
  //       }
  //     }
  //   }
  //
  //   return amortizationEntries;
  // }


  List<AmortizationEntry> _groupAmortizationEntries(List<Emi> allEmis) {

    List<AmortizationEntry> amortizationEntries = [];

    for (var emi in allEmis) {
      // print(emi.title);
      DateTime startDate = emi.startDate;
      final int tenureInYears = ((emi.endDate?.year ?? 0) - emi.startDate.year);

      // Calculate monthly EMI for the current EMI item
      final int sign = emi.emiType=='loan'? (-1): 1;
      double monthlyEmi = _calculateEMI(emi.principalAmount, emi.interestRate, tenureInYears);
      double remainingPrincipal = emi.principalAmount;
      for (int month = 0; month < tenureInYears * 12; month++) {
        double monthlyInterestRate = emi.interestRate / (12 * 100);
        double monthlyInterest = remainingPrincipal * monthlyInterestRate;
        double monthlyPrincipal = monthlyEmi - monthlyInterest;
        remainingPrincipal -= monthlyPrincipal;

        int adjustedYear = startDate.year + ((startDate.month - 1 + month) ~/ 12);
        int adjustedMonth = (startDate.month - 1 + month) % 12 + 1;
        amortizationEntries.add(AmortizationEntry(
            title: emi.title,
            principal: sign*monthlyPrincipal,
            interest: sign*monthlyInterest,
            totalPayment: sign*monthlyEmi,
            year: adjustedYear,
            month: adjustedMonth,
            type: emi.emiType=='loan'? 0: 1
        ));
      }
    }

    // Calculate total interest and total amount across all amortization entries
    double totalInterest = _calculateTotalInterest(amortizationEntries);
    double totalAmount = _calculateTotalAmount(amortizationEntries);

    // Print or log totals if needed

    return amortizationEntries;
  }

  double _calculateEMI(double principalAmount, double interestRate, int tenureYears) {
    // Calculate monthly interest rate from the annual rate
    double monthlyInterestRate = interestRate / (12 * 100);
    int totalMonths = tenureYears * 12;

    // Calculate monthly EMI amount using the compound interest formula
    return (principalAmount * monthlyInterestRate *
        pow(1 + monthlyInterestRate, totalMonths)) /
        (pow(1 + monthlyInterestRate, totalMonths) - 1);
  }

  double _calculateTotalInterest(List<AmortizationEntry> amortizationEntries) {
    return amortizationEntries.fold(0.0, (sum, entry) => sum + entry.interest);
  }

  double _calculateTotalAmount(List<AmortizationEntry> amortizationEntries) {
    return amortizationEntries.fold(0.0, (sum, entry) => sum + entry.totalPayment);
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