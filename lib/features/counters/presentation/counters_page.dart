import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/features/counters/providers/counter_providers.dart';
import 'package:otopark_demo/features/counters/domain/counters.dart';
import 'package:otopark_demo/features/vehicles/providers/vehicle_providers.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle_status.dart';

class CountersPage extends ConsumerWidget {
  const CountersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countersAsync = ref.watch(countersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sayaçlar'),
        // Theme'den otomatik renk alır (sarı yazı, koyu gri arka plan)
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Sayaçları yenile (gerçek araç sayısına göre güncelle)
              ref.invalidate(countersProvider);
            },
            tooltip: 'Sayaçları yenile',
          ),
        ],
      ),
      body: countersAsync.when(
        data: (counters) {
          // Negatif değerleri 0'a çek (güvenlik kontrolü)
          final safeCounters = Counters(
            totalPark: counters.totalPark < 0 ? 0 : counters.totalPark,
            totalMaintenance: counters.totalMaintenance < 0 ? 0 : counters.totalMaintenance,
            totalWash: counters.totalWash < 0 ? 0 : counters.totalWash,
            totalDelivered: counters.totalDelivered < 0 ? 0 : counters.totalDelivered,
            activePark: counters.activePark < 0 ? 0 : counters.activePark,
            activeMaintenance: counters.activeMaintenance < 0 ? 0 : counters.activeMaintenance,
            activeWash: counters.activeWash < 0 ? 0 : counters.activeWash,
          );
          
          // Teslim edilen araçları al
          final vehiclesAsync = ref.watch(vehiclesProvider);
          
          return vehiclesAsync.when(
            data: (vehicles) {
              final deliveredVehicles = vehicles
                  .where((v) => v.status == VehicleStatus.delivered)
                  .toList()
                ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // En yeni önce
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Aktif sayaçlar
                    Text(
                      'Şu An Aktif',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _buildActiveCounter(
                            context,
                            'Parkta',
                            safeCounters.activePark,
                            Icons.local_parking,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActiveCounter(
                            context,
                            'Bakımda',
                            safeCounters.activeMaintenance,
                            Icons.build_circle,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActiveCounter(
                            context,
                            'Yıkamada',
                            safeCounters.activeWash,
                            Icons.local_car_wash,
                            Colors.lightBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActiveCounter(
                            context,
                            'Teslim Edilenler',
                            safeCounters.totalDelivered,
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Teslim edilen araçlar listesi
                    if (deliveredVehicles.isNotEmpty) ...[
                      Text(
                        'Teslim Edilen Araçlar',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: deliveredVehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = deliveredVehicles[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.withOpacity(0.2),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                              ),
                              title: Text(
                                vehicle.plate,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${vehicle.brand ?? ''} ${vehicle.model ?? ''}'.trim().isEmpty
                                    ? 'Marka/Model bilgisi yok'
                                    : '${vehicle.brand ?? ''} ${vehicle.model ?? ''}'.trim(),
                              ),
                              trailing: Text(
                                _formatDate(vehicle.updatedAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'Henüz teslim edilen araç yok',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Araçlar yüklenirken hata: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }

  Widget _buildActiveCounter(
    BuildContext context,
    String label,
    int count,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} dk önce';
      }
      return '${difference.inHours} saat önce';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
