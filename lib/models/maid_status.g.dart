// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maid_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaidStatusAdapter extends TypeAdapter<MaidStatus> {
  @override
  final int typeId = 3;

  @override
  MaidStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MaidStatus.atAgency;
      case 1:
        return MaidStatus.sentAbroad;
      case 2:
        return MaidStatus.completed;
      default:
        return MaidStatus.atAgency;
    }
  }

  @override
  void write(BinaryWriter writer, MaidStatus obj) {
    switch (obj) {
      case MaidStatus.atAgency:
        writer.writeByte(0);
        break;
      case MaidStatus.sentAbroad:
        writer.writeByte(1);
        break;
      case MaidStatus.completed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaidStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
