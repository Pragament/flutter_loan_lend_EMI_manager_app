import 'package:emi_manager/logic/rounding_provider.dart';
import 'package:emi_manager/utils/number_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AmountDisplay extends ConsumerWidget {
  final double amount;

  const AmountDisplay({super.key, required this.amount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current rounding settings from provider
    final roundingSettings = ref.watch(roundingProvider);

    // Format the amount based on settings
    final formattedAmount =
        NumberFormatter.formatDisplay(amount, roundingSettings);

    return Text(
      formattedAmount,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

// When performing calculations
class SomeCalculation extends ConsumerWidget {
  const SomeCalculation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roundingSettings = ref.watch(roundingProvider);

    // Original calculation
    double result = 123.456789;

    // Apply rounding
    double roundedResult =
        NumberFormatter.formatNumber(result, roundingSettings);

    return Text('Result: $roundedResult');
  }
}
