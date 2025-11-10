import 'dart:typed_data';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

/// Basit Görüntü İşleme Servisi
class SimpleImageProcessor {
  
  /// Basit görüntü işleme
  static Future<Uint8List> processImageForOcr(Uint8List imageBytes) async {
    try {
      print('🖼️ Basit görüntü işleme başlatılıyor...');
      
      // 1. Görüntüyü decode et
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        print('❌ Görüntü decode edilemedi');
        return imageBytes;
      }
      
      print('📏 Orijinal boyut: ${image.width}x${image.height}');
      
      // 2. Boyut optimizasyonu
      final resizedImage = _resizeImage(image);
      print('📏 Yeniden boyutlandırıldı: ${resizedImage.width}x${resizedImage.height}');
      
      // 3. Gri tonlama
      final grayscaleImage = img.grayscale(resizedImage);
      print('🎨 Gri tonlama uygulandı');
      
      // 4. Kontrast artırma
      final contrastImage = img.contrast(grayscaleImage, contrast: 1.5);
      print('🔆 Kontrast artırıldı');
      
      // 5. Gamma düzeltme
      final gammaImage = img.gamma(contrastImage, gamma: 1.2);
      print('📈 Gamma düzeltildi');
      
      // 6. Uint8List'e çevir
      final processedBytes = img.encodePng(gammaImage);
      print('✅ Basit görüntü işleme tamamlandı');
      
      return Uint8List.fromList(processedBytes);
      
    } catch (e) {
      print('❌ Görüntü işleme hatası: $e');
      return imageBytes; // Hata durumunda orijinal görüntüyü döndür
    }
  }
  
  /// Görüntüyü yeniden boyutlandır
  static img.Image _resizeImage(img.Image image) {
    const targetWidth = 800;
    const targetHeight = 600;
    
    if (image.width <= targetWidth && image.height <= targetHeight) {
      return image;
    }
    
    return img.copyResize(
      image,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.cubic,
    );
  }
  
  /// Görüntü kalitesi analizi
  static Map<String, dynamic> analyzeImageQuality(Uint8List imageBytes) {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return {};
      
      // Basit istatistikler
      int totalPixels = image.width * image.height;
      int totalBrightness = 0;
      int minBrightness = 255;
      int maxBrightness = 0;
      
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          final brightness = img.getLuminance(pixel).round();
          
          totalBrightness += brightness;
          minBrightness = math.min(minBrightness, brightness);
          maxBrightness = math.max(maxBrightness, brightness);
        }
      }
      
      final meanBrightness = totalBrightness / totalPixels;
      final contrast = (maxBrightness - minBrightness) / 255.0;
      
      return {
        'width': image.width,
        'height': image.height,
        'meanBrightness': meanBrightness,
        'minBrightness': minBrightness,
        'maxBrightness': maxBrightness,
        'contrast': contrast,
        'brightness': meanBrightness / 255.0,
        'totalPixels': totalPixels,
      };
      
    } catch (e) {
      print('❌ Görüntü analizi hatası: $e');
      return {};
    }
  }
}
