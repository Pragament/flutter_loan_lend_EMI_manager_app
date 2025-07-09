import 'package:emi_manager/data/models/emi_model.dart';
import 'package:emi_manager/presentation/widgets/amortization_schedule_table.dart';
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
    double monthlyRate = interestRate / (12 * 100);
    int totalPayments = tenureYears * 12;

    if (monthlyRate == 0) {
      return principal / totalPayments;
    } else {
      return principal *
          monthlyRate *
          pow(1 + monthlyRate, totalPayments) /
          (pow(1 + monthlyRate, totalPayments) - 1);
    }
  }

  double applyRounding(WidgetRef ref, double value) {
    // Placeholder for global formatting logic
    return value;
  }

  /// Generates the amortization schedule for a given loan.
  /// Returns a list of AmortizationEntry objects.
  List<AmortizationEntry> generateAmortizationSchedule(
    double principal,
    double annualInterestRate,
    int tenureYears,
    String emiId, {
    required DateTime startDate,
  }) {
    final List<AmortizationEntry> schedule = [];
    double monthlyEmi = calculateMonthlyEmi(principal, annualInterestRate, tenureYears);
    monthlyEmi = monthlyEmi.roundToDouble();

    double remainingPrincipal = principal;
    final double monthlyRate = annualInterestRate / (12 * 100);
    final int totalMonths = tenureYears * 12;

    for (int month = 0; month < totalMonths; month++) {
      double interest = monthlyRate * remainingPrincipal;
      double principalComponent = monthlyEmi - interest;

      // For 0% interest, all payment goes to principal
      if (monthlyRate == 0) {
        principalComponent = monthlyEmi;
        interest = 0;
      }

      // Final payment adjustment to clear the principal
      if (month == totalMonths - 1 || principalComponent > remainingPrincipal) {
        principalComponent = remainingPrincipal;
        monthlyEmi = interest + principalComponent;
      }

      // Update balance before adding to schedule
      remainingPrincipal -= principalComponent;
      if (remainingPrincipal < 0) remainingPrincipal = 0;

      // Calculate payment date robustly
      DateTime paymentDate = DateTime(
        startDate.year,
        startDate.month + month,
        startDate.day,
      );

      schedule.add(
        AmortizationEntry(
          title : month == 0 ? 'First Payment' : 'EMI Payment',
          principal: principalComponent,
          interest: interest,
          totalPayment: monthlyEmi,
          year: paymentDate.year,
          month: paymentDate.month,
          type: month == 0 ? 'First Payment' : 'EMI',
          paymentDate: paymentDate,
          balance: remainingPrincipal,
        ),
      );
    }

    return schedule;
  }
}
