import 'dart:typed_data';

/// Basit OCR Servisi - Mock VIN'ler
class SimpleOcr {
  
  /// Mock VIN listesi
  static final List<String> _mockVins = [
    'WBA12345678901234',
    'VF1ABC12345678901', 
    '1HGBH41JXMN109186',
    'WDB12345678901234',
    'UU1XYZ98765432109'
  ];
  
  /// Basit VIN çıkarma - Mock
  static Future<List<String>> extractVin(Uint8List imageBytes) async {
    // 1-2 saniye bekle (gerçekçi OCR simülasyonu)
    await Future.delayed(const Duration(seconds: 1));
    
    // Rastgele 1-3 VIN döndür
    final random = DateTime.now().millisecond;
    final count = (random % 3) + 1;
    
    final results = <String>[];
    for (int i = 0; i < count; i++) {
      final index = (random + i) % _mockVins.length;
      results.add(_mockVins[index]);
    }
    
    print('🎯 ${results.length} VIN bulundu: ${results.join(', ')}');
    return results;
  }
}

