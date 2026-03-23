// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'race_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RaceModelAdapter extends TypeAdapter<RaceModel> {
  @override
  final int typeId = 0;

  @override
  RaceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RaceModel(
      round: fields[0] as int,
      raceName: fields[1] as String,
      circuitId: fields[2] as String,
      circuitName: fields[3] as String,
      country: fields[4] as String,
      locality: fields[5] as String,
      raceDate: fields[6] as DateTime,
      qualifyingDate: fields[7] as DateTime?,
      practice1Date: fields[8] as DateTime?,
      practice2Date: fields[9] as DateTime?,
      practice3Date: fields[10] as DateTime?,
      sprintDate: fields[11] as DateTime?,
      season: fields[12] as String,
      isCompleted: fields[13] as bool,
      isNextRace: fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RaceModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.round)
      ..writeByte(1)
      ..write(obj.raceName)
      ..writeByte(2)
      ..write(obj.circuitId)
      ..writeByte(3)
      ..write(obj.circuitName)
      ..writeByte(4)
      ..write(obj.country)
      ..writeByte(5)
      ..write(obj.locality)
      ..writeByte(6)
      ..write(obj.raceDate)
      ..writeByte(7)
      ..write(obj.qualifyingDate)
      ..writeByte(8)
      ..write(obj.practice1Date)
      ..writeByte(9)
      ..write(obj.practice2Date)
      ..writeByte(10)
      ..write(obj.practice3Date)
      ..writeByte(11)
      ..write(obj.sprintDate)
      ..writeByte(12)
      ..write(obj.season)
      ..writeByte(13)
      ..write(obj.isCompleted)
      ..writeByte(14)
      ..write(obj.isNextRace);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RaceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
