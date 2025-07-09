// ignore_for_file: unused_local_variable, use_build_context_synchronously, avoid_print, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:emi_manager/data/models/emi_model.dart';
import 'package:emi_manager/data/models/tag_model.dart';
import 'package:emi_manager/logic/currency_provider.dart';
import 'package:emi_manager/logic/emis_provider.dart';
import 'package:emi_manager/logic/tags_provider.dart';
import 'package:emi_manager/presentation/constants.dart';
import 'package:emi_manager/presentation/pages/home/logic/home_state_provider.dart';
import 'package:emi_manager/presentation/pages/home/widgets/tags_strip.dart';
import 'package:emi_manager/presentation/pages/new_emi_page.dart';
import 'package:emi_manager/presentation/router/routes.dart';
import 'package:emi_manager/presentation/widgets/home_bar_graph.dart';
import 'package:emi_manager/presentation/widgets/formatted_amount.dart';
import 'package:emi_manager/utils/global_formatter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:emi_manager/presentation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart'; // For charting widgets
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package
import '../widgets/amorzation_table.dart';
import '../widgets/locale_selector_popup_menu.dart';

class HomePage extends ConsumerStatefulWidget {
  // GlobalKey loanHelpKey, GlobalKey lendHelpKey, GlobalKey langHelpKey, GlobalKey helpHelpKey

  const HomePage({super.key, this.actionCallback});

  final Function? actionCallback;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  // ignore: unused_field
  final bool _showTable = false; // Toggle for the Amortization Table
  bool noEmis = false;

  final GlobalKey loanHelpKey = GlobalKey();
  final GlobalKey lendHelpKey = GlobalKey();
  final GlobalKey langHelpKey = GlobalKey();
  final GlobalKey helpHelpKey = GlobalKey();
  final GlobalKey filterHelpKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); //for drawer

  // State variable to control Lottie animation visibility
  bool _showLottie = false;

  // State variable to control Lottie animation visibility for comparison
  bool _showComparisonLottie = false;

  // State variable to control Lottie animation visibility for errors
  bool _showErrorLottie = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Trigger the comparison Lottie animation when returning to the home screen
    _triggerComparisonLottie();
  }

  @override
  void initState() {
    super.initState();
    // Attach a NavigatorObserver to detect navigation events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context)
          .widget
          .observers
          .add(_HomePageNavigatorObserver(this));
    });
  }

  // Trigger the animation after adding or deleting a loan/lend
  void _onLoanOrLendModified() {
    _triggerComparisonLottie();
  }

  // ignore: unused_element
  void _triggerLottieAnimation() {
    setState(() {
      _showLottie = true;
    });

    // Hide the animation after a short duration (e.g., 1.5 seconds)
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _showLottie = false;
      });
    });
  }

  void _triggerComparisonLottie() {
    setState(() {
      _showComparisonLottie = true;
    });

    // Show the scales balancing animation for 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showComparisonLottie = false;
      });
    });
  }

  // ignore: unused_element
  void _triggerErrorLottie() {
    setState(() {
      _showErrorLottie = true;
    });

    // Hide the animation after a short duration (e.g., 2 seconds)
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showErrorLottie = false;
      });
    });
  }

  // ignore: unused_element
  void _triggerSequentialAnimations() async {
    // Trigger the checkmark animation
    setState(() {
      _showLottie = true;
    });

    // Wait for the checkmark animation to complete (1 second)
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _showLottie = false;
    });

    // Trigger the scales balancing animation
    _triggerComparisonLottie();
  }

  void _showHelpOptions(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext, //parentModel context
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('All Home Bottons'),
              onTap: () async {
                Navigator.pop(
                    context); // Close the bumodal with current context
                //language
                if (noEmis == false) {
                  _scaffoldKey.currentState?.openDrawer();
                  ShowCaseWidget.of(parentContext).startShowCase(
                      [langHelpKey]); //language help model context
                  await Future.delayed(const Duration(seconds: 2));
                  ShowCaseWidget.of(parentContext).startShowCase([helpHelpKey]);
                  await Future.delayed(const Duration(seconds: 2));
                }
                if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                  //if drawer open
                  Navigator.pop(parentContext); //close drawer
                }
                ShowCaseWidget.of(parentContext).startShowCase([loanHelpKey]);
                await Future.delayed(const Duration(seconds: 2));
                ShowCaseWidget.of(parentContext).startShowCase([lendHelpKey]);
              },
            ),
            if (noEmis == false)
              ListTile(
                leading: const Icon(Icons.tag),
                title: const Text('Filter By Tag'),
                onTap: () {
                  Navigator.pop(context); // Close the modal
                  //if no emis present
                  if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                    //if drawer open
                    Navigator.pop(parentContext); //close drawer
                  }
                  ShowCaseWidget.of(parentContext)
                      .startShowCase([filterHelpKey]);
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

  Future<void> exportToCSV(BuildContext context, List<Emi> allemis) async {
    try {
      // Reverse the payments list to ensure correct order

      final Emis = List<Emi>.from(allemis);
      // List to hold the CSV data
      List<List<String>> csvData = [];
      // Add the header row
      // Add the header row
      csvData.add([
        "ID",
        "Title",
        "EMI Type",
        "Principal Amount",
        "Interest Rate",
        "Start Date",
        "End Date",
        "Monthly EMI",
        "Total EMI",
        "Paid",
        "Contact Person Name",
        "Contact Person Phone",
        "Contact Person Email",
        "Other Info",
        "Processing Fee",
        "Other Charges",
        "Part Payment",
        "Advance Payment",
        "Insurance Charges",
        "Moratorium",
        "Moratorium Month",
        "Moratorium Type",
        "Tags",
      ]);

      // Add each emi's data
      for (var emi in Emis) {
        // Convert each Tag object to a map and then encode the list as JSON
        List<Map<String, dynamic>> tagMapList =
            emi.tags.map((tag) => tag.toMap()).toList();
        String tagJson = json.encode(tagMapList);
        String tags = tagJson;
        csvData.add([
          emi.id.toString(),
          emi.title,
          emi.emiType,
          emi.principalAmount.toString(),
          emi.interestRate.toString(),
          emi.startDate.toIso8601String(),
          emi.endDate?.toIso8601String() ?? '',
          emi.contactPersonName,
          emi.contactPersonPhone,
          emi.contactPersonEmail,
          emi.otherInfo,
          emi.processingFee.toString(),
          emi.otherCharges.toString(),
          emi.partPayment.toString(),
          emi.advancePayment.toString(),
          emi.insuranceCharges.toString(),
          (emi.moratorium ?? false) ? "Yes" : "No",
          emi.moratoriumMonth.toString(),
          emi.moratoriumType ?? '',
          emi.monthlyEmi.toString(),
          emi.totalEmi.toString(),
          emi.paid.toString(),
          tags, // Join tags list as a comma-separated string
        ]);
      }
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(csvData);
      // Get the directory to save the file
      Directory directory = await getApplicationDocumentsDirectory();
      final path =
          "/storage/emulated/0/Download/${Emis[0].startDate.day}emi.csv";
      final file = File(path);
      await file.writeAsString(csv);
      // Show the dialog box to let the user choose an action
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Export Options"),
            content: const Text(
                "Would you like to download the CSV or share it via WhatsApp?"),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  // Open the file directly for the user to download it
                  final result = await OpenFile.open(file.path);
                  //  print(result.message);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('CSV saved to: ${file.path}')),
                  );
                },
                child: const Text("Download"),
              ),
              TextButton(
                onPressed: () async {
                  // Open the file using XFile
                  final xfile = XFile(file.path);
                  // Share the file via WhatsApp
                  final result = await Share.shareXFiles([xfile],
                      text: "Here is the CSV file of Payment");
                  if (result.status == ShareResultStatus.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Shared Successfully')),
                    );
                  }
                  await file.delete();
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("Share to WhatsApp"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error while exporting CSV: $e");
    }
  }

  // Function to import CSV data and map it to your Payment model
  Future<void> importPaymentsFromCSV(BuildContext context) async {
    try {
      // File picker to allow user to select CSV file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'], // CSV only
      );

      if (result != null && result.files.single.path != null) {
        //if file exist
        File file = File(result.files.single.path!);

        // Read the file contents
        final input = await file.readAsString();
        // Parse the CSV file
        List<List<dynamic>> csvData = const CsvToListConverter().convert(input);
        // Skip the header row and process the rest
        for (int i = 1; i < csvData.length; i++) {
          //oth row is heading
          var row = csvData[i];
          // Map CSV data to Payment fields
          // Assuming row[22] is a JSON string of tags
          String tagJson = row[22];
          List<Tag> tags = [];
          try {
            // Parse JSON string into a list of maps
            List<dynamic> tagList = json.decode(tagJson);
            print(tagList);

            // Convert each map to a Tag object
            tags = tagList.map((tag) {
              return Tag.fromMap(tag);
            }).toList();
            if (tags.isNotEmpty) // saving  tags in hive
            {
              for (var tag in tags) {
                await ref.read(tagsNotifierProvider.notifier).add(tag);
              }
            }
          } catch (e) {
            print("Error parsing tags: $e");
          }
          Emi SingleEmi = Emi(
            id: row[0].toString(),
            title: row[1].toString(),
            emiType: row[2].toString(),
            principalAmount: double.tryParse(row[3].toString()) ?? 0.0,
            interestRate: double.tryParse(row[4].toString()) ?? 0.0,
            startDate: DateTime.parse(row[5].toString()),
            endDate: DateTime.parse(row[6].toString()),
            contactPersonName: row[7].toString(),
            contactPersonPhone: row[8].toString(),
            contactPersonEmail: row[9].toString(),
            otherInfo: row[10].toString(),
            processingFee: double.tryParse(row[11].toString()),
            otherCharges: double.tryParse(row[12].toString()),
            partPayment: double.tryParse(row[13].toString()),
            advancePayment: double.tryParse(row[14].toString()),
            insuranceCharges: double.tryParse(row[15].toString()),
            moratorium: (row[16].toString() == "Yes" ? true : false),
            moratoriumMonth: int.tryParse(row[17].toString()),
            moratoriumType: row[18].toString(),
            monthlyEmi: double.tryParse(row[19].toString()),
            totalEmi: double.tryParse(row[20].toString()),
            paid: double.tryParse(row[21].toString()),
            tags: tags,
          );
          ref.read(emisNotifierProvider.notifier).add(SingleEmi);
        }
        // Now, do something with the imported payments (e.g., add to your current list)
        setState(() {
          //refresh the ui
        });

        Navigator.of(context).pop(); //pop the drawer
        // Show a confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payments imported successfully!')),
        );
      }
    } catch (e) {
      print("Error while importing CSV: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing CSV: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allEmis =
        ref.watch(homeStateNotifierProvider.select((state) => state.emis));
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
          body: Center(
            child: Lottie.asset(
              'assets/animations/nodata_search.json',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
              repeat: true,
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
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NewEmiPage(emiType: 'lend'),
                      ),
                    ); // Use Navigator instead of GoRouter
                  },
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
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NewEmiPage(emiType: 'loan'),
                      ),
                    ); // Use Navigator instead of GoRouter
                  },
                  heroTag: 'newLoanBtn',
                  backgroundColor: loanColor(context, false),
                  label: Text(l10n.loan),
                  icon: const Icon(Icons.remove),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Collect data for the BarGraph using actual EMIs from the database
    List<double> principalAmounts =
        allEmis.map((emi) => emi.principalAmount).toList();
    List<double> interestAmounts =
        allEmis.map((emi) => emi.totalEmi! - emi.principalAmount).toList();
    List<double> balances = allEmis.map((emi) => emi.totalEmi!).toList();
    List<int> years = allEmis
        .map((emi) => emi.year)
        .toSet()
        .toList(); // Unique years for grouping

    // Trigger animation whenever the home page state changes
    ref.listen(homeStateNotifierProvider, (_, __) {
      _triggerComparisonLottie();
    });

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
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text('Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              Showcase(
                key: langHelpKey,
                description: "You Can Choose Your Regional Language",
                child: const ListTile(
                  title: Text('Select Language'),
                  trailing: LocaleSelectorPopupMenu(),
                ),
              ),
              Showcase(
                key: helpHelpKey,
                description: "Help Button",
                child: ListTile(
                  title: const Text('Help'),
                  trailing: IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () {
                      _showHelpOptions(context);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 13),
                child: ListTile(
                  trailing: const Icon(Icons.settings),
                  title: const Text(
                    'Settings',
                    style: TextStyle(fontStyle: FontStyle.normal),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    context.push('/settings'); // Navigate to settings
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    showCurrencyPicker(
                      context: context,
                      showFlag: true,
                      showCurrencyName: true,
                      showCurrencyCode: true,
                      onSelect: (Currency currency) {
                        ref
                            .read(currencyProvider.notifier)
                            .setCurrencySymbol(currency.symbol);
                      },
                    );
                  },
                  backgroundColor: loanColor(context, false),
                  label: const Text("Change Currency"),
                  icon: const Icon(Icons.currency_exchange),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    importPaymentsFromCSV(context);
                  },
                  backgroundColor: loanColor(context, false),
                  label: const Text("Import CSV"),
                  icon: const Icon(Icons.arrow_downward),
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            // Main content
            SingleChildScrollView(
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

                  // Lottie animation
                  if (_showLottie)
                    SizedBox(
                      height: 100, // Small height
                      child: Lottie.asset(
                        'assets/animations/check_mark.json', // Replace with your Lottie file path
                        repeat: false,
                      ),
                    ),

                  // Comparison results section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (_showComparisonLottie)
                          SizedBox(
                            height: 100, // Adjust height as needed
                            child: Lottie.asset(
                              'assets/animations/scales_balancing.json', // Replace with your Lottie file path
                              repeat: false, // Play only once
                            ),
                          ),
                        // Comparison data (example placeholder)
                      ],
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
                        onLoanOrLendModified:
                            _onLoanOrLendModified, // Pass callback
                      );
                    },
                  ),
                ],
              ),
            ),
            // Lottie animation for validation errors
            if (_showErrorLottie)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: SizedBox(
                    height: 250,
                    child: Lottie.asset(
                      'assets/animations/warning_icon.json',
                      repeat: true,
                    ),
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Showcase(
              key: lendHelpKey,
              description: "Add New Lend from Here",
              child: FloatingActionButton.extended(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NewEmiPage(emiType: 'lend'),
                    ),
                  );
                  _triggerComparisonLottie(); // Trigger scales balancing animation
                },
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
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NewEmiPage(emiType: 'loan'),
                    ),
                  );
                  _triggerComparisonLottie(); // Trigger scales balancing animation
                },
                heroTag: 'newLoanBtn',
                backgroundColor: loanColor(context, false),
                label: Text(l10n.loan),
                icon: const Icon(Icons.remove),
              ),
            ),
            FloatingActionButton.extended(
              onPressed: () {
                _triggerComparisonLottie(); // Trigger comparison animation
                exportToCSV(context, allEmis);
              },
              backgroundColor: Colors.green,
              label: Text(l10n.share),
              icon: const Icon(Icons.share),
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
  //

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
      DateTime startDate = emi.startDate;
      final int tenureInYears = ((emi.endDate?.year ?? 0) - emi.startDate.year);

      final int sign = emi.emiType == 'loan' ? (-1) : 1;
      double monthlyEmi =
          _calculateEMI(emi.principalAmount, emi.interestRate, tenureInYears);
      double remainingPrincipal = emi.principalAmount;
      for (int month = 0; month < tenureInYears * 12; month++) {
        double monthlyInterestRate = emi.interestRate / (12 * 100);
        double monthlyInterest = remainingPrincipal * monthlyInterestRate;
        double monthlyPrincipal = monthlyEmi - monthlyInterest;
        remainingPrincipal -= monthlyPrincipal;

        int adjustedYear =
            startDate.year + ((startDate.month - 1 + month) ~/ 12);
        int adjustedMonth = (startDate.month - 1 + month) % 12 + 1;
        amortizationEntries.add(AmortizationEntry(
            title: emi.title,
            principal: sign * monthlyPrincipal,
            interest: sign * monthlyInterest,
            totalPayment: sign * monthlyEmi,
            year: adjustedYear,
            month: adjustedMonth,
            type: emi.emiType == 'loan' ? 0 : 1));
      }
    }

    return amortizationEntries;
  }

  double _calculateEMI(
      double principalAmount, double interestRate, int tenureYears) {
    double monthlyInterestRate = interestRate / (12 * 100);
    int totalMonths = tenureYears * 12;

    double emiAmount;
    if (monthlyInterestRate == 0) {
      // 0% interest: simple division
      emiAmount = principalAmount / totalMonths;
    } else {
      emiAmount = (principalAmount *
              monthlyInterestRate *
              pow(1 + monthlyInterestRate, totalMonths)) /
          (pow(1 + monthlyInterestRate, totalMonths) - 1);
    }

    return GlobalFormatter.roundNumber(ref, emiAmount);
  }

  double _calculateTotalInterest(List<AmortizationEntry> amortizationEntries) {
    return amortizationEntries.fold(0.0, (sum, entry) => sum + entry.interest);
  }

  double _calculateTotalAmount(List<AmortizationEntry> amortizationEntries) {
    return amortizationEntries.fold(
        0.0, (sum, entry) => sum + entry.totalPayment);
  }

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
    required this.onLoanOrLendModified,
  });

  final Color emiTypeColor;
  final AppLocalizations l10n;
  final Emi emi;
  final double interestAmount;
  final double totalAmount;
  final double principalAmount;
  final VoidCallback onLoanOrLendModified;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencySymbol = ref.watch(currencyProvider);
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
          side: BorderSide(color: emiTypeColor, width: 2),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
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
                        final emiId = emi.id;
                        final emiType = emi.emiType;
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
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        Row(
                          children: [
                            Text(
                              '${l10n.emi}: ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
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
                    thickness: 2,
                    color: Colors.grey,
                    width: 2,
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
      onLoanOrLendModified();
    }
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

class _HomePageNavigatorObserver extends NavigatorObserver {
  final HomePageState homePageState;

  _HomePageNavigatorObserver(this.homePageState);

  void didPopNext() {
    homePageState._triggerComparisonLottie();
  }
}
