import 'package:emi_manager/utils/global_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FormattedAmount extends ConsumerWidget {
  final double amount;
  final TextStyle? style;
  final String currencySymbol;
  final bool boldText;

  const FormattedAmount({
    super.key,
    required this.amount,
    this.style,
    this.currencySymbol = '₹',
    this.boldText = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatted = GlobalFormatter.formatCurrency(ref, amount,
        currencySymbol: currencySymbol);

    return Text(
      formatted,
      style: style?.copyWith(
            fontWeight: boldText ? FontWeight.bold : style?.fontWeight,
          ) ??
          TextStyle(
            fontWeight: boldText ? FontWeight.bold : FontWeight.normal,
          ),
    );
  }
}

class FormattedPercentage extends ConsumerWidget {
  final double value;
  final TextStyle? style;
  final bool boldText;

  const FormattedPercentage({
    super.key,
    required this.value,
    this.style,
    this.boldText = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatted = GlobalFormatter.formatPercentage(ref, value);

    return Text(
      formatted,
      style: style?.copyWith(
            fontWeight: boldText ? FontWeight.bold : style?.fontWeight,
          ) ??
          TextStyle(
            fontWeight: boldText ? FontWeight.bold : FontWeight.normal,
          ),
    );
  }
}

class FormattedNumber extends ConsumerWidget {
  final double value;
  final TextStyle? style;
  final bool boldText;

  const FormattedNumber({
    super.key,
    required this.value,
    this.style,
    this.boldText = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatted = GlobalFormatter.formatNumber(ref, value);

    return Text(
      formatted,
      style: style?.copyWith(
            fontWeight: boldText ? FontWeight.bold : style?.fontWeight,
          ) ??
          TextStyle(
            fontWeight: boldText ? FontWeight.bold : FontWeight.normal,
          ),
    );
  }
}
