// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rounding_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoundingSettingsAdapter extends TypeAdapter<RoundingSettings> {
  @override
  final int typeId = 4;

  @override
  RoundingSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoundingSettings(
      precisionType: fields[0] as PrecisionType,
      precisionValue: fields[1] as int,
      roundingMethod: fields[2] as RoundingMethod,
    );
  }

  @override
  void write(BinaryWriter writer, RoundingSettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.precisionType)
      ..writeByte(1)
      ..write(obj.precisionValue)
      ..writeByte(2)
      ..write(obj.roundingMethod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoundingSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// Enum adapters
class PrecisionTypeAdapter extends TypeAdapter<PrecisionType> {
  @override
  final int typeId = 5;

  @override
  PrecisionType read(BinaryReader reader) {
    return PrecisionType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, PrecisionType obj) {
    writer.writeByte(obj.index);
  }
}

class RoundingMethodAdapter extends TypeAdapter<RoundingMethod> {
  @override
  final int typeId = 6;

  @override
  RoundingMethod read(BinaryReader reader) {
    return RoundingMethod.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, RoundingMethod obj) {
    writer.writeByte(obj.index);
  }
}
