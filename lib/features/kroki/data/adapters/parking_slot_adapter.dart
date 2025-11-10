import 'package:hive/hive.dart';
import 'package:otopark_demo/features/kroki/data/models/parking_slot_model.dart';
import 'package:otopark_demo/features/kroki/domain/entities/parking_status.dart';

class ParkingSlotAdapter extends TypeAdapter<ParkingSlotModel> {
  @override
  final int typeId = 0;

  @override
  ParkingSlotModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParkingSlotModel(
      id: fields[0] as String,
      label: fields[1] as String,
      status: ParkingStatus.values[fields[2] as int],
      vehicleId: fields[3] as String?,
      occupiedAt: fields[4] as DateTime?,
      isServiceArea: fields[5] as bool,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ParkingSlotModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.status.index)
      ..writeByte(3)
      ..write(obj.vehicleId)
      ..writeByte(4)
      ..write(obj.occupiedAt)
      ..writeByte(5)
      ..write(obj.isServiceArea)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkingSlotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

