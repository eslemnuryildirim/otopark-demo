import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle_status.dart';

/// 🔄 Araç Provider - Mock data ile çalışır
/// 
/// Hive kullanımı nedeniyle geçici olarak kapatıldı.
/// Mock data kullanıldığında bu provider gerekli değil.
final vehiclesProvider = AsyncNotifierProvider<VehiclesNotifier, List<Vehicle>>(() {
  return VehiclesNotifier();
});

/// 📋 Araç Notifier - Mock data ile çalışır
/// 
/// Hive kullanımı nedeniyle geçici olarak kapatıldı.
/// Mock data kullanıldığında bu notifier gerekli değil.
class VehiclesNotifier extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() async {
    // Mock data döndür
    return [
      Vehicle(
        id: 'mock-1',
        plate: '34 ABC 123',
        brand: 'BMW',
        model: 'M3',
        color: 'Siyah',
        status: VehicleStatus.parked,
        currentParkSlotId: 'A1',
        parkStartAt: DateTime.now().subtract(const Duration(minutes: 45)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        damagedParts: const {},
      ),
      Vehicle(
        id: 'mock-2',
        plate: '06 DEF 456',
        brand: 'Mercedes',
        model: 'C200',
        color: 'Beyaz',
        status: VehicleStatus.inMaintenance,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        damagedParts: const {},
      ),
    ];
  }

  /// Araç ekle
  Future<void> addVehicle(Vehicle vehicle) async {
    // Mock data ekleme
  }

  /// Araç güncelle
  Future<void> updateVehicle(Vehicle vehicle) async {
    // Mock data güncelleme
  }

  /// Araç sil
  Future<void> deleteVehicle(String vehicleId) async {
    // Mock data silme
  }

  /// Araç durumu değiştir
  Future<String?> changeVehicleStatus(String vehicleId, VehicleStatus newStatus) async {
    // Mock data güncelleme
    return null; // Hata yok
  }
}