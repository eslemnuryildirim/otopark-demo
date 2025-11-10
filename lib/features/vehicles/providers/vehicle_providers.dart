import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/features/vehicles/data/vehicle_repository.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle_status.dart';
import 'package:otopark_demo/features/vehicles/domain/usecases/change_vehicle_status_usecase.dart';
import 'package:otopark_demo/features/operations/domain/operation.dart';
import 'package:otopark_demo/features/operations/domain/operation_type.dart';
import 'package:otopark_demo/features/operations/providers/operation_providers.dart';
import 'package:otopark_demo/features/counters/providers/counter_providers.dart';
import 'package:otopark_demo/features/park_slots/providers/slot_providers.dart';
import 'package:uuid/uuid.dart';

final uuidProvider = Provider((ref) => const Uuid());

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final repository = HybridVehicleRepository();
  repository.init(); // init zaten main'de yapıldı, box açık
  return repository;
});

final vehiclesProvider = AsyncNotifierProvider<VehiclesNotifier, List<Vehicle>>(
  VehiclesNotifier.new,
);

class VehiclesNotifier extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() async {
    return ref.watch(vehicleRepositoryProvider).getVehicles();
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    state = const AsyncValue.loading();
    await ref.read(vehicleRepositoryProvider).addVehicle(vehicle);
    
    // Yeni araç eklendiyse sayacı ve işlemi güncelle
    if (vehicle.status == VehicleStatus.parked) {
      // Sayacı güncelle
      final currentCounters = await ref.read(countersProvider.future);
      final updatedCounters = currentCounters.copyWith(
        totalPark: currentCounters.totalPark + 1,
        activePark: currentCounters.activePark + 1,
      );
      await ref.read(counterRepositoryProvider).updateCounters(updatedCounters);
      ref.invalidate(countersProvider);
      
      // İşlem kaydı oluştur
      final operation = Operation(
        id: ref.read(uuidProvider).v4(),
        vehicleId: vehicle.id,
        type: OperationType.park,
        note: 'Araç ilk kez parka alındı',
        timestamp: DateTime.now(),
        toSlotId: vehicle.currentParkSlotId,
      );
      await ref.read(operationsProvider.notifier).addOperation(operation);
    }
    
    state = AsyncValue.data(
      await ref.read(vehicleRepositoryProvider).getVehicles(),
    );
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    state = const AsyncValue.loading();
    await ref.read(vehicleRepositoryProvider).updateVehicle(vehicle);
    state = AsyncValue.data(
      await ref.read(vehicleRepositoryProvider).getVehicles(),
    );
  }

  Future<void> deleteVehicle(String id) async {
    state = const AsyncValue.loading();
    await ref.read(vehicleRepositoryProvider).deleteVehicle(id);
    state = AsyncValue.data(
      await ref.read(vehicleRepositoryProvider).getVehicles(),
    );
  }

  /// Araç durumu değiştirme - UseCase kullanarak
  Future<String?> changeVehicleStatus({
    required Vehicle vehicle,
    required VehicleStatus newStatus,
    String? targetSlotId,
    String? note,
  }) async {
    try {
      final useCase = ChangeVehicleStatusUseCase();
      
      // UseCase çalıştır
      final result = useCase.execute(
        vehicle: vehicle,
        newStatus: newStatus,
        targetSlotId: targetSlotId,
        note: note,
      );

      if (!result.success) {
        return result.error;
      }

      // 1. Aracı güncelle
      await ref.read(vehicleRepositoryProvider).updateVehicle(result.updatedVehicle!);

      // 2. Operation ekle
      await ref.read(operationsProvider.notifier).addOperation(result.operation!);

      // 3. Sayaçları güncelle
      if (result.counterUpdates != null) {
        await ref.read(countersProvider.notifier).applyUpdates(result.counterUpdates!);
      }

      // 4. Slot'ları güncelle
      if (result.fromSlotId != null && result.fromSlotId!.isNotEmpty) {
        try {
          await ref.read(slotsProvider.notifier).vacateSlot(result.fromSlotId!);
        } catch (e) {
          print('⚠️ Slot boşaltma hatası: $e');
        }
      }
      if (result.toSlotId != null && result.toSlotId!.isNotEmpty) {
        try {
          await ref.read(slotsProvider.notifier).occupySlot(result.toSlotId!, vehicle.id);
        } catch (e) {
          print('⚠️ Slot doldurma hatası: $e');
        }
      }

      // 5. UI'ı yenile
      state = AsyncValue.data(
        await ref.read(vehicleRepositoryProvider).getVehicles(),
      );
      
      // 6. Slots provider'ı da yenile (kroki sayfası için)
      ref.invalidate(slotsProvider);

      return null; // Başarılı
    } catch (e) {
      return 'Hata: $e';
    }
  }
}
