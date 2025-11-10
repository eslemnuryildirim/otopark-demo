import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/features/kroki/domain/entities/parking_slot.dart';
import 'package:otopark_demo/features/kroki/domain/utils/responsive_grid_layout.dart';
import 'package:otopark_demo/features/kroki/domain/utils/slot_label_generator.dart';
import 'package:otopark_demo/features/kroki/presentation/providers/parking_slots_provider.dart';
import 'package:otopark_demo/features/kroki/presentation/widgets/parking_slot_tile.dart';

class ParkingGridView extends ConsumerWidget {
  final List<ParkingSlot> slots;
  final Function(ParkingSlot)? onSlotTap;

  const ParkingGridView({
    super.key,
    required this.slots,
    this.onSlotTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
        final gridSizes = ResponsiveGridLayout.getBreakpointSizes(screenSize);
        
        return _buildGrid(context, ref, gridSizes);
      },
    );
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref, ResponsiveGridSizes gridSizes) {
    // Slot map oluştur (ID -> ParkSlot)
    final slotMap = {for (var slot in slots) slot.id: slot};

    // Layout yapısı
    final layout = _buildLayout();

    if (gridSizes.enableHorizontalScroll) {
      return _buildScrollableGrid(context, ref, layout, slotMap, gridSizes);
    } else {
      return _buildFixedGrid(context, ref, layout, slotMap, gridSizes);
    }
  }

  Widget _buildScrollableGrid(
    BuildContext context,
    WidgetRef ref,
    List<List<String>> layout,
    Map<String, ParkingSlot> slotMap,
    ResponsiveGridSizes gridSizes,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: layout.map((row) {
            if (row.isEmpty) {
              return const SizedBox(height: 20);
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: row.map((slotId) {
                  final slot = slotMap[slotId];
                  if (slot == null) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: gridSizes.slotSize,
                        height: gridSizes.slotSize,
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ParkingSlotTile(
                      slot: slot,
                      size: gridSizes.slotSize,
                      onTap: () => _handleSlotTap(context, ref, slot),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFixedGrid(
    BuildContext context,
    WidgetRef ref,
    List<List<String>> layout,
    Map<String, ParkingSlot> slotMap,
    ResponsiveGridSizes gridSizes,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: layout.map((row) {
            if (row.isEmpty) {
              return const SizedBox(height: 20);
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((slotId) {
                  final slot = slotMap[slotId];
                  if (slot == null) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: gridSizes.slotSize,
                        height: gridSizes.slotSize,
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ParkingSlotTile(
                      slot: slot,
                      size: gridSizes.slotSize,
                      onTap: () => _handleSlotTap(context, ref, slot),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<List<String>> _buildLayout() {
    return [
      // Servis alanları
      ['YIKAMA', 'BAKIM'],
      [], // Koridor
      // Ana park alanları - 6 satır x 13 sütun
      ['A-04', 'A-05', 'A-06', 'A-07', 'A-08', 'A-09', 'A-10', 'A-11', 'A-12', 'A-13', 'A-14', 'A-15', 'A-16'],
      ['B-04', 'B-05', 'B-06', 'B-07', 'B-08', 'B-09', 'B-10', 'B-11', 'B-12', 'B-13', 'B-14', 'B-15', 'B-16'],
      ['C-04', 'C-05', 'C-06', 'C-07', 'C-08', 'C-09', 'C-10', 'C-11', 'C-12', 'C-13', 'C-14', 'C-15', 'C-16'],
      [], // Koridor
      ['D-04', 'D-05', 'D-06', 'D-07', 'D-08', 'D-09', 'D-10', 'D-11', 'D-12', 'D-13', 'D-14', 'D-15', 'D-16'],
      ['E-04', 'E-05', 'E-06', 'E-07', 'E-08', 'E-09', 'E-10', 'E-11', 'E-12', 'E-13', 'E-14', 'E-15', 'E-16'],
      ['F-04', 'F-05', 'F-06', 'F-07', 'F-08', 'F-09', 'F-10', 'F-11', 'F-12', 'F-13', 'F-14', 'F-15', 'F-16'],
    ];
  }

  void _handleSlotTap(BuildContext context, WidgetRef ref, ParkingSlot slot) {
    // Seçili slot'u güncelle
    ref.read(selectedSlotProvider.notifier).state = slot.id;
    
    // Callback'i çağır
    onSlotTap?.call(slot);
  }
}

// Grid Legend Widget
class ParkingGridLegend extends StatelessWidget {
  const ParkingGridLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Renk Açıklaması',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildLegendItem('Boş', Colors.green),
                const SizedBox(width: 16),
                _buildLegendItem('Dolu', Colors.red),
                const SizedBox(width: 16),
                _buildLegendItem('Bakım', Colors.blue),
                const SizedBox(width: 16),
                _buildLegendItem('Rezerve', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

