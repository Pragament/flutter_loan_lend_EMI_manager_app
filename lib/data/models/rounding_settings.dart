import 'package:hive/hive.dart';

part 'rounding_settings.g.dart';

enum PrecisionType { decimal, wholeNumber, fraction }

enum DecimalPrecision {
  ones(0),
  tenths(1),
  hundredths(2),
  thousandths(3),
  tenThousandths(4),
  hundredThousandths(5),
  millionths(6);

  final int value;
  const DecimalPrecision(this.value);
}

enum WholeNumberPrecision {
  ones(0),
  tens(-1),
  hundreds(-2),
  thousands(-3),
  millions(-6);

  final int value;
  const WholeNumberPrecision(this.value);
}

enum FractionPrecision {
  half(2),
  quarter(4),
  eighth(8),
  sixteenth(16),
  thirtySecond(32),
  sixtyFourth(64);

  final int denominator;
  const FractionPrecision(this.denominator);
}

enum RoundingMethod {
  nearest,
  halfUp,
  halfDown,
  ceiling,
  floor,
  halfToEven,
  halfToOdd,
  halfAwayFromZero,
  halfTowardsZero
}

@HiveType(typeId: 4)
class RoundingSettings {
  @HiveField(0)
  final PrecisionType precisionType;

  @HiveField(1)
  final int precisionValue;

  @HiveField(2)
  final RoundingMethod roundingMethod;

  RoundingSettings({
    this.precisionType = PrecisionType.decimal,
    this.precisionValue = 2, // Default: 2 decimal places
    this.roundingMethod = RoundingMethod.nearest,
  });

  // Create from decimal precision
  factory RoundingSettings.fromDecimal(
      DecimalPrecision precision, RoundingMethod method) {
    return RoundingSettings(
      precisionType: PrecisionType.decimal,
      precisionValue: precision.value,
      roundingMethod: method,
    );
  }

  // Create from whole number precision
  factory RoundingSettings.fromWholeNumber(
      WholeNumberPrecision precision, RoundingMethod method) {
    return RoundingSettings(
      precisionType: PrecisionType.wholeNumber,
      precisionValue: precision.value,
      roundingMethod: method,
    );
  }

  // Create from fraction precision
  factory RoundingSettings.fromFraction(
      FractionPrecision precision, RoundingMethod method) {
    return RoundingSettings(
      precisionType: PrecisionType.fraction,
      precisionValue: precision.denominator,
      roundingMethod: method,
    );
  }
}
