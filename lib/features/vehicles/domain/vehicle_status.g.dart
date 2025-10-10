// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VehicleStatusAdapter extends TypeAdapter<VehicleStatus> {
  @override
  final int typeId = 1;

  @override
  VehicleStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return VehicleStatus.parked;
      case 1:
        return VehicleStatus.inMaintenance;
      case 2:
        return VehicleStatus.inWash;
      case 3:
        return VehicleStatus.inDeliveryQueue;
      case 4:
        return VehicleStatus.delivered;
      case 5:
        return VehicleStatus.exited;
      default:
        return VehicleStatus.parked;
    }
  }

  @override
  void write(BinaryWriter writer, VehicleStatus obj) {
    switch (obj) {
      case VehicleStatus.parked:
        writer.writeByte(0);
        break;
      case VehicleStatus.inMaintenance:
        writer.writeByte(1);
        break;
      case VehicleStatus.inWash:
        writer.writeByte(2);
        break;
      case VehicleStatus.inDeliveryQueue:
        writer.writeByte(3);
        break;
      case VehicleStatus.delivered:
        writer.writeByte(4);
        break;
      case VehicleStatus.exited:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
