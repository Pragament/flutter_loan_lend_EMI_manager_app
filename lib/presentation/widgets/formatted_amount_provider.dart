import 'package:emi_manager/logic/rounding_provider.dart';
import 'package:emi_manager/utils/number_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider that gives formatted strings for numeric values
final formattedAmountProvider = Provider.family<String, double>((ref, amount) {
  final settings = ref.watch(roundingProvider);
  return NumberFormatter.formatDisplay(amount, settings);
});

// Provider that gives formatted currency strings
final formattedCurrencyProvider =
    Provider.family<String, FormattedCurrencyParams>((ref, params) {
  final settings = ref.watch(roundingProvider);
  final formattedAmount =
      NumberFormatter.formatDisplay(params.amount, settings);
  return '${params.symbol} $formattedAmount';
});

// Provider that gives formatted percentage strings
final formattedPercentageProvider =
    Provider.family<String, double>((ref, value) {
  final settings = ref.watch(roundingProvider);
  final formattedValue = NumberFormatter.formatDisplay(value, settings);
  return '$formattedValue%';
});

// Class to hold params for formatted currency
class FormattedCurrencyParams {
  final double amount;
  final String symbol;

  const FormattedCurrencyParams({
    required this.amount,
    this.symbol = '₹',
  });
}
