import 'package:hive_flutter/hive_flutter.dart';
import 'package:otopark_demo/features/operations/domain/operation.dart';

abstract class OperationRepository {
  Future<List<Operation>> getOperations();
  Future<void> addOperation(Operation operation);
  Future<List<Operation>> getOperationsByVehicleId(String vehicleId);
}

class HiveOperationRepository implements OperationRepository {
  Box<Operation> get _operationBox => Hive.box<Operation>('operations');

  void init() {
    // Box zaten main.dart'ta açıldı
  }

  @override
  Future<List<Operation>> getOperations() async {
    return _operationBox.values.toList();
  }

  @override
  Future<void> addOperation(Operation operation) async {
    await _operationBox.put(operation.id, operation);
  }

  @override
  Future<List<Operation>> getOperationsByVehicleId(String vehicleId) async {
    return _operationBox.values
        .where((operation) => operation.vehicleId == vehicleId)
        .toList();
  }
}
