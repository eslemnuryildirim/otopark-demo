import 'package:hive/hive.dart';

/// Duration için Hive TypeAdapter
/// 
/// Hive, dart:core türlerinden Duration'ı otomatik olarak desteklemez.
/// Bu adapter, Duration'ı millisecond cinsinden int'e dönüştürür.
class DurationAdapter extends TypeAdapter<Duration> {
  @override
  final int typeId = 100; // Yüksek bir typeId kullanıyoruz çakışmaması için

  @override
  Duration read(BinaryReader reader) {
    final milliseconds = reader.readInt();
    return Duration(milliseconds: milliseconds);
  }

  @override
  void write(BinaryWriter writer, Duration obj) {
    writer.writeInt(obj.inMilliseconds);
  }
}

