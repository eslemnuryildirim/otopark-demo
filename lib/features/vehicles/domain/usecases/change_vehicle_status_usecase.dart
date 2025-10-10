import 'package:otopark_demo/features/counters/domain/counters.dart';
import 'package:otopark_demo/features/operations/domain/operation.dart';
import 'package:otopark_demo/features/operations/domain/operation_type.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle_state_machine.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle_status.dart';
import 'package:uuid/uuid.dart';

/// Araç durum değiştirme use case
/// Tüm iş kurallarını, sayaç güncellemelerini ve operation loglarını yönetir
class ChangeVehicleStatusUseCase {
  final Uuid _uuid = const Uuid();

  /// Durum değiştirme ve gerekli tüm güncellemeleri yap
  ChangeVehicleStatusResult execute({
    required Vehicle vehicle,
    required VehicleStatus newStatus,
    String? targetSlotId,
    String? note,
  }) {
    // 1. Geçiş kontrolü
    if (!VehicleStateMachine.canTransition(vehicle.status, newStatus)) {
      return ChangeVehicleStatusResult(
        success: false,
        error: VehicleStateMachine.getTransitionErrorMessage(vehicle.status, newStatus),
      );
    }

    // 2. Slot kontrolü
    if (VehicleStateMachine.requiresSlot(newStatus) && targetSlotId == null) {
      return ChangeVehicleStatusResult(
        success: false,
        error: 'Park durumuna geçmek için slot seçimi gereklidir.',
      );
    }

    final oldStatus = vehicle.status;
    final now = DateTime.now();
    
    // 3. Park süresi hesapla (parktan çıkıyorsa)
    Duration? parkDuration;
    if (oldStatus == VehicleStatus.parked && vehicle.parkStartAt != null) {
      parkDuration = now.difference(vehicle.parkStartAt!);
    }

    // 4. Aracı güncelle
    final updatedVehicle = vehicle.copyWith(
      status: newStatus,
      updatedAt: now,
      currentParkSlotId: newStatus == VehicleStatus.parked ? targetSlotId : null,
      parkStartAt: newStatus == VehicleStatus.parked ? now : null,
      clearParkSlotId: newStatus != VehicleStatus.parked,
      clearParkStartAt: newStatus != VehicleStatus.parked,
    );

    // 5. Operation oluştur
    final operation = Operation(
      id: _uuid.v4(),
      vehicleId: vehicle.id,
      type: _mapStatusToOperationType(newStatus),
      note: note,
      timestamp: now,
      fromSlotId: vehicle.currentParkSlotId,
      toSlotId: targetSlotId,
      parkDuration: parkDuration,
    );

    // 6. Sayaç güncellemelerini hesapla
    final counterUpdates = _calculateCounterUpdates(oldStatus, newStatus);

    return ChangeVehicleStatusResult(
      success: true,
      updatedVehicle: updatedVehicle,
      operation: operation,
      counterUpdates: counterUpdates,
      fromSlotId: vehicle.currentParkSlotId,
      toSlotId: targetSlotId,
    );
  }

  OperationType _mapStatusToOperationType(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.parked:
        return OperationType.park;
      case VehicleStatus.inMaintenance:
        return OperationType.maintenance;
      case VehicleStatus.inWash:
        return OperationType.wash;
      case VehicleStatus.inDeliveryQueue:
        return OperationType.deliverQueue;
      case VehicleStatus.delivered:
        return OperationType.delivered;
      case VehicleStatus.exited:
        return OperationType.exit;
    }
  }

  CounterUpdates _calculateCounterUpdates(VehicleStatus from, VehicleStatus to) {
    final updates = CounterUpdates();

    // Eski durumdan çıkış
    switch (from) {
      case VehicleStatus.parked:
        updates.activeParkDelta = -1;
        break;
      case VehicleStatus.inMaintenance:
        updates.activeMaintenanceDelta = -1;
        break;
      case VehicleStatus.inWash:
        updates.activeWashDelta = -1;
        break;
      default:
        break;
    }

    // Yeni duruma giriş
    switch (to) {
      case VehicleStatus.parked:
        updates.totalParkDelta = 1;
        updates.activeParkDelta = (updates.activeParkDelta ?? 0) + 1;
        break;
      case VehicleStatus.inMaintenance:
        updates.totalMaintenanceDelta = 1;
        updates.activeMaintenanceDelta = (updates.activeMaintenanceDelta ?? 0) + 1;
        break;
      case VehicleStatus.inWash:
        updates.totalWashDelta = 1;
        updates.activeWashDelta = (updates.activeWashDelta ?? 0) + 1;
        break;
      case VehicleStatus.delivered:
        updates.totalDeliveredDelta = 1;
        break;
      default:
        break;
    }

    return updates;
  }
}

/// Use case sonucu
class ChangeVehicleStatusResult {
  final bool success;
  final String? error;
  final Vehicle? updatedVehicle;
  final Operation? operation;
  final CounterUpdates? counterUpdates;
  final String? fromSlotId;
  final String? toSlotId;

  ChangeVehicleStatusResult({
    required this.success,
    this.error,
    this.updatedVehicle,
    this.operation,
    this.counterUpdates,
    this.fromSlotId,
    this.toSlotId,
  });
}

/// Sayaç güncellemeleri
class CounterUpdates {
  int? totalParkDelta;
  int? totalMaintenanceDelta;
  int? totalWashDelta;
  int? totalDeliveredDelta;
  int? activeParkDelta;
  int? activeMaintenanceDelta;
  int? activeWashDelta;

  CounterUpdates({
    this.totalParkDelta,
    this.totalMaintenanceDelta,
    this.totalWashDelta,
    this.totalDeliveredDelta,
    this.activeParkDelta,
    this.activeMaintenanceDelta,
    this.activeWashDelta,
  });

  Counters apply(Counters counters) {
    return counters.copyWith(
      totalPark: counters.totalPark + (totalParkDelta ?? 0),
      totalMaintenance: counters.totalMaintenance + (totalMaintenanceDelta ?? 0),
      totalWash: counters.totalWash + (totalWashDelta ?? 0),
      totalDelivered: counters.totalDelivered + (totalDeliveredDelta ?? 0),
      activePark: counters.activePark + (activeParkDelta ?? 0),
      activeMaintenance: counters.activeMaintenance + (activeMaintenanceDelta ?? 0),
      activeWash: counters.activeWash + (activeWashDelta ?? 0),
    );
  }
}

