import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateNotifier that holds the currency symbol state
class CurrencyNotifier extends StateNotifier<String> {
  CurrencyNotifier() : super('₹'); // Default currency symbol

  void setCurrencySymbol(String symbol) {
    state = symbol;
  }
}

// Provider to access the CurrencyNotifier
final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>((ref) {
  return CurrencyNotifier();
});
