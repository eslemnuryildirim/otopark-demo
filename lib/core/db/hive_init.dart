import 'package:hive_flutter/hive_flutter.dart';
import 'package:otopark_demo/features/counters/domain/counters.dart';
import 'package:otopark_demo/features/operations/domain/operation.dart';
import 'package:otopark_demo/features/operations/domain/operation_type.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle_status.dart';
import 'package:otopark_demo/features/park_slots/domain/park_slot.dart';
import 'package:otopark_demo/core/db/duration_adapter.dart';

Future<void> initHive() async {
  await Hive.initFlutter();

  // Register Adapters (TypeId'ler: 0-5, 100)
  Hive.registerAdapter(VehicleAdapter()); // typeId: 0
  Hive.registerAdapter(VehicleStatusAdapter()); // typeId: 1
  Hive.registerAdapter(OperationAdapter()); // typeId: 2
  Hive.registerAdapter(OperationTypeAdapter()); // typeId: 3
  Hive.registerAdapter(CountersAdapter()); // typeId: 4
  Hive.registerAdapter(ParkSlotAdapter()); // typeId: 5
  Hive.registerAdapter(DurationAdapter()); // typeId: 100 - Duration için özel adapter

  // Open Boxes
  await Hive.openBox<Vehicle>('vehicles');
  await Hive.openBox<Operation>('operations');
  await Hive.openBox<Counters>('counters');
  await Hive.openBox<ParkSlot>('park_slots');
  
  // İlk açılışta counters yoksa oluştur
  final counterBox = Hive.box<Counters>('counters');
  if (counterBox.isEmpty) {
    await counterBox.put('app_counters', Counters());
  }
  
  // İlk açılışta park slotları oluştur
  final slotBox = Hive.box<ParkSlot>('park_slots');
  if (slotBox.isEmpty) {
    await _initializeDefaultSlots(slotBox);
  }
  
  // İlk açılışta mock araçlar ve sayaçlar oluştur
  final vehicleBox = Hive.box<Vehicle>('vehicles');
  if (vehicleBox.isEmpty) {
    await _seedMockVehicles(vehicleBox, counterBox);
  }
}

Future<void> _seedMockVehicles(Box<Vehicle> vehicleBox, Box<Counters> counterBox) async {
  final now = DateTime.now();
  final vehicles = [
    Vehicle(
      id: 'mock-1',
      plate: '34 ABC 123',
      brand: 'BMW',
      model: 'M3',
      color: 'Siyah',
      status: VehicleStatus.parked,
      currentParkSlotId: 'A1',
      parkStartAt: now.subtract(const Duration(minutes: 45)),
      createdAt: now,
      updatedAt: now,
      damagedParts: const {},
    ),
    Vehicle(
      id: 'mock-2',
      plate: '06 DEF 456',
      brand: 'Mercedes',
      model: 'C200',
      color: 'Beyaz',
      status: VehicleStatus.inMaintenance,
      createdAt: now,
      updatedAt: now,
      damagedParts: const {},
    ),
    Vehicle(
      id: 'mock-3',
      plate: '35 GHI 789',
      brand: 'Audi',
      model: 'A4',
      color: 'Gri',
      status: VehicleStatus.inWash,
      createdAt: now,
      updatedAt: now,
      damagedParts: const {},
    ),
    Vehicle(
      id: 'mock-4',
      plate: '16 JKL 012',
      brand: 'Renault',
      model: 'Clio',
      color: 'Mavi',
      status: VehicleStatus.exited,
      createdAt: now,
      updatedAt: now,
      damagedParts: const {},
    ),
  ];

  // Araçları kaydet
  for (var vehicle in vehicles) {
    await vehicleBox.put(vehicle.id, vehicle);
  }
  
  // Sayaçları hesapla
  final counters = Counters(
    totalPark: 1,        // 1 araç parked
    totalMaintenance: 1, // 1 araç inMaintenance
    totalWash: 1,        // 1 araç inWash
    totalDelivered: 0,
    activePark: 1,       // 1 araç hala parked
    activeMaintenance: 1,// 1 araç hala inMaintenance
    activeWash: 1,       // 1 araç hala inWash
  );
  await counterBox.put('app_counters', counters);
  
  // A1 slotunu dolu yap
  final slotBox = Hive.box<ParkSlot>('park_slots');
  final slot = slotBox.get('A1');
  if (slot != null) {
    await slotBox.put('A1', slot.copyWith(isOccupied: true, vehicleId: 'mock-1'));
  }
}

Future<void> _initializeDefaultSlots(Box<ParkSlot> slotBox) async {
  // Servis alanları
  final serviceSlots = [
    ParkSlot(id: 'YIK1', label: 'İç Yıkama', isServiceArea: true),
    ParkSlot(id: 'YIK2', label: 'Dış Yıkama', isServiceArea: true),
    ParkSlot(id: 'CAM1', label: 'Cam-Kaput', isServiceArea: true),
    ParkSlot(id: 'DET1', label: 'Detaylı İç Temizlik', isServiceArea: true),
    ParkSlot(id: 'PAS1', label: 'Pasta Cila (İkinci El)', isServiceArea: true),
    ParkSlot(id: 'PAS2', label: 'Pasta Cila (0 Araç)', isServiceArea: true),
  ];

  // Ana park alanları - 13 spot per row
  final rows = ['A', 'B', 'C', 'D', 'E', 'F'];
  final parkSlots = <ParkSlot>[];
  
  for (var row in rows) {
    for (var i = 1; i <= 13; i++) {
      parkSlots.add(
        ParkSlot(
          id: '$row$i',
          label: '$row-${i.toString().padLeft(2, '0')}',
          isServiceArea: false,
        ),
      );
    }
  }

  // Tüm slotları kaydet
  for (var slot in [...serviceSlots, ...parkSlots]) {
    await slotBox.put(slot.id, slot);
  }
}
