// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_fund_service.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FundRecordAdapter extends TypeAdapter<FundRecord> {
  @override
  final int typeId = 1;

  @override
  FundRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FundRecord(
      donationId: fields[0] as int,
      programName: fields[1] as String,
      penerima: fields[2] as String,
      uangKeluar: fields[3] as num,
      sisaSaldo: fields[4] as num,
      timestamp: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FundRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.donationId)
      ..writeByte(1)
      ..write(obj.programName)
      ..writeByte(2)
      ..write(obj.penerima)
      ..writeByte(3)
      ..write(obj.uangKeluar)
      ..writeByte(4)
      ..write(obj.sisaSaldo)
      ..writeByte(5)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FundRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
