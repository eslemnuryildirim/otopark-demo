import 'package:otopark_demo/features/kroki/domain/entities/parking_slot.dart';

abstract class ParkingRepository {
  /// Tüm slot'ları getir
  Future<List<ParkingSlot>> getAllSlots();
  
  /// ID'ye göre slot getir
  Future<ParkingSlot?> getSlotById(String id);
  
  /// Slot'u güncelle
  Future<void> updateSlot(ParkingSlot slot);
  
  /// Slot'u boşalt
  Future<void> vacateSlot(String slotId);
  
  /// Slot'u doldur
  Future<void> occupySlot(String slotId, String vehicleId);
  
  /// Varsayılan slot'ları oluştur
  Future<void> initializeDefaultSlots();
  
  /// Slot'ları senkronize et (Firebase ↔ Hive)
  Future<void> syncSlots();
  
  /// Boş slot'ları getir
  Future<List<ParkingSlot>> getAvailableSlots();
  
  /// Dolu slot'ları getir
  Future<List<ParkingSlot>> getOccupiedSlots();
  
  /// Servis alanı slot'larını getir
  Future<List<ParkingSlot>> getServiceSlots();
  
  /// Slot istatistiklerini getir
  Future<ParkingSlotStats> getSlotStats();
  
  /// Slot'ları stream olarak dinle
  Stream<List<ParkingSlot>> watchSlots();
}

class ParkingSlotStats {
  final int totalSlots;
  final int occupiedSlots;
  final int availableSlots;
  final int serviceSlots;
  final int occupiedServiceSlots;
  final int availableServiceSlots;

  ParkingSlotStats({
    required this.totalSlots,
    required this.occupiedSlots,
    required this.availableSlots,
    required this.serviceSlots,
    required this.occupiedServiceSlots,
    required this.availableServiceSlots,
  });

  double get occupancyRate => totalSlots > 0 ? occupiedSlots / totalSlots : 0.0;
  double get serviceOccupancyRate => serviceSlots > 0 ? occupiedServiceSlots / serviceSlots : 0.0;

  @override
  String toString() {
    return 'ParkingSlotStats(total: $totalSlots, occupied: $occupiedSlots, available: $availableSlots, service: $serviceSlots)';
  }
}

