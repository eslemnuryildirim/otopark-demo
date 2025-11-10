import 'package:hive_flutter/hive_flutter.dart';
import 'package:otopark_demo/features/kroki/data/models/parking_slot_model.dart';
import 'package:otopark_demo/features/kroki/domain/entities/parking_slot.dart';
import 'package:otopark_demo/features/kroki/domain/entities/parking_status.dart';
import 'package:otopark_demo/features/kroki/domain/repositories/parking_repository.dart';
import 'package:otopark_demo/features/kroki/domain/utils/slot_label_generator.dart';

class ParkingRepositoryImpl implements ParkingRepository {
  static const String _boxName = 'parking_slots';
  Box<ParkingSlotModel> get _box => Hive.box<ParkingSlotModel>(_boxName);

  @override
  Future<List<ParkingSlot>> getAllSlots() async {
    final models = _box.values.toList();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ParkingSlot?> getSlotById(String id) async {
    final model = _box.get(id);
    return model?.toEntity();
  }

  @override
  Future<void> updateSlot(ParkingSlot slot) async {
    final model = ParkingSlotModel.fromEntity(slot);
    await _box.put(slot.id, model);
  }

  @override
  Future<void> vacateSlot(String slotId) async {
    final model = _box.get(slotId);
    if (model != null) {
      final updatedModel = model.copyWith(
        status: ParkingStatus.available,
        vehicleId: null,
        occupiedAt: null,
        updatedAt: DateTime.now(),
      );
      await _box.put(slotId, updatedModel);
    }
  }

  @override
  Future<void> occupySlot(String slotId, String vehicleId) async {
    final model = _box.get(slotId);
    if (model != null) {
      final updatedModel = model.copyWith(
        status: ParkingStatus.occupied,
        vehicleId: vehicleId,
        occupiedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _box.put(slotId, updatedModel);
    }
  }

  @override
  Future<void> initializeDefaultSlots() async {
    if (_box.isNotEmpty) return; // Zaten var

    final now = DateTime.now();
    final slots = <ParkingSlotModel>[];

    // Servis alanları
    final serviceLabels = SlotLabelGenerator.getServiceLabels();
    for (final label in serviceLabels) {
      slots.add(ParkingSlotModel(
        id: label,
        label: label,
        status: ParkingStatus.available,
        isServiceArea: true,
        createdAt: now,
        updatedAt: now,
      ));
    }

    // Ana park alanları (78 slot)
    for (int i = 0; i < SlotLabelGenerator.totalSlots; i++) {
      final label = SlotLabelGenerator.generate(i);
      slots.add(ParkingSlotModel(
        id: label,
        label: label,
        status: ParkingStatus.available,
        isServiceArea: false,
        createdAt: now,
        updatedAt: now,
      ));
    }

    // Hive'a kaydet
    for (final slot in slots) {
      await _box.put(slot.id, slot);
    }
  }

  @override
  Future<void> syncSlots() async {
    // TODO: Firebase ile senkronizasyon implementasyonu
    // Şimdilik sadece Hive kullanıyoruz
  }

  @override
  Future<List<ParkingSlot>> getAvailableSlots() async {
    final models = _box.values
        .where((model) => model.status == ParkingStatus.available)
        .toList();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ParkingSlot>> getOccupiedSlots() async {
    final models = _box.values
        .where((model) => model.status == ParkingStatus.occupied)
        .toList();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ParkingSlot>> getServiceSlots() async {
    final models = _box.values
        .where((model) => model.isServiceArea)
        .toList();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ParkingSlotStats> getSlotStats() async {
    final allSlots = await getAllSlots();
    
    final totalSlots = allSlots.length;
    final occupiedSlots = allSlots.where((slot) => slot.isOccupied).length;
    final availableSlots = allSlots.where((slot) => slot.isAvailable).length;
    
    final serviceSlots = allSlots.where((slot) => slot.isServiceArea).toList();
    final occupiedServiceSlots = serviceSlots.where((slot) => slot.isOccupied).length;
    final availableServiceSlots = serviceSlots.where((slot) => slot.isAvailable).length;

    return ParkingSlotStats(
      totalSlots: totalSlots,
      occupiedSlots: occupiedSlots,
      availableSlots: availableSlots,
      serviceSlots: serviceSlots.length,
      occupiedServiceSlots: occupiedServiceSlots,
      availableServiceSlots: availableServiceSlots,
    );
  }

  @override
  Stream<List<ParkingSlot>> watchSlots() {
    return _box.watch().map((event) {
      final models = _box.values.toList();
      return models.map((model) => model.toEntity()).toList();
    });
  }
}

