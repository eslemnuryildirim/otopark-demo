import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/features/kroki/data/repositories/parking_repository_impl.dart';
import 'package:otopark_demo/features/kroki/domain/entities/parking_slot.dart';
import 'package:otopark_demo/features/kroki/domain/repositories/parking_repository.dart';

// Repository provider
final parkingRepositoryProvider = Provider<ParkingRepository>((ref) {
  return ParkingRepositoryImpl();
});

// Tüm slot'ları getiren provider
final parkingSlotsProvider = StreamProvider<List<ParkingSlot>>((ref) {
  final repository = ref.watch(parkingRepositoryProvider);
  return repository.watchSlots();
});

// Slot istatistikleri provider
final parkingStatsProvider = FutureProvider<ParkingSlotStats>((ref) async {
  final repository = ref.watch(parkingRepositoryProvider);
  return repository.getSlotStats();
});

// Seçili slot provider
final selectedSlotProvider = StateProvider<String?>((ref) => null);

// Slot'u güncelleme provider
final updateSlotProvider = FutureProvider.family<void, ParkingSlot>((ref, slot) async {
  final repository = ref.watch(parkingRepositoryProvider);
  return repository.updateSlot(slot);
});

// Slot'u boşaltma provider
final vacateSlotProvider = FutureProvider.family<void, String>((ref, slotId) async {
  final repository = ref.watch(parkingRepositoryProvider);
  return repository.vacateSlot(slotId);
});

// Slot'u doldurma provider
final occupySlotProvider = FutureProvider.family<void, ({String slotId, String vehicleId})>((ref, params) async {
  final repository = ref.watch(parkingRepositoryProvider);
  return repository.occupySlot(params.slotId, params.vehicleId);
});

// Boş slot'lar provider
final availableSlotsProvider = FutureProvider<List<ParkingSlot>>((ref) async {
  final repository = ref.watch(parkingRepositoryProvider);
  return repository.getAvailableSlots();
});

// Dolu slot'lar provider
final occupiedSlotsProvider = FutureProvider<List<ParkingSlot>>((ref) async {
  final repository = ref.watch(parkingRepositoryProvider);
  return repository.getOccupiedSlots();
});

// Servis slot'ları provider
final serviceSlotsProvider = FutureProvider<List<ParkingSlot>>((ref) async {
  final repository = ref.watch(parkingRepositoryProvider);
  return repository.getServiceSlots();
});

// Computed providers
final totalSlotsCountProvider = Provider<int>((ref) {
  final slotsAsync = ref.watch(parkingSlotsProvider);
  return slotsAsync.when(
    data: (slots) => slots.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final occupiedSlotsCountProvider = Provider<int>((ref) {
  final slotsAsync = ref.watch(parkingSlotsProvider);
  return slotsAsync.when(
    data: (slots) => slots.where((slot) => slot.isOccupied).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final availableSlotsCountProvider = Provider<int>((ref) {
  final slotsAsync = ref.watch(parkingSlotsProvider);
  return slotsAsync.when(
    data: (slots) => slots.where((slot) => slot.isAvailable).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final serviceSlotsCountProvider = Provider<int>((ref) {
  final slotsAsync = ref.watch(parkingSlotsProvider);
  return slotsAsync.when(
    data: (slots) => slots.where((slot) => slot.isServiceArea).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final occupiedServiceSlotsCountProvider = Provider<int>((ref) {
  final slotsAsync = ref.watch(parkingSlotsProvider);
  return slotsAsync.when(
    data: (slots) => slots.where((slot) => slot.isServiceArea && slot.isOccupied).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final availableServiceSlotsCountProvider = Provider<int>((ref) {
  final slotsAsync = ref.watch(parkingSlotsProvider);
  return slotsAsync.when(
    data: (slots) => slots.where((slot) => slot.isServiceArea && slot.isAvailable).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

