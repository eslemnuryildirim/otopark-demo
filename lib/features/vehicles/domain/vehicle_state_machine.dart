import 'package:otopark_demo/features/vehicles/domain/vehicle_status.dart';

/// Araç durum geçiş kurallarını yöneten State Machine
class VehicleStateMachine {
  /// İzin verilen geçişler matrisi
  static const Map<VehicleStatus, List<VehicleStatus>> _allowedTransitions = {
    VehicleStatus.parked: [
      VehicleStatus.inWash,
      VehicleStatus.inMaintenance,
      VehicleStatus.inDeliveryQueue,
      VehicleStatus.exited,
    ],
    VehicleStatus.inWash: [
      VehicleStatus.parked,
      VehicleStatus.inMaintenance,
      VehicleStatus.inDeliveryQueue,
    ],
    VehicleStatus.inMaintenance: [
      VehicleStatus.parked,
      VehicleStatus.inWash,
      VehicleStatus.inDeliveryQueue,
    ],
    VehicleStatus.inDeliveryQueue: [
      VehicleStatus.delivered,
      VehicleStatus.parked, // Geri alınabilir
    ],
    VehicleStatus.delivered: [
      VehicleStatus.exited,
    ],
    VehicleStatus.exited: [], // Terminal state - geçiş yok
  };

  /// Geçişin izin verilen olup olmadığını kontrol et
  static bool canTransition(VehicleStatus from, VehicleStatus to) {
    final allowedTargets = _allowedTransitions[from];
    if (allowedTargets == null) return false;
    return allowedTargets.contains(to);
  }

  /// İzin verilen hedef durumları döndür
  static List<VehicleStatus> getAllowedTransitions(VehicleStatus from) {
    return _allowedTransitions[from] ?? [];
  }

  /// Geçiş hatası mesajı
  static String getTransitionErrorMessage(VehicleStatus from, VehicleStatus to) {
    return '${from.displayName} durumundan ${to.displayName} durumuna geçiş yapılamaz.';
  }

  /// Slot gerektiren durumlar
  static bool requiresSlot(VehicleStatus status) {
    return status == VehicleStatus.parked;
  }

  /// Park süresinin hesaplanması gereken durumlar
  static bool tracksParkTime(VehicleStatus status) {
    return status == VehicleStatus.parked;
  }
}

