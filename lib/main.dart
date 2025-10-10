import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/app/app.dart';
import 'package:otopark_demo/core/db/hive_init.dart';
import 'package:otopark_demo/core/db/firebase_init.dart';
import 'package:otopark_demo/core/db/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Firebase'i başlat
  await FirebaseInit.initialize();
  
  // 2. Hive'ı başlat
  await initHive();
  
  // 3. Sync servisini başlat
  await SyncService.initialize();
  
  runApp(const ProviderScope(child: OtoparkApp()));
}
