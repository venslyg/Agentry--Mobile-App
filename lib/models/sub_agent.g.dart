// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_agent.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubAgentAdapter extends TypeAdapter<SubAgent> {
  @override
  final int typeId = 0;

  @override
  SubAgent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubAgent(
      id: fields[0] as String,
      name: fields[1] as String,
      contact: fields[2] as String,
      notes: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SubAgent obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.contact)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubAgentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
