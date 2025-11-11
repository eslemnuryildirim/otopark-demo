import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/car_part.dart';
import '../domain/expertiz_status.dart';
import '../providers/expertiz_provider.dart';
import 'svg_car_schema_widget.dart';
import 'car_schema_widget.dart'; // ExpertizStatusSelector için

/// Ekspertiz detay sayfası - Modal bottom sheet
class ExpertizDetailPage extends ConsumerStatefulWidget {
  final String vehicleId;
  final String vehiclePlate;

  const ExpertizDetailPage({
    super.key,
    required this.vehicleId,
    required this.vehiclePlate,
  });

  @override
  ConsumerState<ExpertizDetailPage> createState() => _ExpertizDetailPageState();
}

class _ExpertizDetailPageState extends ConsumerState<ExpertizDetailPage> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Mevcut notları yükle
  Future<void> _loadNotes() async {
    final expertiz = await ref.read(expertizRepositoryProvider).getVehicleExpertiz(widget.vehicleId);
    if (expertiz?.notes != null) {
      _notesController.text = expertiz!.notes!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expertizStatus = ref.watch(expertizStatusProvider(widget.vehicleId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Başlık ve kapatma butonu
          _buildHeader(),
          
          // Ana içerik - SVG tam genişlikte
          Expanded(
            child: Column(
              children: [
                // SVG araç şeması (büyük)
                Expanded(
                  child: _buildCarSchemaSection(expertizStatus),
                ),
                
                // Notlar (alt kısımda)
                _buildNotesSection(),
              ],
            ),
          ),
          
          // Alt butonlar
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Araç Ekspertizi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.vehiclePlate,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarSchemaSection(Map<CarPart, ExpertizStatus> partStatuses) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // SVG'yi MÜMKÜN OLDUĞUNCA BÜYÜK yap
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        
        // Header, notes, buttons için alan hesapla (minimal)
        final headerHeight = 70.0;
        final notesHeight = 100.0;
        final buttonsHeight = 70.0;
        final statusGuideHeight = 45.0;
        
        // Kalan alanı SVG için kullan (maksimum)
        final availableHeight = (screenHeight * 0.9) - headerHeight - notesHeight - buttonsHeight - statusGuideHeight - 20; // Minimal padding
        final availableWidth = screenWidth - 8; // Çok minimal padding
        
        // SVG oranını koru (300:430 = 0.697)
        double svgWidth = availableWidth;
        double svgHeight = (svgWidth / 300) * 430;
        
        // Eğer yükseklik çok büyükse, yüksekliğe göre ayarla
        if (svgHeight > availableHeight) {
          svgHeight = availableHeight;
          svgWidth = (svgHeight / 430) * 300;
        }
        
        return Container(
          padding: const EdgeInsets.all(2), // Çok minimal padding
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // SVG araç şeması (MÜMKÜN OLDUĞUNCA BÜYÜK)
              Expanded(
                child: Center(
                  child: SvgCarSchemaWidget(
                    partStatuses: partStatuses,
                    onPartTap: (part) {
                      _showStatusSelectorDialog(part, partStatuses[part] ?? ExpertizStatus.original);
                    },
                    width: svgWidth,
                    height: svgHeight,
                    debugMode: true, // Debug modu açık - tıklanan yerleri göster
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Durum rehberi (kompakt)
              _buildStatusGuide(),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStatusGuide() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          _buildStatusGuideItem('Orijinal', Colors.green),
          _buildStatusGuideItem('Boyalı', Colors.orange),
          _buildStatusGuideItem('Lokal Boyalı', const Color(0xFFFFE94D)),
          _buildStatusGuideItem('Değişmiş', Colors.purple),
          _buildStatusGuideItem('Belirtilmemiş', Colors.grey),
        ],
      ),
    );
  }
  
  Widget _buildStatusGuideItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
  
  Widget _buildPartListSection(Map<CarPart, ExpertizStatus> partStatuses) {
    // Durumlara göre parçaları grupla
    final groupedParts = <ExpertizStatus, List<CarPart>>{};
    
    for (final part in CarPart.values) {
      final status = partStatuses[part] ?? ExpertizStatus.original;
      groupedParts.putIfAbsent(status, () => []).add(part);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Parça Durumları',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...groupedParts.entries.map((entry) {
          final status = entry.key;
          final parts = entry.value;
          
          return _buildPartGroup(status, parts);
        }).toList(),
      ],
    );
  }
  
  Widget _buildPartGroup(ExpertizStatus status, List<CarPart> parts) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: status.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                status.displayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (parts.isEmpty)
            const Text(
              '-',
              style: TextStyle(color: Colors.grey),
            )
          else
            ...parts.map((part) => Padding(
              padding: const EdgeInsets.only(left: 22, top: 4),
              child: Text(
                part.displayName,
                style: const TextStyle(fontSize: 12),
              ),
            )).toList(),
        ],
      ),
    );
  }
  
  Widget _buildTramerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_money, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: 'Tramer tutarı: ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: 'Belirtilmemiş',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Durum seçici pop-up dialog'u
  void _showStatusSelectorDialog(CarPart part, ExpertizStatus currentStatus) {
    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder içinde state'i tut
        ExpertizStatus? tempSelectedStatus = currentStatus;
        
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text('Parça Durumu: ${part.displayName}'),
            content: ExpertizStatusSelector(
              selectedStatus: tempSelectedStatus,
              onStatusSelected: (status) {
                // Sadece görsel seçimi güncelle, henüz kaydetme
                setDialogState(() {
                  tempSelectedStatus = status;
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // İptal - hiçbir şey yapma, sadece dialog'u kapat
                  Navigator.of(context).pop();
                },
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () {
                  // Tamam - seçimi kaydet
                  if (tempSelectedStatus != null) {
                    Navigator.of(context).pop();
                    ref.read(expertizStatusProvider(widget.vehicleId).notifier)
                        .updatePartStatus(part, tempSelectedStatus!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${part.displayName} - ${tempSelectedStatus!.displayName} olarak işaretlendi'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('Tamam'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notlar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Ekspertiz notlarınızı buraya yazın...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // Notları kaydet
              ref.read(expertizStatusProvider(widget.vehicleId).notifier)
                  .updateNotes(value.isEmpty ? null : value);
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              // Manuel kaydet butonu
              ref.read(expertizStatusProvider(widget.vehicleId).notifier)
                  .updateNotes(_notesController.text.isEmpty ? null : _notesController.text);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notlar kaydedildi'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('Notları Kaydet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Map<CarPart, ExpertizStatus> partStatuses) {
    final stats = _calculateStats(partStatuses);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ekspertiz İstatistikleri',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Orijinal',
                  stats['original'] ?? 0,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Boyalı',
                  stats['painted'] ?? 0,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Değişen',
                  stats['replaced'] ?? 0,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Hasarlı',
                  stats['damaged'] ?? 0,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                ref.read(expertizStatusProvider(widget.vehicleId).notifier)
                    .deleteExpertiz();
                Navigator.of(context).pop();
              },
              child: const Text('Ekspertizi Sil'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _calculateStats(Map<CarPart, ExpertizStatus> partStatuses) {
    final stats = <String, int>{
      'original': 0,
      'painted': 0,
      'replaced': 0,
      'damaged': 0,
      'scratched': 0,
    };

    for (final status in partStatuses.values) {
      switch (status) {
        case ExpertizStatus.original:
          stats['original'] = (stats['original'] ?? 0) + 1;
          break;
        case ExpertizStatus.localPainted:
        case ExpertizStatus.painted:
          stats['painted'] = (stats['painted'] ?? 0) + 1;
          break;
        case ExpertizStatus.replaced:
          stats['replaced'] = (stats['replaced'] ?? 0) + 1;
          break;
        case ExpertizStatus.damaged:
          stats['damaged'] = (stats['damaged'] ?? 0) + 1;
          break;
        case ExpertizStatus.scratched:
          stats['scratched'] = (stats['scratched'] ?? 0) + 1;
          break;
      }
    }

    return stats;
  }
}
