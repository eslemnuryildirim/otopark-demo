// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'park_slot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParkSlotAdapter extends TypeAdapter<ParkSlot> {
  @override
  final int typeId = 5;

  @override
  ParkSlot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParkSlot(
      id: fields[0] as String,
      label: fields[1] as String,
      isOccupied: fields[2] as bool,
      vehicleId: fields[3] as String?,
      isServiceArea: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ParkSlot obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.isOccupied)
      ..writeByte(3)
      ..write(obj.vehicleId)
      ..writeByte(4)
      ..write(obj.isServiceArea);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkSlotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
