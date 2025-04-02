import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // App theme settings

          // Rounding & Precision settings
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('Rounding & Precision Settings'),
            subtitle: const Text(
                'Configure how numbers are displayed and calculated'),
            onTap: () {
              context.push('/settings/rounding');
            },
          ),

          // About section
        ],
      ),
    );
  }
}
