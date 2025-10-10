import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/features/operations/data/operation_repository.dart';
import 'package:otopark_demo/features/operations/domain/operation.dart';

final operationRepositoryProvider = Provider<OperationRepository>((ref) {
  final repository = HiveOperationRepository();
  repository.init();
  return repository;
});

final operationsProvider =
    AsyncNotifierProvider<OperationsNotifier, List<Operation>>(
  OperationsNotifier.new,
);

class OperationsNotifier extends AsyncNotifier<List<Operation>> {
  @override
  Future<List<Operation>> build() async {
    return ref.watch(operationRepositoryProvider).getOperations();
  }

  Future<void> addOperation(Operation operation) async {
    state = const AsyncValue.loading();
    await ref.read(operationRepositoryProvider).addOperation(operation);
    state = AsyncValue.data(
      await ref.read(operationRepositoryProvider).getOperations(),
    );
  }

  Future<List<Operation>> getOperationsByVehicleId(String vehicleId) async {
    return ref
        .read(operationRepositoryProvider)
        .getOperationsByVehicleId(vehicleId);
  }
}
