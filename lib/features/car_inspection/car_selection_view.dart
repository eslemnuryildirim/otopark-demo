import 'package:flutter/material.dart';

class CarSelectionView extends StatefulWidget {
  final String vehicleId;
  final Map<String, CarPart>? initialParts;
  final Function(CarPart)? onPartSelected;
  final Function(Map<String, bool>)? onDamageSaved; // Tüm hasar bilgilerini kaydet
  final bool allowMultipleSelection;

  const CarSelectionView({
    super.key,
    required this.vehicleId,
    this.initialParts,
    this.onPartSelected,
    this.onDamageSaved,
    this.allowMultipleSelection = false,
  });

  @override
  State<CarSelectionView> createState() => _CarSelectionViewState();
}

class _CarSelectionViewState extends State<CarSelectionView> {
  Map<String, CarPart> _parts = {};
  Set<String> _selectedParts = {};

  @override
  void initState() {
    super.initState();
    _initializeParts();
  }

  void _initializeParts() {
    _parts = widget.initialParts ?? {};
    
    final defaultParts = {
      'front_bumper': CarPart(name: 'Ön Tampon', isSelected: false),
      'rear_bumper': CarPart(name: 'Arka Tampon', isSelected: false),
      'left_front_door': CarPart(name: 'Sol Ön Kapı', isSelected: false),
      'left_rear_door': CarPart(name: 'Sol Arka Kapı', isSelected: false),
      'right_front_door': CarPart(name: 'Sağ Ön Kapı', isSelected: false),
      'right_rear_door': CarPart(name: 'Sağ Arka Kapı', isSelected: false),
      'hood': CarPart(name: 'Kaput', isSelected: false),
      'roof': CarPart(name: 'Tavan', isSelected: false),
      'trunk': CarPart(name: 'Bagaj', isSelected: false),
    };
    
    for (String partId in defaultParts.keys) {
      _parts.putIfAbsent(partId, () => defaultParts[partId]!);
    }
  }

  void _togglePart(String partId) {
    setState(() {
      if (widget.allowMultipleSelection) {
        if (_selectedParts.contains(partId)) {
          _selectedParts.remove(partId);
          _parts[partId] = _parts[partId]!.copyWith(isSelected: false);
        } else {
          _selectedParts.add(partId);
          _parts[partId] = _parts[partId]!.copyWith(isSelected: true);
        }
      } else {
        if (_selectedParts.contains(partId)) {
          _selectedParts.clear();
          _parts[partId] = _parts[partId]!.copyWith(isSelected: false);
        } else {
          for (String selectedPartId in _selectedParts) {
            _parts[selectedPartId] = _parts[selectedPartId]!.copyWith(isSelected: false);
          }
          _selectedParts.clear();
          _selectedParts.add(partId);
          _parts[partId] = _parts[partId]!.copyWith(isSelected: true);
        }
      }
    });
    
    widget.onPartSelected?.call(_parts[partId]!);
    _showPartInfo(partId);
  }

  void _showPartInfo(String partId) {
    final part = _parts[partId]!;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Icon(
              Icons.directions_car,
              size: 48,
              color: part.isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              part.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: part.isSelected ? Colors.blue : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              part.isSelected ? 'Hasar var' : 'Hasar yok',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: part.isSelected ? Colors.red : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Kapat'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _togglePart(partId);
                    },
                    child: Text(part.isSelected ? 'Hasarı Kaldır' : 'Hasar Ekle'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Hasar bilgilerini kaydet
  void _saveDamageInfo() {
    final damageMap = <String, bool>{};
    
    for (String partId in _parts.keys) {
      damageMap[partId] = _parts[partId]!.isSelected;
    }
    
    widget.onDamageSaved?.call(damageMap);
    
    // Başarı mesajı göster
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hasar bilgileri kaydedildi'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Geri dön
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Araç Parça Seçimi'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (widget.allowMultipleSelection && _selectedParts.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedParts.clear();
                  for (String partId in _parts.keys) {
                    _parts[partId] = _parts[partId]!.copyWith(isSelected: false);
                  }
                });
              },
              child: const Text(
                'Temizle',
                style: TextStyle(color: Colors.white),
              ),
            ),
          TextButton(
            onPressed: _saveDamageInfo,
            child: const Text(
              'Kaydet',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.surface,
        child: Center(
          child: _buildCarSchematic(),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget? _buildBottomBar() {
    if (_selectedParts.isEmpty) return null;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hasarlı Parçalar: ${_selectedParts.length}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _selectedParts.map((partId) {
              final part = _parts[partId]!;
              return Chip(
                label: Text(part.name),
                backgroundColor: Colors.blue.withOpacity(0.1),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _togglePart(partId),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCarSchematic() {
    return Container(
      width: 400,
      height: 600,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildPartArea('roof', 100, 130, 200, 100, 'rectangle'),
          _buildPartArea('hood', 90, 50, 220, 80, 'rectangle'),
          _buildPartArea('trunk', 90, 350, 220, 80, 'rectangle'),
          _buildPartArea('front_bumper', 80, 20, 240, 30, 'rectangle'),
          _buildPartArea('rear_bumper', 80, 450, 240, 30, 'rectangle'),
          _buildPartArea('left_front_door', 50, 135, 50, 100, 'trapezoid'),
          _buildPartArea('left_rear_door', 50, 245, 50, 100, 'trapezoid'),
          _buildPartArea('right_front_door', 300, 135, 50, 100, 'trapezoid'),
          _buildPartArea('right_rear_door', 300, 245, 50, 100, 'trapezoid'),
        ],
      ),
    );
  }

  Widget _buildPartArea(String partId, double left, double top, double width, double height, String shape) {
    final part = _parts[partId]!;
    final isSelected = part.isSelected;
    
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => _togglePart(partId),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.red.withOpacity(0.3)
                : Colors.grey[200]!.withOpacity(0.6),
            border: Border.all(
              color: isSelected 
                  ? Colors.red
                  : Colors.grey[400]!,
              width: isSelected ? 3 : 1,
            ),
            borderRadius: shape == 'trapezoid' 
                ? BorderRadius.circular(4)
                : BorderRadius.circular(8),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.7,
              child: Text(
                part.name,
                style: TextStyle(
                  color: isSelected ? Colors.red[800] : Colors.grey[700],
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CarPart {
  final String name;
  final bool isSelected;

  CarPart({
    required this.name,
    this.isSelected = false,
  });

  CarPart copyWith({
    String? name,
    bool? isSelected,
  }) {
    return CarPart(
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
