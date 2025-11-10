import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase başlatma
class FirebaseInit {
  static Future<void> initialize() async {
    try {
      // Firebase zaten başlatılmış mı kontrol et
      if (Firebase.apps.isNotEmpty) {
        print('✅ Firebase zaten başlatılmış');
        return;
      }
      
      await Firebase.initializeApp();
      print('✅ Firebase.initializeApp() başarılı');
      
      // Firestore ayarları
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true, // Offline destek
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      print('✅ Firestore ayarları yapıldı');
    } catch (e, stackTrace) {
      print('❌ Firebase başlatma hatası: $e');
      print('Stack trace: $stackTrace');
      rethrow; // Hatayı yukarı fırlat
    }
  }
}

