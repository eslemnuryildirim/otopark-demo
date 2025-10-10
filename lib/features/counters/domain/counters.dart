import 'package:hive/hive.dart';

part 'counters.g.dart';

/// Sayaçlar modeli - Genişletilmiş versiyon
@HiveType(typeId: 4)
class Counters extends HiveObject {
  @HiveField(0)
  int totalPark;
  
  @HiveField(1)
  int totalMaintenance;
  
  @HiveField(2)
  int totalWash;
  
  @HiveField(3)
  int totalDelivered;
  
  @HiveField(4)
  int activePark; // Şu an parkta olan araç sayısı
  
  @HiveField(5)
  int activeMaintenance; // Şu an bakımda olan araç sayısı
  
  @HiveField(6)
  int activeWash; // Şu an yıkamada olan araç sayısı

  Counters({
    this.totalPark = 0,
    this.totalMaintenance = 0,
    this.totalWash = 0,
    this.totalDelivered = 0,
    this.activePark = 0,
    this.activeMaintenance = 0,
    this.activeWash = 0,
  });

  Counters copyWith({
    int? totalPark,
    int? totalMaintenance,
    int? totalWash,
    int? totalDelivered,
    int? activePark,
    int? activeMaintenance,
    int? activeWash,
  }) {
    return Counters(
      totalPark: totalPark ?? this.totalPark,
      totalMaintenance: totalMaintenance ?? this.totalMaintenance,
      totalWash: totalWash ?? this.totalWash,
      totalDelivered: totalDelivered ?? this.totalDelivered,
      activePark: activePark ?? this.activePark,
      activeMaintenance: activeMaintenance ?? this.activeMaintenance,
      activeWash: activeWash ?? this.activeWash,
    );
  }
}
