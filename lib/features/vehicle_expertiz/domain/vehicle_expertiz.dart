import 'package:freezed_annotation/freezed_annotation.dart';
import 'car_part.dart';
import 'expertiz_status.dart';

part 'vehicle_expertiz.freezed.dart';
part 'vehicle_expertiz.g.dart';

/// Araç ekspertiz veri modeli
@freezed
class VehicleExpertiz with _$VehicleExpertiz {
  const factory VehicleExpertiz({
    required String vehicleId,
    required String id,
    required Map<CarPart, ExpertizStatus> partStatuses,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? inspectorName,
    List<String>? photos, // Fotoğraf URL'leri
  }) = _VehicleExpertiz;

  factory VehicleExpertiz.fromJson(Map<String, dynamic> json) =>
      _$VehicleExpertizFromJson(json);
}

/// Ekspertiz parça durumu
@freezed
class ExpertizPartStatus with _$ExpertizPartStatus {
  const factory ExpertizPartStatus({
    required CarPart part,
    required ExpertizStatus status,
    String? notes,
    DateTime? inspectedAt,
    String? inspectorName,
  }) = _ExpertizPartStatus;

  factory ExpertizPartStatus.fromJson(Map<String, dynamic> json) =>
      _$ExpertizPartStatusFromJson(json);
}

/// Ekspertiz istatistikleri
@freezed
class ExpertizStats with _$ExpertizStats {
  const factory ExpertizStats({
    required int totalParts,
    required int originalParts,
    required int paintedParts,
    required int replacedParts,
    required int damagedParts,
    required int scratchedParts,
    required double overallCondition, // 0.0 - 1.0 arası
  }) = _ExpertizStats;

  factory ExpertizStats.fromJson(Map<String, dynamic> json) =>
      _$ExpertizStatsFromJson(json);
}

/// Ekspertiz durumu hesaplama yardımcıları
extension VehicleExpertizExtension on VehicleExpertiz {
  /// Genel durum skoru (0.0 - 1.0)
  double get overallCondition {
    if (partStatuses.isEmpty) return 1.0;
    
    final totalSeverity = partStatuses.values
        .map((status) => status.severityLevel)
        .reduce((a, b) => a + b);
    
    final maxSeverity = partStatuses.length * 5; // En kötü durum
    return 1.0 - (totalSeverity / maxSeverity);
  }
  
  /// İstatistikleri hesapla
  ExpertizStats get stats {
    final totalParts = partStatuses.length;
    final originalParts = partStatuses.values
        .where((status) => status == ExpertizStatus.original)
        .length;
    final paintedParts = partStatuses.values
        .where((status) => status == ExpertizStatus.painted || status == ExpertizStatus.localPainted)
        .length;
    final replacedParts = partStatuses.values
        .where((status) => status == ExpertizStatus.replaced)
        .length;
    final damagedParts = partStatuses.values
        .where((status) => status == ExpertizStatus.damaged)
        .length;
    final scratchedParts = partStatuses.values
        .where((status) => status == ExpertizStatus.scratched)
        .length;
    
    return ExpertizStats(
      totalParts: totalParts,
      originalParts: originalParts,
      paintedParts: paintedParts,
      replacedParts: replacedParts,
      damagedParts: damagedParts,
      scratchedParts: scratchedParts,
      overallCondition: overallCondition,
    );
  }
  
  /// En problemli parçaları döndür
  List<CarPart> get problematicParts {
    return partStatuses.entries
        .where((entry) => entry.value.severityLevel >= 3)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// Ekspertiz tamamlanmış mı?
  bool get isComplete {
    return partStatuses.length >= CarPart.values.length;
  }
}

