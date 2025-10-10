// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OperationTypeAdapter extends TypeAdapter<OperationType> {
  @override
  final int typeId = 3;

  @override
  OperationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OperationType.park;
      case 1:
        return OperationType.maintenance;
      case 2:
        return OperationType.wash;
      case 3:
        return OperationType.move;
      case 4:
        return OperationType.deliverQueue;
      case 5:
        return OperationType.delivered;
      case 6:
        return OperationType.exit;
      default:
        return OperationType.park;
    }
  }

  @override
  void write(BinaryWriter writer, OperationType obj) {
    switch (obj) {
      case OperationType.park:
        writer.writeByte(0);
        break;
      case OperationType.maintenance:
        writer.writeByte(1);
        break;
      case OperationType.wash:
        writer.writeByte(2);
        break;
      case OperationType.move:
        writer.writeByte(3);
        break;
      case OperationType.deliverQueue:
        writer.writeByte(4);
        break;
      case OperationType.delivered:
        writer.writeByte(5);
        break;
      case OperationType.exit:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
