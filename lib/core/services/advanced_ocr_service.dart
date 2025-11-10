import 'dart:typed_data';
import 'package:otopark_demo/core/services/simple_ocr_service.dart';

/// Basit OCR Servisi - GitHub projesi gibi
class AdvancedOcrService {
  
  /// Ana OCR fonksiyonu - Basit ve etkili
  static Future<List<String>> extractVinWithOpenCV(Uint8List imageBytes) async {
    try {
      print('🔍 BASİT OCR başlatılıyor...');

      // Basit OCR ile VIN çıkar
      final vins = await SimpleOcrService.extractVin(imageBytes);

      if (vins.isNotEmpty) {
        print('✅ Basit OCR tamamlandı: ${vins.length} VIN bulundu');
        return vins;
      } else {
        print('❌ Basit OCR VIN bulamadı');
        return [];
      }

    } catch (e) {
      print('❌ Basit OCR hatası: $e');
      return [];
    }
  }
}
