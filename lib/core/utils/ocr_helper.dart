import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

/// 🔍 Hafif ve Hızlı OCR Helper
/// 
/// Şase numarası okuma için optimize edilmiş, minimum işlemle maksimum sonuç.
/// Performans odaklı, tek geçişli OCR sistemi.
class OcrHelper {
  /// Fotoğraftan şase numarası oku (ultra hızlı)
  /// 
  /// **Tek Geçiş Stratejisi:**
  /// - Sadece temel görüntü iyileştirme (gri tonlama + kontrast)
  /// - Google ML Kit'in kendi OCR optimizasyonlarına güven
  /// - Minimum işlem = Maksimum hız
  static Future<List<String>> extractTextFromImage(String imagePath) async {
    try {
      // Hafif görüntü iyileştirme (isteğe bağlı)
      final processedPath = await _lightProcess(imagePath);
      
      // Google ML Kit OCR (tek geçiş)
      final inputImage = InputImage.fromFilePath(processedPath);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();
      
      // Geçici dosyayı sil
      if (processedPath != imagePath) {
        try {
          await File(processedPath).delete();
        } catch (_) {}
      }
      
      // Metni topla ve filtrele
      final results = <String>{};
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          // Temizle
          final cleaned = line.text
              .replaceAll(RegExp(r'[^A-Z0-9]'), '')
              .toUpperCase();
          
          // Şase formatına uygunsa ekle
          if (_isValidChassisFormat(cleaned)) {
            results.add(cleaned);
          }
        }
      }
      
      // Uzunluğa göre sırala
      final validResults = results.toList()
        ..sort((a, b) => b.length.compareTo(a.length));
      
      return validResults;
    } catch (e) {
      print('OCR Hatası: $e');
      return [];
    }
  }

  /// Hafif görüntü işleme (sadece gerekli olanlar)
  static Future<String> _lightProcess(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) return imagePath;

      // 1. Boyut kontrolü (max 1500px - daha hızlı)
      if (image.width > 1500 || image.height > 1500) {
        final scale = 1500 / (image.width > image.height ? image.width : image.height);
        image = img.copyResize(
          image,
          width: (image.width * scale).toInt(),
          height: (image.height * scale).toInt(),
          interpolation: img.Interpolation.average, // En hızlı
        );
      }

      // 2. Gri tonlama (OCR için daha iyi)
      image = img.grayscale(image);

      // 3. Hafif kontrast artırma (çok agresif değil)
      image = img.adjustColor(image, contrast: 1.4, brightness: 1.05);

      // Geçici dosyaya kaydet (düşük kalite = hız)
      final tempPath = '${imagePath}_light.jpg';
      await File(tempPath).writeAsBytes(img.encodeJpg(image, quality: 80));
      
      return tempPath;
    } catch (e) {
      print('Hafif işleme hatası: $e');
      return imagePath; // Hata durumunda orijinal fotoğrafı kullan
    }
  }

  /// Şase formatı doğrulama (basit ve hızlı)
  static bool _isValidChassisFormat(String text) {
    // Çok kısa veya çok uzun
    if (text.length < 8 || text.length > 25) return false;
    
    // Sadece harf ve rakam
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(text)) return false;
    
    // En az 3 rakam içermeli
    final digitCount = text.split('').where((c) => RegExp(r'\d').hasMatch(c)).length;
    if (digitCount < 3) return false;
    
    return true;
  }
}
