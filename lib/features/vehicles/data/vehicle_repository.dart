import 'package:hive_flutter/hive_flutter.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle.dart';
import 'package:otopark_demo/core/db/sync_service.dart';

/// 📦 Araç Veritabanı Repository (Interface)
/// 
/// **Repository Pattern Nedir?**
/// - Veritabanı işlemlerini tek yerden yönetir
/// - UI kodundan veritabanı detaylarını saklar
/// - Kolay test edilebilir
/// 
/// **Abstract Class Nedir?**
/// - Sözleşme gibidir (contract)
/// - "Bu fonksiyonlar olmalı" der
/// - Farklı implementasyonlar yapılabilir
/// 
/// **Örnek:**
/// ```dart
/// // Bu interface
/// abstract class VehicleRepository { 
///   Future<void> addVehicle(Vehicle v);
/// }
/// 
/// // Farklı implementasyonlar
/// class HiveRepo implements VehicleRepository {...}
/// class SQLiteRepo implements VehicleRepository {...}
/// class MockRepo implements VehicleRepository {...} // Test için
/// ```
abstract class VehicleRepository {
  /// 📋 Tüm araçları getir
  Future<List<Vehicle>> getVehicles();
  
  /// 🔍 ID'ye göre araç bul
  Future<Vehicle?> getVehicleById(String id);
  
  /// ➕ Yeni araç ekle
  Future<void> addVehicle(Vehicle vehicle);
  
  /// ✏️ Mevcut aracı güncelle
  Future<void> updateVehicle(Vehicle vehicle);
  
  /// 🗑️ Araç sil
  Future<void> deleteVehicle(String id);
  
  /// 🔄 Cloud'dan lokal'e senkronize et
  Future<void> syncFromCloud();
}

/// 🔄 Hybrid Repository: Hive (Lokal) + Firebase (Cloud)
/// 
/// **Hybrid Nedir?**
/// - İki veritabanı birlikte kullanılır
/// - Hive: Lokal, hızlı, offline çalışır
/// - Firebase: Cloud, yedek, multi-device
/// 
/// **Nasıl Çalışır?**
/// ```
/// Yazma İşlemi:
/// User → addVehicle() → [1] Hive'a kaydet → [2] Firebase'e kaydet
///                             ↓                    ↓
///                        Hızlı (10ms)        Yavaş ama güvenli (500ms)
/// 
/// Okuma İşlemi:
/// User → getVehicles() → Hive'dan oku (çok hızlı!)
/// ```
/// 
/// **Avantajlar:**
/// - ⚡ Çok hızlı (Hive)
/// - 📴 Offline çalışır (Hive)
/// - ☁️ Yedek var (Firebase)
/// - 📱 Multi-device sync (Firebase)
class HybridVehicleRepository implements VehicleRepository {
  Box<Vehicle> get _vehicleBox => Hive.box<Vehicle>('vehicles');
  static const String _collection = 'vehicles';

  void init() {
    // Box zaten main.dart'ta açıldı
  }

  @override
  Future<List<Vehicle>> getVehicles() async {
    // Önce lokal'den oku (hızlı)
    return _vehicleBox.values.toList();
  }

  @override
  Future<Vehicle?> getVehicleById(String id) async {
    try {
      return _vehicleBox.values.firstWhere((vehicle) => vehicle.id == id);
    } catch (e) {
      return null;
    }
  }

  /// ➕ Yeni Araç Ekle (Hybrid)
  /// 
  /// **İşlem Adımları:**
  /// 1. Hive'a kaydet (lokal, çok hızlı ~10ms)
  /// 2. Firebase'e kaydet (cloud, yavaş ~500ms ama arka planda)
  /// 
  /// **Kullanıcı Deneyimi:**
  /// - Kullanıcı "Kaydet" butonuna basar
  /// - Anında UI güncellenir (Hive'dan)
  /// - Arka planda Firebase'e de kaydedilir
  /// - İnternet yoksa sadece Hive'a kaydeder
  /// 
  /// **Örnek:**
  /// ```dart
  /// final newCar = Vehicle(
  ///   id: 'v123',
  ///   plate: '34ABC123',
  ///   status: VehicleStatus.parked,
  /// );
  /// await repo.addVehicle(newCar);
  /// ```
  @override
  Future<void> addVehicle(Vehicle vehicle) async {
    // 1️⃣ LOKAL: Hive'a kaydet (çok hızlı!)
    await _vehicleBox.put(vehicle.id, vehicle);
    
    // 2️⃣ CLOUD: Firebase'e kaydet (arka planda, yavaş ama güvenli)
    // Not: SyncService içinde internet kontrolü var
    await SyncService.setData(
      collection: _collection,
      docId: vehicle.id,
      data: vehicle.toJson(), // Vehicle'ı Map'e çevir
    );
  }

  @override
  Future<void> updateVehicle(Vehicle vehicle) async {
    // 1. Hive'a yaz (lokal)
    await _vehicleBox.put(vehicle.id, vehicle);
    
    // 2. Firebase'e yaz (cloud) - arka planda
    await SyncService.setData(
      collection: _collection,
      docId: vehicle.id,
      data: vehicle.toJson(),
    );
  }

  @override
  Future<void> deleteVehicle(String id) async {
    // 1. Hive'dan sil (lokal)
    await _vehicleBox.delete(id);
    
    // 2. Firebase'den sil (cloud) - arka planda
    await SyncService.deleteData(
      collection: _collection,
      docId: id,
    );
  }

  @override
  Future<void> syncFromCloud() async {
    if (!SyncService.isOnline) {
      print('📴 Offline: Cloud sync atlandı');
      return;
    }

    try {
      // Cloud'dan tüm veriyi çek
      final cloudData = await SyncService.getAllData(_collection);
      
      // Her bir veriyi Hive'a kaydet
      for (final data in cloudData) {
        try {
          final vehicle = Vehicle.fromJson(data);
          await _vehicleBox.put(vehicle.id, vehicle);
        } catch (e) {
          print('❌ Vehicle sync hatası: $e');
        }
      }
      
      print('✅ Cloud sync tamamlandı: ${cloudData.length} araç');
    } catch (e) {
      print('❌ Cloud sync hatası: $e');
    }
  }
}

// Eski isim için alias (geriye uyumluluk)
class HiveVehicleRepository extends HybridVehicleRepository {}
