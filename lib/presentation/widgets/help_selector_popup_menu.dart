import 'package:flutter/material.dart';

// Function to show help dialog with a list of topics
void showHelpDialog(BuildContext context, String screen) {
  List<String> helpTopics;

  // Define help topics based on the current screen
  if (screen == 'Home') {
    helpTopics = [
      'Create Loan',
      'Create Lend',
      'Change language/currency',
      'Filtering by multiple tags',
      'Help Button'
    ];
  } else if (screen == 'Loan' || screen == 'Lend' || screen == 'Loan') {
    helpTopics = [
      'Tags - Create Tags',
      'Pick from List',
    ];
  } else {
    helpTopics = [];
  }

  // Show the help dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Help Topic'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: helpTopics.map((topic) {
            return ListTile(
              title: Text(topic),
              onTap: () {
                // Close the current dialog and show detailed help
                Navigator.of(context).pop();
                showHelpDetail(context, topic);
              },
            );
          }).toList(),
        ),
      );
    },
  );
}

// Function to show detailed help content for a selected topic
void showHelpDetail(BuildContext context, String topic) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(topic),
        content: Text('This is help content for $topic.'),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
