import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/core/utils/formatters.dart';
import 'package:otopark_demo/features/operations/domain/operation_type.dart';
import 'package:otopark_demo/features/operations/providers/operation_providers.dart';
import 'package:otopark_demo/features/vehicles/providers/vehicle_providers.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle_status.dart';

class VehicleDetailPage extends ConsumerWidget {
  final String vehicle; // vehicleId olarak kullanılacak
  const VehicleDetailPage({required this.vehicle, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final operationsAsync = ref.watch(operationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Araç Detayı'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: vehiclesAsync.when(
        data: (vehicles) {
          final vehicleObj = vehicles.where((v) => v.id == vehicle).firstOrNull;
          if (vehicleObj == null) {
            return const Center(child: Text('Araç bulunamadı'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vehicleObj.brand ?? ''} ${vehicleObj.model ?? ''}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                                const SizedBox(height: 8),
                                Text('Şase: ${vehicleObj.plate}'),
                                Text('Renk: ${vehicleObj.color ?? 'Belirtilmemiş'}'),
                        Row(
                          children: [
                            const Text('Durum: '),
                            Icon(vehicleObj.status.icon, size: 16, color: vehicleObj.status.color),
                            const SizedBox(width: 4),
                            Text(vehicleObj.status.displayName, 
                              style: TextStyle(color: vehicleObj.status.color, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text('Giriş Tarihi: ${Formatters.formatDateTime(vehicleObj.createdAt)}'),
                        Text('Son Güncelleme: ${Formatters.formatDateTime(vehicleObj.updatedAt)}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'İşlem Geçmişi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                operationsAsync.when(
                  data: (operations) {
                    final vehicleOperations = operations
                        .where((op) => op.vehicleId == vehicle)
                        .toList()
                      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

                    if (vehicleOperations.isEmpty) {
                      return const Text('Bu araca ait işlem geçmişi bulunamadı.');
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vehicleOperations.length,
                      itemBuilder: (context, index) {
                        final operation = vehicleOperations[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(operation.type.icon, color: operation.type.color),
                            title: Text(operation.type.displayName),
                            subtitle: Text(
                                '${Formatters.formatDateTime(operation.timestamp)}\n${operation.note ?? ''}'),
                            isThreeLine: true,
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('İşlem geçmişi yüklenirken hata: $err'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Araç detayı yüklenirken hata: $err')),
      ),
    );
  }
}
