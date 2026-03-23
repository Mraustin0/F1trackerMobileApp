// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'constructor_standing_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConstructorStandingModelAdapter
    extends TypeAdapter<ConstructorStandingModel> {
  @override
  final int typeId = 3;

  @override
  ConstructorStandingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConstructorStandingModel(
      position: fields[0] as int,
      constructorId: fields[1] as String,
      name: fields[2] as String,
      nationality: fields[3] as String,
      points: fields[4] as double,
      wins: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ConstructorStandingModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.position)
      ..writeByte(1)
      ..write(obj.constructorId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.nationality)
      ..writeByte(4)
      ..write(obj.points)
      ..writeByte(5)
      ..write(obj.wins);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConstructorStandingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
