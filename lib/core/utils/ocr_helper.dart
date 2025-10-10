import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

/// Hızlı ve Hafif OCR Helper - UI donmasını önler
class OcrHelper {
  /// Fotoğraftan şase numarası oku (optimize edilmiş)
  static Future<List<String>> extractTextFromImage(String imagePath) async {
    try {
      // 1. Basit görüntü iyileştirme (hızlı)
      final enhancedPath = await _quickEnhance(imagePath);
      
      // 2. ML Kit OCR
      final inputImage = InputImage.fromFilePath(enhancedPath);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      textRecognizer.close();
      
      // Geçici dosyayı sil
      if (enhancedPath != imagePath) {
        try {
          await File(enhancedPath).delete();
        } catch (_) {}
      }
      
      if (recognizedText.text.isEmpty) return [];
      
      // 3. Metni topla
      final Set<String> allTexts = {};
      
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final cleaned = line.text
              .replaceAll(RegExp(r'[^A-Z0-9]'), '')
              .toUpperCase();
          if (cleaned.length >= 8) {
            allTexts.add(cleaned);
          }
        }
      }
      
      // 4. En iyi sonuçları döndür
      final results = allTexts.toList()
        ..sort((a, b) => b.length.compareTo(a.length));
      
      return results;
    } catch (e) {
      print('OCR Hatası: $e');
      return [];
    }
  }

  /// Hızlı görüntü iyileştirme (sadece temel işlemler)
  static Future<String> _quickEnhance(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) return imagePath;

      // Sadece kritik işlemler (çok hızlı)
      
      // 1. Maksimum boyut kontrolü (performans için)
      if (image.width > 2000) {
        final scale = 2000 / image.width;
        image = img.copyResize(
          image,
          width: (image.width * scale).toInt(),
          height: (image.height * scale).toInt(),
          interpolation: img.Interpolation.average, // En hızlı
        );
      }

      // 2. Gri tonlama
      image = img.grayscale(image);

      // 3. Kontrast artırma (hafif)
      image = img.adjustColor(image, contrast: 1.5);

      // Geçici dosyaya kaydet
      final tempPath = '${imagePath}_temp.jpg';
      await File(tempPath).writeAsBytes(img.encodeJpg(image, quality: 85));
      
      return tempPath;
    } catch (e) {
      print('Görüntü iyileştirme hatası: $e');
      return imagePath;
    }
  }
}
