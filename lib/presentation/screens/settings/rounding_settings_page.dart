import 'package:emi_manager/data/models/rounding_settings.dart';
import 'package:emi_manager/logic/rounding_provider.dart';
import 'package:emi_manager/utils/number_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RoundingSettingsPage extends ConsumerWidget {
  const RoundingSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(roundingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rounding & Precision Settings'),
        actions: [
          // Add restore defaults button
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Restore Default Settings',
            onPressed: () {
              _showRestoreDefaultsDialog(context, ref);
            },
          ),
          // Add a save button to the app bar
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Settings',
            onPressed: () {
              // Save settings (already handled by provider)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings saved!'),
                  duration: Duration(seconds: 2),
                ),
              );
              // Navigate back
              context.pop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Current Settings Summary Card
          _buildCurrentSettingsCard(context, settings),
          const SizedBox(height: 16),

          _buildPrecisionTypeSection(context, settings, ref),
          const Divider(),
          _buildPrecisionValueSection(context, settings, ref),
          const Divider(),
          _buildRoundingMethodSection(context, settings, ref),
          const Divider(),
          _buildPreviewSection(context, settings),

          // Add two buttons side by side: restore defaults and save
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.restore),
                  label: const Text('RESTORE DEFAULTS'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.grey,
                  ),
                  onPressed: () {
                    _showRestoreDefaultsDialog(context, ref);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('SAVE SETTINGS'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    // Save settings (already handled by provider)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings saved!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    // Navigate back
                    context.pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRestoreDefaultsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Default Settings'),
        content: const Text(
            'This will reset all rounding and precision settings to their default values. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              // Reset to default settings (2 decimal places, round to nearest)
              ref.read(roundingProvider.notifier).updateSettings(
                    RoundingSettings(), // Default constructor uses defaults
                  );
              Navigator.of(context).pop();

              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings restored to defaults'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('RESTORE'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSettingsCard(
      BuildContext context, RoundingSettings settings) {
    // Sample value to demonstrate current formatting
    const sampleValue = 123.456789;
    final formatted = NumberFormatter.formatDisplay(sampleValue, settings);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Type: '),
                Text(
                  settings.precisionType.toString().split('.').last,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Value: '),
                Text(
                  settings.precisionValue.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Method: '),
                Text(
                  _getRoundingMethodName(settings.roundingMethod),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Text('Example: '),
                Text(
                  '$sampleValue → $formatted',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrecisionTypeSection(
      BuildContext context, RoundingSettings settings, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Precision Type',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListTile(
          title: const Text('Decimal Places'),
          trailing: Icon(
            settings.precisionType == PrecisionType.decimal
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
          ),
          onTap: () {
            ref.read(roundingProvider.notifier).setPrecisionType(PrecisionType.decimal);
          },
        ),
        ListTile(
          title: const Text('Whole Numbers'),
          trailing: Icon(
            settings.precisionType == PrecisionType.wholeNumber
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
          ),
          onTap: () {
            ref.read(roundingProvider.notifier).setPrecisionType(PrecisionType.wholeNumber);
          },
        ),
        ListTile(
          title: const Text('Fractions'),
          trailing: Icon(
            settings.precisionType == PrecisionType.fraction
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
          ),
          onTap: () {
            ref.read(roundingProvider.notifier).setPrecisionType(PrecisionType.fraction);
          },
        ),
      ],
    );
  }

  Widget _buildPrecisionValueSection(
      BuildContext context, RoundingSettings settings, WidgetRef ref) {
    Widget content;

    switch (settings.precisionType) {
      case PrecisionType.decimal:
        content = Column(
          children: DecimalPrecision.values.map((precision) {
            final selected = settings.precisionValue == precision.value;
            return ListTile(
              title: Text('${precision.name} (${precision.value})'),
              trailing: Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              ),
              onTap: () {
                ref.read(roundingProvider.notifier).setPrecisionValue(precision.value);
              },
            );
          }).toList(),
        );
        break;
      case PrecisionType.wholeNumber:
        content = Column(
          children: WholeNumberPrecision.values.map((precision) {
            final selected = settings.precisionValue == precision.value;
            return ListTile(
              title: Text('${precision.name} (${precision.value})'),
              trailing: Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              ),
              onTap: () {
                ref.read(roundingProvider.notifier).setPrecisionValue(precision.value);
              },
            );
          }).toList(),
        );
        break;
      case PrecisionType.fraction:
        content = Column(
          children: FractionPrecision.values.map((precision) {
            final selected = settings.precisionValue == precision.denominator;
            return ListTile(
              title: Text('1/${precision.denominator}'),
              trailing: Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              ),
              onTap: () {
                ref.read(roundingProvider.notifier).setPrecisionValue(precision.denominator);
              },
            );
          }).toList(),
        );
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Precision Value',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildRoundingMethodSection(
      BuildContext context, RoundingSettings settings, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rounding Method',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<RoundingMethod>(
          initialValue: settings.roundingMethod,
          onChanged: (value) {
            if (value != null) {
              ref.read(roundingProvider.notifier).setRoundingMethod(value);
            }
          },
          items: RoundingMethod.values.map((method) {
            return DropdownMenuItem(
              value: method,
              child: Text(_getRoundingMethodName(method)),
            );
          }).toList(),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }

  String _getRoundingMethodName(RoundingMethod method) {
    switch (method) {
      case RoundingMethod.nearest:
        return 'Round to the nearest';
      case RoundingMethod.halfUp:
        return 'Round half up';
      case RoundingMethod.halfDown:
        return 'Round half down';
      case RoundingMethod.ceiling:
        return 'Round up (ceiling)';
      case RoundingMethod.floor:
        return 'Round down (floor)';
      case RoundingMethod.halfToEven:
        return 'Round half to even';
      case RoundingMethod.halfToOdd:
        return 'Round half to odd';
      case RoundingMethod.halfAwayFromZero:
        return 'Round half away from zero';
      case RoundingMethod.halfTowardsZero:
        return 'Round half towards zero';
    }
  }

  Widget _buildPreviewSection(BuildContext context, RoundingSettings settings) {
    // Sample values to preview rounding
    const testValues = [
      123.456789,
      9.5,
      10.5,
      -7.5,
      0.3333333,
      999.999,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Sample values with current settings:'),
        const SizedBox(height: 8),
        ...testValues.map((value) {
          final formatted = NumberFormatter.formatDisplay(value, settings);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Text('$value → '),
                Text(
                  formatted,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
