import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/features/kroki/domain/entities/parking_slot.dart';
import 'package:otopark_demo/features/kroki/domain/entities/parking_status.dart';
import 'package:otopark_demo/features/kroki/presentation/providers/parking_slots_provider.dart';

class ParkingSlotDetails extends ConsumerWidget {
  final String slotId;
  final VoidCallback onClose;

  const ParkingSlotDetails({
    super.key,
    required this.slotId,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(parkingSlotsProvider);
    
    return slotsAsync.when(
      data: (slots) {
        final slot = slots.firstWhere(
          (s) => s.id == slotId,
          orElse: () => throw Exception('Slot not found'),
        );
        return _buildDetails(context, ref, slot);
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(16),
        child: Text('Hata: $error'),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, WidgetRef ref, ParkingSlot slot) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Header
          Row(
            children: [
              Icon(
                _getIcon(slot.status),
                color: _getColor(slot.status),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  slot.label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Details
          _buildDetailRow('Durum', getStatusText(slot.status), _getColor(slot.status)),
          _buildDetailRow('Tip', slot.isServiceArea ? 'Servis Alanı' : 'Park Yeri', Colors.grey[600]!),
          
          if (slot.vehicleId != null)
            _buildDetailRow('Araç ID', slot.vehicleId!, Colors.blue),
          
          if (slot.occupiedAt != null)
            _buildDetailRow('Park Başlangıç', _formatDateTime(slot.occupiedAt!), Colors.green),
          
          if (slot.occupationDuration != null)
            _buildDetailRow('Park Süresi', slot.occupationDurationText, Colors.orange),
          
          const SizedBox(height: 16),
          
          // Actions
          _buildActions(context, ref, slot),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, ParkingSlot slot) {
    return Row(
      children: [
        if (slot.isOccupied) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  await ref.read(vacateSlotProvider(slot.id).future);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${slot.label} boşaltıldı')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hata: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.remove_circle_outline),
              label: const Text('Boşalt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              onClose();
              // TODO: Show assign vehicle dialog
            },
            icon: Icon(slot.isOccupied ? Icons.swap_horiz : Icons.add_circle_outline),
            label: Text(slot.isOccupied ? 'Değiştir' : 'Araç Ekle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: slot.isOccupied ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIcon(ParkingStatus status) {
    switch (status) {
      case ParkingStatus.available:
        return Icons.add_circle_outline;
      case ParkingStatus.occupied:
        return Icons.directions_car;
      case ParkingStatus.maintenance:
        return Icons.build;
      case ParkingStatus.reserved:
        return Icons.schedule;
    }
  }

  Color _getColor(ParkingStatus status) {
    switch (status) {
      case ParkingStatus.available:
        return Colors.green;
      case ParkingStatus.occupied:
        return Colors.red;
      case ParkingStatus.maintenance:
        return Colors.blue;
      case ParkingStatus.reserved:
        return Colors.orange;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
