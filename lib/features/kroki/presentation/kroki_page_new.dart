import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otopark_demo/core/utils/ocr_helper.dart';
import 'package:otopark_demo/features/park_slots/domain/park_slot.dart';
import 'package:otopark_demo/features/park_slots/providers/slot_providers.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle_status.dart';
import 'package:otopark_demo/features/vehicles/providers/vehicle_providers.dart';

/// Kroki Page - Riverpod entegrasyonlu
class KrokiPageNew extends ConsumerWidget {
  const KrokiPageNew({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(slotsProvider);
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Otopark Krokisi'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: slotsAsync.when(
        data: (slots) {
          return vehiclesAsync.when(
            data: (vehicles) => _buildParkingMap(context, ref, slots, vehicles),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Araçlar yüklenirken hata: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Slotlar yüklenirken hata: $err')),
      ),
    );
  }

  Widget _buildParkingMap(BuildContext context, WidgetRef ref, List<ParkSlot> slots, List<Vehicle> vehicles) {
    // Layout yapısı - Eski kroki gibi
    final layout = [
      // Servis alanları
      ['YIK1', 'YIK2', 'CAM1', 'DET1', 'PAS1', 'PAS2'],
      [], // Boş satır (koridor)
      // Ana park alanları - 13'er araç
      ['A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'A9', 'A10', 'A11', 'A12', 'A13'],
      [], // Koridor
      ['B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B9', 'B10', 'B11', 'B12', 'B13'],
      ['C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11', 'C12', 'C13'],
      [], // Koridor
      ['D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8', 'D9', 'D10', 'D11', 'D12', 'D13'],
      ['E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8', 'E9', 'E10', 'E11', 'E12', 'E13'],
      [], // Koridor
      ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', 'F13'],
    ];

    // Slot map oluştur (ID -> ParkSlot)
    final slotMap = {for (var slot in slots) slot.id: slot};

    return Column(
      children: [
        // İstatistikler
        _buildStats(slots),
        const SizedBox(height: 16),
        
        // Grid layout
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: layout.map((row) {
                  if (row.isEmpty) {
                    // Koridor (boş alan)
                    return const SizedBox(height: 20);
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: row.map((slotId) {
                        final slot = slotMap[slotId];
                        if (slot == null) return const SizedBox(width: 60);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildSlotCard(context, ref, slot, vehicles),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(List<ParkSlot> slots) {
    final totalSlots = slots.where((s) => !s.isServiceArea).length;
    final occupiedSlots = slots.where((s) => !s.isServiceArea && s.isOccupied).length;
    final availableSlots = totalSlots - occupiedSlots;

    final totalService = slots.where((s) => s.isServiceArea).length;
    final occupiedService = slots.where((s) => s.isServiceArea && s.isOccupied).length;
    final availableService = totalService - occupiedService;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Toplam Park', totalSlots, Colors.blue),
            _buildStatItem('Dolu', occupiedSlots, Colors.red),
            _buildStatItem('Boş', availableSlots, Colors.green),
            const VerticalDivider(),
            _buildStatItem('Servis Dolu', occupiedService, Colors.orange),
            _buildStatItem('Servis Boş', availableService, Colors.lightBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSlotCard(BuildContext context, WidgetRef ref, ParkSlot slot, List<Vehicle> vehicles) {
    Color cardColor;
    Color textColor;

    if (slot.isOccupied) {
      if (slot.isServiceArea) {
        cardColor = Colors.orange;
        textColor = Colors.white;
      } else {
        cardColor = Colors.red;
        textColor = Colors.white;
      }
    } else {
      if (slot.isServiceArea) {
        cardColor = Colors.blue;
        textColor = Colors.white;
      } else {
        cardColor = Colors.green;
        textColor = Colors.white;
      }
    }

    return GestureDetector(
      onTap: () => _handleSlotTap(context, ref, slot, vehicles),
      child: Container(
        width: 60,
        height: 50,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black26, width: 1),
        ),
        child: Center(
          child: Text(
            slot.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _handleSlotTap(BuildContext context, WidgetRef ref, ParkSlot slot, List<Vehicle> vehicles) {
    if (slot.isOccupied) {
      // Slot doluysa → Aracı çıkar
      _showOccupiedSlotDialog(context, ref, slot, vehicles);
    } else {
      // Slot boşsa → Araç ata
      _showAssignVehicleDialog(context, ref, slot, vehicles);
    }
  }

  void _showOccupiedSlotDialog(BuildContext context, WidgetRef ref, ParkSlot slot, List<Vehicle> vehicles) {
    final vehicle = vehicles.where((v) => v.id == slot.vehicleId).firstOrNull;

    if (vehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Araç bulunamadı!')),
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
            Text('Durum: ${vehicle.status.displayName}'),
            if (vehicle.parkStartAt != null)
              Text('Park Süresi: ${DateTime.now().difference(vehicle.parkStartAt!).inMinutes} dk'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          FilledButton(
            onPressed: () async {
              // Önce mevcut dialog'u kapat
              Navigator.pop(context);
              
              // Sonra yeni durum seçme dialog'unu aç
              _showVehicleActionDialog(context, ref, vehicle, slot, vehicles);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Aracı Çıkar'),
          ),
        ],
      ),
    );
  }

  /// Araç çıkarıldıktan sonra yeni durum seçme dialog'u
  void _showVehicleActionDialog(BuildContext context, WidgetRef ref, Vehicle vehicle, ParkSlot currentSlot, List<Vehicle> vehicles) {
    showDialog(
      context: context,
      barrierDismissible: false, // Dışarı tıklayınca kapanmasın
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Expanded(child: Text('Araç Nereye Gidiyor?')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${vehicle.plate} aracını ${currentSlot.label} alanından çıkardınız.',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lütfen aracın yeni durumunu seçin:',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          // Başka bir yere park et
          ListTile(
            leading: const Icon(Icons.local_parking_rounded, color: Colors.blue),
            title: const Text('Başka Bir Yere Park Et'),
            subtitle: const Text('Farklı bir park yerine taşı'),
            onTap: () async {
              Navigator.pop(context);
              _showSelectNewSlotDialog(context, ref, vehicle, currentSlot, vehicles);
            },
          ),
          const Divider(),
          
          // Teslimat alanına al
          ListTile(
            leading: const Icon(Icons.local_shipping_rounded, color: Colors.purple),
            title: const Text('Teslimat Alanına Al'),
            subtitle: const Text('Teslim için hazırla'),
            onTap: () async {
              Navigator.pop(context);
              await _changeVehicleStatusAndVacate(
                context,
                ref,
                vehicle,
                currentSlot,
                VehicleStatus.inDeliveryQueue,
                'Teslimat alanına alındı',
              );
            },
          ),
          const Divider(),
          
          // Yıkamaya götür
          ListTile(
            leading: const Icon(Icons.local_car_wash_rounded, color: Colors.lightBlue),
            title: const Text('Yıkamaya Götür'),
            subtitle: const Text('Araç yıkamaya gönderildi'),
            onTap: () async {
              Navigator.pop(context);
              await _changeVehicleStatusAndVacate(
                context,
                ref,
                vehicle,
                currentSlot,
                VehicleStatus.inWash,
                'Yıkamaya gönderildi',
              );
            },
          ),
          const Divider(),
          
          // Bakıma götür
          ListTile(
            leading: const Icon(Icons.build_circle_rounded, color: Colors.orange),
            title: const Text('Bakıma Götür'),
            subtitle: const Text('Bakım için gönderildi'),
            onTap: () async {
              Navigator.pop(context);
              await _changeVehicleStatusAndVacate(
                context,
                ref,
                vehicle,
                currentSlot,
                VehicleStatus.inMaintenance,
                'Bakıma gönderildi',
              );
            },
          ),
          const Divider(),
          
          // Çıkış yap
          ListTile(
            leading: const Icon(Icons.exit_to_app_rounded, color: Colors.grey),
            title: const Text('Çıkış Yap'),
            subtitle: const Text('Araç otoparktan ayrıldı'),
            onTap: () async {
              Navigator.pop(context);
              await _changeVehicleStatusAndVacate(
                context,
                ref,
                vehicle,
                currentSlot,
                VehicleStatus.exited,
                'Otoparktan çıkış yaptı',
              );
            },
          ),
        ],
      ),
    );
  }

  /// Araç durumunu değiştir ve slotu boşalt
  Future<void> _changeVehicleStatusAndVacate(
    BuildContext context,
    WidgetRef ref,
    Vehicle vehicle,
    ParkSlot currentSlot,
    VehicleStatus newStatus,
    String actionMessage,
  ) async {
    try {
      // Slotu boşalt
      await ref.read(slotsProvider.notifier).vacateSlot(currentSlot.id);

      // Araç durumunu değiştir
      final error = await ref.read(vehiclesProvider.notifier).changeVehicleStatus(
        vehicle: vehicle,
        newStatus: newStatus,
        note: actionMessage,
      );

      if (context.mounted) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $error'), backgroundColor: Colors.red),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${vehicle.plate} - $actionMessage'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Başka bir park yerine taşıma dialog'u
  void _showSelectNewSlotDialog(BuildContext context, WidgetRef ref, Vehicle vehicle, ParkSlot currentSlot, List<Vehicle> vehicles) async {
    final slotsAsync = ref.read(slotsProvider);
    
    await slotsAsync.when(
      data: (slots) async {
        // Boş slotları filtrele (mevcut slot hariç)
        final availableSlots = slots
            .where((s) => !s.isOccupied && s.id != currentSlot.id)
            .toList();

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
              title: Text('${vehicle.plate} - Yeni Park Yeri Seç'),
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
                      onTap: () async {
                        // Mevcut slotu boşalt
                        await ref.read(slotsProvider.notifier).vacateSlot(currentSlot.id);

                        // Yeni slotu doldur
                        await ref.read(slotsProvider.notifier).occupySlot(slot.id, vehicle.id);

                        // Aracı güncelle
                        final updatedVehicle = vehicle.copyWith(
                          currentParkSlotId: slot.id,
                          parkStartAt: DateTime.now(),
                        );
                        await ref.read(vehiclesProvider.notifier).updateVehicle(updatedVehicle);

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${vehicle.plate} ${currentSlot.label} → ${slot.label} taşındı.'),
                              backgroundColor: Colors.green,
                            ),
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

  void _showAssignVehicleDialog(BuildContext context, WidgetRef ref, ParkSlot slot, List<Vehicle> vehicles) {
    // Atanabilir araçlar (park edilmemiş veya başka slotta olmayan)
    final availableVehicles = vehicles.where((v) => v.currentParkSlotId == null).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${slot.label} - Araç Seç veya Ekle'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              // Yeni araç ekle butonu
              ListTile(
                leading: const Icon(Icons.add_circle, color: Colors.green, size: 32),
                title: const Text('Yeni Araç Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Yeni bir araç kaydı oluştur'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddVehicleDialog(context, ref, slot);
                },
              ),
              const Divider(),
              
              // Mevcut araçlar
              if (availableVehicles.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('Atanabilecek başka araç yok.\nYeni araç ekleyebilirsiniz.'),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableVehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = availableVehicles[index];
                      return ListTile(
                        leading: Icon(vehicle.status.icon, color: vehicle.status.color),
                        title: Text(vehicle.plate),
                        subtitle: Text('${vehicle.brand ?? ''} ${vehicle.model ?? ''}'),
                        onTap: () async {
                          // Aracı slota ata
                          await ref.read(slotsProvider.notifier).occupySlot(slot.id, vehicle.id);
                          
                          // Aracı güncelle
                          final updatedVehicle = vehicle.copyWith(
                            currentParkSlotId: slot.id,
                            parkStartAt: DateTime.now(),
                          );
                          await ref.read(vehiclesProvider.notifier).updateVehicle(updatedVehicle);
                          
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${vehicle.plate} ${slot.label} alanına atandı.')),
                            );
                          }
                        },
                      );
                    },
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
        ],
      ),
    );
  }

  void _showAddVehicleDialog(BuildContext context, WidgetRef ref, ParkSlot slot) {
    final plateController = TextEditingController();
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final colorController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${slot.label} - Yeni Araç Ekle'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: plateController,
                  decoration: InputDecoration(
                    labelText: 'Şase *',
                    hintText: 'ABC123456789',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () async {
                        final scanned = await _scanChassisNumber(context);
                        if (scanned != null) {
                          plateController.text = scanned;
                        }
                      },
                      tooltip: 'Şase Tara (OCR)',
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şase gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: brandController,
                  decoration: const InputDecoration(labelText: 'Marka'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: modelController,
                  decoration: const InputDecoration(labelText: 'Model'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: colorController,
                  decoration: const InputDecoration(labelText: 'Renk'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final uuid = ref.read(uuidProvider);
                final newVehicle = Vehicle(
                  id: uuid.v4(),
                  plate: plateController.text.trim(),
                  brand: brandController.text.trim().isEmpty ? null : brandController.text.trim(),
                  model: modelController.text.trim().isEmpty ? null : modelController.text.trim(),
                  color: colorController.text.trim().isEmpty ? null : colorController.text.trim(),
                  status: VehicleStatus.parked,
                  currentParkSlotId: slot.id,
                  parkStartAt: DateTime.now(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await ref.read(vehiclesProvider.notifier).addVehicle(newVehicle);
                await ref.read(slotsProvider.notifier).occupySlot(slot.id, newVehicle.id);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${newVehicle.plate} eklendi ve ${slot.label} alanına atandı!')),
                  );
                }
              }
            },
            child: const Text('Kaydet ve Ata'),
          ),
        ],
      ),
    );
  }

  Future<String?> _scanChassisNumber(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    
    // Kamera ile fotoğraf çek
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    
    if (image == null) return null;
    
    try {
      // Gelişmiş OCR ile metni tanı (görüntü iyileştirme + Tesseract)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şase okunuyor...')),
        );
      }
      
      final lines = await OcrHelper.extractTextFromImage(image.path);
      
      if (lines.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Şase numarası okunamadı. Fotoğrafı daha net çekin.')),
          );
        }
        return null;
      }
      
      // Kullanıcıya okunan metinleri göster
      if (context.mounted) {
        return showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Şase Seçin'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: lines.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(lines[index]),
                    onTap: () => Navigator.pop(context, lines[index]),
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
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
    
    return null;
  }
}

