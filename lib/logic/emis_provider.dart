import 'package:emi_manager/data/models/emi_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:math';

part 'emis_provider.g.dart';

@riverpod
class EmisNotifier extends _$EmisNotifier {
  late Box<Emi> _box;

  @override
  List<Emi> build() {
    _box = Hive.box<Emi>('emis');
    return _box.values.toList();
  }

  Future<void> add(Emi emi) async {
    await _box.put(emi.id, emi);
    state = [...state, emi];
  }

  Future<void> remove(Emi emi) async {
    await _box.delete(emi.id);
    state = state.where((item) => item.id != emi.id).toList();
  }

  Future<void> update(Emi emi) async {
    await _box.put(emi.id, emi);
    state = [
      for (final existingEmi in state)
        if (existingEmi.id == emi.id) emi else existingEmi
    ];
  }

  Future<void> updateEmiTenure(String emiId, DateTime newEndDate) async {
    final emi = _box.get(emiId);
    if (emi != null) {
      emi.updateTenure(newEndDate); // Update tenure and recalculate EMI
      await _box.put(emiId, emi); // Save updated EMI
      state = [
        for (final existingEmi in state)
          if (existingEmi.id == emiId) emi else existingEmi
      ];
    }
  }

  Future<Emi?> getEmiById(String id) async {
    return _box.get(id);
  }

  double calculateMonthlyEmi(
      double principal, double interestRate, int tenureYears) {
    // Convert annual interest rate to monthly rate
    double monthlyRate = interestRate / (12 * 100);

    // Calculate total number of monthly payments
    int totalPayments = tenureYears * 12;

    // Calculate EMI using the standard formula
    double emi = principal *
        monthlyRate *
        pow(1 + monthlyRate, totalPayments) /
        (pow(1 + monthlyRate, totalPayments) - 1);

    return emi;
  }

  // A method to apply rounding to a calculated EMI value
  double applyRounding(WidgetRef ref, double value) {
    // This method will be called from outside the provider with the appropriate WidgetRef
    return value; // For now return the original value - actual rounding will be done by the GlobalFormatter
  }
}
