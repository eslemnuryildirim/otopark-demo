import 'package:hive/hive.dart';

part 'park_slot.g.dart';

/// Park yeri modeli
@HiveType(typeId: 5)
class ParkSlot extends HiveObject {
  @HiveField(0)
  final String id; // Örn: A-01, B-05, YIK1
  
  @HiveField(1)
  String label; // UI'da gösterilecek etiket
  
  @HiveField(2)
  bool isOccupied;
  
  @HiveField(3)
  String? vehicleId; // Doluysa hangi araç
  
  @HiveField(4)
  bool isServiceArea; // Servis alanı mı (yıkama, bakım vb.)

  ParkSlot({
    required this.id,
    required this.label,
    this.isOccupied = false,
    this.vehicleId,
    this.isServiceArea = false,
  });

  ParkSlot copyWith({
    String? id,
    String? label,
    bool? isOccupied,
    String? vehicleId,
    bool? isServiceArea,
    bool clearVehicleId = false,
  }) {
    return ParkSlot(
      id: id ?? this.id,
      label: label ?? this.label,
      isOccupied: isOccupied ?? this.isOccupied,
      vehicleId: clearVehicleId ? null : (vehicleId ?? this.vehicleId),
      isServiceArea: isServiceArea ?? this.isServiceArea,
    );
  }
}

