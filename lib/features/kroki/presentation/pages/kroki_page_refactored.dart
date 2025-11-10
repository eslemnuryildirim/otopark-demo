import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/features/kroki/domain/entities/parking_slot.dart';
import 'package:otopark_demo/features/kroki/domain/entities/parking_status.dart';
import 'package:otopark_demo/features/kroki/presentation/providers/parking_slots_provider.dart';
import 'package:otopark_demo/features/kroki/presentation/widgets/parking_grid_view.dart';
import 'package:otopark_demo/features/kroki/presentation/widgets/parking_stats_header.dart';
import 'package:otopark_demo/features/kroki/presentation/widgets/parking_slot_details.dart';

class KrokiPageRefactored extends ConsumerWidget {
  const KrokiPageRefactored({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(parkingSlotsProvider);
    final selectedSlotId = ref.watch(selectedSlotProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Otopark Krokisi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(parkingSlotsProvider);
            },
          ),
        ],
      ),
      body: slotsAsync.when(
        data: (slots) => _buildContent(context, ref, slots, selectedSlotId),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Hata: $error',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(parkingSlotsProvider);
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<ParkingSlot> slots,
    String? selectedSlotId,
  ) {
    return Column(
      children: [
        // İstatistikler
        const ParkingStatsHeader(),
        
        // Grid
        Expanded(
          child: ParkingGridView(
            slots: slots,
            onSlotTap: (slot) => _handleSlotTap(context, ref, slot),
          ),
        ),
        
        // Seçili slot detayları
        if (selectedSlotId != null)
          ParkingSlotDetails(
            slotId: selectedSlotId,
            onClose: () {
              ref.read(selectedSlotProvider.notifier).state = null;
            },
          ),
      ],
    );
  }

  void _handleSlotTap(BuildContext context, WidgetRef ref, ParkingSlot slot) {
    // Seçili slot'u güncelle
    ref.read(selectedSlotProvider.notifier).state = slot.id;
    
    // Slot durumuna göre action göster
    if (slot.isOccupied) {
      _showOccupiedSlotDialog(context, ref, slot);
    } else {
      _showAssignVehicleDialog(context, ref, slot);
    }
  }

  void _showOccupiedSlotDialog(BuildContext context, WidgetRef ref, ParkingSlot slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${slot.label} - Dolu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Durum: ${getStatusText(slot.status)}'),
            if (slot.vehicleId != null)
              Text('Araç ID: ${slot.vehicleId}'),
            if (slot.occupationDuration != null)
              Text('Park Süresi: ${slot.occupationDurationText}'),
            const SizedBox(height: 16),
            const Text('Ne yapmak istiyorsunuz?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAssignVehicleDialog(context, ref, slot);
            },
            child: const Text('Araç Değiştir'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(vacateSlotProvider(slot.id).future);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${slot.label} boşaltıldı')),
                );
              }
            },
            child: const Text('Boşalt'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  void _showAssignVehicleDialog(BuildContext context, WidgetRef ref, ParkingSlot slot) {
    final plateController = TextEditingController();
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final colorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${slot.label} - Araç Ekle'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: plateController,
                decoration: const InputDecoration(
                  labelText: 'Plaka/Şase',
                  hintText: 'ABC123456789',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: brandController,
                decoration: const InputDecoration(
                  labelText: 'Marka',
                  hintText: 'Toyota',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  hintText: 'Corolla',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(
                  labelText: 'Renk',
                  hintText: 'Beyaz',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (plateController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Plaka/Şase gerekli')),
                );
                return;
              }

              // Mock vehicle ID
              final vehicleId = DateTime.now().millisecondsSinceEpoch.toString();
              
              try {
                await ref.read(occupySlotProvider((
                  slotId: slot.id,
                  vehicleId: vehicleId,
                )).future);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${slot.label} dolduruldu')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
