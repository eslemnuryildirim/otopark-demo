import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/vehicle_expertiz.dart';
import '../domain/car_part.dart';
import '../domain/expertiz_status.dart';

/// Ekspertiz repository provider
final expertizRepositoryProvider = Provider<ExpertizRepository>((ref) {
  return MockExpertizRepository();
});

/// Araç ekspertiz provider'ı
final vehicleExpertizProvider = FutureProvider.family<VehicleExpertiz?, String>((ref, vehicleId) async {
  final repository = ref.read(expertizRepositoryProvider);
  return await repository.getVehicleExpertiz(vehicleId);
});

/// Ekspertiz durumu provider'ı
final expertizStatusProvider = StateNotifierProvider.family<ExpertizStatusNotifier, Map<CarPart, ExpertizStatus>, String>((ref, vehicleId) {
  return ExpertizStatusNotifier(vehicleId, ref.read(expertizRepositoryProvider));
});

/// Ekspertiz durumu notifier'ı
class ExpertizStatusNotifier extends StateNotifier<Map<CarPart, ExpertizStatus>> {
  final String vehicleId;
  final ExpertizRepository repository;
  final Uuid _uuid = const Uuid();
  
  VehicleExpertiz? _currentExpertiz; // Mevcut ekspertizi sakla
  String? _currentNotes; // Mevcut notları sakla

  ExpertizStatusNotifier(this.vehicleId, this.repository) : super({}) {
    _loadExpertiz();
  }

  Future<void> _loadExpertiz() async {
    _currentExpertiz = await repository.getVehicleExpertiz(vehicleId);
    if (_currentExpertiz != null) {
      state = _currentExpertiz!.partStatuses;
      _currentNotes = _currentExpertiz!.notes;
    }
  }

  /// Parça durumunu güncelle
  Future<void> updatePartStatus(CarPart part, ExpertizStatus status) async {
    final newState = Map<CarPart, ExpertizStatus>.from(state);
    newState[part] = status;
    state = newState;

    await _saveExpertiz();
  }

  /// Notları güncelle
  Future<void> updateNotes(String? notes) async {
    _currentNotes = notes;
    await _saveExpertiz();
  }

  /// Ekspertizi kaydet
  Future<void> _saveExpertiz() async {
    final expertiz = VehicleExpertiz(
      vehicleId: vehicleId,
      id: _currentExpertiz?.id ?? _uuid.v4(), // Mevcut ID'yi kullan veya yeni oluştur
      partStatuses: state,
      notes: _currentNotes,
      createdAt: _currentExpertiz?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      inspectorName: _currentExpertiz?.inspectorName,
      photos: _currentExpertiz?.photos,
    );

    _currentExpertiz = expertiz;
    await repository.saveVehicleExpertiz(expertiz);
    print('✅ Ekspertiz kaydedildi: ${expertiz.notes}');
  }

  /// Ekspertizi sil
  Future<void> deleteExpertiz() async {
    await repository.deleteVehicleExpertiz(vehicleId);
    state = {};
  }
}

/// Mock ekspertiz repository
class MockExpertizRepository implements ExpertizRepository {
  final Map<String, VehicleExpertiz> _expertizMap = {};

  @override
  Future<VehicleExpertiz?> getVehicleExpertiz(String vehicleId) async {
    return _expertizMap[vehicleId];
  }

  @override
  Future<void> saveVehicleExpertiz(VehicleExpertiz expertiz) async {
    _expertizMap[expertiz.vehicleId] = expertiz;
  }

  @override
  Future<void> deleteVehicleExpertiz(String vehicleId) async {
    _expertizMap.remove(vehicleId);
  }

  @override
  Future<List<VehicleExpertiz>> getAllExpertiz() async {
    return _expertizMap.values.toList();
  }
}

/// Ekspertiz repository interface
abstract class ExpertizRepository {
  Future<VehicleExpertiz?> getVehicleExpertiz(String vehicleId);
  Future<void> saveVehicleExpertiz(VehicleExpertiz expertiz);
  Future<void> deleteVehicleExpertiz(String vehicleId);
  Future<List<VehicleExpertiz>> getAllExpertiz();
}
