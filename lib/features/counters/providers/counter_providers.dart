import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/features/counters/data/counter_repository.dart';
import 'package:otopark_demo/features/counters/domain/counters.dart';
import 'package:otopark_demo/features/vehicles/domain/usecases/change_vehicle_status_usecase.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle_status.dart';
import 'package:otopark_demo/features/vehicles/providers/vehicle_providers.dart';

final counterRepositoryProvider = Provider<CounterRepository>((ref) {
  final repository = HiveCounterRepository();
  repository.init();
  return repository;
});

final countersProvider = AsyncNotifierProvider<CountersNotifier, Counters>(
  CountersNotifier.new,
);

class CountersNotifier extends AsyncNotifier<Counters> {
  @override
  Future<Counters> build() async {
    final counters = await ref.watch(counterRepositoryProvider).getCounters();
    
    // Active sayaçları gerçek araç sayısına göre güncelle (senkronizasyon için)
    try {
      final vehicles = await ref.read(vehiclesProvider.future);
      
      final actualActivePark = vehicles.where((v) => v.status == VehicleStatus.parked).length;
      final actualActiveMaintenance = vehicles.where((v) => v.status == VehicleStatus.inMaintenance).length;
      final actualActiveWash = vehicles.where((v) => v.status == VehicleStatus.inWash).length;
      
      // Eğer farklıysa güncelle (negatif değerleri de düzelt)
      final hasNegativeValues = counters.activePark < 0 ||
          counters.activeMaintenance < 0 ||
          counters.activeWash < 0 ||
          counters.totalPark < 0 ||
          counters.totalMaintenance < 0 ||
          counters.totalWash < 0 ||
          counters.totalDelivered < 0;
      
      if (counters.activePark != actualActivePark ||
          counters.activeMaintenance != actualActiveMaintenance ||
          counters.activeWash != actualActiveWash ||
          hasNegativeValues) {
        
        final correctedCounters = counters.copyWith(
          activePark: actualActivePark < 0 ? 0 : actualActivePark,
          activeMaintenance: actualActiveMaintenance < 0 ? 0 : actualActiveMaintenance,
          activeWash: actualActiveWash < 0 ? 0 : actualActiveWash,
          totalPark: counters.totalPark < 0 ? 0 : counters.totalPark,
          totalMaintenance: counters.totalMaintenance < 0 ? 0 : counters.totalMaintenance,
          totalWash: counters.totalWash < 0 ? 0 : counters.totalWash,
          totalDelivered: counters.totalDelivered < 0 ? 0 : counters.totalDelivered,
        );
        
        // Düzeltilmiş sayaçları kaydet
        await ref.read(counterRepositoryProvider).updateCounters(correctedCounters);
        return correctedCounters;
      }
    } catch (e) {
      print('⚠️ Sayaç senkronizasyon hatası: $e');
      // Hata olursa mevcut sayaçları döndür ama negatif değerleri düzelt
      if (counters.activePark < 0 || counters.activeMaintenance < 0 || counters.activeWash < 0 ||
          counters.totalPark < 0 || counters.totalMaintenance < 0 || counters.totalWash < 0 ||
          counters.totalDelivered < 0) {
        final correctedCounters = counters.copyWith(
          activePark: counters.activePark < 0 ? 0 : counters.activePark,
          activeMaintenance: counters.activeMaintenance < 0 ? 0 : counters.activeMaintenance,
          activeWash: counters.activeWash < 0 ? 0 : counters.activeWash,
          totalPark: counters.totalPark < 0 ? 0 : counters.totalPark,
          totalMaintenance: counters.totalMaintenance < 0 ? 0 : counters.totalMaintenance,
          totalWash: counters.totalWash < 0 ? 0 : counters.totalWash,
          totalDelivered: counters.totalDelivered < 0 ? 0 : counters.totalDelivered,
        );
        await ref.read(counterRepositoryProvider).updateCounters(correctedCounters);
        return correctedCounters;
      }
    }
    
    return counters;
  }

  Future<void> incrementCounter({
    bool park = false,
    bool maintenance = false,
    bool wash = false,
  }) async {
    state = const AsyncValue.loading();
    final currentCounters = await ref.read(counterRepositoryProvider).getCounters();
    final updatedCounters = currentCounters.copyWith(
      totalPark: park ? currentCounters.totalPark + 1 : currentCounters.totalPark,
      totalMaintenance: maintenance
          ? currentCounters.totalMaintenance + 1
          : currentCounters.totalMaintenance,
      totalWash: wash ? currentCounters.totalWash + 1 : currentCounters.totalWash,
    );
    await ref.read(counterRepositoryProvider).updateCounters(updatedCounters);
    state = AsyncValue.data(updatedCounters);
  }

  Future<void> resetCounters() async {
    state = const AsyncValue.loading();
    await ref.read(counterRepositoryProvider).resetCounters();
    state = AsyncValue.data(
      await ref.read(counterRepositoryProvider).getCounters(),
    );
  }

  /// UseCase'den gelen güncellemeleri uygula
  Future<void> applyUpdates(CounterUpdates updates) async {
    state = const AsyncValue.loading();
    final currentCounters = await ref.read(counterRepositoryProvider).getCounters();
    final updatedCounters = updates.apply(currentCounters);
    
    // Negatif değerleri düzelt
    final correctedCounters = updatedCounters.copyWith(
      activePark: updatedCounters.activePark < 0 ? 0 : updatedCounters.activePark,
      activeMaintenance: updatedCounters.activeMaintenance < 0 ? 0 : updatedCounters.activeMaintenance,
      activeWash: updatedCounters.activeWash < 0 ? 0 : updatedCounters.activeWash,
      totalPark: updatedCounters.totalPark < 0 ? 0 : updatedCounters.totalPark,
      totalMaintenance: updatedCounters.totalMaintenance < 0 ? 0 : updatedCounters.totalMaintenance,
      totalWash: updatedCounters.totalWash < 0 ? 0 : updatedCounters.totalWash,
      totalDelivered: updatedCounters.totalDelivered < 0 ? 0 : updatedCounters.totalDelivered,
    );
    
    await ref.read(counterRepositoryProvider).updateCounters(correctedCounters);
    state = AsyncValue.data(correctedCounters);
  }
}
