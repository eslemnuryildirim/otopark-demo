import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'package:otopark_demo/features/vehicles/providers/vehicle_providers.dart';
import 'package:otopark_demo/core/db/cleanup_service.dart';

class OtoparkApp extends ConsumerStatefulWidget {
  const OtoparkApp({super.key});

  @override
  ConsumerState<OtoparkApp> createState() => _OtoparkAppState();
}

class _OtoparkAppState extends ConsumerState<OtoparkApp> {
  @override
  void initState() {
    super.initState();
    // İlk açılışta cloud'dan sync yap (arka planda)
    _initialSync();
  }

  Future<void> _initialSync() async {
    try {
      // 1. Önce veri temizliği yap (orphan slot/vehicle temizle)
      await _cleanupData();
      
      // 2. Vehicles sync
      final vehicleRepo = ref.read(vehicleRepositoryProvider);
      await vehicleRepo.syncFromCloud();
      
      // Diğer sync'ler de buraya eklenebilir
      // await countersRepo.syncFromCloud();
      // await operationsRepo.syncFromCloud();
      
      print('✅ İlk sync tamamlandı');
    } catch (e) {
      print('❌ İlk sync hatası: $e');
    }
  }
  
  Future<void> _cleanupData() async {
    try {
      // Orphan verileri temizle
      await CleanupService.cleanupAll();
    } catch (e) {
      print('❌ Cleanup hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Otopark Yönetim Sistemi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

