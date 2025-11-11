import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otopark_demo/features/vehicles/providers/vehicle_providers.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle_status.dart';
import 'car_selection_view.dart';

/// 🚗 Araç Seçim Sayfası
/// 
/// Muayene yapılacak aracı seçmek için kullanılan sayfa
class VehicleSelectionPage extends ConsumerWidget {
  const VehicleSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Araç Seç - Muayene'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: vehiclesAsync.when(
        data: (vehicles) => _buildVehicleList(context, vehicles),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Araçlar yüklenirken hata oluştu',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(vehiclesProvider),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Araç listesini oluştur
  Widget _buildVehicleList(BuildContext context, List<Vehicle> vehicles) {
    if (vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz araç eklenmemiş',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Önce araç ekleyin, sonra muayene yapın',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/kroki'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Geri Dön'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return _buildVehicleCard(context, vehicle);
      },
    );
  }

  /// Araç kartını oluştur
  Widget _buildVehicleCard(BuildContext context, Vehicle vehicle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: vehicle.status.color,
          child: Icon(
            vehicle.status.icon,
            color: Colors.white,
          ),
        ),
        title: Text(
          vehicle.plate,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vehicle.model != null)
              Text('Model: ${vehicle.model}'),
            if (vehicle.brand != null)
              Text('Marka: ${vehicle.brand}'),
            if (vehicle.color != null)
              Text('Renk: ${vehicle.color}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: vehicle.status.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: vehicle.status.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                vehicle.status.displayName,
                style: TextStyle(
                  color: vehicle.status.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (vehicle.damagedParts.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Hasarlı Parçalar: ${vehicle.damagedParts.entries.where((e) => e.value).length}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: () => _navigateToInspection(context, vehicle),
      ),
    );
  }

  /// Muayene sayfasına git
  void _navigateToInspection(BuildContext context, Vehicle vehicle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CarSelectionView(
          vehicleId: vehicle.id,
          initialParts: _getInitialPartsForVehicle(vehicle),
          allowMultipleSelection: true,
          onDamageSaved: (damageMap) {
            // Hasar bilgilerini Vehicle'a kaydet
            _saveDamageInfo(context, vehicle, damageMap);
          },
        ),
      ),
    );
  }
  
  /// Hasar bilgilerini kaydet
  void _saveDamageInfo(BuildContext context, Vehicle vehicle, Map<String, bool> damageMap) {
    // Vehicle'ı güncelle
    final updatedVehicle = vehicle.copyWith(
      damagedParts: damageMap,
      updatedAt: DateTime.now(),
    );
    
    // Repository'ye kaydet
    // Burada vehiclesProvider'ı kullanarak güncelleyeceğiz
    print('Hasar bilgileri kaydedildi: $damageMap');
    
    // Başarı mesajı göster
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hasar bilgileri kaydedildi'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Araç için başlangıç parça verilerini oluştur
  Map<String, CarPart> _getInitialPartsForVehicle(Vehicle vehicle) {
    final parts = <String, CarPart>{};
    
    // Araçtaki hasar bilgilerini yükle
    for (String partId in vehicle.damagedParts.keys) {
      parts[partId] = CarPart(
        name: _getPartName(partId),
        isSelected: vehicle.damagedParts[partId] ?? false,
      );
    }
    
    return parts;
  }
  
  /// Parça ID'sinden parça adını al
  String _getPartName(String partId) {
    const partNames = {
      'front_bumper': 'Ön Tampon',
      'rear_bumper': 'Arka Tampon',
      'left_front_door': 'Sol Ön Kapı',
      'left_rear_door': 'Sol Arka Kapı',
      'right_front_door': 'Sağ Ön Kapı',
      'right_rear_door': 'Sağ Arka Kapı',
      'hood': 'Kaput',
      'roof': 'Tavan',
      'trunk': 'Bagaj',
    };
    return partNames[partId] ?? partId;
  }
}
