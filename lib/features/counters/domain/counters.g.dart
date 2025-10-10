// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counters.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CountersAdapter extends TypeAdapter<Counters> {
  @override
  final int typeId = 4;

  @override
  Counters read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Counters(
      totalPark: fields[0] as int,
      totalMaintenance: fields[1] as int,
      totalWash: fields[2] as int,
      totalDelivered: fields[3] as int,
      activePark: fields[4] as int,
      activeMaintenance: fields[5] as int,
      activeWash: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Counters obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.totalPark)
      ..writeByte(1)
      ..write(obj.totalMaintenance)
      ..writeByte(2)
      ..write(obj.totalWash)
      ..writeByte(3)
      ..write(obj.totalDelivered)
      ..writeByte(4)
      ..write(obj.activePark)
      ..writeByte(5)
      ..write(obj.activeMaintenance)
      ..writeByte(6)
      ..write(obj.activeWash);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
