// ignore_for_file: use_build_context_synchronously

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
                      child: const Text('Lend', textAlign: TextAlign.center),
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
                      child: const Text('Loan', textAlign: TextAlign.center),
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
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: titleC,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(borderRadius))),
                          prefixIcon: Icon(Icons.title),
                          labelText: 'Title',
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
                  startDate: DateTime.now(),
                  endDate: null,
                  contactPersonName: '',
                  contactPersonPhone: '',
                  contactPersonEmail: '',
                  otherInfo: '',
                  processingFee: 0,
                  otherCharges: 0,
                  partPayment: 0,
                  advancePayment: 0,
                  insuranceCharges: 0,
                  moratorium: false,
                  moratoriumMonth: 1,
                  moratoriumType: '',
                  monthlyEmi: 0,
                  totalEmi: 0,
                  paid: 0,
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
            label: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}
