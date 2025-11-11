import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/features/vehicles/providers/vehicle_providers.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle_status.dart';
import 'expertiz_detail_page.dart';

/// Ekspertiz ana sayfası - Kroki gibi ayrı sayfa
class ExpertizPage extends ConsumerStatefulWidget {
  const ExpertizPage({super.key});

  @override
  ConsumerState<ExpertizPage> createState() => _ExpertizPageState();
}

class _ExpertizPageState extends ConsumerState<ExpertizPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Araç Ekspertizi'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _syncFromFirebase(context),
            tooltip: 'Firebase\'den senkronize et',
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: vehiclesAsync.when(
        data: (vehicles) {
          // Debug: Kaç araç geldi?
          print('📊 Ekspertiz sayfası: Toplam ${vehicles.length} araç geldi');
          
          final filteredVehicles = vehicles.where((vehicle) {
            return vehicle.plate.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (vehicle.brand?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                (vehicle.model?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
          }).toList();

          print('🔍 Arama sonrası: ${filteredVehicles.length} araç gösteriliyor');

          if (filteredVehicles.isEmpty) {
            return _buildEmptyState();
          }

          return _buildVehiclesList(filteredVehicles);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Hata: $error'),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment_outlined,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'Henüz araç bulunmuyor' : 'Arama sonucu bulunamadı',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '"$_searchQuery" için sonuç yok',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVehiclesList(List<Vehicle> vehicles) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return _buildVehicleCard(vehicle);
      },
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[800],
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: vehicle.status.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: vehicle.status.color,
              width: 2,
            ),
          ),
          child: Icon(
            vehicle.status.icon,
            color: vehicle.status.color,
            size: 24,
          ),
        ),
        title: Text(
          vehicle.plate,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${vehicle.brand ?? ''} ${vehicle.model ?? ''}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: vehicle.status.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
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
                if (vehicle.currentParkSlotId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Slot: ${vehicle.currentParkSlotId}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ekspertiz durumu göstergesi
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.assessment,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
        onTap: () => _showExpertizDetail(vehicle.id, vehicle.plate),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Araç Ara'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Plaka, marka veya model yazın...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.of(context).pop();
            },
            child: const Text('Temizle'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showExpertizDetail(String vehicleId, String vehiclePlate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpertizDetailPage(
        vehicleId: vehicleId,
        vehiclePlate: vehiclePlate,
      ),
    );
  }

  /// Firebase'den araçları senkronize et
  Future<void> _syncFromFirebase(BuildContext context) async {
    // Loading göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 1. Firebase'den sync yap
      final vehicleRepo = ref.read(vehicleRepositoryProvider);
      await vehicleRepo.syncFromCloud();
      
      // 2. Provider'ı yenile (yeni verileri çek)
      ref.invalidate(vehiclesProvider);
      
      // 3. Başarı mesajı göster
      if (context.mounted) {
        Navigator.of(context).pop(); // Loading'i kapat
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Firebase\'den araçlar senkronize edildi'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Sync hatası: $e');
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Loading'i kapat
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Sync hatası: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
