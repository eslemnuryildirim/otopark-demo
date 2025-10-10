import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/features/counters/data/counter_repository.dart';
import 'package:otopark_demo/features/counters/domain/counters.dart';
import 'package:otopark_demo/features/vehicles/domain/usecases/change_vehicle_status_usecase.dart';

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
    return ref.watch(counterRepositoryProvider).getCounters();
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
    await ref.read(counterRepositoryProvider).updateCounters(updatedCounters);
    state = AsyncValue.data(updatedCounters);
  }
}
