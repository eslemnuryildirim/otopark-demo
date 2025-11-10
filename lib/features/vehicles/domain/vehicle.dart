import 'package:hive/hive.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle_status.dart';

part 'vehicle.g.dart';

/// Araç domain modeli - Genişletilmiş versiyon
@HiveType(typeId: 0)
class Vehicle extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String plate;
  
  @HiveField(2)
  String? brand;
  
  @HiveField(3)
  String? model;
  
  @HiveField(4)
  String? color;
  
  @HiveField(5)
  VehicleStatus status;
  
  @HiveField(6)
  final DateTime createdAt;
  
  @HiveField(7)
  DateTime updatedAt;
  
  @HiveField(8)
  String? currentParkSlotId; // Parkta iken hangi slotta
  
  @HiveField(9)
  DateTime? parkStartAt; // Park başlangıç zamanı (süre hesabı için)

  @HiveField(10)
  Map<String, bool> damagedParts; // Hasar bilgileri (parça ID -> hasarlı mı)

  Vehicle({
    required this.id,
    required this.plate,
    this.brand,
    this.model,
    this.color,
    this.status = VehicleStatus.parked,
    required this.createdAt,
    required this.updatedAt,
    this.currentParkSlotId,
    this.parkStartAt,
    this.damagedParts = const {},
  });

  /// Park süresini dakika olarak hesapla
  int? get parkDurationMinutes {
    if (parkStartAt == null) return null;
    return DateTime.now().difference(parkStartAt!).inMinutes;
  }

  /// Kopyalama metodu
  Vehicle copyWith({
    String? id,
    String? plate,
    String? brand,
    String? model,
    String? color,
    VehicleStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? currentParkSlotId,
    DateTime? parkStartAt,
    Map<String, bool>? damagedParts,
    bool clearParkSlotId = false,
    bool clearParkStartAt = false,
  }) {
    return Vehicle(
      id: id ?? this.id,
      plate: plate ?? this.plate,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      color: color ?? this.color,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentParkSlotId: clearParkSlotId ? null : (currentParkSlotId ?? this.currentParkSlotId),
      parkStartAt: clearParkStartAt ? null : (parkStartAt ?? this.parkStartAt),
      damagedParts: damagedParts ?? this.damagedParts,
    );
  }

  /// Firebase için JSON serileştirme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plate': plate,
      'brand': brand,
      'model': model,
      'color': color,
      'status': status.index, // Enum index olarak kaydet
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'currentParkSlotId': currentParkSlotId,
      'parkStartAt': parkStartAt?.toIso8601String(),
      'damagedParts': damagedParts,
    };
  }

  /// Firebase'den JSON deserializasyon
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      plate: json['plate'] as String,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      color: json['color'] as String?,
      status: VehicleStatus.values[json['status'] as int],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      currentParkSlotId: json['currentParkSlotId'] as String?,
      parkStartAt: json['parkStartAt'] != null 
          ? DateTime.parse(json['parkStartAt'] as String)
          : null,
      damagedParts: (json['damagedParts'] as Map<String, dynamic>?)?.cast<String, bool>() ?? {},
    );
  }
}
