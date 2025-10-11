import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/core/utils/formatters.dart';
import 'package:otopark_demo/features/operations/domain/operation_type.dart';
import 'package:otopark_demo/features/operations/providers/operation_providers.dart';
import 'package:otopark_demo/features/vehicles/providers/vehicle_providers.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle_status.dart';
import 'package:otopark_demo/features/park_slots/providers/slot_providers.dart';

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
        actions: [
          // Durum değiştirme menüsü
          PopupMenuButton<VehicleStatus>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Durum Değiştir',
            onSelected: (newStatus) {
              vehiclesAsync.whenData((vehicles) {
                final vehicleObj = vehicles.where((v) => v.id == vehicle).firstOrNull;
                if (vehicleObj != null && vehicleObj.status != newStatus) {
                  _changeVehicleStatus(context, ref, vehicleObj, newStatus);
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: VehicleStatus.parked,
                child: Row(
                  children: [
                    Icon(VehicleStatus.parked.icon, color: VehicleStatus.parked.color, size: 20),
                    const SizedBox(width: 8),
                    Text(VehicleStatus.parked.displayName),
                  ],
                ),
              ),
              PopupMenuItem(
                value: VehicleStatus.inMaintenance,
                child: Row(
                  children: [
                    Icon(VehicleStatus.inMaintenance.icon, color: VehicleStatus.inMaintenance.color, size: 20),
                    const SizedBox(width: 8),
                    Text(VehicleStatus.inMaintenance.displayName),
                  ],
                ),
              ),
              PopupMenuItem(
                value: VehicleStatus.inWash,
                child: Row(
                  children: [
                    Icon(VehicleStatus.inWash.icon, color: VehicleStatus.inWash.color, size: 20),
                    const SizedBox(width: 8),
                    Text(VehicleStatus.inWash.displayName),
                  ],
                ),
              ),
              PopupMenuItem(
                value: VehicleStatus.inDeliveryQueue,
                child: Row(
                  children: [
                    Icon(VehicleStatus.inDeliveryQueue.icon, color: VehicleStatus.inDeliveryQueue.color, size: 20),
                    const SizedBox(width: 8),
                    Text(VehicleStatus.inDeliveryQueue.displayName),
                  ],
                ),
              ),
              PopupMenuItem(
                value: VehicleStatus.delivered,
                child: Row(
                  children: [
                    Icon(VehicleStatus.delivered.icon, color: VehicleStatus.delivered.color, size: 20),
                    const SizedBox(width: 8),
                    Text(VehicleStatus.delivered.displayName),
                  ],
                ),
              ),
              PopupMenuItem(
                value: VehicleStatus.exited,
                child: Row(
                  children: [
                    Icon(VehicleStatus.exited.icon, color: VehicleStatus.exited.color, size: 20),
                    const SizedBox(width: 8),
                    Text(VehicleStatus.exited.displayName),
                  ],
                ),
              ),
            ],
          ),
        ],
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
                        if (vehicleObj.currentParkSlotId != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.red),
                              const SizedBox(width: 4),
                              Text(
                                'Park Yeri: ${vehicleObj.currentParkSlotId}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                        if (vehicleObj.parkStartAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Park Süresi: ${DateTime.now().difference(vehicleObj.parkStartAt!).inMinutes} dakika',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
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

  /// Araç durumunu değiştir
  void _changeVehicleStatus(BuildContext context, WidgetRef ref, vehicle, VehicleStatus newStatus) async {
    // Eğer yeni durum "parked" ise, slot seçmesi gerekir
    if (newStatus == VehicleStatus.parked) {
      _showSelectSlotDialog(context, ref, vehicle);
      return;
    }

    // Eğer araç şu anda park edilmişse ve park dışı duruma geçiyorsa, slotu boşalt
    if (vehicle.currentParkSlotId != null && newStatus != VehicleStatus.parked) {
      await ref.read(slotsProvider.notifier).vacateSlot(vehicle.currentParkSlotId!);
    }

    // Diğer durumlar için direkt değişiklik yap
    final error = await ref.read(vehiclesProvider.notifier).changeVehicleStatus(
      vehicle: vehicle,
      newStatus: newStatus,
      note: 'Durum değiştirildi: ${newStatus.displayName}',
    );

    if (context.mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $error'), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${vehicle.plate} durumu ${newStatus.displayName} olarak güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// Park yeri seçme dialog'u
  void _showSelectSlotDialog(BuildContext context, WidgetRef ref, vehicle) async {
    final slotsAsync = ref.read(slotsProvider);
    
    await slotsAsync.when(
      data: (slots) async {
        // Boş slotları filtrele VEYA aracın mevcut park yerini dahil et
        final availableSlots = slots.where((s) => 
          !s.isOccupied || s.id == vehicle.currentParkSlotId
        ).toList();

        if (availableSlots.isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Boş park yeri yok!')),
            );
          }
          return;
        }

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('${vehicle.plate} - Park Yeri Seç'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: ListView.builder(
                  itemCount: availableSlots.length,
                  itemBuilder: (context, index) {
                    final slot = availableSlots[index];
                    return ListTile(
                      leading: Icon(
                        slot.isServiceArea ? Icons.build_rounded : Icons.local_parking_rounded,
                        color: slot.isServiceArea ? Colors.orange : Colors.blue,
                      ),
                      title: Text(slot.label),
                      subtitle: Text(slot.isServiceArea ? 'Servis Alanı' : 'Park Alanı'),
                      trailing: slot.id == vehicle.currentParkSlotId
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () async {
                        // Eğer aynı slot seçildiyse işlem yapma
                        if (slot.id == vehicle.currentParkSlotId) {
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${vehicle.plate} zaten ${slot.label} alanında.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                          return;
                        }

                        // Slotu doldur
                        await ref.read(slotsProvider.notifier).occupySlot(slot.id, vehicle.id);

                        // Araç durumunu değiştir
                        final error = await ref.read(vehiclesProvider.notifier).changeVehicleStatus(
                          vehicle: vehicle,
                          newStatus: VehicleStatus.parked,
                          targetSlotId: slot.id,
                          note: '${slot.label} alanına park edildi',
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          if (error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Hata: $error'), backgroundColor: Colors.red),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${vehicle.plate} ${slot.label} alanına park edildi.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
              ],
            ),
          );
        }
      },
      loading: () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Yükleniyor...')),
          );
        }
      },
      error: (err, stack) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $err')),
          );
        }
      },
    );
  }
}
