import 'package:hive_flutter/hive_flutter.dart';
import 'package:otopark_demo/features/park_slots/domain/park_slot.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle.dart';

/// 🧹 Veri Temizleme Servisi
/// 
/// Bu servis, veritabanındaki tutarsızlıkları (orphan data) temizler.
/// 
/// **Orphan Data Nedir?**
/// Örnek: Bir araç silinmiş ama park slot'u hala "dolu" gösteriyorsa,
/// bu slot "orphan" (sahipsiz) duruma gelmiştir.
/// 
/// **Ne Zaman Çalışır?**
/// - Uygulama her açıldığında otomatik çalışır
/// - Veri tutarlılığını sağlar
class CleanupService {
  
  /// 🔍 Orphan Slot Temizleme
  /// 
  /// **Problem:** Araç silinmiş ama slot hala "dolu" gösteriliyor
  /// 
  /// **Çözüm Adımları:**
  /// 1. Tüm mevcut araçların ID'lerini topla
  /// 2. Her slot'u kontrol et
  /// 3. Eğer slot dolu ama araç yoksa → slot'u boşalt
  /// 
  /// **Örnek Senaryo:**
  /// - Araç A1 slot'unda
  /// - Araç silindi (ama slot güncellemesi unutuldu)
  /// - Bu fonksiyon çalışır → A1 slot'unu boşaltır
  static Future<void> cleanupOrphanSlots() async {
    try {
      // 1️⃣ Veritabanı bağlantıları
      final vehicleBox = Hive.box<Vehicle>('vehicles'); // Araç veritabanı
      final slotBox = Hive.box<ParkSlot>('park_slots'); // Slot veritabanı
      
      // 2️⃣ Mevcut araç ID'lerini Set'e topla
      // Set kullanıyoruz çünkü contains() operasyonu çok hızlı (O(1))
      final activeVehicleIds = vehicleBox.values.map((v) => v.id).toSet();
      // Örnek: {'vehicle-123', 'vehicle-456', 'vehicle-789'}
      
      // 3️⃣ Tüm slotları tek tek kontrol et
      for (final slot in slotBox.values) {
        // Slot dolu mu VE bir araca atanmış mı?
        if (slot.isOccupied && slot.vehicleId != null) {
          
          // 4️⃣ Bu slot'taki araç hala mevcut mu kontrol et
          if (!activeVehicleIds.contains(slot.vehicleId)) {
            // ⚠️ ORPHAN BULUNDU! Araç yok ama slot dolu gösteriliyor
            print('🧹 Orphan slot bulundu: ${slot.id} (Araç: ${slot.vehicleId}) - temizleniyor...');
            
            // 5️⃣ Slot'u temizle (yeni bir slot objesi oluştur)
            final cleanedSlot = ParkSlot(
              id: slot.id,               // ID aynı kalsın
              label: slot.label,         // Label aynı kalsın
              isServiceArea: slot.isServiceArea, // Tip aynı kalsın
              isOccupied: false,         // ✅ BOŞ olarak işaretle
              vehicleId: null,           // ✅ Araç referansını kaldır
            );
            
            // 6️⃣ Güncellenmiş slot'u veritabanına kaydet
            await slotBox.put(slot.id, cleanedSlot);
          }
        }
      }
      
      print('✅ Slot temizleme tamamlandı');
    } catch (e) {
      // Hata olursa uygulamayı çökertme, sadece logla
      print('❌ Cleanup hatası: $e');
    }
  }
  
  /// 🔍 Orphan Vehicle Temizleme
  /// 
  /// **Problem:** Slot silinmiş ama araç hala o slot'a referans veriyor
  /// 
  /// **Çözüm Adımları:**
  /// 1. Tüm mevcut slot ID'lerini topla
  /// 2. Her aracı kontrol et
  /// 3. Eğer araç var olmayan bir slot'a referans veriyorsa → referansı sil
  /// 
  /// **Örnek Senaryo:**
  /// - Araç "A1" slot'una atanmış
  /// - A1 slot'u yanlışlıkla silindi
  /// - Bu fonksiyon çalışır → Araçtan A1 referansını kaldırır
  static Future<void> cleanupOrphanVehicles() async {
    try {
      // 1️⃣ Veritabanı bağlantıları
      final vehicleBox = Hive.box<Vehicle>('vehicles');
      final slotBox = Hive.box<ParkSlot>('park_slots');
      
      // 2️⃣ Mevcut slot ID'lerini Set'e topla
      final activeSlotIds = slotBox.values.map((s) => s.id).toSet();
      // Örnek: {'A1', 'A2', 'B1', 'YIK1', ...}
      
      // 3️⃣ Tüm araçları kontrol et
      for (final vehicle in vehicleBox.values) {
        // Araç bir slot'a atanmış mı?
        if (vehicle.currentParkSlotId != null) {
          
          // 4️⃣ Bu slot hala mevcut mu kontrol et
          if (!activeSlotIds.contains(vehicle.currentParkSlotId)) {
            // ⚠️ ORPHAN BULUNDU! Slot yok ama araç ona referans veriyor
            print('🧹 Orphan vehicle bulundu: ${vehicle.id} (Slot: ${vehicle.currentParkSlotId}) - temizleniyor...');
            
            // 5️⃣ Araçtan slot referansını kaldır
            final cleanedVehicle = vehicle.copyWith(
              clearParkSlotId: true,   // ✅ Park slot ID'sini temizle
              clearParkStartAt: true,  // ✅ Park başlangıç zamanını temizle
            );
            
            // 6️⃣ Güncellenmiş aracı veritabanına kaydet
            await vehicleBox.put(vehicle.id, cleanedVehicle);
          }
        }
      }
      
      print('✅ Vehicle temizleme tamamlandı');
    } catch (e) {
      print('❌ Cleanup hatası: $e');
    }
  }
  
  /// 🚀 Ana Temizleme Fonksiyonu
  /// 
  /// Bu fonksiyon tüm temizleme işlemlerini sırayla çalıştırır.
  /// 
  /// **Çalışma Sırası:**
  /// 1. Orphan slot'ları temizle (boşalt)
  /// 2. Orphan vehicle'ları temizle (referansları kaldır)
  /// 
  /// **Ne Zaman Kullanılır?**
  /// - Uygulama açılışında (app.dart'ta otomatik çağrılır)
  /// - Manuel cleanup gerektiğinde
  /// 
  /// **Performans:** 
  /// - Genellikle 100ms altında tamamlanır
  /// - Arka planda çalışır, UI'ı bloklamaz
  static Future<void> cleanupAll() async {
    print('🧹 Veri temizleme başlatılıyor...');
    
    // 1. Slot orphan'larını temizle
    await cleanupOrphanSlots();
    
    // 2. Vehicle orphan'larını temizle
    await cleanupOrphanVehicles();
    
    print('✅ Veri temizleme tamamlandı');
  }
}

/*
 * 📚 ÖĞRENME NOTU: Neden Set Kullanıyoruz?
 * 
 * List vs Set Performans Karşılaştırması:
 * 
 * List.contains():
 * - O(n) - Her aramada tüm listeyi tarar
 * - 1000 araç varsa → 1000 işlem
 * 
 * Set.contains():
 * - O(1) - Hash map ile direkt bulur
 * - 1000 araç varsa → 1 işlem!
 * 
 * Sonuç: 1000 slot kontrolü için
 * - List: 1,000,000 işlem (1000 x 1000)
 * - Set: 1,000 işlem (1000 x 1)
 * 
 * Fark: ~1000x daha hızlı! ⚡
 */

/*
 * 📚 ÖĞRENME NOTU: Neden copyWith Kullanıyoruz?
 * 
 * Flutter'da immutability (değişmezlik) prensibi:
 * 
 * ❌ YANLIŞ:
 * vehicle.currentParkSlotId = null;  // Direkt değiştiremezsiniz!
 * 
 * ✅ DOĞRU:
 * final updated = vehicle.copyWith(clearParkSlotId: true);
 * 
 * Neden?
 * - State management güvenliği
 * - UI değişiklik algılama
 * - Undo/Redo kolaylığı
 * - Bug'ları önler
 */

/*
 * 📚 ÖĞRENME NOTU: Async/Await Nedir?
 * 
 * await: "Bekle, bu iş bitsin sonra devam et"
 * async: "Bu fonksiyon asenkron çalışır"
 * 
 * Örnek:
 * 
 * await cleanupOrphanSlots();     // ← Bu biter
 * await cleanupOrphanVehicles();  // ← Sonra bu başlar
 * 
 * Neden async?
 * - Veritabanı işlemleri zaman alır
 * - UI donmasını önler
 * - Kullanıcı deneyimi bozulmaz
 */
