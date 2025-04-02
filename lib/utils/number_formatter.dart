import 'dart:math';
import 'package:emi_manager/data/models/rounding_settings.dart';

class NumberFormatter {
  static double formatNumber(double value, RoundingSettings settings) {
    switch (settings.precisionType) {
      case PrecisionType.decimal:
        return _roundDecimal(
            value, settings.precisionValue, settings.roundingMethod);
      case PrecisionType.wholeNumber:
        return _roundWholeNumber(
            value, settings.precisionValue, settings.roundingMethod);
      case PrecisionType.fraction:
        return _roundFraction(
            value, settings.precisionValue, settings.roundingMethod);
    }
  }

  static double _roundDecimal(
      double value, int decimalPlaces, RoundingMethod method) {
    if (decimalPlaces < 0) {
      return _roundWholeNumber(value, decimalPlaces, method);
    }

    final factor = pow(10, decimalPlaces).toDouble();
    final multiplied = value * factor;

    double rounded;
    switch (method) {
      case RoundingMethod.nearest:
        rounded = (multiplied + 0.5).floorToDouble();
        break;
      case RoundingMethod.halfUp:
        rounded = (multiplied >= 0)
            ? (multiplied + 0.5).floorToDouble()
            : (multiplied - 0.5).ceilToDouble();
        break;
      case RoundingMethod.halfDown:
        rounded = (multiplied >= 0)
            ? (multiplied + 0.49999).floorToDouble()
            : (multiplied - 0.49999).ceilToDouble();
        break;
      case RoundingMethod.ceiling:
        rounded = multiplied.ceilToDouble();
        break;
      case RoundingMethod.floor:
        rounded = multiplied.floorToDouble();
        break;
      case RoundingMethod.halfToEven:
        final intPart = multiplied.floorToDouble();
        final fractPart = multiplied - intPart;
        if (fractPart == 0.5) {
          rounded = (intPart % 2 == 0) ? intPart : intPart + 1;
        } else {
          rounded = (multiplied + 0.5).floorToDouble();
        }
        break;
      case RoundingMethod.halfToOdd:
        final intPart = multiplied.floorToDouble();
        final fractPart = multiplied - intPart;
        if (fractPart == 0.5) {
          rounded = (intPart % 2 == 1) ? intPart : intPart + 1;
        } else {
          rounded = (multiplied + 0.5).floorToDouble();
        }
        break;
      case RoundingMethod.halfAwayFromZero:
        rounded = (multiplied >= 0)
            ? (multiplied + 0.5).floorToDouble()
            : (multiplied - 0.5).ceilToDouble();
        break;
      case RoundingMethod.halfTowardsZero:
        rounded = (multiplied >= 0)
            ? (multiplied + 0.49999).floorToDouble()
            : (multiplied - 0.49999).ceilToDouble();
        break;
    }

    return rounded / factor;
  }

  static double _roundWholeNumber(
      double value, int precision, RoundingMethod method) {
    // For whole numbers, precision is negative or zero
    final factor = pow(10, precision.abs()).toDouble();
    return _roundDecimal(value / factor, 0, method) * factor;
  }

  static double _roundFraction(
      double value, int denominator, RoundingMethod method) {
    final factor = denominator.toDouble();
    final multiplied = value * factor;

    double rounded;
    switch (method) {
      case RoundingMethod.nearest:
        rounded = (multiplied + 0.5).floorToDouble();
        break;
      case RoundingMethod.halfUp:
        rounded = (multiplied >= 0)
            ? (multiplied + 0.5).floorToDouble()
            : (multiplied - 0.5).ceilToDouble();
        break;
      case RoundingMethod.halfDown:
        rounded = (multiplied >= 0)
            ? (multiplied + 0.49999).floorToDouble()
            : (multiplied - 0.49999).ceilToDouble();
        break;
      case RoundingMethod.ceiling:
        rounded = multiplied.ceilToDouble();
        break;
      case RoundingMethod.floor:
        rounded = multiplied.floorToDouble();
        break;
      case RoundingMethod.halfToEven:
        final intPart = multiplied.floorToDouble();
        final fractPart = multiplied - intPart;
        if (fractPart == 0.5) {
          rounded = (intPart % 2 == 0) ? intPart : intPart + 1;
        } else {
          rounded = (multiplied + 0.5).floorToDouble();
        }
        break;
      case RoundingMethod.halfToOdd:
        final intPart = multiplied.floorToDouble();
        final fractPart = multiplied - intPart;
        if (fractPart == 0.5) {
          rounded = (intPart % 2 == 1) ? intPart : intPart + 1;
        } else {
          rounded = (multiplied + 0.5).floorToDouble();
        }
        break;
      case RoundingMethod.halfAwayFromZero:
        rounded = (multiplied >= 0)
            ? (multiplied + 0.5).floorToDouble()
            : (multiplied - 0.5).ceilToDouble();
        break;
      case RoundingMethod.halfTowardsZero:
        rounded = (multiplied >= 0)
            ? (multiplied + 0.49999).floorToDouble()
            : (multiplied - 0.49999).ceilToDouble();
        break;
    }

    return rounded / factor;
  }

  static String formatDisplay(double value, RoundingSettings settings) {
    final formatted = formatNumber(value, settings);

    if (settings.precisionType == PrecisionType.fraction) {
      return _toFractionString(formatted, settings.precisionValue);
    }

    if (settings.precisionType == PrecisionType.decimal ||
        settings.precisionType == PrecisionType.wholeNumber) {
      final places =
          (settings.precisionValue >= 0) ? settings.precisionValue : 0;
      return formatted.toStringAsFixed(places);
    }

    return formatted.toString();
  }

  static String _toFractionString(double value, int denominator) {
    final wholePart = value.truncate();
    final fractionalPart = value - wholePart;

    if (fractionalPart == 0) {
      return wholePart.toString();
    }

    final numerator = (fractionalPart * denominator).round();
    if (numerator == 0) {
      return wholePart.toString();
    }

    // Simplify fraction
    int gcd = _findGCD(numerator, denominator);
    final simplifiedNumerator = numerator ~/ gcd;
    final simplifiedDenominator = denominator ~/ gcd;

    if (wholePart == 0) {
      return '$simplifiedNumerator/$simplifiedDenominator';
    } else {
      return '$wholePart $simplifiedNumerator/$simplifiedDenominator';
    }
  }

  static int _findGCD(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }
}
