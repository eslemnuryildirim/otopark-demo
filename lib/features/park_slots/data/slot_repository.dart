import 'package:hive_flutter/hive_flutter.dart';
import 'package:otopark_demo/features/park_slots/domain/park_slot.dart';

abstract class SlotRepository {
  Future<List<ParkSlot>> getSlots();
  Future<ParkSlot?> getSlotById(String id);
  Future<void> addSlot(ParkSlot slot);
  Future<void> updateSlot(ParkSlot slot);
  Future<void> deleteSlot(String id);
  Future<void> initializeDefaultSlots();
}

class HiveSlotRepository implements SlotRepository {
  Box<ParkSlot> get _slotBox => Hive.box<ParkSlot>('park_slots');

  Future<void> init() async {
    // İlk açılışta varsayılan slotları oluştur
    if (_slotBox.isEmpty) {
      await initializeDefaultSlots();
    }
  }

  @override
  Future<List<ParkSlot>> getSlots() async {
    return _slotBox.values.toList();
  }

  @override
  Future<ParkSlot?> getSlotById(String id) async {
    return _slotBox.get(id);
  }

  @override
  Future<void> addSlot(ParkSlot slot) async {
    await _slotBox.put(slot.id, slot);
  }

  @override
  Future<void> updateSlot(ParkSlot slot) async {
    await _slotBox.put(slot.id, slot);
  }

  @override
  Future<void> deleteSlot(String id) async {
    await _slotBox.delete(id);
  }

  @override
  Future<void> initializeDefaultSlots() async {
    // Servis alanları
    final serviceSlots = [
      ParkSlot(id: 'YIK1', label: 'İç Yıkama', isServiceArea: true),
      ParkSlot(id: 'YIK2', label: 'Dış Yıkama', isServiceArea: true),
      ParkSlot(id: 'CAM1', label: 'Cam-Kaput', isServiceArea: true),
      ParkSlot(id: 'DET1', label: 'Detaylı İç Temizlik', isServiceArea: true),
      ParkSlot(id: 'PAS1', label: 'Pasta Cila (İkinci El)', isServiceArea: true),
      ParkSlot(id: 'PAS2', label: 'Pasta Cila (0 Araç)', isServiceArea: true),
    ];

    // Ana park alanları - 13 spot per row
    final rows = ['A', 'B', 'C', 'D', 'E', 'F'];
    final parkSlots = <ParkSlot>[];
    
    for (var row in rows) {
      for (var i = 1; i <= 13; i++) {
        parkSlots.add(
          ParkSlot(
            id: '$row$i',
            label: '$row-${i.toString().padLeft(2, '0')}',
            isServiceArea: false,
          ),
        );
      }
    }

    // Tüm slotları kaydet
    for (var slot in [...serviceSlots, ...parkSlots]) {
      await _slotBox.put(slot.id, slot);
    }
  }
}

