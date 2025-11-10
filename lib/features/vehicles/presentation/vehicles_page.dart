import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle_status.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle_state_machine.dart';
import 'package:otopark_demo/features/vehicles/providers/vehicle_providers.dart';
import 'package:otopark_demo/features/vehicles/providers/park_timer_provider.dart';
import 'package:otopark_demo/features/vehicles/presentation/add_vehicle_sheet.dart';
import 'package:otopark_demo/features/park_slots/providers/slot_providers.dart';
import 'package:otopark_demo/features/vehicle_expertiz/presentation/expertiz_detail_page.dart';

class VehiclesPage extends ConsumerStatefulWidget {
  const VehiclesPage({super.key});

  @override
  ConsumerState<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends ConsumerState<VehiclesPage> {
  String _searchQuery = '';
  VehicleStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    // Timer'ı dinle (30 saniyede bir yenilenir)
    ref.watch(parkTimerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Araçlar'),
        // Theme'den otomatik renk alır (sarı yazı, koyu gri arka plan)
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: vehiclesAsync.when(
        data: (vehicles) {
          final filteredVehicles = vehicles.where((vehicle) {
            final matchesSearch = vehicle.plate.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (vehicle.brand?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                (vehicle.model?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
            final matchesStatus = _filterStatus == null || vehicle.status == _filterStatus;
            return matchesSearch && matchesStatus;
          }).toList();

          if (filteredVehicles.isEmpty) {
            return const Center(child: Text('Hiç araç bulunamadı.'));
          }

          return Column(
            children: [
              // Arama çubuğu
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Şase, marka veya model ara...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () => setState(() => _searchQuery = ''),
                                  )
                                : null,
                          ),
                          onChanged: (value) => setState(() => _searchQuery = value),
                        ),
                      ),
              
              // Liste
              Expanded(
                child: ListView.builder(
                  itemCount: filteredVehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = filteredVehicles[index];
                    return _buildVehicleCard(vehicle);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: true, // ✅ Dışarı tıklayınca kapanır
            enableDrag: true, // ✅ Aşağı kaydırınca kapanır
            builder: (context) => const AddVehicleSheet(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Araç Ekle'),
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(vehicle.status.icon, color: vehicle.status.color, size: 32),
        title: Row(
          children: [
            Expanded(
              child: Text(
                vehicle.plate,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Park süresi göstergesi
            if (vehicle.status == VehicleStatus.parked && vehicle.parkStartAt != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer, size: 14, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Text(
                      '${vehicle.parkDurationMinutes ?? 0} dk',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Text('${vehicle.brand ?? ''} ${vehicle.model ?? ''}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ekspertiz butonu
            IconButton(
              onPressed: () => _showExpertizDetail(vehicle.id, vehicle.plate),
              icon: const Icon(Icons.assessment, color: Colors.blue),
              tooltip: 'Ekspertizi Gör/Düzenle',
            ),
            Chip(
              label: Text(vehicle.status.displayName),
              backgroundColor: vehicle.status.color.withOpacity(0.2),
              labelStyle: TextStyle(color: vehicle.status.color, fontSize: 11),
              padding: EdgeInsets.zero,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) => _handleAction(value, vehicle),
              itemBuilder: (context) => _buildActionMenu(vehicle),
            ),
          ],
        ),
        onTap: () {
          context.go('/vehicles/${vehicle.id}');
        },
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildActionMenu(Vehicle vehicle) {
    final allowedTransitions = VehicleStateMachine.getAllowedTransitions(vehicle.status);
    final menuItems = <PopupMenuEntry<String>>[];

    // Geçiş aksiyonları
    for (final status in allowedTransitions) {
      menuItems.add(
        PopupMenuItem(
          value: 'transition_${status.name}',
          child: Row(
            children: [
              Icon(status.icon, color: status.color, size: 20),
              const SizedBox(width: 8),
              Text(status.displayName),
            ],
          ),
        ),
      );
    }

    if (menuItems.isNotEmpty) {
      menuItems.add(const PopupMenuDivider());
    }

    // Genel aksiyonlar
    menuItems.addAll([
      const PopupMenuItem(
        value: 'history',
        child: Row(
          children: [
            Icon(Icons.history, size: 20),
            SizedBox(width: 8),
            Text('Geçmişi Gör'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text('Sil', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ]);

    return menuItems;
  }

  void _handleAction(String action, Vehicle vehicle) async {
    if (action.startsWith('transition_')) {
      final statusName = action.replaceFirst('transition_', '');
      final newStatus = VehicleStatus.values.firstWhere((s) => s.name == statusName);
      await _changeStatus(vehicle, newStatus);
    } else if (action == 'history') {
      context.go('/vehicles/${vehicle.id}');
    } else if (action == 'delete') {
      _confirmDelete(vehicle);
    }
  }

  Future<void> _changeStatus(Vehicle vehicle, VehicleStatus newStatus) async {
    String? targetSlotId;
    
    // Park durumuna geçiyorsa slot seçtir
    if (newStatus == VehicleStatus.parked) {
      targetSlotId = await _selectSlot();
      if (targetSlotId == null) return; // İptal edildi
    }

    // Not gir (opsiyonel)
    final note = await _askForNote(newStatus);

    // Durum değiştir
    final error = await ref.read(vehiclesProvider.notifier).changeVehicleStatus(
      vehicle: vehicle,
      newStatus: newStatus,
      targetSlotId: targetSlotId,
      note: note,
    );

    if (mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${vehicle.plate} ${newStatus.displayName} durumuna alındı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<String?> _selectSlot() async {
    final slotsAsync = ref.read(slotsProvider);
    final slots = slotsAsync.value ?? [];
    final availableSlots = slots.where((s) => !s.isOccupied && !s.isServiceArea).toList();

    if (availableSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boş park yeri yok!')),
      );
      return null;
    }

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Park Yeri Seç'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableSlots.length,
            itemBuilder: (context, index) {
              final slot = availableSlots[index];
              return ListTile(
                leading: const Icon(Icons.local_parking, color: Colors.green),
                title: Text(slot.label),
                onTap: () => Navigator.pop(context, slot.id),
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

  Future<String?> _askForNote(VehicleStatus status) async {
    final controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Not Ekle (Opsiyonel)'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'İşlem notu...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Atla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aracı Sil?'),
        content: Text('${vehicle.plate} plakasını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(vehiclesProvider.notifier).deleteVehicle(vehicle.id);
              Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${vehicle.plate} silindi')),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrele'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tümü'),
              leading: Radio<VehicleStatus?>(
                value: null,
                groupValue: _filterStatus,
                onChanged: (value) {
                  setState(() => _filterStatus = value);
                  Navigator.pop(context);
                },
              ),
            ),
            ...VehicleStatus.values.map((status) {
              return ListTile(
                title: Text(status.displayName),
                leading: Radio<VehicleStatus?>(
                  value: status,
                  groupValue: _filterStatus,
                  onChanged: (value) {
                    setState(() => _filterStatus = value);
                    Navigator.pop(context);
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// Ekspertiz detay sayfasını göster
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
}
