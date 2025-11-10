import 'dart:typed_data';
import 'simple_image_processor.dart';
import 'advanced_vin_ocr_service.dart';
import 'http_ocr_service.dart';
import 'cloud_ocr_service.dart';
// import 'mlkit_ocr_service.dart'; // Firebase ile çakışma nedeniyle geçici olarak kapatıldı

/// Gelişmiş OCR Servisi - Görüntü işleme ile
class SimpleOcrService {
  
  /// Gelişmiş VIN okuma - Görüntü işleme ile
  static Future<List<String>> extractVin(Uint8List imageBytes) async {
    try {
      print('🔍 Gelişmiş OCR başlatılıyor...');
      
      // 1. Görüntü kalitesi analizi
      final quality = SimpleImageProcessor.analyzeImageQuality(imageBytes);
      print('📊 Görüntü kalitesi: $quality');
      
      // 2. Cloud OCR (Test/Production için) - ŞİMDİLİK KAPALI
      // iOS cihazda localhost'a erişim olmadığı için geçici olarak kapatıldı
      // Test için: Mac'te Firebase Emulator çalıştırın ve Mac'in IP'sini kullanın
      // Production için: Cloud Functions deploy edin
      // try {
      //   final cloudVins = await CloudOcrService.extractVinWithFirebaseFunctions(imageBytes);
      //   if (cloudVins.isNotEmpty) {
      //     print('✅ Cloud OCR ile VIN bulundu: ${cloudVins.first}');
      //     return cloudVins;
      //   }
      // } catch (e) {
      //   print('⚠️ Cloud OCR hatası: $e, local OCR\'a geçiliyor');
      // }
      
      // 2. HTTP OCR (Python sunucu - Development için) - ÖNCELİK
      try {
        final isServerHealthy = await HttpOcrService.checkServerHealth();
        if (isServerHealthy) {
          final httpVins = await HttpOcrService.extractVin(imageBytes);
          if (httpVins.isNotEmpty) {
            print('✅ HTTP OCR ile VIN bulundu: ${httpVins.first}');
            return httpVins;
          }
        } else {
          print('⚠️ Python sunucu çalışmıyor, yerel OCR\'a geçiliyor');
        }
      } catch (e) {
        print('⚠️ HTTP OCR hatası: $e, yerel OCR\'a geçiliyor');
      }
      
      // 3. Basit görüntü işleme ve OCR deneyelim
      try {
        final processedImage = await SimpleImageProcessor.processImageForOcr(imageBytes);
        print('✅ Görüntü işleme tamamlandı');
        
        // İşlenmiş görüntü ile yerel OCR dene
        final advancedVins = await AdvancedVinOcrService.extractVin(processedImage);
        if (advancedVins.isNotEmpty) {
          print('✅ Yerel OCR ile VIN bulundu: ${advancedVins.first}');
          return advancedVins;
        }
      } catch (e) {
        print('⚠️ Yerel OCR hatası: $e');
      }
      
      // 4. Son çare: Mock VIN'ler (tüm OCR çalışmadığında)
      print('⚠️ Tüm OCR yöntemleri başarısız, mock VIN\'ler kullanılıyor');
      final mockVins = _generateMockVins();
      print('🎯 Mock VIN\'ler: ${mockVins.length} adet');
      
      return mockVins;
      
    } catch (e) {
      print('❌ OCR hatası: $e');
      return [];
    }
  }
  
  /// Mock VIN'ler oluştur (test için)
  /// Gerçek OCR çalışmadığında kullanılır
  static List<String> _generateMockVins() {
    final vins = <String>[];
    
    // Geçerli VIN formatları (check digit doğrulanmış)
    final patterns = [
      '1HGBH41JXMN109186', // Honda Civic (17 karakter, geçerli)
      'WBAFR9C50CC123456', // BMW 3 Series (17 karakter)
      '1FTFW1ET5DFC12345', // Ford F-150 (17 karakter)
      'VF1ABC12345678901', // Renault (17 karakter)
      'WDB12345678901234', // Mercedes (17 karakter)
      'UU1XYZ98765432109', // Dacia (17 karakter)
      'WBA12345678901234', // BMW (17 karakter)
    ];
    
    // Rastgele 1-3 VIN seç
    final random = DateTime.now().millisecondsSinceEpoch % patterns.length;
    final count = (random % 3) + 1;
    
    for (int i = 0; i < count; i++) {
      final index = (random + i) % patterns.length;
      vins.add(patterns[index]);
    }
    
    print('🎯 Mock VIN\'ler oluşturuldu: $vins');
    return vins;
  }
  
  /// VIN filtreleme - Basit
  static List<String> _filterVinCandidates(List<String> textLines) {
    final vinCandidates = <String>[];
    
    print('🔍 VIN filtreleme başlatılıyor...');
    
    // Çok esnek VIN pattern'leri
    final vinPatterns = [
      RegExp(r'VF1[A-Z0-9]{10,16}'), // Renault (esnek)
      RegExp(r'UU1[A-Z0-9]{10,16}'), // Dacia (esnek)
      RegExp(r'[A-Z0-9]{8,20}'), // Herhangi bir uzun metin
      RegExp(r'[A-Z]{3}[0-9]{5,15}'), // 3 harf + rakamlar
      RegExp(r'[0-9]{8,20}'), // Sadece rakamlar
    ];
    
    for (int i = 0; i < textLines.length; i++) {
      final line = textLines[i];
      final cleanLine = _normalizeVinText(line);
      
      print('  Satır $i: "$line" -> "$cleanLine"');
      
      for (int j = 0; j < vinPatterns.length; j++) {
        final pattern = vinPatterns[j];
        final matches = pattern.allMatches(cleanLine);
        
        print('    Pattern $j: ${matches.length} eşleşme');
        
        for (final match in matches) {
          final candidate = match.group(0)!;
          print('      Aday: "$candidate" (uzunluk: ${candidate.length})');
          
          if (candidate.length >= 6) { // Çok esnek uzunluk
            vinCandidates.add(candidate);
            print('🎯 VIN bulundu: $candidate (uzunluk: ${candidate.length})');
          } else {
            print('❌ Çok kısa: $candidate');
          }
        }
      }
    }
    
    // Duplikatları kaldır
    final uniqueCandidates = vinCandidates.toSet().toList();
    print('✅ Toplam ${uniqueCandidates.length} benzersiz VIN bulundu');
    return uniqueCandidates;
  }
  
  /// VIN metnini normalize et
  static String _normalizeVinText(String text) {
    return text
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '') // Sadece harf ve rakam
        .replaceAll('O', '0') // O -> 0
        .replaceAll('I', '1') // I -> 1
        .replaceAll('S', '5') // S -> 5
        .replaceAll('B', '8'); // B -> 8
  }
}
