// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OperationAdapter extends TypeAdapter<Operation> {
  @override
  final int typeId = 2;

  @override
  Operation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Operation(
      id: fields[0] as String,
      vehicleId: fields[1] as String,
      type: fields[2] as OperationType,
      note: fields[3] as String?,
      timestamp: fields[4] as DateTime,
      fromSlotId: fields[5] as String?,
      toSlotId: fields[6] as String?,
      parkDuration: fields[7] as Duration?,
    );
  }

  @override
  void write(BinaryWriter writer, Operation obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.vehicleId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.fromSlotId)
      ..writeByte(6)
      ..write(obj.toSlotId)
      ..writeByte(7)
      ..write(obj.parkDuration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
