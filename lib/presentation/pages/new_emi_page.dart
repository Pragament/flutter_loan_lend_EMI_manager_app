import 'dart:math';
import 'package:emi_manager/data/models/emi_model.dart';
import 'package:emi_manager/data/models/tag_model.dart';
import 'package:emi_manager/logic/emis_provider.dart';
import 'package:emi_manager/presentation/constants.dart';
import 'package:emi_manager/presentation/pages/home/widgets/tags_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class NewEmiPage extends ConsumerStatefulWidget {
  const NewEmiPage({super.key, required this.emiType, this.emiId});
  final String emiType;
  final String? emiId; // Optional parameter for editing
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewEmiPageState();
}

class _NewEmiPageState extends ConsumerState<NewEmiPage> {
  late String emiType;
  String? emiId;

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
  double months = 1.0;

  // tags
  List<Tag> tags = [];

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

          final totalDays = duration.inDays;
          final yearsFromDays = (totalDays / 365).floor();
          final remainingDays = totalDays % 365;
          final monthsFromDays = (remainingDays / 30).floor();

          years = yearsFromDays.toDouble();
          months = monthsFromDays.toDouble();
        } else {
          // If endDate is null, set default values for years and months
          years = 1.0;
          months = 1.0;
        }
      });
    }
  }

  void _showPreviewDialog() {
    final l10n = AppLocalizations.of(context)!;

    final totalMonths = (years * 12 + months).toInt();
    final monthlyInterestRate = interestRate / 12 / 100;
    final powTerm = pow((1 + monthlyInterestRate), totalMonths);
    final numerator = principalAmount * monthlyInterestRate * powTerm;
    final denominator = powTerm - 1;
    final monthlyEmi = numerator / denominator;
    final totalEmi = monthlyEmi * totalMonths;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.preview),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.title}: ${titleC.text}'),
            Text('${l10n.loanAmount}: ₹${principalAmount.toStringAsFixed(0)}'),
            Text('${l10n.interestRate}: ${interestRate.toStringAsFixed(1)}%'),
            Text('${l10n.startDate}: ${startDateC.text}'),
            Text(
                '${l10n.endDate}: ${DateTime.parse(startDateC.text).add(Duration(days: (totalMonths * 30))).toLocal().toString().split(' ')[0]}'),
            Text('${l10n.monthlyEmi}: ₹${monthlyEmi.toStringAsFixed(2)}'),
            Text('${l10n.totalEmi}: ₹${totalEmi.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveEmi();
            },
            child: Text(l10n.save),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _saveEmi() {
    final startDate = DateTime.parse(startDateC.text);
    final totalMonths = (years * 12 + months).toInt();
    final endDate =
        startDate.add(Duration(days: (totalMonths * 30))); // Approximation

    // EMI Calculation using the formula
    final monthlyInterestRate = interestRate / 12 / 100;
    final powTerm = pow((1 + monthlyInterestRate), totalMonths);
    final numerator = principalAmount * monthlyInterestRate * powTerm;
    final denominator = powTerm - 1;
    final monthlyEmi = numerator / denominator;
    final totalEmi = monthlyEmi * totalMonths;

    final emi = Emi(
      id: emiId ??
          const Uuid().v4(), // Use provided emiId or generate a new one
      title: titleC.text,
      principalAmount: principalAmount,
      interestRate: interestRate,
      startDate: startDate,
      endDate: endDate,
      contactPersonName: contactPersonNameC.text,
      contactPersonPhone: contactPersonPhoneC.text,
      contactPersonEmail: contactPersonEmailC.text,
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
    );

    if (emiId != null) {
      // Update existing EMI
      ref.read(emisNotifierProvider.notifier).update(emi);
    } else {
      // Create new EMI
      ref.read(emisNotifierProvider.notifier).add(emi);
    }

    GoRouter.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.emi),
      ),
      body: body(context, l10n),
    );
  }

  Column body(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
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
                    child: TextFormField(
                      controller: titleC,
                      decoration: InputDecoration(
                        labelText: l10n.title,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  // Principal Amount Slider
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Text(
                            '${l10n.loanAmount}: ₹${principalAmount.toStringAsFixed(0)}'),
                        Expanded(
                          child: Slider(
                            value: principalAmount,
                            min: 0,
                            max: 1000000,
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
                          child: TextField(
                            controller: principalAmountC,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              //labelText: l10n.loanAmount,
                            ),
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
                  // Interest Rate Slider
                  Padding(
                    padding: const EdgeInsets.all(4.0),
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
                              //labelText: l10n.interestRate,
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
                  // Start Date Field
                  // Start Date Field with Date Picker
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: InkWell(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          setState(() {
                            startDateC.text =
                                pickedDate.toLocal().toString().split(' ')[0];
                          });
                        }
                      },
                      child: IgnorePointer(
                        // To prevent keyboard from appearing
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

                  // Years Slider
                  Padding(
                    padding: const EdgeInsets.all(4.0),
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
                            min: 1,
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
                    child: TextFormField(
                      controller: contactPersonNameC,
                      decoration: InputDecoration(
                        labelText: l10n.contactPersonName,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                      controller: contactPersonPhoneC,
                      decoration: InputDecoration(
                        labelText: l10n.contactPersonPhone,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                      controller: contactPersonEmailC,
                      decoration: InputDecoration(
                        labelText: l10n.contactPersonEmail,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
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
                          tags.isEmpty
                              ? Expanded(
                                  child: GestureDetector(
                                    child: const Text(
                                      'Tap to add a tag',
                                      style: TextStyle(color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                    onTap: () async {
                                      tags = await showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) =>
                                            TagsSelectionDialog(
                                                selectedTags: tags),
                                      );

                                      setState(() {});
                                    },
                                  ),
                                )
                              : Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: List.generate(
                                        tags.length,
                                        (index) {
                                          final tag = tags.elementAt(index);

                                          return Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: FittedBox(
                                              fit: BoxFit.contain,
                                              child: FilterChip(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                label: Text('# ${tag.name}'),
                                                shape: RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            borderRadius)),
                                                onSelected: (selected) =>
                                                    setState(
                                                        () => tags.remove(tag)),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                          IconButton(
                            onPressed: () async {
                              tags = await showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) =>
                                    TagsSelectionDialog(selectedTags: tags),
                              );

                              setState(() {});
                            },
                            icon: Icon(Icons.add,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Submit Button
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _showPreviewDialog();
                        }
                      },
                      child: Text(l10n.save),
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
