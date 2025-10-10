import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'operation_type.g.dart';

/// İşlem tipi enum'ı - Genişletilmiş versiyon
@HiveType(typeId: 3)
enum OperationType {
  @HiveField(0)
  park,
  @HiveField(1)
  maintenance,
  @HiveField(2)
  wash,
  @HiveField(3)
  move,
  @HiveField(4)
  deliverQueue,
  @HiveField(5)
  delivered,
  @HiveField(6)
  exit,
}

extension OperationTypeExtension on OperationType {
  String get displayName {
    switch (this) {
      case OperationType.park:
        return 'Park Etme';
      case OperationType.maintenance:
        return 'Bakım';
      case OperationType.wash:
        return 'Yıkama';
      case OperationType.move:
        return 'Taşıma';
      case OperationType.deliverQueue:
        return 'Teslimat Alanına';
      case OperationType.delivered:
        return 'Teslim Edildi';
      case OperationType.exit:
        return 'Çıkış';
    }
  }

  IconData get icon {
    switch (this) {
      case OperationType.park:
        return Icons.local_parking_rounded;
      case OperationType.maintenance:
        return Icons.build_circle_rounded;
      case OperationType.wash:
        return Icons.local_car_wash_rounded;
      case OperationType.move:
        return Icons.move_up_rounded;
      case OperationType.deliverQueue:
        return Icons.local_shipping_rounded;
      case OperationType.delivered:
        return Icons.check_circle_rounded;
      case OperationType.exit:
        return Icons.exit_to_app_rounded;
    }
  }

  Color get color {
    switch (this) {
      case OperationType.park:
        return Colors.blue.shade600;
      case OperationType.maintenance:
        return Colors.orange.shade600;
      case OperationType.wash:
        return Colors.lightBlue.shade600;
      case OperationType.move:
        return Colors.indigo.shade600;
      case OperationType.deliverQueue:
        return Colors.purple.shade600;
      case OperationType.delivered:
        return Colors.green.shade600;
      case OperationType.exit:
        return Colors.grey.shade600;
    }
  }
}
