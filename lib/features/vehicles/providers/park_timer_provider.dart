import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/features/vehicles/providers/vehicle_providers.dart';

/// Gerçek zamanlı park süresi güncellemesi için timer provider
final parkTimerProvider = StreamProvider.autoDispose<DateTime>((ref) {
  return Stream.periodic(
    const Duration(seconds: 30), // Her 30 saniyede bir güncelle
    (_) => DateTime.now(),
  );
});

/// Belirli bir araç için park süresini hesaplayan provider
final vehicleParkDurationProvider = Provider.family<int?, String>((ref, vehicleId) {
  // Timer'ı dinle (her 30 saniyede tetiklenir)
  ref.watch(parkTimerProvider);
  
  // Aracı bul
  final vehiclesAsync = ref.watch(vehiclesProvider);
  final vehicle = vehiclesAsync.value?.where((v) => v.id == vehicleId).firstOrNull;
  
  if (vehicle == null || vehicle.parkStartAt == null) {
    return null;
  }
  
  // Şu anki süreyi hesapla
  return DateTime.now().difference(vehicle.parkStartAt!).inMinutes;
});

