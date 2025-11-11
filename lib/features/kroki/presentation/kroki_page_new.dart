import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otopark_demo/core/services/simple_ocr_service.dart';
import 'package:otopark_demo/core/utils/vin_decoder.dart';
import 'package:otopark_demo/features/park_slots/providers/slot_providers.dart';
import 'package:otopark_demo/features/vehicles/providers/vehicle_providers.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle_status.dart';
import 'package:otopark_demo/features/park_slots/domain/park_slot.dart';
import 'package:otopark_demo/features/vehicle_expertiz/presentation/expertiz_detail_page.dart';

/// 🅿️ Otopark Planı - Modern Grid Arayüzü
/// 
/// 13 satır × 6 sütun grid yapısı
/// Sadece seçilen sütun büyür, diğerleri normal kalır
/// Sketch/kroki efekti yok, sadece düz modern tasarım
class KrokiPageNew extends ConsumerStatefulWidget {
  const KrokiPageNew({super.key});

  @override
  ConsumerState<KrokiPageNew> createState() => _KrokiPageNewState();
}

class _KrokiPageNewState extends ConsumerState<KrokiPageNew> {
  String? selectedColumn; // A, B, C, D, E, F veya null
  
  // Sütun başlıkları
  final List<String> columns = ['A', 'B', 'C', 'D', 'E', 'F'];
  
  // Satır sayısı
  final int rowCount = 13;

  // Responsive breakpoints
  bool get isCompact => MediaQuery.of(context).size.width < 360;
  bool get isRegular => MediaQuery.of(context).size.width >= 360 && MediaQuery.of(context).size.width < 430;
  bool get isLarge => MediaQuery.of(context).size.width >= 430;
  
  // Responsive spacing
  double get horizontalPadding {
    if (isCompact) return 12.0;
    if (isRegular) return 16.0;
    return 20.0; // isLarge
  }
  
  double get verticalPadding {
    if (isCompact) return 12.0;
    if (isRegular) return 16.0;
    return 20.0; // isLarge
  }
  
  double get headerGridSpacing {
    if (isCompact) return 12.0;
    if (isRegular) return 16.0;
    return 20.0; // isLarge
  }
  
  double get rowSpacing {
    if (isCompact) return 6.0;
    if (isRegular) return 8.0;
    return 10.0; // isLarge
  }
  
  // Responsive typography
  double get appBarTitleSize {
    final baseSize = isCompact ? 20.0 : isRegular ? 22.0 : 24.0;
    return baseSize * MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2);
  }
  
  double get columnHeaderSize {
    final baseSize = isCompact ? 14.0 : isRegular ? 16.0 : 18.0;
    return baseSize * MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2);
  }
  
  double get slotLabelSize {
    final baseSize = isCompact ? 10.0 : isRegular ? 11.0 : 12.0;
    return baseSize * MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2);
  }
  
  // Responsive grid dimensions
  double get columnHeaderHeight {
    if (isCompact) return 36.0;
    if (isRegular) return 40.0;
    return 44.0; // isLarge
  }
  
  double get rowHeight {
    if (isCompact) return 36.0;
    if (isRegular) return 40.0;
    return 44.0; // isLarge
  }
  
  double get slotHeight {
    if (isCompact) return 32.0;
    if (isRegular) return 36.0;
    return 40.0; // isLarge
  }
  
  double get selectedSlotHeight {
    if (isCompact) return 38.0;
    if (isRegular) return 42.0;
    return 46.0; // isLarge
  }
  
  // Minimum touch target size
  double get minTouchTarget => 44.0;

  @override
  Widget build(BuildContext context) {
    final slotsAsync = ref.watch(slotsProvider);
    final vehiclesAsync = ref.watch(vehiclesProvider);
    
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme - siyah arka plan
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            children: [
              // Sütun başlıkları (A-F butonları)
              _buildColumnHeaders(),
              SizedBox(height: headerGridSpacing),
              // Ana grid
              Expanded(
                child: slotsAsync.when(
                  data: (slots) => _buildParkingGrid(slots, vehiclesAsync.value ?? []),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Hata: $error'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Üst bar - Başlık ve sıfırlama butonu
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Otopark Planı',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: appBarTitleSize,
          color: Colors.orange,
        ),
      ),
      backgroundColor: Colors.grey[900],
      elevation: 0,
      actions: [
        // Sadece bir sütun seçiliyken görünen sıfırlama butonu
        if (selectedColumn != null)
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: minTouchTarget,
              minWidth: minTouchTarget,
            ),
            child: TextButton.icon(
              onPressed: _resetSelection,
              icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
              label: const Text('Büyütmeyi Sıfırla', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Sütun başlıkları (A-F butonları)
  Widget _buildColumnHeaders() {
    return Container(
      height: columnHeaderHeight,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // Glass efekti
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sol boşluk (satır etiketleri için)
          SizedBox(width: isCompact ? 32.0 : 40.0),
          // Sütun butonları
          Expanded(
            child: Row(
              children: columns.map((column) => _buildColumnButton(column)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Tek sütun butonu
  Widget _buildColumnButton(String column) {
    final isSelected = selectedColumn == column;
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _toggleColumn(column),
            borderRadius: BorderRadius.circular(6),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: minTouchTarget,
                minWidth: minTouchTarget,
              ),
              child: Container(
                height: columnHeaderHeight - 8, // Padding için
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.blue.withOpacity(0.3) 
                      : Colors.white.withOpacity(0.1), // Glass efekti
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? Colors.blue.withOpacity(0.5) 
                        : Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Center(
                  child: Text(
                    column,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[200],
                      fontWeight: FontWeight.w600,
                      fontSize: columnHeaderSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Ana otopark grid'i
  Widget _buildParkingGrid(List<ParkSlot> slots, List<Vehicle> vehicles) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // Glass efekti - şeffaf beyaz
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Grid başlığı
          Container(
            height: columnHeaderHeight,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                // Sol etiket sütunu başlığı
                Container(
                  width: isCompact ? 32.0 : 40.0,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Sıra',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontSize: columnHeaderSize * 0.8,
                      ),
                    ),
                  ),
                ),
                // Sütun başlıkları
                Expanded(
                  child: Row(
                    children: columns.map((column) => _buildGridColumnHeader(column)).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Grid satırları
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                height: (rowHeight + rowSpacing) * rowCount + 40, // Toplam yükseklik + daha fazla ekstra boşluk
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(), // Scroll'u SingleChildScrollView'a bırak
                  itemCount: rowCount,
                  itemExtent: rowHeight + rowSpacing, // Performans için sabit yükseklik
                  itemBuilder: (context, index) => _buildGridRow(index + 1, slots, vehicles),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Grid sütun başlığı
  Widget _buildGridColumnHeader(String column) {
    final isSelected = selectedColumn == column;
    
    return Expanded(
      child: Container(
        height: columnHeaderHeight,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[800] : Colors.grey[700],
          border: Border(
            right: BorderSide(color: Colors.grey[500]!),
          ),
        ),
        child: Center(
          child: Text(
            column,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[200],
              fontWeight: FontWeight.w600,
              fontSize: columnHeaderSize,
            ),
          ),
        ),
      ),
    );
  }

  /// Grid satırı
  Widget _buildGridRow(int rowNumber, List<ParkSlot> slots, List<Vehicle> vehicles) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rowSpacing / 2), // Responsive satır arası boşluk
      child: Container(
        height: rowHeight,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[600]!),
          ),
        ),
      child: Row(
        children: [
          // Sol etiket sütunu
          Container(
            width: isCompact ? 32.0 : 40.0,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey[500]!),
              ),
            ),
            child: Center(
              child: Text(
                rowNumber.toString(),
                style: TextStyle(
                  color: Colors.grey[300],
                  fontWeight: FontWeight.w500,
                  fontSize: slotLabelSize * 0.9,
                ),
              ),
            ),
          ),
          // Park yerleri - Büyüme özelliği ile
          Expanded(
            child: Row(
              children: columns.map((column) => _buildParkingSlotWithExpansion(column, rowNumber, slots, vehicles)).toList(),
            ),
          ),
        ],
      ),
      ),
    );
  }

  /// Tek park yeri
  Widget _buildParkingSlot(String column, int row, List<ParkSlot> slots, List<Vehicle> vehicles) {
    final slotId = '$column$row';
    final isSelected = selectedColumn == column;
    
    // Gerçek slot verisini bul
    final slot = slots.firstWhere(
      (s) => s.id == slotId,
      orElse: () => ParkSlot(
        id: slotId,
        label: slotId,
        isOccupied: false,
        isServiceArea: false,
      ),
    );
    
    // ÖNEMLİ: isOccupied yerine doğrudan araçların currentParkSlotId'sine göre kontrol et
    // Çünkü slot.isOccupied güncellenmemiş olabilir
    final parkedVehicles = vehicles.where(
      (v) => v.currentParkSlotId == slotId && v.status == VehicleStatus.parked,
    ).toList();
    
    // Debug: Eğer slot dolu görünüyor ama araç bulunamıyorsa logla
    if (slot.isOccupied && parkedVehicles.isEmpty) {
      final allVehiclesInSlot = vehicles.where((v) => v.currentParkSlotId == slotId).toList();
      print('⚠️ Slot $slotId: slot.isOccupied=true ama parked vehicle bulunamadı. Tüm araçlar: ${allVehiclesInSlot.map((v) => '${v.plate} (${v.status.displayName})').join(', ')}');
    }
    
    final isOccupied = parkedVehicles.isNotEmpty;
    final vehicle = isOccupied ? parkedVehicles.first : null;
    
    // Eski kroki renkleri
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    
    if (isSelected) {
      backgroundColor = Colors.blue[400]!; // Seçili slot - daha belirgin mavi
      borderColor = Colors.blue[600]!;
      textColor = Colors.white;
    } else if (isOccupied) {
      backgroundColor = Colors.red[300]!; // Dolu slot - daha net kırmızı
      borderColor = Colors.red[400]!;
      textColor = Colors.white;
    } else {
      backgroundColor = Colors.green[300]!; // Boş slot - daha net yeşil
      borderColor = Colors.green[400]!;
      textColor = Colors.white;
    }
    
    return GestureDetector(
      onTap: () {
        if (isOccupied) {
          // Dolu slot - araç çıkarma popup'ı
          _showExitVehicleDialog(slotId);
        } else {
          // Boş slot - araç kaydetme popup'ı
          _showVehicleAssignmentDialog(slotId);
        }
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: minTouchTarget,
          minWidth: minTouchTarget,
        ),
        child: Container(
          height: isSelected ? selectedSlotHeight : slotHeight,
          decoration: BoxDecoration(
            color: backgroundColor.withOpacity(0.8), // Daha net glass efekti
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: backgroundColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    slotId,
                    style: TextStyle(
                      color: textColor,
                      fontSize: isSelected ? slotLabelSize + 1 : slotLabelSize,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                if (isOccupied)
                  Icon(
                    Icons.directions_car,
                    size: isSelected ? slotLabelSize + 2 : slotLabelSize,
                    color: textColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Sütun seçimini toggle et
  void _toggleColumn(String column) {
    setState(() {
      if (selectedColumn == column) {
        selectedColumn = null; // Aynı sütuna tekrar basılırsa seçimi kaldır
      } else {
        selectedColumn = column; // Yeni sütunu seç
      }
    });
  }

  /// Seçimi sıfırla
  void _resetSelection() {
    setState(() {
      selectedColumn = null;
    });
  }

  /// Büyüme özelliği olan park yeri
  Widget _buildParkingSlotWithExpansion(String column, int row, List<ParkSlot> slots, List<Vehicle> vehicles) {
    final isSelected = selectedColumn == column;
    final flex = isSelected ? 4 : 1; // Seçili sütun 4 kat büyür (daha belirgin)
    
    return Flexible(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2), // Sütunlar arası boşluk - azaltıldı
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          transform: Matrix4.identity(),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: isSelected ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: _buildParkingSlot(column, row, slots, vehicles),
          ),
        ),
      ),
    );
  }

  /// Araç kaydetme popup'ı
  void _showVehicleAssignmentDialog(String slotId) {
    final vehiclesAsync = ref.read(vehiclesProvider);
    final vehicles = vehiclesAsync.value ?? [];
    // Park edilmemiş, slot'u olmayan ve çıkış yapmamış araçlar
    final availableVehicles = vehicles.where((v) => 
      (v.currentParkSlotId == null || v.currentParkSlotId!.isEmpty) &&
      v.status != VehicleStatus.exited &&
      v.status != VehicleStatus.delivered
    ).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Araç Kaydet - $slotId'),
        content: SizedBox(
          width: double.maxFinite,
          child: availableVehicles.isEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Kayıtlı araç bulunamadı.'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showAddVehicleDialog(slotId);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Yeni Araç Ekle'),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableVehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = availableVehicles[index];
                          return ListTile(
                            leading: Icon(
                              Icons.directions_car,
                              color: vehicle.status.color,
                            ),
                            title: Text(vehicle.plate),
                            subtitle: Text('${vehicle.brand} ${vehicle.model}'),
                            onTap: () async {
                              Navigator.of(context).pop();
                              await _assignVehicleToSlot(vehicle.id, slotId);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showAddVehicleDialog(slotId);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Yeni Araç Ekle'),
                    ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  /// Araç çıkarma popup'ı
  void _showExitVehicleDialog(String slotId) {
    final vehiclesAsync = ref.read(vehiclesProvider);
    final vehicles = vehiclesAsync.valueOrNull ?? [];
    final vehicle = vehicles.firstWhere(
      (v) => v.currentParkSlotId == slotId,
      orElse: () => Vehicle(
        id: 'unknown',
        plate: 'Bilinmiyor',
        brand: 'Bilinmiyor',
        model: 'Bilinmiyor',
        color: 'Bilinmiyor',
        status: VehicleStatus.parked,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        damagedParts: const {},
      ),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Araç Çıkar - $slotId'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Plaka: ${vehicle.plate}'),
              Text('Marka: ${vehicle.brand}'),
              Text('Model: ${vehicle.model}'),
              const SizedBox(height: 24),
              const Text(
                'Aracı nereye çıkarmak istiyorsunuz?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Çıkış seçenekleri
              _buildExitOption(
                context,
                VehicleStatus.exited,
                'Çıkış Yaptı',
                Icons.exit_to_app,
                Colors.grey,
                () => _removeVehicleFromSlot(slotId, vehicle, VehicleStatus.exited, context),
              ),
              const SizedBox(height: 8),
              _buildExitOption(
                context,
                VehicleStatus.delivered,
                'Teslim Edildi',
                Icons.check_circle,
                Colors.green,
                () => _removeVehicleFromSlot(slotId, vehicle, VehicleStatus.delivered, context),
              ),
              const SizedBox(height: 8),
              _buildExitOption(
                context,
                VehicleStatus.inMaintenance,
                'Bakıma Al',
                Icons.build_circle,
                Colors.orange,
                () => _removeVehicleFromSlot(slotId, vehicle, VehicleStatus.inMaintenance, context),
              ),
              const SizedBox(height: 8),
              _buildExitOption(
                context,
                VehicleStatus.inWash,
                'Yıkamaya Al',
                Icons.local_car_wash,
                Colors.lightBlue,
                () => _removeVehicleFromSlot(slotId, vehicle, VehicleStatus.inWash, context),
              ),
              const SizedBox(height: 8),
              _buildExitOption(
                context,
                VehicleStatus.inDeliveryQueue,
                'Teslimat Alanına Al',
                Icons.local_shipping,
                Colors.purple,
                () => _removeVehicleFromSlot(slotId, vehicle, VehicleStatus.inDeliveryQueue, context),
              ),
            ],
          ),
        ),
        actions: [
          // Ekspertiz butonu
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _showExpertizDetail(vehicle.id, vehicle.plate);
            },
            icon: const Icon(Icons.assessment),
            label: const Text('Ekspertizi Gör/Düzenle'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue[600],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  /// Çıkış seçeneği widget'ı
  Widget _buildExitOption(
    BuildContext context,
    VehicleStatus status,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Aracı slota ata
  Future<void> _assignVehicleToSlot(String vehicleId, String slotId) async {
    try {
      // Önce vehicle'ı bul
      final vehiclesAsync = ref.read(vehiclesProvider);
      final vehicles = vehiclesAsync.valueOrNull ?? [];
      final vehicle = vehicles.firstWhere(
        (v) => v.id == vehicleId,
        orElse: () => throw Exception('Araç bulunamadı'),
      );
      
      // Aracın durumunu güncelle ve slota ata
      final error = await ref.read(vehiclesProvider.notifier).changeVehicleStatus(
        vehicle: vehicle,
        newStatus: VehicleStatus.parked,
        targetSlotId: slotId,
      );
      
      if (!mounted) return;
      
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $error'), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Araç $slotId slotuna kaydedildi'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }

  /// Aracı slot'tan çıkar ve yeni duruma geçir
  Future<void> _removeVehicleFromSlot(String slotId, Vehicle vehicle, VehicleStatus newStatus, BuildContext dialogContext) async {
    // Dialog'u kapat
    Navigator.of(dialogContext).pop();
    
    try {
      // Aracın mevcut slot'unu al (eğer varsa)
      final currentSlotId = vehicle.currentParkSlotId ?? slotId;
      
      // Aracın durumunu güncelle (changeVehicleStatus slot'u da boşaltır ve işlem kaydı oluşturur)
      final error = await ref.read(vehiclesProvider.notifier).changeVehicleStatus(
        vehicle: vehicle,
        newStatus: newStatus,
        targetSlotId: null, // Slot'tan çıkarıyoruz
      );
      
      if (!mounted) return;
      
      if (error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Slot'u manuel olarak boşalt (eğer UseCase boşaltmadıysa)
        try {
          await ref.read(slotsProvider.notifier).vacateSlot(currentSlotId);
        } catch (e) {
          print('⚠️ Slot boşaltma hatası (zaten boşaltılmış olabilir): $e');
        }
        
        // Slots provider'ı yenile
        ref.invalidate(slotsProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Araç ${vehicle.plate} ${newStatus.displayName} durumuna geçirildi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Araç ekleme popup'ı
  void _showAddVehicleDialog(String slotId) {
    final vinController = TextEditingController();
    final plateController = TextEditingController();
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final colorController = TextEditingController();
    final productionYearController = TextEditingController();
    final ageController = TextEditingController();
    
    // VIN bilgilerini güncelle
    void updateVinInfo(String vin) {
      final brand = VinDecoder.getBrandFromVin(vin);
      final productionYear = VinDecoder.getProductionYear(vin);
      final age = VinDecoder.getAge(vin);
      
      if (brand != 'Bilinmiyor') {
        brandController.text = brand;
      }
      
      if (productionYear != null) {
        productionYearController.text = productionYear.toString();
      }
      
      if (age != null) {
        ageController.text = '$age yaşında';
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Yeni Araç Ekle - $slotId'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: vinController,
                  decoration: InputDecoration(
                    labelText: 'Şase Numarası (VIN)',
                    prefixIcon: const Icon(Icons.badge),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () => _scanVinForDialog(
                            context,
                            vinController,
                            brandController,
                            productionYearController,
                            ageController,
                            setState,
                          ),
                          tooltip: 'Şase Tara (OCR)',
                        ),
                        if (vinController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              vinController.clear();
                              brandController.clear();
                              productionYearController.clear();
                              ageController.clear();
                              setState(() {});
                            },
                          ),
                      ],
                    ),
                  ),
                  onChanged: (vin) {
                    if (vin.length >= 10) {
                      updateVinInfo(vin);
                      setState(() {});
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: plateController,
                  decoration: const InputDecoration(
                    labelText: 'Plaka',
                    hintText: '34 ABC 123',
                    prefixIcon: Icon(Icons.directions_car),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: brandController,
                  decoration: const InputDecoration(
                    labelText: 'Marka',
                    hintText: 'BMW',
                    prefixIcon: Icon(Icons.branding_watermark),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(
                    labelText: 'Model',
                    hintText: 'M3',
                    prefixIcon: Icon(Icons.car_rental),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: productionYearController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Üretim Yılı',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: ageController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Yaş',
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: colorController,
                  decoration: const InputDecoration(
                    labelText: 'Renk',
                    hintText: 'Siyah',
                    prefixIcon: Icon(Icons.color_lens),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (plateController.text.isNotEmpty && 
                  brandController.text.isNotEmpty && 
                  modelController.text.isNotEmpty) {
                Navigator.of(context).pop();
                await _addAndAssignVehicle(
                  plateController.text,
                  brandController.text,
                  modelController.text,
                  colorController.text,
                  slotId,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
                );
              }
            },
            child: const Text('Ekle ve Kaydet'),
          ),
        ],
        ),
      ),
    );
  }

  /// Yeni araç ekle ve slota ata
  Future<void> _addAndAssignVehicle(String plate, String brand, String model, String color, String slotId) async {
    try {
      // Yeni araç oluştur
      final newVehicle = Vehicle(
        id: 'vehicle-${DateTime.now().millisecondsSinceEpoch}',
        plate: plate,
        brand: brand,
        model: model,
        color: color,
        status: VehicleStatus.parked,
        currentParkSlotId: slotId, // Slot ID'yi direkt ekle
        parkStartAt: DateTime.now(), // Park başlangıç zamanı
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        damagedParts: const {},
      );
      
      // Aracı ekle (addVehicle içinde zaten slot güncellemesi yapılıyor)
      await ref.read(vehiclesProvider.notifier).addVehicle(newVehicle);
      
      // Slot'u dolu olarak işaretle
      await ref.read(slotsProvider.notifier).occupySlot(slotId, newVehicle.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Araç eklendi ve $slotId slotuna kaydedildi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Dialog için VIN tara
  Future<void> _scanVinForDialog(
    BuildContext context,
    TextEditingController vinController,
    TextEditingController brandController,
    TextEditingController productionYearController,
    TextEditingController ageController,
    StateSetter setState,
  ) async {
    final ImagePicker picker = ImagePicker();
    
    // Kaynak seçimi
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şase Numarası Tara'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    
    if (source == null) return;
    
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 90,
    );
    
    if (image == null) return;
    
    try {
      // Yükleme dialog'u göster
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PopScope(
            canPop: false,
            child: const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Şase numarası okunuyor...'),
                  SizedBox(height: 8),
                  Text(
                    'Görüntü işleme ile VIN taranıyor',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }
      
      // Görüntüyü byte array'e çevir
      final imageBytes = await image.readAsBytes();
      
      // OCR ile VIN oku
      final vins = await SimpleOcrService.extractVin(imageBytes);
      
      // Yükleme dialog'unu kapat
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      if (vins.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Şase numarası okunamadı. Lütfen tekrar deneyin.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      
      // Kullanıcıya okunan VIN'leri göster
      if (context.mounted) {
        final selectedVin = await showDialog<String>(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text('${vins.length} VIN Bulundu'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'En uygun şase numarasını seçin:',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: vins.length,
                      itemBuilder: (context, index) {
                        final vin = vins[index];
                        final brand = VinDecoder.getBrandFromVin(vin);
                        final year = VinDecoder.getProductionYear(vin);
                        
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${index + 1}'),
                            ),
                            title: Text(
                              vin,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontFamily: 'monospace',
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${vin.length} karakter'),
                                if (brand != 'Bilinmiyor') Text('Marka: $brand'),
                                if (year != null) Text('Üretim: $year'),
                              ],
                            ),
                            onTap: () => Navigator.pop(context, vin),
                          ),
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
        
        if (selectedVin != null) {
          vinController.text = selectedVin;
          final brand = VinDecoder.getBrandFromVin(selectedVin);
          final productionYear = VinDecoder.getProductionYear(selectedVin);
          final age = VinDecoder.getAge(selectedVin);
          
          if (brand != 'Bilinmiyor') {
            brandController.text = brand;
          }
          
          if (productionYear != null) {
            productionYearController.text = productionYear.toString();
          }
          
          if (age != null) {
            ageController.text = '$age yaşında';
          }
          
          setState(() {});
        }
      }
    } catch (e) {
      // Hata durumunda yükleme dialog'unu kapat
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ OCR Hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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