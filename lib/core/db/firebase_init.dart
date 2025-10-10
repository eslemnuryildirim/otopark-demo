import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase başlatma
class FirebaseInit {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    // Firestore ayarları
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true, // Offline destek
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}

