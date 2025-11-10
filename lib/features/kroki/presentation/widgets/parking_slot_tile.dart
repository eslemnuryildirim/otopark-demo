import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/features/kroki/domain/entities/parking_slot.dart';
import 'package:otopark_demo/features/kroki/domain/entities/parking_status.dart';
import 'package:otopark_demo/features/kroki/presentation/providers/parking_slots_provider.dart';

class ParkingSlotTile extends ConsumerWidget {
  final ParkingSlot slot;
  final double size;
  final VoidCallback? onTap;
  final bool showDetails;

  const ParkingSlotTile({
    super.key,
    required this.slot,
    required this.size,
    this.onTap,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(selectedSlotProvider) == slot.id;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: _getGradient(slot.status),
          border: Border.all(
            color: isSelected ? Colors.yellow : Colors.white24,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _getShadowColor(slot.status),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              _getIcon(slot.status),
              size: size * 0.3,
              color: Colors.white,
            ),
            
            if (showDetails) ...[
              const SizedBox(height: 4),
              
              // Label
              Text(
                slot.label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Status
              if (slot.isOccupied) ...[
                const SizedBox(height: 2),
                Text(
                  getStatusText(slot.status),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: size * 0.08,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              // Duration (if occupied)
              if (slot.isOccupied && slot.occupationDuration != null) ...[
                const SizedBox(height: 2),
                Text(
                  slot.occupationDurationText,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: size * 0.07,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  LinearGradient _getGradient(ParkingStatus status) {
    switch (status) {
      case ParkingStatus.available:
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ParkingStatus.occupied:
        return const LinearGradient(
          colors: [Color(0xFFEF5350), Color(0xFFC62828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ParkingStatus.maintenance:
        return const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ParkingStatus.reserved:
        return const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFE65100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getShadowColor(ParkingStatus status) {
    switch (status) {
      case ParkingStatus.available:
        return Colors.green.withOpacity(0.3);
      case ParkingStatus.occupied:
        return Colors.red.withOpacity(0.3);
      case ParkingStatus.maintenance:
        return Colors.blue.withOpacity(0.3);
      case ParkingStatus.reserved:
        return Colors.orange.withOpacity(0.3);
    }
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
}

// Animated Counter Widget
class AnimatedCounter extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = IntTween(
      begin: _previousValue,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = _animation.value;
      _animation = IntTween(
        begin: _previousValue,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${_animation.value}',
          style: widget.style,
        );
      },
    );
  }
}
