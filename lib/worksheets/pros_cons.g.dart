// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pros_cons.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProsConsEntryAdapter extends TypeAdapter<ProsConsEntry> {
  @override
  final int typeId = 2;

  @override
  ProsConsEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProsConsEntry(
      email: fields[0] as String,
      date: fields[1] as DateTime,
      problematicBehavior: fields[2] as String,
      prosActImpulsively: fields[3] as String,
      prosResistImpulse: fields[4] as String,
      consActImpulsively: fields[5] as String,
      consResistImpulse: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProsConsEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.problematicBehavior)
      ..writeByte(3)
      ..write(obj.prosActImpulsively)
      ..writeByte(4)
      ..write(obj.prosResistImpulse)
      ..writeByte(5)
      ..write(obj.consActImpulsively)
      ..writeByte(6)
      ..write(obj.consResistImpulse);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProsConsEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
