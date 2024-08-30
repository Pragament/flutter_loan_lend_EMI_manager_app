import 'package:emi_manager/logic/emis_provider.dart';
import 'package:emi_manager/presentation/constants.dart';
import 'package:emi_manager/presentation/router/routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/locale_selector_popup_menu.dart';

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

    final allEmis = ref.watch(emisNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: const [
          LocaleSelectorPopupMenu(),
        ],
      ),
      body: ListView.builder(
        itemCount: allEmis.length,
        itemBuilder: (context, index) {
          final emi = allEmis.elementAt(index);

          final emiTypeColor = emi.emiType == 'lend'
              ? lendColor(context, true)
              : loanColor(context, true);

          return Card(
            elevation: 0,
            child: ListTile(
              leading: Container(
                color: emiTypeColor,
                width: 50,
              ),
              title: Text(emi.title),
            ),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () => const NewEmiRoute(emiType: 'lend').push(context),
            heroTag: 'newLendBtn',
            backgroundColor: lendColor(context, false),
            label: const Text('Lend'),
            icon: const Icon(Icons.add),
          ),
          FloatingActionButton.extended(
            onPressed: () => const NewEmiRoute(emiType: 'loan').push(context),
            heroTag: 'newLoanBtn',
            backgroundColor: loanColor(context, false),
            label: const Text('Loan'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
