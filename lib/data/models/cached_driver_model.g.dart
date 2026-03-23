// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_driver_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedDriverModelAdapter extends TypeAdapter<CachedDriverModel> {
  @override
  final int typeId = 5;

  @override
  CachedDriverModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedDriverModel(
      driverNumber: fields[0] as int,
      broadcastName: fields[1] as String,
      fullName: fields[2] as String,
      nameAcronym: fields[3] as String,
      teamName: fields[4] as String,
      teamColour: fields[5] as String,
      headshotUrl: fields[6] as String?,
      countryCode: fields[7] as String,
      sessionKey: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CachedDriverModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.driverNumber)
      ..writeByte(1)
      ..write(obj.broadcastName)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.nameAcronym)
      ..writeByte(4)
      ..write(obj.teamName)
      ..writeByte(5)
      ..write(obj.teamColour)
      ..writeByte(6)
      ..write(obj.headshotUrl)
      ..writeByte(7)
      ..write(obj.countryCode)
      ..writeByte(8)
      ..write(obj.sessionKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedDriverModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
