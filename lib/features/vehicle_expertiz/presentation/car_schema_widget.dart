import 'package:flutter/material.dart';
import '../domain/car_part.dart';
import '../domain/expertiz_status.dart';

/// Araç şeması widget'ı - Görseldeki gibi parçalara ayrılmış araç
class CarSchemaWidget extends StatelessWidget {
  final Map<CarPart, ExpertizStatus> partStatuses;
  final Function(CarPart part)? onPartTap;
  final bool isInteractive;
  final double size;

  const CarSchemaWidget({
    super.key,
    required this.partStatuses,
    this.onPartTap,
    this.isInteractive = true,
    this.size = 300.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.6,
      child: Stack(
        children: [
          // Ana gövde (Tavan/Kaput/Bagaj)
          _buildCenterBody(),
          
          // Ön tampon ve farlar
          _buildFrontBumper(),
          
          // Arka tampon ve stop lambaları
          _buildRearBumper(),
          
          // Sol taraf kapılar ve çamurluklar
          _buildLeftSide(),
          
          // Sağ taraf kapılar ve çamurluklar
          _buildRightSide(),
        ],
      ),
    );
  }

  /// Ana gövde (Tavan/Kaput/Bagaj)
  Widget _buildCenterBody() {
    return Positioned(
      left: size * 0.25,
      top: size * 0.1,
      child: Column(
        children: [
          // Kaput
          _buildPartArea(
            CarPart.hood,
            Rect.fromLTWH(0, 0, size * 0.5, size * 0.15),
            'KAPUT',
          ),
          // Tavan
          _buildPartArea(
            CarPart.roof,
            Rect.fromLTWH(0, 0, size * 0.5, size * 0.2),
            'TAVAN',
          ),
          // Bagaj
          _buildPartArea(
            CarPart.trunk,
            Rect.fromLTWH(0, 0, size * 0.5, size * 0.15),
            'BAGAJ',
          ),
        ],
      ),
    );
  }

  /// Ön tampon ve farlar
  Widget _buildFrontBumper() {
    return Positioned(
      left: size * 0.2,
      top: 0,
      child: _buildPartArea(
        CarPart.frontBumper,
        Rect.fromLTWH(0, 0, size * 0.6, size * 0.1),
        'ÖN TAMPON',
      ),
    );
  }

  /// Arka tampon ve stop lambaları
  Widget _buildRearBumper() {
    return Positioned(
      left: size * 0.2,
      bottom: 0,
      child: _buildPartArea(
        CarPart.rearBumper,
        Rect.fromLTWH(0, 0, size * 0.6, size * 0.1),
        'ARKA TAMPON',
      ),
    );
  }

  /// Sol taraf kapılar ve çamurluklar
  Widget _buildLeftSide() {
    return Positioned(
      left: 0,
      top: size * 0.1,
      child: Column(
        children: [
          // Ön sol kapı/çamurluk
          _buildPartArea(
            CarPart.frontLeftDoor,
            Rect.fromLTWH(0, 0, size * 0.2, size * 0.25),
            'ÖN SOL',
          ),
          // Arka sol kapı/çamurluk
          _buildPartArea(
            CarPart.rearLeftDoor,
            Rect.fromLTWH(0, 0, size * 0.2, size * 0.25),
            'ARKA SOL',
          ),
        ],
      ),
    );
  }

  /// Sağ taraf kapılar ve çamurluklar
  Widget _buildRightSide() {
    return Positioned(
      right: 0,
      top: size * 0.1,
      child: Column(
        children: [
          // Ön sağ kapı/çamurluk
          _buildPartArea(
            CarPart.frontRightDoor,
            Rect.fromLTWH(0, 0, size * 0.2, size * 0.25),
            'ÖN SAĞ',
          ),
          // Arka sağ kapı/çamurluk
          _buildPartArea(
            CarPart.rearRightDoor,
            Rect.fromLTWH(0, 0, size * 0.2, size * 0.25),
            'ARKA SAĞ',
          ),
        ],
      ),
    );
  }

  /// Parça alanı oluştur
  Widget _buildPartArea(CarPart part, Rect bounds, String label) {
    final status = partStatuses[part] ?? ExpertizStatus.original;
    final isSelected = partStatuses.containsKey(part);

    Widget partWidget = Container(
      width: bounds.width,
      height: bounds.height,
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.3),
        border: Border.all(
          color: status.color,
          width: isSelected ? 3 : 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: status.color,
            fontWeight: FontWeight.bold,
            fontSize: bounds.width * 0.08,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );

    if (isInteractive && onPartTap != null) {
      return GestureDetector(
        onTap: () => onPartTap!(part),
        child: partWidget,
      );
    }

    return partWidget;
  }
}

/// Ekspertiz durumu seçici widget'ı
class ExpertizStatusSelector extends StatelessWidget {
  final ExpertizStatus? selectedStatus;
  final Function(ExpertizStatus) onStatusSelected;

  const ExpertizStatusSelector({
    super.key,
    this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Durum Seçin:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ExpertizStatus.values.map((status) {
              final isSelected = selectedStatus == status;
              return GestureDetector(
                onTap: () => onStatusSelected(status),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? status.color : status.color.withOpacity(0.1),
                    border: Border.all(
                      color: status.color,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        status.icon,
                        color: isSelected ? Colors.white : status.color,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        status.displayName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : status.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

