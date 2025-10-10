import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/features/park_slots/providers/slot_providers.dart';
import 'package:otopark_demo/features/vehicles/providers/vehicle_providers.dart';

class ParkSlotsPage extends ConsumerWidget {
  const ParkSlotsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(slotsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Park Yerleri'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: slotsAsync.when(
        data: (slots) {
          // Servis ve park alanlarını ayır
          final serviceSlots = slots.where((s) => s.isServiceArea).toList();
          final parkSlots = slots.where((s) => !s.isServiceArea).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Özet istatistikler
                _buildSummaryCard(context, slots),
                const SizedBox(height: 24),
                
                // Servis Alanları
                Text(
                  'Servis Alanları',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: serviceSlots.map((slot) {
                    return _buildSlotCard(context, ref, slot, isCompact: false);
                  }).toList(),
                ),
                
                const SizedBox(height: 24),
                
                // Park Alanları
                Text(
                  'Park Alanları',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: parkSlots.length,
                  itemBuilder: (context, index) {
                    return _buildSlotCard(context, ref, parkSlots[index], isCompact: true);
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, List slots) {
    final occupied = slots.where((s) => s.isOccupied).length;
    final available = slots.length - occupied;
    
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat(context, 'Toplam', slots.length.toString(), Icons.grid_on),
            _buildStat(context, 'Boş', available.toString(), Icons.check_circle, Colors.green),
            _buildStat(context, 'Dolu', occupied.toString(), Icons.cancel, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value, IconData icon, [Color? color]) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color ?? Colors.grey),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSlotCard(BuildContext context, WidgetRef ref, slot, {required bool isCompact}) {
    final color = slot.isOccupied 
        ? (slot.isServiceArea ? Colors.orange : Colors.red)
        : (slot.isServiceArea ? Colors.blue : Colors.green);
    
    return InkWell(
      onTap: () => _handleSlotTap(context, ref, slot),
      child: Card(
        color: color.shade100,
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 8 : 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                slot.isOccupied ? Icons.directions_car : Icons.check_circle_outline,
                color: color,
                size: isCompact ? 24 : 32,
              ),
              const SizedBox(height: 4),
              Text(
                slot.label,
                style: TextStyle(
                  fontSize: isCompact ? 10 : 12,
                  fontWeight: FontWeight.bold,
                  color: color.shade800,
                ),
                textAlign: TextAlign.center,
                maxLines: isCompact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSlotTap(BuildContext context, WidgetRef ref, slot) {
    if (slot.isOccupied) {
      _showVehicleOptions(context, ref, slot);
    } else {
      _showAssignVehicle(context, ref, slot);
    }
  }

  void _showVehicleOptions(BuildContext context, WidgetRef ref, slot) async {
    final vehiclesAsync = ref.read(vehiclesProvider);
    final vehicles = vehiclesAsync.value ?? [];
    final vehicle = vehicles.where((v) => v.id == slot.vehicleId).firstOrNull;
    
    if (vehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Araç bilgisi bulunamadı')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${slot.label} - ${vehicle.plate}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Marka: ${vehicle.brand ?? '-'}'),
            Text('Model: ${vehicle.model ?? '-'}'),
            Text('Durum: ${vehicle.status.name}'),
            if (vehicle.parkDurationMinutes != null)
              Text('Park Süresi: ${vehicle.parkDurationMinutes} dk'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(slotsProvider.notifier).vacateSlot(slot.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${slot.label} boşaltıldı')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Slotu Boşalt'),
          ),
        ],
      ),
    );
  }

  void _showAssignVehicle(BuildContext context, WidgetRef ref, slot) async {
    final vehiclesAsync = ref.read(vehiclesProvider);
    final vehicles = vehiclesAsync.value ?? [];
    final availableVehicles = vehicles.where((v) => v.currentParkSlotId == null).toList();
    
    if (availableVehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Park edilebilir araç yok')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${slot.label} - Araç Seç'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableVehicles.length,
            itemBuilder: (context, index) {
              final vehicle = availableVehicles[index];
              return ListTile(
                leading: Icon(Icons.directions_car, color: Colors.blue),
                title: Text(vehicle.plate),
                subtitle: Text('${vehicle.brand ?? ''} ${vehicle.model ?? ''}'),
                onTap: () async {
                  try {
                    await ref.read(slotsProvider.notifier).occupySlot(slot.id, vehicle.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${vehicle.plate} ${slot.label}\'e yerleştirildi')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hata: $e')),
                    );
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
}

