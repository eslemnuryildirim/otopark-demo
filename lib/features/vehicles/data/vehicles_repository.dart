import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle.dart';

/// Araçlar repository provider'ı
final vehiclesRepositoryProvider = Provider<VehiclesRepository>((ref) {
  return VehiclesRepository();
});

/// Araçlar repository'si
class VehiclesRepository {
  /// Tüm araçları getir
  Future<List<Vehicle>> getAllVehicles() async {
    try {
      // Box açık mı kontrol et
      if (!Hive.isBoxOpen('vehicles')) {
        print('⚠️ vehicles box açık değil, açılıyor...');
        await Hive.openBox<Vehicle>('vehicles');
      }
      
      final box = Hive.box<Vehicle>('vehicles');
      return box.values.toList();
    } catch (e) {
      print('❌ Araçlar yüklenirken hata: $e');
      return [];
    }
  }

  /// Araç ekle
  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      if (!Hive.isBoxOpen('vehicles')) {
        await Hive.openBox<Vehicle>('vehicles');
      }
      final box = Hive.box<Vehicle>('vehicles');
      await box.put(vehicle.id, vehicle);
    } catch (e) {
      print('❌ Araç eklenirken hata: $e');
    }
  }

  /// Araç güncelle
  Future<void> updateVehicle(Vehicle vehicle) async {
    try {
      if (!Hive.isBoxOpen('vehicles')) {
        await Hive.openBox<Vehicle>('vehicles');
      }
      final box = Hive.box<Vehicle>('vehicles');
      await box.put(vehicle.id, vehicle);
    } catch (e) {
      print('❌ Araç güncellenirken hata: $e');
    }
  }

  /// Araç sil
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      if (!Hive.isBoxOpen('vehicles')) {
        await Hive.openBox<Vehicle>('vehicles');
      }
      final box = Hive.box<Vehicle>('vehicles');
      await box.delete(vehicleId);
    } catch (e) {
      print('❌ Araç silinirken hata: $e');
    }
  }
}
