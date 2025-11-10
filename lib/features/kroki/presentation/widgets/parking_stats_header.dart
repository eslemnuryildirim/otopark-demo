import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/features/kroki/presentation/providers/parking_slots_provider.dart';
import 'package:otopark_demo/features/kroki/presentation/widgets/parking_slot_tile.dart';

class ParkingStatsHeader extends ConsumerWidget {
  const ParkingStatsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalSlots = ref.watch(totalSlotsCountProvider);
    final occupiedSlots = ref.watch(occupiedSlotsCountProvider);
    final availableSlots = ref.watch(availableSlotsCountProvider);
    final serviceSlots = ref.watch(serviceSlotsCountProvider);
    final occupiedServiceSlots = ref.watch(occupiedServiceSlotsCountProvider);
    final availableServiceSlots = ref.watch(availableServiceSlotsCountProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ana istatistikler
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Toplam',
                  totalSlots,
                  Colors.blue,
                  Icons.grid_view,
                ),
                _buildStatItem(
                  'Dolu',
                  occupiedSlots,
                  Colors.red,
                  Icons.directions_car,
                ),
                _buildStatItem(
                  'Boş',
                  availableSlots,
                  Colors.green,
                  Icons.add_circle_outline,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Servis alanı istatistikleri
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Servis',
                  serviceSlots,
                  Colors.orange,
                  Icons.build,
                ),
                _buildStatItem(
                  'S.Dolu',
                  occupiedServiceSlots,
                  Colors.deepOrange,
                  Icons.build_circle,
                ),
                _buildStatItem(
                  'S.Boş',
                  availableServiceSlots,
                  Colors.lightBlue,
                  Icons.build_outlined,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Doluluk oranı
            _buildOccupancyRate(occupiedSlots, totalSlots),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedCounter(
          value: value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildOccupancyRate(int occupied, int total) {
    final rate = total > 0 ? (occupied / total * 100) : 0.0;
    final color = rate > 80 ? Colors.red : rate > 60 ? Colors.orange : Colors.green;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.pie_chart,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Doluluk Oranı: ${rate.toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Compact Stats Header (daha küçük ekranlar için)
class CompactParkingStatsHeader extends ConsumerWidget {
  const CompactParkingStatsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalSlots = ref.watch(totalSlotsCountProvider);
    final occupiedSlots = ref.watch(occupiedSlotsCountProvider);
    final availableSlots = ref.watch(availableSlotsCountProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCompactStatItem('Toplam', totalSlots, Colors.blue),
          _buildCompactStatItem('Dolu', occupiedSlots, Colors.red),
          _buildCompactStatItem('Boş', availableSlots, Colors.green),
        ],
      ),
    );
  }

  Widget _buildCompactStatItem(String label, int value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedCounter(
          value: value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

