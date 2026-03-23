// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_standing_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DriverStandingModelAdapter extends TypeAdapter<DriverStandingModel> {
  @override
  final int typeId = 2;

  @override
  DriverStandingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DriverStandingModel(
      position: fields[0] as int,
      driverId: fields[1] as String,
      givenName: fields[2] as String,
      familyName: fields[3] as String,
      code: fields[4] as String,
      permanentNumber: fields[5] as int,
      nationality: fields[6] as String,
      points: fields[7] as double,
      wins: fields[8] as int,
      constructorId: fields[9] as String,
      constructorName: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DriverStandingModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.position)
      ..writeByte(1)
      ..write(obj.driverId)
      ..writeByte(2)
      ..write(obj.givenName)
      ..writeByte(3)
      ..write(obj.familyName)
      ..writeByte(4)
      ..write(obj.code)
      ..writeByte(5)
      ..write(obj.permanentNumber)
      ..writeByte(6)
      ..write(obj.nationality)
      ..writeByte(7)
      ..write(obj.points)
      ..writeByte(8)
      ..write(obj.wins)
      ..writeByte(9)
      ..write(obj.constructorId)
      ..writeByte(10)
      ..write(obj.constructorName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverStandingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
