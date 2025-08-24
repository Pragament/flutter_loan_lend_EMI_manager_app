import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

// Function to show help dialog with a list of topics
void showHomeHelpDialog(BuildContext context, GlobalKey loankey,
    GlobalKey lendkey, GlobalKey langkey, GlobalKey helpkey) {
  List<Map<String, dynamic>> helpTopics = [
    {'title': 'Create Loan', 'key': loankey},
    {'title': 'Create Lend', 'key': lendkey},
    {'title': 'Change language/currency', 'key': langkey},
    {'title': 'Need Help', 'key': helpkey},
    // Add more help topics as necessary
  ];

  // Show the help topic dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Help Topic'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: helpTopics.map((topic) {
            return ListTile(
              title: Text(topic['title']),
              onTap: () {
                Navigator.of(context).pop();
                // Trigger ShowcaseView for the selected key
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ShowCaseWidget.of(context).startShowCase([topic['key']]);
                });
              },
            );
          }).toList(),
        ),
      );
    },
  );
}
