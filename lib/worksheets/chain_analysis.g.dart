// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chain_analysis.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChainAnalysisEntryAdapter extends TypeAdapter<ChainAnalysisEntry> {
  @override
  final int typeId = 1;

  @override
  ChainAnalysisEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChainAnalysisEntry(
      email: fields[0] as String,
      date: fields[1] as DateTime,
      problematicBehavior: fields[2] as String,
      promptingEvent: fields[3] as String,
      environment: fields[4] as String,
      chainLinks: fields[5] as String,
      adaptiveBehaviour: fields[6] as String,
      consequencesForOthers: fields[7] as String,
      consequencesForMe: fields[8] as String,
      damage: fields[9] as String,
      decreaseVulnerability: fields[10] as String,
      preventEvent: fields[11] as String,
      fixPlan: fields[12] as String,
      worksheetName: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChainAnalysisEntry obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.problematicBehavior)
      ..writeByte(3)
      ..write(obj.promptingEvent)
      ..writeByte(4)
      ..write(obj.environment)
      ..writeByte(5)
      ..write(obj.chainLinks)
      ..writeByte(6)
      ..write(obj.adaptiveBehaviour)
      ..writeByte(7)
      ..write(obj.consequencesForOthers)
      ..writeByte(8)
      ..write(obj.consequencesForMe)
      ..writeByte(9)
      ..write(obj.damage)
      ..writeByte(10)
      ..write(obj.decreaseVulnerability)
      ..writeByte(11)
      ..write(obj.preventEvent)
      ..writeByte(12)
      ..write(obj.fixPlan)
      ..writeByte(13)
      ..write(obj.worksheetName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChainAnalysisEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
