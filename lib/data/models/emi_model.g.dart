// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emi_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmiAdapter extends TypeAdapter<Emi> {
  @override
  final int typeId = 0;

  @override
  Emi read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Emi(
      id: fields[1] as String,
      title: fields[2] as String,
      emiType: fields[3] as String,
      principalAmount: fields[4] as double,
      interestRate: fields[5] as double,
      startDate: fields[6] as DateTime,
      endDate: fields[7] as DateTime?,
      contactPersonName: fields[8] as String,
      contactPersonPhone: fields[10] as String,
      contactPersonEmail: fields[9] as String,
      otherInfo: fields[11] as String,
      processingFee: fields[12] as double?,
      otherCharges: fields[13] as double?,
      partPayment: fields[14] as double?,
      advancePayment: fields[15] as double?,
      insuranceCharges: fields[16] as double?,
      moratorium: fields[17] as bool?,
      moratoriumMonth: fields[18] as int?,
      moratoriumType: fields[19] as String?,
      monthlyEmi: fields[20] as double?,
      totalEmi: fields[21] as double?,
      paid: fields[22] as double?,
      tags: (fields[23] as List).cast<Tag>(),
    );
  }

  @override
  void write(BinaryWriter writer, Emi obj) {
    writer
      ..writeByte(23)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.emiType)
      ..writeByte(4)
      ..write(obj.principalAmount)
      ..writeByte(5)
      ..write(obj.interestRate)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.endDate)
      ..writeByte(8)
      ..write(obj.contactPersonName)
      ..writeByte(9)
      ..write(obj.contactPersonEmail)
      ..writeByte(10)
      ..write(obj.contactPersonPhone)
      ..writeByte(11)
      ..write(obj.otherInfo)
      ..writeByte(12)
      ..write(obj.processingFee)
      ..writeByte(13)
      ..write(obj.otherCharges)
      ..writeByte(14)
      ..write(obj.partPayment)
      ..writeByte(15)
      ..write(obj.advancePayment)
      ..writeByte(16)
      ..write(obj.insuranceCharges)
      ..writeByte(17)
      ..write(obj.moratorium)
      ..writeByte(18)
      ..write(obj.moratoriumMonth)
      ..writeByte(19)
      ..write(obj.moratoriumType)
      ..writeByte(20)
      ..write(obj.monthlyEmi)
      ..writeByte(21)
      ..write(obj.totalEmi)
      ..writeByte(22)
      ..write(obj.paid)
      ..writeByte(23)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmiAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
