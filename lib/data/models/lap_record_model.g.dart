// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lap_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LapRecordModelAdapter extends TypeAdapter<LapRecordModel> {
  @override
  final int typeId = 4;

  @override
  LapRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LapRecordModel(
      circuitId: fields[0] as String,
      driverCode: fields[1] as String,
      driverName: fields[2] as String,
      team: fields[3] as String,
      lapTime: fields[4] as String,
      year: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LapRecordModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.circuitId)
      ..writeByte(1)
      ..write(obj.driverCode)
      ..writeByte(2)
      ..write(obj.driverName)
      ..writeByte(3)
      ..write(obj.team)
      ..writeByte(4)
      ..write(obj.lapTime)
      ..writeByte(5)
      ..write(obj.year);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LapRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
