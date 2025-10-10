import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'vehicle_status.g.dart';

/// Araç durumu enum'ı - Genişletilmiş versiyon
@HiveType(typeId: 1)
enum VehicleStatus {
  @HiveField(0)
  parked,
  @HiveField(1)
  inMaintenance,
  @HiveField(2)
  inWash,
  @HiveField(3)
  inDeliveryQueue,
  @HiveField(4)
  delivered,
  @HiveField(5)
  exited,
}

extension VehicleStatusExtension on VehicleStatus {
  String get displayName {
    switch (this) {
      case VehicleStatus.parked:
        return 'Parkta';
      case VehicleStatus.inMaintenance:
        return 'Bakımda';
      case VehicleStatus.inWash:
        return 'Yıkamada';
      case VehicleStatus.inDeliveryQueue:
        return 'Teslimat Alanında';
      case VehicleStatus.delivered:
        return 'Teslim Edildi';
      case VehicleStatus.exited:
        return 'Çıkış Yaptı';
    }
  }

  Color get color {
    switch (this) {
      case VehicleStatus.parked:
        return Colors.blue.shade600;
      case VehicleStatus.inMaintenance:
        return Colors.orange.shade600;
      case VehicleStatus.inWash:
        return Colors.lightBlue.shade600;
      case VehicleStatus.inDeliveryQueue:
        return Colors.purple.shade600;
      case VehicleStatus.delivered:
        return Colors.green.shade600;
      case VehicleStatus.exited:
        return Colors.grey.shade600;
    }
  }

  IconData get icon {
    switch (this) {
      case VehicleStatus.parked:
        return Icons.local_parking_rounded;
      case VehicleStatus.inMaintenance:
        return Icons.build_circle_rounded;
      case VehicleStatus.inWash:
        return Icons.local_car_wash_rounded;
      case VehicleStatus.inDeliveryQueue:
        return Icons.local_shipping_rounded;
      case VehicleStatus.delivered:
        return Icons.check_circle_rounded;
      case VehicleStatus.exited:
        return Icons.exit_to_app_rounded;
    }
  }
}
