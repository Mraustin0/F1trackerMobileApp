// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'race_result_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RaceResultModelAdapter extends TypeAdapter<RaceResultModel> {
  @override
  final int typeId = 5;

  @override
  RaceResultModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RaceResultModel(
      position: fields[0] as int,
      driverCode: fields[1] as String,
      driverNumber: fields[2] as String,
      givenName: fields[3] as String,
      familyName: fields[4] as String,
      constructorId: fields[5] as String,
      constructorName: fields[6] as String,
      points: fields[7] as double,
      status: fields[8] as String,
      time: fields[9] as String?,
      fastestLapTime: fields[10] as String?,
      fastestLapRank: fields[11] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, RaceResultModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.position)
      ..writeByte(1)
      ..write(obj.driverCode)
      ..writeByte(2)
      ..write(obj.driverNumber)
      ..writeByte(3)
      ..write(obj.givenName)
      ..writeByte(4)
      ..write(obj.familyName)
      ..writeByte(5)
      ..write(obj.constructorId)
      ..writeByte(6)
      ..write(obj.constructorName)
      ..writeByte(7)
      ..write(obj.points)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.time)
      ..writeByte(10)
      ..write(obj.fastestLapTime)
      ..writeByte(11)
      ..write(obj.fastestLapRank);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RaceResultModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
