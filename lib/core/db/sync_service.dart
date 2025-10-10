import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// ☁️ Firebase Senkronizasyon Servisi
/// 
/// Bu servis, lokal veritabanı (Hive) ile cloud veritabanı (Firebase) 
/// arasında senkronizasyon sağlar.
/// 
/// **Hybrid Database Mimarisi:**
/// - Hive (Lokal) → Hızlı, offline çalışır
/// - Firebase (Cloud) → Yedek, multi-device sync
/// 
/// **Nasıl Çalışır?**
/// 1. Yazma: Hem Hive'a hem Firebase'e kaydedilir
/// 2. Okuma: Önce Hive'dan (çok hızlı)
/// 3. Sync: Uygulama açılışında Firebase'den Hive'a
class SyncService {
  // Firebase Firestore bağlantısı (cloud database)
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Internet bağlantısı kontrolü
  static final Connectivity _connectivity = Connectivity();
  
  // Internet durumu (true = online, false = offline)
  static bool _isOnline = false;
  
  // Internet değişikliklerini dinleyen stream
  static StreamSubscription? _connectivitySubscription;

  /// 🚀 Servis Başlatma
  /// 
  /// **Ne Yapar?**
  /// 1. Mevcut internet durumunu kontrol eder
  /// 2. Internet değişikliklerini dinlemeye başlar
  /// 
  /// **Ne Zaman Çağrılır?**
  /// - main.dart'ta, uygulama başlangıcında
  static Future<void> initialize() async {
    // 1️⃣ İlk internet durumunu kontrol et
    final connectivityResult = await _connectivity.checkConnectivity();
    _isOnline = connectivityResult.first != ConnectivityResult.none;
    
    // 2️⃣ Internet değişikliklerini dinle
    // Örnek: WiFi → Mobile Data, Online → Offline
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      // Yeni durumu güncelle
      _isOnline = results.first != ConnectivityResult.none;
      
      // Console'a yazdır (debug için)
      print('📡 İnternet durumu: ${_isOnline ? "Online ✅" : "Offline ❌"}');
    });
  }

  /// ⏹️ Servisi Durdur
  /// 
  /// **Ne Yapar?**
  /// - Internet dinleyiciyi kapatır
  /// - Memory leak'i önler
  /// 
  /// **Ne Zaman Çağrılır?**
  /// - Uygulama kapanırken (nadiren kullanılır)
  static void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// 📶 Online Durumu Kontrol Et
  /// 
  /// **Kullanım:**
  /// ```dart
  /// if (SyncService.isOnline) {
  ///   // Firebase'e kaydet
  /// } else {
  ///   // Sadece Hive'a kaydet
  /// }
  /// ```
  static bool get isOnline => _isOnline;

  /// 📂 Firestore Collection Referansı
  /// 
  /// **Collection Nedir?**
  /// - SQL'deki "table" gibi
  /// - Örnek: 'vehicles', 'operations', 'counters'
  /// 
  /// **Kullanım:**
  /// ```dart
  /// final ref = SyncService.collection('vehicles');
  /// ```
  static CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  /// ✍️ Veri Ekle/Güncelle (Firebase'e)
  /// 
  /// **Parametreler:**
  /// - collection: Hangi collection'a? (örn: 'vehicles')
  /// - docId: Doküman ID (örn: 'vehicle-123')
  /// - data: Kaydedilecek veri (Map formatında)
  /// 
  /// **Çalışma Mantığı:**
  /// 1. Online değilse → İşlemi atla (sadece Hive'da kalır)
  /// 2. Online ise → Firebase'e kaydet
  /// 
  /// **SetOptions.merge Nedir?**
  /// - Mevcut veriyi korur
  /// - Sadece değişen alanları günceller
  /// - Örnek: Sadece 'status' değişti → diğer alanlar aynen kalır
  /// 
  /// **Örnek Kullanım:**
  /// ```dart
  /// await SyncService.setData(
  ///   collection: 'vehicles',
  ///   docId: 'vehicle-123',
  ///   data: {'plate': '34ABC123', 'status': 'parked'},
  /// );
  /// ```
  static Future<void> setData({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    // Offline ise Firebase'e yazma
    if (!_isOnline) {
      print('📴 Offline: Firestore\'a yazılamadı - $collection/$docId');
      return; // Fonksiyondan çık
    }

    try {
      // Firebase'e yaz
      await _firestore.collection(collection).doc(docId).set(
        data,
        SetOptions(merge: true), // Mevcut veriyi koru, sadece güncelle
      );
      print('☁️ Firestore\'a yazıldı: $collection/$docId');
    } catch (e) {
      // Hata olursa uygulamayı çökertme, sadece logla
      print('❌ Firestore yazma hatası: $e');
    }
  }

  /// 🗑️ Veri Sil (Firebase'den)
  /// 
  /// **Ne Yapar?**
  /// - Firebase'deki dokümanı siler
  /// - Hive'daki veri silinmez (Repository'de ayrı yapılır)
  /// 
  /// **Örnek Kullanım:**
  /// ```dart
  /// await SyncService.deleteData(
  ///   collection: 'vehicles',
  ///   docId: 'vehicle-123',
  /// );
  /// ```
  static Future<void> deleteData({
    required String collection,
    required String docId,
  }) async {
    // Offline ise Firebase'den silme
    if (!_isOnline) {
      print('📴 Offline: Firestore\'dan silinemedi - $collection/$docId');
      return;
    }

    try {
      // Firebase'den sil
      await _firestore.collection(collection).doc(docId).delete();
      print('🗑️ Firestore\'dan silindi: $collection/$docId');
    } catch (e) {
      print('❌ Firestore silme hatası: $e');
    }
  }

  /// 📥 Tüm Veriyi Çek (Firebase'den)
  /// 
  /// **Ne Zaman Kullanılır?**
  /// - Uygulama ilk açılışında
  /// - Manuel refresh işleminde
  /// - Yeni cihazda ilk sync'te
  /// 
  /// **Nasıl Çalışır?**
  /// 1. Firebase'den tüm dokümanları çek
  /// 2. Her dokümanı Map'e dönüştür
  /// 3. List<Map> olarak döndür
  /// 
  /// **Örnek Kullanım:**
  /// ```dart
  /// final vehicles = await SyncService.getAllData('vehicles');
  /// // vehicles = [
  /// //   {'id': 'v1', 'plate': '34ABC123', ...},
  /// //   {'id': 'v2', 'plate': '06XYZ456', ...},
  /// // ]
  /// ```
  static Future<List<Map<String, dynamic>>> getAllData(String collection) async {
    // Offline ise boş liste döndür
    if (!_isOnline) {
      print('📴 Offline: Firestore\'dan okunamadı - $collection');
      return [];
    }

    try {
      // 1️⃣ Firebase'den tüm dokümanları çek
      final snapshot = await _firestore.collection(collection).get();
      
      // 2️⃣ Her dokümanı Map'e dönüştür
      return snapshot.docs.map((doc) => {
        'id': doc.id,           // Doküman ID'sini ekle
        ...doc.data(),          // Doküman verisini ekle (spread operator)
      }).toList();
    } catch (e) {
      print('❌ Firestore okuma hatası: $e');
      return []; // Hata durumunda boş liste döndür
    }
  }

  /// 📡 Real-time Veri Akışı (Stream)
  /// 
  /// **Stream Nedir?**
  /// - Sürekli veri akışı (Netflix gibi)
  /// - Veri değiştiğinde otomatik güncellenir
  /// 
  /// **Ne Zaman Kullanılır?**
  /// - Multi-user senaryolarda
  /// - Real-time güncelleme gerektiğinde
  /// - Örnek: Bir kullanıcı veri ekler → diğer kullanıcı anında görür
  /// 
  /// **Örnek Kullanım:**
  /// ```dart
  /// SyncService.streamData('vehicles').listen((vehicles) {
  ///   print('Yeni veri geldi: ${vehicles.length} araç');
  ///   // UI'ı güncelle
  /// });
  /// ```
  /// 
  /// **Not:** Şu an aktif kullanılmıyor, gelecekte eklenebilir
  static Stream<List<Map<String, dynamic>>> streamData(String collection) {
    return _firestore.collection(collection).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList(),
    );
  }
}

/*
 * 📚 ÖĞRENME NOTU: Offline-First Mimari
 * 
 * Geleneksel Yaklaşım (Server-First):
 * ❌ Internet yok → Uygulama kullanılamaz
 * ❌ Yavaş internet → Her işlem yavaş
 * ❌ Server çöktü → Uygulama çalışmaz
 * 
 * Offline-First Yaklaşım (Bizim Sistemimiz):
 * ✅ Internet yok → Hive'dan çalışır (hızlı)
 * ✅ Yavaş internet → Kullanıcı fark etmez
 * ✅ Server çöktü → Uygulama normal çalışır
 * ✅ Online olunca → Otomatik sync olur
 * 
 * Sonuç: Her zaman hızlı ve çalışır durumda! 🚀
 */

/*
 * 📚 ÖĞRENME NOTU: Firebase vs SQL
 * 
 * SQL (Geleneksel):
 * - İlişkisel (tablolar arası bağlantılar)
 * - JOIN sorguları
 * - Schema zorunlu
 * - Örnek: MySQL, PostgreSQL
 * 
 * Firestore (NoSQL):
 * - Doküman bazlı (JSON gibi)
 * - JOIN yok (her doküman bağımsız)
 * - Schema esnek
 * - Real-time sync var
 * 
 * Hangi Durumlarda?
 * - SQL: Kompleks sorgular, raporlama
 * - Firestore: Real-time, mobile, hızlı prototipleme
 */

/*
 * 📚 ÖĞRENME NOTU: Spread Operator (...)
 * 
 * Spread operator ne işe yarar?
 * 
 * Örnek:
 * ```dart
 * final data = {'name': 'Ali', 'age': 25};
 * final newData = {
 *   'id': '123',
 *   ...data,  // ← data'nın tüm içeriğini buraya kopyala
 * };
 * 
 * Sonuç:
 * newData = {'id': '123', 'name': 'Ali', 'age': 25}
 * ```
 * 
 * Neden kullanıyoruz?
 * - Kod daha temiz
 * - Manuel kopyalama gereksiz
 * - Hata riski düşük
 */
