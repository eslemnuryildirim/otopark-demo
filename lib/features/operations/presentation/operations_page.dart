import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otopark_demo/core/utils/formatters.dart';
import 'package:otopark_demo/features/operations/domain/operation_type.dart';
import 'package:otopark_demo/features/operations/providers/operation_providers.dart';
import 'package:otopark_demo/features/vehicles/providers/vehicle_providers.dart';

class OperationsPage extends ConsumerStatefulWidget {
  const OperationsPage({super.key});

  @override
  ConsumerState<OperationsPage> createState() => _OperationsPageState();
}

class _OperationsPageState extends ConsumerState<OperationsPage> {
  OperationType? _filterType;
  String _filterPlate = '';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final operationsAsync = ref.watch(operationsProvider);
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İşlemler'),
        // Theme'den otomatik renk alır (sarı yazı, koyu gri arka plan)
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: operationsAsync.when(
        data: (operations) {
          final filteredOperations = operations.where((operation) {
            final matchesType = _filterType == null || operation.type == _filterType;
            final matchesDate = (_startDate == null || operation.timestamp.isAfter(_startDate!)) &&
                (_endDate == null || operation.timestamp.isBefore(_endDate!.add(const Duration(days: 1))));

            // Plaka filtresi için araç bilgilerini al
            if (_filterPlate.isEmpty) {
              return matchesType && matchesDate;
            }

            final vehicle = vehiclesAsync.value?.where((v) => v.id == operation.vehicleId).firstOrNull;
            final matchesPlate = vehicle?.plate.toLowerCase().contains(_filterPlate.toLowerCase()) ?? false;

            return matchesType && matchesDate && matchesPlate;
          }).toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // En yeni üste

          if (filteredOperations.isEmpty) {
            return const Center(child: Text('Hiç işlem bulunamadı.'));
          }

          return ListView.builder(
            itemCount: filteredOperations.length,
            itemBuilder: (context, index) {
              final operation = filteredOperations[index];
              final vehicle = vehiclesAsync.value?.where((v) => v.id == operation.vehicleId).firstOrNull;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(operation.type.icon, color: operation.type.color),
                  title: Text(
                      '${operation.type.displayName} - ${vehicle?.plate ?? 'Bilinmiyor'}'),
                  subtitle: Text(
                      '${Formatters.formatDateTime(operation.timestamp)}\n${operation.note ?? ''}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrele'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('İşlem Tipi:'),
            ...OperationType.values.map((type) {
              return RadioListTile<OperationType?>(
                title: Text(type.displayName),
                value: type,
                groupValue: _filterType,
                onChanged: (value) {
                  setState(() => _filterType = value);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _filterType = null);
              Navigator.pop(context);
            },
            child: const Text('Temizle'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
