// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fact_check.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FactCheckEntryAdapter extends TypeAdapter<FactCheckEntry> {
  @override
  final int typeId = 3;

  @override
  FactCheckEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FactCheckEntry(
      email: fields[0] as String,
      date: fields[1] as DateTime,
      emotions: (fields[2] as List).cast<String>(),
      initialIntensity: fields[3] as int,
      promptingEvent: fields[4] as String,
      factsExtremes: fields[5] as String,
      myInterpretation: fields[6] as String,
      alternativeInterpretations: fields[7] as String,
      perceivedThreat: fields[8] as String,
      alternativeOutcomes: fields[9] as String,
      catastropheThoughts: fields[10] as String,
      copingPlan: fields[11] as String,
      emotionMatchScore: fields[12] as int,
      currentIntensity: fields[13] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FactCheckEntry obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.emotions)
      ..writeByte(3)
      ..write(obj.initialIntensity)
      ..writeByte(4)
      ..write(obj.promptingEvent)
      ..writeByte(5)
      ..write(obj.factsExtremes)
      ..writeByte(6)
      ..write(obj.myInterpretation)
      ..writeByte(7)
      ..write(obj.alternativeInterpretations)
      ..writeByte(8)
      ..write(obj.perceivedThreat)
      ..writeByte(9)
      ..write(obj.alternativeOutcomes)
      ..writeByte(10)
      ..write(obj.catastropheThoughts)
      ..writeByte(11)
      ..write(obj.copingPlan)
      ..writeByte(12)
      ..write(obj.emotionMatchScore)
      ..writeByte(13)
      ..write(obj.currentIntensity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FactCheckEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
