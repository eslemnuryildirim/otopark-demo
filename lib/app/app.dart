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
    // Widget build edildikten sonra çalıştır (ref hazır olmalı)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialSync();
    });
  }

  Future<void> _initialSync() async {
    try {
      // 1. Önce veri temizliği yap (orphan slot/vehicle temizle)
      await _cleanupData();
      
      // 2. Vehicles sync
      final vehicleRepo = ref.read(vehicleRepositoryProvider);
      await vehicleRepo.syncFromCloud();
      
      // 3. Provider'ı yenile (yeni verileri göster)
      ref.invalidate(vehiclesProvider);
      
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
        // 🎨 PROFESYONEl AMBER-KOYU GRİ TEMA
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFA726), // Amber/Turuncu
          primary: const Color(0xFFFFA726), // Ana amber
          secondary: const Color(0xFFFFB74D), // Açık amber
          surface: const Color(0xFF263238), // Koyu gri (Blue Grey 900)
          background: const Color(0xFF1C1C1C), // Çok koyu gri
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1C1C1C), // Koyu gri arka plan
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF263238), // Blue Grey 900
          foregroundColor: Color(0xFFFFA726), // Amber yazı
          elevation: 2,
          centerTitle: true, // Başlık ortada
        ),
        cardTheme: CardThemeData(
          elevation: 3,
          color: const Color(0xFF2C2C2C), // Koyu gri kartlar
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFA726), // Amber FAB
          foregroundColor: Color(0xFF263238), // Koyu gri ikon
          elevation: 6,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFA726), // Amber buton
            foregroundColor: const Color(0xFF263238), // Koyu gri yazı
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFFA726), // Amber yazı
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF455A64)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFFFA726), width: 2),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFECEFF1)), // Açık gri yazı
          bodyMedium: TextStyle(color: Color(0xFFB0BEC5)), // Orta gri
          titleLarge: TextStyle(color: Color(0xFFECEFF1), fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFFFA726), // Amber ikonlar
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF263238), // Blue Grey 900
          selectedItemColor: Color(0xFFFFA726), // Amber (seçili)
          unselectedItemColor: Color(0xFF78909C), // Gri (seçilmemiş)
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
        dividerColor: const Color(0xFF37474F), // Koyu gri divider
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF37474F),
          labelStyle: const TextStyle(color: Color(0xFFB0BEC5)),
          selectedColor: const Color(0xFFFFA726),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

