import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/car_part.dart';
import '../domain/expertiz_status.dart';
import '../providers/expertiz_provider.dart';
import 'car_schema_widget.dart';

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
  CarPart? selectedPart;
  ExpertizStatus? selectedStatus;
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
          
          // Ana içerik
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Araç şeması
                  _buildCarSchema(expertizStatus),
                  
                  const SizedBox(height: 24),
                  
                  // Durum seçici
                  if (selectedPart != null) _buildStatusSelector(),
                  
                  const SizedBox(height: 24),
                  
                  // Notlar
                  _buildNotesSection(),
                  
                  const SizedBox(height: 24),
                  
                  // İstatistikler
                  _buildStatsSection(expertizStatus),
                ],
              ),
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

  Widget _buildCarSchema(Map<CarPart, ExpertizStatus> partStatuses) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: CarSchemaWidget(
        partStatuses: partStatuses,
        onPartTap: (part) {
          setState(() {
            selectedPart = part;
            selectedStatus = partStatuses[part];
          });
        },
        size: 280,
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seçili Parça: ${selectedPart!.displayName}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ExpertizStatusSelector(
            selectedStatus: selectedStatus,
            onStatusSelected: (status) {
              setState(() {
                selectedStatus = status;
              });
              ref.read(expertizStatusProvider(widget.vehicleId).notifier)
                  .updatePartStatus(selectedPart!, status);
            },
          ),
        ],
      ),
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
