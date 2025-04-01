import 'package:emi_manager/data/models/rounding_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RoundingNotifier extends StateNotifier<RoundingSettings> {
  RoundingNotifier() : super(_getInitialSettings());

  static RoundingSettings _getInitialSettings() {
    final box = Hive.box('preferences');
    final Map<dynamic, dynamic>? savedSettings = box.get('roundingSettings');

    if (savedSettings != null) {
      return RoundingSettings(
        precisionType:
            PrecisionType.values[savedSettings['precisionType'] as int],
        precisionValue: savedSettings['precisionValue'] as int,
        roundingMethod:
            RoundingMethod.values[savedSettings['roundingMethod'] as int],
      );
    }

    // Default settings
    return RoundingSettings();
  }

  void updateSettings(RoundingSettings newSettings) {
    state = newSettings;
    _saveSettings();
  }

  void resetToDefaults() {
    // Create a new instance with default settings
    state = RoundingSettings();
    _saveSettings();
  }

  void setPrecisionType(PrecisionType type) {
    // Adjust precisionValue based on selected type to ensure valid value
    int precisionValue = state.precisionValue;

    // Handle switching between different types with appropriate default values
    switch (type) {
      case PrecisionType.decimal:
        // Default to 2 decimal places if coming from another type
        precisionValue = 2;
        break;
      case PrecisionType.wholeNumber:
        // Default to 0 (ones) if coming from another type
        precisionValue = 0;
        break;
      case PrecisionType.fraction:
        // Default to 2 (half) if coming from another type
        precisionValue = 2;
        break;
    }

    state = RoundingSettings(
      precisionType: type,
      precisionValue: precisionValue,
      roundingMethod: state.roundingMethod,
    );
    _saveSettings();
  }

  void setPrecisionValue(int value) {
    state = RoundingSettings(
      precisionType: state.precisionType,
      precisionValue: value,
      roundingMethod: state.roundingMethod,
    );
    _saveSettings();
  }

  void setRoundingMethod(RoundingMethod method) {
    state = RoundingSettings(
      precisionType: state.precisionType,
      precisionValue: state.precisionValue,
      roundingMethod: method,
    );
    _saveSettings();
  }

  void _saveSettings() {
    final box = Hive.box('preferences');
    box.put('roundingSettings', {
      'precisionType': state.precisionType.index,
      'precisionValue': state.precisionValue,
      'roundingMethod': state.roundingMethod.index,
    });
  }
}

final roundingProvider =
    StateNotifierProvider<RoundingNotifier, RoundingSettings>((ref) {
  return RoundingNotifier();
});
