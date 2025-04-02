import 'package:emi_manager/logic/rounding_provider.dart';
import 'package:emi_manager/utils/number_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalFormatter {
  // Format currency with the current rounding settings
  static String formatCurrency(WidgetRef ref, double amount,
      {String currencySymbol = '₹'}) {
    final settings = ref.watch(roundingProvider);
    final formatted = NumberFormatter.formatDisplay(amount, settings);
    return '$currencySymbol $formatted';
  }

  // Format percentage with the current rounding settings
  static String formatPercentage(WidgetRef ref, double value) {
    final settings = ref.watch(roundingProvider);
    final formatted = NumberFormatter.formatDisplay(value, settings);
    return '$formatted%';
  }

  // Format a number with the current rounding settings
  static String formatNumber(WidgetRef ref, double value) {
    final settings = ref.watch(roundingProvider);
    return NumberFormatter.formatDisplay(value, settings);
  }

  // Actually perform rounding calculation with the current settings
  static double roundNumber(WidgetRef ref, double value) {
    final settings = ref.watch(roundingProvider);
    return NumberFormatter.formatNumber(value, settings);
  }

  // Format a money amount using a specific locale and currency
  static String formatMoney(WidgetRef ref, double value,
      {String currencySymbol = '₹', String locale = 'en_US'}) {
    final rounded = roundNumber(ref, value);
    final formatted = formatNumber(ref, rounded);
    return '$currencySymbol $formatted';
  }

  // Apply rounding based on function (used for complex calculations)
  static double applyRoundingToCalculation(
      WidgetRef ref, double Function() calculationFn) {
    // Perform the calculation
    final result = calculationFn();
    // Round the result according to the current settings
    return roundNumber(ref, result);
  }
}
