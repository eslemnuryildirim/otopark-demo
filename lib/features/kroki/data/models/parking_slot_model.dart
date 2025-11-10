import 'package:hive/hive.dart';
import 'package:otopark_demo/features/kroki/domain/entities/parking_slot.dart';
import 'package:otopark_demo/features/kroki/domain/entities/parking_status.dart';

@HiveType(typeId: 0)
class ParkingSlotModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String label;

  @HiveField(2)
  final ParkingStatus status;

  @HiveField(3)
  final String? vehicleId;

  @HiveField(4)
  final DateTime? occupiedAt;

  @HiveField(5)
  final bool isServiceArea;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  ParkingSlotModel({
    required this.id,
    required this.label,
    required this.status,
    this.vehicleId,
    this.occupiedAt,
    required this.isServiceArea,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ParkingSlotModel.fromJson(Map<String, dynamic> json) {
    return ParkingSlotModel(
      id: json['id'] as String,
      label: json['label'] as String,
      status: ParkingStatus.values[json['status'] as int],
      vehicleId: json['vehicleId'] as String?,
      occupiedAt: json['occupiedAt'] != null ? DateTime.parse(json['occupiedAt'] as String) : null,
      isServiceArea: json['isServiceArea'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'status': status.index,
      'vehicleId': vehicleId,
      'occupiedAt': occupiedAt?.toIso8601String(),
      'isServiceArea': isServiceArea,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ParkingSlotModel.fromEntity(ParkingSlot entity) {
    return ParkingSlotModel(
      id: entity.id,
      label: entity.label,
      status: entity.status,
      vehicleId: entity.vehicleId,
      occupiedAt: entity.occupiedAt,
      isServiceArea: entity.isServiceArea,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ParkingSlot toEntity() {
    return ParkingSlot(
      id: id,
      label: label,
      status: status,
      vehicleId: vehicleId,
      occupiedAt: occupiedAt,
      isServiceArea: isServiceArea,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  ParkingSlotModel copyWith({
    String? id,
    String? label,
    ParkingStatus? status,
    String? vehicleId,
    DateTime? occupiedAt,
    bool? isServiceArea,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParkingSlotModel(
      id: id ?? this.id,
      label: label ?? this.label,
      status: status ?? this.status,
      vehicleId: vehicleId ?? this.vehicleId,
      occupiedAt: occupiedAt ?? this.occupiedAt,
      isServiceArea: isServiceArea ?? this.isServiceArea,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
