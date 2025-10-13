import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/features/counters/providers/counter_providers.dart';

class CountersPage extends ConsumerWidget {
  const CountersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countersAsync = ref.watch(countersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sayaçlar'),
        // Theme'den otomatik renk alır (sarı yazı, koyu gri arka plan)
      ),
      body: countersAsync.when(
        data: (counters) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Toplam sayaçlar
                Text(
                  'Toplam İşlemler',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.local_parking_rounded, color: Colors.blue),
                    title: const Text('Toplam Park Edilen Araç'),
                    trailing: Text(
                      '${counters.totalPark}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.build_circle_rounded, color: Colors.orange),
                    title: const Text('Toplam Bakım İşlemi'),
                    trailing: Text(
                      '${counters.totalMaintenance}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.local_car_wash_rounded, color: Colors.lightBlue),
                    title: const Text('Toplam Yıkama İşlemi'),
                    trailing: Text(
                      '${counters.totalWash}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_rounded, color: Colors.green),
                    title: const Text('Toplam Teslim Edilen'),
                    trailing: Text(
                      '${counters.totalDelivered}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                
                // Aktif sayaçlar
                Text(
                  'Şu An Aktif',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActiveCounter(
                      context,
                      'Parkta',
                      counters.activePark,
                      Icons.local_parking,
                      Colors.blue,
                    ),
                    _buildActiveCounter(
                      context,
                      'Bakımda',
                      counters.activeMaintenance,
                      Icons.build_circle,
                      Colors.orange,
                    ),
                    _buildActiveCounter(
                      context,
                      'Yıkamada',
                      counters.activeWash,
                      Icons.local_car_wash,
                      Colors.lightBlue,
                    ),
                  ],
                ),
                
                const Spacer(),
                const SizedBox(height: 16),
              ],
            ),
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
}
