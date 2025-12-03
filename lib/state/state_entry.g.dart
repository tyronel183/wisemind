// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StateEntryAdapter extends TypeAdapter<StateEntry> {
  @override
  final int typeId = 0;

  @override
  StateEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StateEntry(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      mood: fields[2] as String?,
      grateful: fields[3] as String?,
      importantGoal: fields[4] as String?,
      rest: fields[5] as int,
      sleepHours: fields[6] as double,
      wakeUpTime: fields[7] as String,
      nightWakeUps: fields[8] as int,
      physicalDiscomfort: fields[9] as int,
      emotionalDistress: fields[10] as int,
      dissociation: fields[11] as int,
      ruminations: fields[12] as int,
      selfBlame: fields[13] as int,
      suicidalThoughts: fields[14] as int,
      urges: fields[15] as int?,
      action: fields[16] as String?,
      physicalActivity: fields[17] as int,
      pleasure: fields[18] as int,
      water: fields[19] as String,
      food: fields[20] as int,
      skillsUsed: (fields[21] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, StateEntry obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.mood)
      ..writeByte(3)
      ..write(obj.grateful)
      ..writeByte(4)
      ..write(obj.importantGoal)
      ..writeByte(5)
      ..write(obj.rest)
      ..writeByte(6)
      ..write(obj.sleepHours)
      ..writeByte(7)
      ..write(obj.wakeUpTime)
      ..writeByte(8)
      ..write(obj.nightWakeUps)
      ..writeByte(9)
      ..write(obj.physicalDiscomfort)
      ..writeByte(10)
      ..write(obj.emotionalDistress)
      ..writeByte(11)
      ..write(obj.dissociation)
      ..writeByte(12)
      ..write(obj.ruminations)
      ..writeByte(13)
      ..write(obj.selfBlame)
      ..writeByte(14)
      ..write(obj.suicidalThoughts)
      ..writeByte(15)
      ..write(obj.urges)
      ..writeByte(16)
      ..write(obj.action)
      ..writeByte(17)
      ..write(obj.physicalActivity)
      ..writeByte(18)
      ..write(obj.pleasure)
      ..writeByte(19)
      ..write(obj.water)
      ..writeByte(20)
      ..write(obj.food)
      ..writeByte(21)
      ..write(obj.skillsUsed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StateEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
