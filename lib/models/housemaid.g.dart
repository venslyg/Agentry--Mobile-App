// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'housemaid.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HousemaidAdapter extends TypeAdapter<Housemaid> {
  @override
  final int typeId = 1;

  @override
  Housemaid read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Housemaid(
      id: fields[0] as String,
      name: fields[1] as String,
      passportId: fields[2] as String,
      subAgentId: fields[3] as String,
      totalCommission: fields[4] as double,
      status: fields[5] as MaidStatus,
      country: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Housemaid obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.passportId)
      ..writeByte(3)
      ..write(obj.subAgentId)
      ..writeByte(4)
      ..write(obj.totalCommission)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.country);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HousemaidAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
