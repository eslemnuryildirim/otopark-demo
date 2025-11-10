import 'package:flutter/material.dart';

/// 🚗 Araç Seçim Görünümü
/// 
/// Araç parçalarının interaktif olarak seçilebildiği widget.
/// Resim üzerinde tıklanabilir alanlar tanımlar.
class CarSelectionView extends StatefulWidget {
  /// Araç ID'si
  final String vehicleId;
  
  /// Başlangıç verisi (opsiyonel)
  final Map<String, CarPart>? initialParts;
  
  /// Parça seçildiğinde çağrılan callback
  final Function(CarPart)? onPartSelected;
  
  /// Hasar bilgisi eklendiğinde çağrılan callback
  final Function(String partName, String damageType)? onDamageAdded;

  const CarSelectionView({
    super.key,
    required this.vehicleId,
    this.initialParts,
    this.onPartSelected,
    this.onDamageAdded,
  });

  @override
  State<CarSelectionView> createState() => _CarSelectionViewState();
}

class _CarSelectionViewState extends State<CarSelectionView> {
  /// Araç parçaları
  Map<String, CarPart> _parts = {};
  
  /// Seçili parça
  String? _selectedPart;

  @override
  void initState() {
    super.initState();
    _initializeParts();
  }

  /// Parçaları başlangıç durumuna getir
  void _initializeParts() {
    _parts = widget.initialParts ?? {};
    
    // Eksik parçaları ekle
    final defaultParts = {
      'front_bumper': CarPart(name: 'Ön Tampon', isSelected: false),
      'rear_bumper': CarPart(name: 'Arka Tampon', isSelected: false),
      'left_front_door': CarPart(name: 'Sol Ön Kapı', isSelected: false),
      'left_rear_door': CarPart(name: 'Sol Arka Kapı', isSelected: false),
      'right_front_door': CarPart(name: 'Sağ Ön Kapı', isSelected: false),
      'right_rear_door': CarPart(name: 'Sağ Arka Kapı', isSelected: false),
      'hood': CarPart(name: 'Kaput', isSelected: false),
      'roof': CarPart(name: 'Tavan', isSelected: false),
    };
    
    for (String partId in defaultParts.keys) {
      _parts.putIfAbsent(partId, () => defaultParts[partId]!);
    }
  }

  /// Parça seç
  void _selectPart(String partId) {
    setState(() {
      // Önceki seçimi temizle
      if (_selectedPart != null) {
        _parts[_selectedPart!] = _parts[_selectedPart!]!.copyWith(isSelected: false);
      }
      
      // Yeni seçimi yap
      _selectedPart = partId;
      _parts[partId] = _parts[partId]!.copyWith(isSelected: true);
    });
    
    // Callback çağır
    widget.onPartSelected?.call(_parts[partId]!);
    
    // Hasar bilgisi modalını aç
    _showDamageModal(partId);
  }

  /// Hasar bilgisi modalını göster
  void _showDamageModal(String partId) {
    final part = _parts[partId]!;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DamageModal(
        part: part,
        onDamageAdded: (damageType) {
          setState(() {
            _parts[partId] = _parts[partId]!.copyWith(damageType: damageType);
          });
          
          widget.onDamageAdded?.call(part.name, damageType);
          
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Araç Muayenesi'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.surface,
        child: Center(
          child: _buildCarInspection(),
        ),
      ),
    );
  }

  /// Araç muayene görünümünü oluştur
  Widget _buildCarInspection() {
    return Container(
      width: 400,
      height: 600,
      child: Stack(
        children: [
          // Tıklanabilir parçalar (görsel üzerinde)
          _buildClickableParts(),
        ],
      ),
    );
  }

  /// Araç resmini oluştur (placeholder)
  Widget _buildCarImage() {
    return Container(
      width: 400,
      height: 600,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              size: 120,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Araç Muayene Görünümü',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Parçalara dokunarak hasar bilgisi ekleyin',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Tıklanabilir parçaları oluştur (senin attığın görsele göre)
  Widget _buildClickableParts() {
    return Container(
      width: 400,
      height: 600,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F0), // Açık krem arka plan
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          // Merkezi gövde (Tavan)
          _buildPartArea(
            partId: 'roof',
            left: 100,
            top: 130,
            width: 200,
            height: 100,
            shape: 'rectangle',
          ),
          
          // Kaput (üstte)
          _buildPartArea(
            partId: 'hood',
            left: 90,
            top: 50,
            width: 220,
            height: 80,
            shape: 'rectangle',
          ),
          
          // Arka bölüm (altta)
          _buildPartArea(
            partId: 'rear_bumper',
            left: 90,
            top: 350,
            width: 220,
            height: 80,
            shape: 'rectangle',
          ),
          
          // Sol ön kapı
          _buildPartArea(
            partId: 'left_front_door',
            left: 50,
            top: 135,
            width: 50,
            height: 100,
            shape: 'trapezoid',
          ),
          
          // Sol arka kapı
          _buildPartArea(
            partId: 'left_rear_door',
            left: 50,
            top: 245,
            width: 50,
            height: 100,
            shape: 'trapezoid',
          ),
          
          // Sağ ön kapı
          _buildPartArea(
            partId: 'right_front_door',
            left: 300,
            top: 135,
            width: 50,
            height: 100,
            shape: 'trapezoid',
          ),
          
          // Sağ arka kapı
          _buildPartArea(
            partId: 'right_rear_door',
            left: 300,
            top: 245,
            width: 50,
            height: 100,
            shape: 'trapezoid',
          ),
        ],
      ),
    );
  }

  /// Parça alanını oluştur
  Widget _buildPartArea({
    required String partId,
    required double left,
    required double top,
    required double width,
    required double height,
    String shape = 'rectangle',
  }) {
    final part = _parts[partId]!;
    final isSelected = part.isSelected;
    
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => _selectPart(partId),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.blue.withOpacity(0.3)
                : Colors.grey[200]!.withOpacity(0.8), // Her zaman görünür
            border: Border.all(
              color: isSelected 
                  ? Colors.blue
                  : Colors.grey[400]!,
              width: isSelected ? 3 : 1,
            ),
            borderRadius: shape == 'trapezoid' 
                ? BorderRadius.circular(4)
                : BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          child: Center(
            child: Text(
              part.name,
              style: TextStyle(
                color: isSelected ? Colors.blue[800] : Colors.grey[700],
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

/// 🚗 Araç Parçası Modeli
class CarPart {
  /// Parça adı
  final String name;
  
  /// Seçili mi?
  final bool isSelected;
  
  /// Hasar tipi (opsiyonel)
  final String? damageType;
  
  /// Not (opsiyonel)
  final String? note;

  CarPart({
    required this.name,
    this.isSelected = false,
    this.damageType,
    this.note,
  });

  /// Kopyalama metodu
  CarPart copyWith({
    String? name,
    bool? isSelected,
    String? damageType,
    String? note,
  }) {
    return CarPart(
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
      damageType: damageType ?? this.damageType,
      note: note ?? this.note,
    );
  }
}

/// 🔧 Hasar Bilgisi Modalı
class _DamageModal extends StatefulWidget {
  final CarPart part;
  final Function(String) onDamageAdded;

  const _DamageModal({
    required this.part,
    required this.onDamageAdded,
  });

  @override
  State<_DamageModal> createState() => _DamageModalState();
}

class _DamageModalState extends State<_DamageModal> {
  String? _selectedDamageType;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _noteController.text = widget.part.note ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Text(
              '${widget.part.name} - Hasar Bilgisi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Hasar tipi seçimi
            Text(
              'Hasar Tipi:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Çizik',
                'Göçük',
                'Boyama',
                'Değişim',
                'Tamir',
                'Yok',
              ].map((damageType) {
                final isSelected = _selectedDamageType == damageType;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDamageType = damageType;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      damageType,
                      style: TextStyle(
                        color: isSelected 
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Not alanı
            Text(
              'Not:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Hasar hakkında detaylı bilgi...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            const Spacer(),
            
            // Kaydet butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedDamageType != null
                    ? () {
                        widget.onDamageAdded(_selectedDamageType!);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
