import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/app/app.dart';
import 'package:otopark_demo/core/db/hive_init.dart';
import 'package:otopark_demo/core/db/firebase_init.dart';
import 'package:otopark_demo/core/db/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Firebase'i başlat (hata olursa devam et)
  try {
    await FirebaseInit.initialize();
    print('✅ Firebase başlatıldı');
  } catch (e) {
    print('⚠️ Firebase başlatılamadı (offline mode): $e');
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
  
  runApp(const ProviderScope(child: OtoparkApp()));
}
