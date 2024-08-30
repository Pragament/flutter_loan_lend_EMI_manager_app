import 'package:flutter/material.dart';

// Colors
Color _loanPrimaryColor = Colors.purple;
Color _loanContainerColor = Colors.purple.shade200;
Color _lendPrimaryColor = Colors.lightBlue;
Color _lendContainerColor = Colors.lightBlue.shade200;

Color loanColor(BuildContext context, bool isPrimary) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final loanPrimaryColor = isDark ? _loanContainerColor : _loanPrimaryColor;
  final loanContainerColor = isDark ? _loanPrimaryColor : _loanContainerColor;

  return isPrimary ? loanPrimaryColor : loanContainerColor;
}

Color lendColor(BuildContext context, bool isPrimary) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final lendPrimaryColor = isDark ? _lendContainerColor : _lendPrimaryColor;
  final lendContainerColor = isDark ? _lendPrimaryColor : _lendContainerColor;

  return isPrimary ? lendPrimaryColor : lendContainerColor;
}
//\\

const double borderRadius = 12.0;
