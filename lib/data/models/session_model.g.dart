// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionModelAdapter extends TypeAdapter<SessionModel> {
  @override
  final int typeId = 1;

  @override
  SessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionModel(
      sessionKey: fields[0] as int,
      sessionName: fields[1] as String,
      sessionType: fields[2] as String,
      dateStart: fields[3] as DateTime,
      dateEnd: fields[4] as DateTime,
      circuitShortName: fields[5] as String,
      countryName: fields[6] as String,
      location: fields[7] as String,
      year: fields[8] as int,
      meetingKey: fields[9] as int,
      gmtOffset: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SessionModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.sessionKey)
      ..writeByte(1)
      ..write(obj.sessionName)
      ..writeByte(2)
      ..write(obj.sessionType)
      ..writeByte(3)
      ..write(obj.dateStart)
      ..writeByte(4)
      ..write(obj.dateEnd)
      ..writeByte(5)
      ..write(obj.circuitShortName)
      ..writeByte(6)
      ..write(obj.countryName)
      ..writeByte(7)
      ..write(obj.location)
      ..writeByte(8)
      ..write(obj.year)
      ..writeByte(9)
      ..write(obj.meetingKey)
      ..writeByte(10)
      ..write(obj.gmtOffset);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
