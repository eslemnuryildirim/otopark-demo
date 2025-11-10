import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/app/app.dart';
import 'package:otopark_demo/core/db/hive_init.dart';
import 'package:otopark_demo/core/db/firebase_init.dart';
import 'package:otopark_demo/core/db/sync_service.dart';
import 'package:otopark_demo/core/services/ocr_server_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Firebase'i başlat (hata olursa devam et)
  try {
    await FirebaseInit.initialize();
    print('✅ Firebase başlatıldı');
  } catch (e, stackTrace) {
    print('⚠️ Firebase başlatılamadı (offline mode): $e');
    print('Stack trace: $stackTrace');
  }
  
  // 2. Hive'ı başlat
  await initHive();
  
  // 3. Sync servisini başlat (hata olursa devam et)
  try {
    await SyncService.initialize();
    print('✅ Sync servisi başlatıldı');
  } catch (e) {
    print('⚠️ Sync servisi başlatılamadı (offline mode): $e');
  }
  
  // 4. OCR sunucusunu başlat (arka planda, hata olursa devam et)
  try {
    // Arka planda başlat (await etme, uygulama başlamasını beklemesin)
    OcrServerManager.startServerIfNeeded().then((started) {
      if (started) {
        print('✅ OCR sunucusu otomatik başlatıldı');
      } else {
        print('⚠️ OCR sunucusu başlatılamadı (manuel başlatılabilir)');
      }
    });
  } catch (e) {
    print('⚠️ OCR sunucusu başlatılamadı: $e');
  }
  
  runApp(const ProviderScope(child: OtoparkApp()));
}
