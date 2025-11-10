import 'package:otopark_demo/features/kroki/domain/entities/parking_status.dart';

class ParkingSlot {
  final String id;
  final String label;
  final ParkingStatus status;
  final String? vehicleId;
  final DateTime? occupiedAt;
  final bool isServiceArea;
  final DateTime createdAt;
  final DateTime updatedAt;

  ParkingSlot({
    required this.id,
    required this.label,
    required this.status,
    this.vehicleId,
    this.occupiedAt,
    required this.isServiceArea,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOccupied => status == ParkingStatus.occupied;
  bool get isAvailable => status == ParkingStatus.available;
  bool get isMaintenance => status == ParkingStatus.maintenance;

  Duration? get occupationDuration {
    if (occupiedAt == null) return null;
    return DateTime.now().difference(occupiedAt!);
  }

  String get occupationDurationText {
    final duration = occupationDuration;
    if (duration == null) return '';
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  ParkingSlot copyWith({
    String? id,
    String? label,
    ParkingStatus? status,
    String? vehicleId,
    DateTime? occupiedAt,
    bool? isServiceArea,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParkingSlot(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParkingSlot && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ParkingSlot(id: $id, label: $label, status: $status, isServiceArea: $isServiceArea)';
  }
}

