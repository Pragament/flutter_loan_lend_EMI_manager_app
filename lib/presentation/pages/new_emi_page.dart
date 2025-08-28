// ignore_for_file: unused_element, use_build_context_synchronously

import 'dart:math';

import 'package:emi_manager/data/models/emi_model.dart';
import 'package:emi_manager/data/models/tag_model.dart';
import 'package:emi_manager/logic/currency_provider.dart';
import 'package:emi_manager/logic/emis_provider.dart';
import 'package:emi_manager/presentation/constants.dart';
import 'package:emi_manager/presentation/pages/home/widgets/tags_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:emi_manager/presentation/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:uuid/uuid.dart';
import 'package:lottie/lottie.dart';

class NewEmiPage extends ConsumerStatefulWidget {
  final String emiType;
  final String? emiId;
  final bool startTour;
  const NewEmiPage(
      {super.key, required this.emiType, this.emiId, this.startTour = false});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewEmiPageState();
}

class _NewEmiPageState extends ConsumerState<NewEmiPage> {
  late String emiType;
  String? emiId;
  GlobalKey tagsKey = GlobalKey();
  GlobalKey selectTagsKey = GlobalKey();
  GlobalKey createTagsKey = GlobalKey();
  GlobalKey saveButtonKey = GlobalKey();
  // Add showcase keys for all fields
  final GlobalKey titleKey = GlobalKey();
  final GlobalKey principalAmountKey = GlobalKey();
  final GlobalKey interestRateKey = GlobalKey();
  final GlobalKey startDateKey = GlobalKey();
  final GlobalKey tenureKey = GlobalKey();
  final GlobalKey contactPersonNameKey = GlobalKey();
  final GlobalKey contactPersonPhoneKey = GlobalKey();
  final GlobalKey contactPersonEmailKey = GlobalKey();
  final GlobalKey emiTypeKey = GlobalKey(); // For lend/loan buttons

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final titleC = TextEditingController();
  final startDateC = TextEditingController();
  final contactPersonNameC = TextEditingController();
  final contactPersonPhoneC = TextEditingController();
  final contactPersonEmailC = TextEditingController();

  // TextEditingControllers for Sliders
  final principalAmountC = TextEditingController();
  final interestRateC = TextEditingController();

  // Slider values
  double principalAmount = 110.0;
  double interestRate = 10.0;
  double years = 1.0;
  double months = 0.0;

  // Tags
  List<Tag> tags = [];

  // New state variable to control Lottie animation visibility
  bool _showLottie = false;

  // Short help texts for each field
  final Map<String, String> _helpTexts = {
    'emiType': 'Choose whether this entry is a lend or a loan.',
    'title': 'A short name for your loan or lend.',
    'principalAmount': 'Total money you lend or borrow.',
    'interestRate': 'Yearly interest rate (0 if none).',
    'startDate': 'Date when the loan/lend starts.',
    'tenure': 'How long the loan/lend lasts.',
    'contactPersonName': 'Who you are lending to or borrowing from.',
    'contactPersonPhone': 'Their phone number.',
    'contactPersonEmail': 'Their email address.',
    'tags': 'Tags help you organize and search.',
    'save': 'Save your entry after filling details.',
  };

  @override
  void initState() {
    super.initState();
    emiType = widget.emiType;
    emiId = widget.emiId;

    if (emiId != null) {
      _loadEmiData();
    } else {
      // Default values for new EMI
      principalAmountC.text = principalAmount.toStringAsFixed(0);
      interestRateC.text = interestRate.toStringAsFixed(1);
      startDateC.text = DateTime.now().toLocal().toString().split(' ')[0];
    }

    if (widget.startTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase([
          emiTypeKey,
          titleKey,
          principalAmountKey,
          interestRateKey,
          startDateKey,
          tenureKey,
          contactPersonNameKey,
          contactPersonPhoneKey,
          contactPersonEmailKey,
          tagsKey,
          saveButtonKey,
        ]);
      });
    }
  }

  void _loadEmiData() async {
    // Fetch EMI data using emiId and populate fields
    final emi =
        await ref.read(emisNotifierProvider.notifier).getEmiById(emiId!);

    if (emi != null) {
      setState(() {
        titleC.text = emi.title;
        principalAmount = emi.principalAmount;
        interestRate = emi.interestRate;

        principalAmountC.text = principalAmount.toStringAsFixed(0);
        interestRateC.text = interestRate.toStringAsFixed(1);
        startDateC.text = emi.startDate.toLocal().toString().split(' ')[0];
        contactPersonNameC.text = emi.contactPersonName;
        contactPersonPhoneC.text = emi.contactPersonPhone;
        contactPersonEmailC.text = emi.contactPersonEmail;
        tags = List.from(emi.tags);

        // Calculate the difference between startDate and endDate
        final startDate = emi.startDate;
        final endDate = emi.endDate;

        if (endDate != null) {
          final duration = endDate.difference(startDate);

          final totalMonths =
              (duration.inDays / 30).round(); // Approximate months
          years = (totalMonths / 12).floor().toDouble();
          months = (totalMonths % 12).toDouble();
        } else {
          // If endDate is null, set default values for years and months
          years = 1.0;
          months = 1.0;
        }
      });
    }
  }

  void _saveEmi() {
    final startDate = DateTime.parse(startDateC.text);

    // Store exact user input for total months (important for consistency)
    final int yearsInt = years.toInt();
    final int monthsInt = months.toInt();
    final int totalMonths = (yearsInt * 12 + monthsInt);

    // Calculate end date using the exact number of months
    final endDate = DateTime(
      startDate.year + yearsInt,
      startDate.month + monthsInt,
      startDate.day,
    );

    // Precise EMI calculation with exact formulas
    double monthlyEmi;
    double totalEmi;

    if (interestRate <= 0 || totalMonths <= 0) {
      // Handle 0% interest case
      monthlyEmi = totalMonths > 0 ? principalAmount / totalMonths : 0;
      totalEmi = principalAmount;
    } else {
      // Use exact decimal conversion with precise division
      final double monthlyInterestRate =
          interestRate / 1200; // Divide by 12 and 100

      // Calculate EMI using standard formula with high precision
      final powFactor = pow(1 + monthlyInterestRate, totalMonths);
      monthlyEmi =
          principalAmount * monthlyInterestRate * powFactor / (powFactor - 1);

      // Use fixed precision for financial calculations
      monthlyEmi = double.parse(monthlyEmi.toStringAsFixed(2));

      // Calculate total amount based on precise monthly EMI
      totalEmi = monthlyEmi * totalMonths;
    }

    final emi = Emi(
      id: emiId ?? const Uuid().v4(),
      title: titleC.text,
      principalAmount: principalAmount,
      interestRate: interestRate,
      startDate: startDate,
      endDate: endDate,
      contactPersonName: contactPersonNameC.text,
      contactPersonPhone: contactPersonPhoneC.text,
      contactPersonEmail: contactPersonEmailC.text,
      // Store precise calculation results
      monthlyEmi: monthlyEmi,
      totalEmi: totalEmi,
      emiType: emiType,
      otherInfo: '',
      processingFee: null,
      otherCharges: null,
      partPayment: null,
      advancePayment: null,
      insuranceCharges: null,
      moratorium: null,
      moratoriumMonth: null,
      moratoriumType: '',
      paid: null,
      tags: tags,
      // Store exact user input values for consistency
      selectedYears: years,
      selectedMonths: months,
    );

    if (emiId != null) {
      // Update existing EMI
      ref.read(emisNotifierProvider.notifier).update(emi);
    } else {
      // Create new EMI
      ref.read(emisNotifierProvider.notifier).add(emi);
    }

    // Show Lottie animation and background blur
    setState(() {
      _showLottie = true;
    });

    // Hide Lottie animation after 3 seconds and navigate back
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showLottie = false;
      });
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Use Navigator to safely navigate back
      }
    });
  }

  void _showHelpDialog(BuildContext context, String fieldKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help'),
        content:
            Text(_helpTexts[fieldKey] ?? 'No help available for this field.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpOptions(BuildContext parentContext) {
    ShowCaseWidget.of(parentContext).startShowCase([
      emiTypeKey,
      titleKey,
      principalAmountKey,
      interestRateKey,
      startDateKey,
      tenureKey,
      contactPersonNameKey,
      contactPersonPhoneKey,
      contactPersonEmailKey,
      tagsKey,
      saveButtonKey,
    ]);
  }

  void _addTag(Tag newTag) {
    setState(() {
      if (!tags.contains(newTag)) {
        tags.add(newTag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(currencyProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.emi),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpOptions(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Removed Lottie animation for loan repayment visualization
              Expanded(
                child: body(context, l10n), // Your existing form body
              ),
            ],
          ),
          if (_showLottie)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {}, // Prevent interaction with the background
                child: Container(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.3), // Background blur
                  child: Center(
                    child: Lottie.asset(
                      'assets/animations/check_mark.json', // Path to your Lottie file
                      width: 500, // Width of the animation
                      height: 500, // Height of the animation
                      fit: BoxFit.contain,
                      repeat: false, // Run the animation only once
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Column body(BuildContext context, AppLocalizations l10n) {
    final currencySymbol = ref.watch(currencyProvider);
    return Column(
      children: [
        Showcase(
          key: emiTypeKey,
          description: _helpTexts['emiType']!,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: InkWell(
                    borderRadius:
                        const BorderRadius.all(Radius.circular(borderRadius)),
                    onTap: () => setState(() => emiType = 'lend'),
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: lendColor(context, false),
                        border: emiType == 'lend' ? Border.all() : null,
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      child: Text(l10n.lend, textAlign: TextAlign.center),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: InkWell(
                    borderRadius:
                        const BorderRadius.all(Radius.circular(borderRadius)),
                    onTap: () => setState(() => emiType = 'loan'),
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: loanColor(context, false),
                        border: emiType == 'loan' ? Border.all() : null,
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      child: Text(l10n.loan, textAlign: TextAlign.center),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Title Field
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Showcase(
                      key: titleKey,
                      description: _helpTexts['title']!,
                      child: TextFormField(
                        controller: titleC,
                        decoration: InputDecoration(
                          labelText: l10n.title,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  // Principal Amount Slider
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Showcase(
                      key: principalAmountKey,
                      description: _helpTexts['principalAmount']!,
                      child: Row(
                        children: [
                          Text(
                              '${l10n.loanAmount}: $currencySymbol${principalAmount.toStringAsFixed(0)}'),
                          Expanded(
                            child: Slider(
                              value: principalAmount,
                              min: 0,
                              max: 10000000,
                              divisions: 100,
                              label: principalAmount.toStringAsFixed(0),
                              onChanged: (value) {
                                setState(() {
                                  principalAmount = value;
                                  principalAmountC.text =
                                      value.toStringAsFixed(0);
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              controller: principalAmountC,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                final amount = double.tryParse(value ?? '');
                                if (amount == null || amount <= 0) {
                                  return 'Enter amount > 0';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  principalAmount = double.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Interest Rate Slider
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Showcase(
                      key: interestRateKey,
                      description: _helpTexts['interestRate']!,
                      child: Row(
                        children: [
                          Text(
                              '${l10n.interestRate}: ${interestRate.toStringAsFixed(1)}%'),
                          Expanded(
                            child: Slider(
                              value: interestRate,
                              min: 0,
                              max: 20,
                              divisions: 200,
                              label: interestRate.toStringAsFixed(1),
                              onChanged: (value) {
                                setState(() {
                                  interestRate = value;
                                  interestRateC.text = value.toStringAsFixed(1);
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: interestRateC,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  interestRate = double.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Start Date Field with Date Picker
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Showcase(
                      key: startDateKey,
                      description: _helpTexts['startDate']!,
                      child: InkWell(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );

                          setState(() {
                            startDateC.text =
                                pickedDate!.toLocal().toString().split(' ')[0];
                          });
                        },
                        child: IgnorePointer(
                          child: TextFormField(
                            controller: startDateC,
                            decoration: InputDecoration(
                              labelText: l10n.startDate,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? l10n.enterStartDate
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Years Slider
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Showcase(
                      key: tenureKey,
                      description: _helpTexts['tenure']!,
                      child: Row(
                        children: [
                          Text(
                              '${l10n.tenure}: ${years.toStringAsFixed(0)} ${l10n.years}'),
                          Expanded(
                            child: Slider(
                              value: years,
                              min: 1,
                              max: 30,
                              divisions: 29,
                              label: years.toStringAsFixed(0),
                              onChanged: (value) {
                                setState(() {
                                  years = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Months Slider
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Text(
                            '${l10n.tenure}: ${months.toStringAsFixed(0)} ${l10n.months}'),
                        Expanded(
                          child: Slider(
                            value: months,
                            min: 0,
                            max: 11,
                            divisions: 11,
                            label: months.toStringAsFixed(0),
                            onChanged: (value) {
                              setState(() {
                                months = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Contact Person Fields
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Showcase(
                      key: contactPersonNameKey,
                      description: _helpTexts['contactPersonName']!,
                      child: TextFormField(
                        controller: contactPersonNameC,
                        decoration: InputDecoration(
                          labelText: l10n.contactPersonName,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Showcase(
                      key: contactPersonPhoneKey,
                      description: _helpTexts['contactPersonPhone']!,
                      child: TextFormField(
                        controller: contactPersonPhoneC,
                        decoration: InputDecoration(
                          labelText: l10n.contactPersonPhone,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Showcase(
                      key: contactPersonEmailKey,
                      description: _helpTexts['contactPersonEmail']!,
                      child: TextFormField(
                        controller: contactPersonEmailC,
                        decoration: InputDecoration(
                          labelText: l10n.contactPersonEmail,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  // Tags Field
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Card(
                      elevation: 0,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.tag,
                                color: Theme.of(context).colorScheme.primary,
                                size: 22),
                          ),
                          Text(
                            '${l10n.tags}:',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: tags.map((tag) {
                                  return Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: FilterChip(
                                        padding: const EdgeInsets.all(4.0),
                                        label: Text('# ${tag.name}'),
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                              color: Colors.grey),
                                          borderRadius: BorderRadius.circular(
                                              borderRadius),
                                        ),
                                        onSelected: (selected) {
                                          setState(() {
                                            tags.remove(
                                                tag); // Remove tag on deselect
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              final selectedTags = await showDialog<List<Tag>>(
                                context: context,
                                builder: (context) =>
                                    TagsSelectionDialog(selectedTags: tags),
                              );

                              if (selectedTags != null) {
                                setState(() {
                                  tags = List.from(
                                      selectedTags); // Ensure tags are updated correctly
                                });
                              }
                            },
                            icon: Showcase(
                              key: tagsKey,
                              description:
                                  "Create New Tags or Select From Previous Tags",
                              child: Icon(
                                Icons.add,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    left: MediaQuery.of(context).size.width / 2 - 50,
                    child: Lottie.asset(
                      'assets/animations/arrow_bouncing.json',
                      width: 50,
                      height: 50,
                      repeat: true, // Keep looping
                    ),
                  ),
                  // Submit Button
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Showcase(
                      key: saveButtonKey,
                      description: "Tap here to save your loan/lend entry.",
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _saveEmi();
                          }
                        },
                        child: Text(l10n.save),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
