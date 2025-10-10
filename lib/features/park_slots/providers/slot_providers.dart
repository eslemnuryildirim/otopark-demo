import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/features/park_slots/data/slot_repository.dart';
import 'package:otopark_demo/features/park_slots/domain/park_slot.dart';

final slotRepositoryProvider = Provider<SlotRepository>((ref) {
  final repository = HiveSlotRepository();
  repository.init(); // Async init - varsayılan slotları oluştur
  return repository;
});

final slotsProvider = AsyncNotifierProvider<SlotsNotifier, List<ParkSlot>>(
  SlotsNotifier.new,
);

class SlotsNotifier extends AsyncNotifier<List<ParkSlot>> {
  @override
  Future<List<ParkSlot>> build() async {
    return ref.watch(slotRepositoryProvider).getSlots();
  }

  Future<void> updateSlot(ParkSlot slot) async {
    state = const AsyncValue.loading();
    await ref.read(slotRepositoryProvider).updateSlot(slot);
    state = AsyncValue.data(
      await ref.read(slotRepositoryProvider).getSlots(),
    );
  }

  Future<void> occupySlot(String slotId, String vehicleId) async {
    final slots = state.value ?? [];
    final slot = slots.firstWhere((s) => s.id == slotId);
    
    if (slot.isOccupied) {
      throw Exception('Slot ${slot.label} zaten dolu!');
    }
    
    final updatedSlot = slot.copyWith(
      isOccupied: true,
      vehicleId: vehicleId,
    );
    
    await updateSlot(updatedSlot);
  }

  Future<void> vacateSlot(String slotId) async {
    final slots = state.value ?? [];
    final slot = slots.firstWhere((s) => s.id == slotId);
    
    final updatedSlot = slot.copyWith(
      isOccupied: false,
      clearVehicleId: true,
    );
    
    await updateSlot(updatedSlot);
  }

  Future<List<ParkSlot>> getAvailableSlots({bool serviceOnly = false}) async {
    final slots = await ref.read(slotRepositoryProvider).getSlots();
    return slots.where((s) {
      if (serviceOnly) {
        return s.isServiceArea && !s.isOccupied;
      }
      return !s.isServiceArea && !s.isOccupied;
    }).toList();
  }
}

