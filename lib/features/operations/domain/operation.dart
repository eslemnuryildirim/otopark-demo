import 'package:hive/hive.dart';
import 'package:otopark_demo/features/operations/domain/operation_type.dart';

part 'operation.g.dart';

/// İşlem modeli - Genişletilmiş versiyon
@HiveType(typeId: 2)
class Operation extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String vehicleId;
  
  @HiveField(2)
  final OperationType type;
  
  @HiveField(3)
  final String? note;
  
  @HiveField(4)
  final DateTime timestamp;
  
  @HiveField(5)
  final String? fromSlotId; // Taşıma/çıkış için kaynak slot
  
  @HiveField(6)
  final String? toSlotId; // Park/taşıma için hedef slot
  
  @HiveField(7)
  final Duration? parkDuration; // Parktan çıkarken hesaplanan süre

  Operation({
    required this.id,
    required this.vehicleId,
    required this.type,
    this.note,
    required this.timestamp,
    this.fromSlotId,
    this.toSlotId,
    this.parkDuration,
  });

  /// Park süresini dakika olarak döndür
  int? get parkDurationMinutes => parkDuration?.inMinutes;
}
