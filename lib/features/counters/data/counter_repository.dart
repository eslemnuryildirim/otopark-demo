import 'package:hive_flutter/hive_flutter.dart';
import 'package:otopark_demo/features/counters/domain/counters.dart';

abstract class CounterRepository {
  Future<Counters> getCounters();
  Future<void> updateCounters(Counters counters);
  Future<void> resetCounters();
}

class HiveCounterRepository implements CounterRepository {
  Box<Counters> get _counterBox => Hive.box<Counters>('counters');
  final String _counterKey = 'app_counters';

  void init() {
    // Box zaten main.dart'ta açıldı
  }

  @override
  Future<Counters> getCounters() async {
    return _counterBox.get(_counterKey)!;
  }

  @override
  Future<void> updateCounters(Counters counters) async {
    await _counterBox.put(_counterKey, counters);
  }

  @override
  Future<void> resetCounters() async {
    await _counterBox.put(_counterKey, Counters());
  }
}
