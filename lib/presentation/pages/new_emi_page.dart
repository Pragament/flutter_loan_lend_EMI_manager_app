import 'package:emi_manager/data/models/emi_model.dart';
import 'package:emi_manager/logic/emis_provider.dart';
import 'package:emi_manager/presentation/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class NewEmiPage extends ConsumerStatefulWidget {
  const NewEmiPage({super.key, required this.emiType});
  final String emiType;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewEmiPageState();
}

class _NewEmiPageState extends ConsumerState<NewEmiPage> {
  late String emiType;

  final _formKey = GlobalKey<FormState>();

  //controllers
  final titleC = TextEditingController();
  final principalAmountC = TextEditingController(text: '0');
  final interestRateC = TextEditingController(text: '0');
  final startDateC = TextEditingController(text: DateTime.now().toLocal().toString().split(' ')[0]);
  final endDateC = TextEditingController();
  final contactPersonNameC = TextEditingController();
  final contactPersonPhoneC = TextEditingController();
  final contactPersonEmailC = TextEditingController();
  final otherInfoC = TextEditingController();
  final processingFeeC = TextEditingController(text: '0');
  final otherChargesC = TextEditingController(text: '0');
  final partPaymentC = TextEditingController(text: '0');
  final advancePaymentC = TextEditingController(text: '0');
  final insuranceChargesC = TextEditingController(text: '0');
  final moratoriumC = TextEditingController(text: 'false');
  final moratoriumMonthC = TextEditingController(text: '1');
  final moratoriumTypeC = TextEditingController();
  final monthlyEmiC = TextEditingController(text: '0');
  final totalEmiC = TextEditingController(text: '0');
  final paidC = TextEditingController(text: '0');
  //\\

  @override
  void initState() {
    emiType = widget.emiType;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.emi),
      ),
      body: Column(
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
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.title),
                          labelText: l10n.title,
                        ),
                      ),
                    ),
                    // Principal Amount Field
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: principalAmountC,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.money),
                          labelText: l10n.loanAmount,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.enterAmount;
                          }
                          return null;
                        },
                      ),
                    ),
                    // Interest Rate Field
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: interestRateC,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.percent),
                          labelText: l10n.interestRate,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.enterInterestRate;
                          }
                          return null;
                        },
                      ),
                    ),
                    // Start Date Field
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: startDateC,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                          labelText: l10n.startDate,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.enterStartDate;
                          }
                          return null;
                        },
                      ),
                    ),
                    // End Date Field
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: endDateC,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                          labelText: l10n.endDate,
                        ),
                      ),
                    ),
                    // Contact Person Name Field
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: contactPersonNameC,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.person),
                          labelText: l10n.contactPersonName,
                        ),
                      ),
                    ),
                    // Contact Person Phone Field
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: contactPersonPhoneC,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.phone),
                          labelText: l10n.contactPersonPhone,
                        ),
                      ),
                    ),
                    // Contact Person Email Field
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: contactPersonEmailC,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.email),
                          labelText: l10n.contactPersonEmail,
                        ),
                      ),
                    ),
                    // Other Info Field
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: otherInfoC,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.info),
                          labelText: l10n.otherInfo,
                        ),
                      ),
                    ),
                    // Processing Fee Field
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: processingFeeC,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                          labelText: l10n.processingFee,
                        ),
                      ),
                    ),
                    // Other Charges Field
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: otherChargesC,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                          labelText: l10n.otherCharges,
                        ),
                      ),
                    ),
                    // Part Payment Field
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: partPaymentC,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                          labelText: l10n.partPayment,
                        ),
                      ),
                    ),
                    // Advance Payment Field
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: advancePaymentC,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                          labelText: l10n.advancePayment,
                        ),
                      ),
                    ),
                    // Insurance Charges Field
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: insuranceChargesC,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                          labelText: l10n.insuranceCharges,
                        ),
                      ),
                    ),
                    // Moratorium Field
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: moratoriumC,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.access_time),
                          labelText: l10n.moratorium,
                        ),
                      ),
                    ),
                    // Moratorium Month Field
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: moratoriumMonthC,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.access_time),
                          labelText: l10n.moratoriumMonth,
                        ),
                      ),
                    ),
                    // Moratorium Type Field
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: moratoriumTypeC,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.access_time),
                          labelText: l10n.moratoriumType,
                        ),
                      ),
                    ),
                    // Monthly EMI Field
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: monthlyEmiC,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                          labelText: l10n.monthlyEmi,
                        ),
                      ),
                    ),
                    // Total EMI Field
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: totalEmiC,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                          labelText: l10n.totalEmi,
                        ),
                      ),
                    ),
                    // Paid Field
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: paidC,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(borderRadius)),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                          labelText: l10n.paid,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                var id = const Uuid().v4();

                final newEmi = Emi(
                  id: id,
                  title: titleC.text,
                  emiType: emiType,
                  principalAmount: double.tryParse(principalAmountC.text) ??
                      int.parse(principalAmountC.text).toDouble(),
                  interestRate: double.tryParse(interestRateC.text) ??
                      int.parse(interestRateC.text).toDouble(),
                  startDate: DateTime.tryParse(startDateC.text) ?? DateTime.now(),
                  endDate: DateTime.tryParse(endDateC.text),
                  contactPersonName: contactPersonNameC.text,
                  contactPersonPhone: contactPersonPhoneC.text,
                  contactPersonEmail: contactPersonEmailC.text,
                  otherInfo: otherInfoC.text,
                  processingFee: double.tryParse(processingFeeC.text) ?? 0,
                  otherCharges: double.tryParse(otherChargesC.text) ?? 0,
                  partPayment: double.tryParse(partPaymentC.text) ?? 0,
                  advancePayment: double.tryParse(advancePaymentC.text) ?? 0,
                  insuranceCharges: double.tryParse(insuranceChargesC.text) ?? 0,
                  moratorium: moratoriumC.text.toLowerCase() == 'true',
                  moratoriumMonth: int.tryParse(moratoriumMonthC.text) ?? 1,
                  moratoriumType: moratoriumTypeC.text,
                  monthlyEmi: double.tryParse(monthlyEmiC.text) ?? 0,
                  totalEmi: double.tryParse(totalEmiC.text) ?? 0,
                  paid: double.tryParse(paidC.text) ?? 0,
                );

                await ref.read(emisNotifierProvider.notifier).add(newEmi);
                context.pop();
              }
            },
            style: const ButtonStyle(
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(borderRadius))))),
            icon: const Icon(Icons.save),
            label: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
