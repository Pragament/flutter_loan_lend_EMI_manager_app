import 'package:emi_manager/logic/rounding_provider.dart';
import 'package:emi_manager/utils/number_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

/// Provider to calculate and round EMI values for given parameters.
final emiCalculationProvider = Provider.family<double, EmiParams>((ref, params) {
  final double monthlyRate = params.annualInterestRate / 1200;
  final int totalMonths = params.tenureInYears * 12;

  double emi;
  if (params.principalAmount <= 0 || totalMonths <= 0) {
    emi = 0;
  } else if (monthlyRate == 0) {
    // 0% interest: simple division
    emi = params.principalAmount / totalMonths;
  } else {
    final powFactor = pow(1 + monthlyRate, totalMonths);
    emi = params.principalAmount * monthlyRate * powFactor / (powFactor - 1);
  }

  // Round the EMI according to settings
  final settings = ref.watch(roundingProvider);
  return NumberFormatter.formatNumber(emi, settings);
});

/// Provider for general calculations with rounding.
final calculationProvider = Provider.family<double, CalculationParams>((ref, params) {
  final result = params.calculationFn();
  final settings = ref.watch(roundingProvider);
  return NumberFormatter.formatNumber(result, settings);
});

/// Parameters for EMI calculation.
class EmiParams {
  final double principalAmount;
  final double annualInterestRate;
  final int tenureInYears;

  const EmiParams({
    required this.principalAmount,
    required this.annualInterestRate,
    required this.tenureInYears,
  });
}

/// Parameters for general calculations.
class CalculationParams {
  final double Function() calculationFn;

  const CalculationParams({
    required this.calculationFn,
  });
}
