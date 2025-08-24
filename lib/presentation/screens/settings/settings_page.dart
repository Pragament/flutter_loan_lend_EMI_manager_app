import 'dart:convert'; // For jsonEncode
import 'package:emi_manager/logic/backup_service.dart';
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
        padding: const EdgeInsets.all(16.0),
        children: [
          // Rounding & Precision settings
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('Rounding & Precision Settings'),
            subtitle: const Text(
              'Configure how numbers are displayed and calculated',
            ),
            onTap: () {
              context.push('/settings/rounding');
            },
          ),

          const SizedBox(height: 20),

          // 🔹 Backup button
          ElevatedButton(
            onPressed: () async {
              try {
                // Replace this with your Hive data later
                final dummyBackupData = jsonEncode({
                  "loans": [],
                  "lends": [],
                  "transactions": [],
                });

                await BackupService.uploadBackupFile(
                  'emi_backup.json',
                  dummyBackupData,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Backup uploaded to Drive')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Backup failed: $e')),
                );
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Text('Backup'),
            ),
          ),
        ],
      ),
    );
  }
}