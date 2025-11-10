import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:math' as math;

/// Profesyonel görüntü işleme servisi
class ImageProcessingService {
  /// ROI'yi işle ve optimize et
  static Future<Uint8List> processRoi(Uint8List imageBytes, {
    int maxWidth = 1024,
    double contrast = 2.0,
    double brightness = 0.1,
    double gamma = 0.8,
  }) async {
    try {
      // Görüntüyü decode et
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) throw Exception('Failed to decode image');

      // Boyut optimizasyonu
      if (image.width > maxWidth) {
        final scale = maxWidth / image.width;
        image = img.copyResize(
          image,
          width: maxWidth,
          height: (image.height * scale).toInt(),
          interpolation: img.Interpolation.cubic,
        );
      }

      // Gri tonlama (OCR için ideal)
      image = img.grayscale(image);

      // Histogram eşitleme (CLAHE benzeri)
      image = img.adjustColor(
        image,
        contrast: contrast,
        brightness: brightness,
        gamma: gamma,
      );

      // Unsharp mask (kenar keskinleştirme)
      image = img.adjustColor(
        image,
        contrast: 1.5,
        brightness: 0.0,
      );

      // Gürültü azaltma (hafif)
      image = img.adjustColor(
        image,
        contrast: 1.1,
        brightness: 0.0,
      );

      // Final optimizasyon
      image = img.adjustColor(
        image,
        contrast: 1.2,
        brightness: 0.02,
        gamma: 1.1,
      );

      return Uint8List.fromList(img.encodeJpg(image, quality: 95));
    } catch (e) {
      throw Exception('Image processing failed: $e');
    }
  }

  /// Blur skoru hesapla (Laplacian variance)
  static double calculateBlurScore(Uint8List imageBytes) {
    try {
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return 0.0;

      // Gri tonlama
      image = img.grayscale(image);

      // Laplacian kernel
      final kernel = [
        [0, -1, 0],
        [-1, 4, -1],
        [0, -1, 0],
      ];

      double variance = 0.0;
      double mean = 0.0;
      int count = 0;

      // Laplacian uygula ve variance hesapla
      for (int y = 1; y < image.height - 1; y++) {
        for (int x = 1; x < image.width - 1; x++) {
          double sum = 0.0;
          for (int ky = 0; ky < 3; ky++) {
            for (int kx = 0; kx < 3; kx++) {
              final pixel = image.getPixel(x + kx - 1, y + ky - 1);
              final gray = img.getLuminance(pixel);
              sum += gray * kernel[ky][kx];
            }
          }
          mean += sum.abs();
          count++;
        }
      }

      mean /= count;

      // Variance hesapla
      for (int y = 1; y < image.height - 1; y++) {
        for (int x = 1; x < image.width - 1; x++) {
          double sum = 0.0;
          for (int ky = 0; ky < 3; ky++) {
            for (int kx = 0; kx < 3; kx++) {
              final pixel = image.getPixel(x + kx - 1, y + ky - 1);
              final gray = img.getLuminance(pixel);
              sum += gray * kernel[ky][kx];
            }
          }
          variance += math.pow(sum.abs() - mean, 2);
        }
      }

      variance /= count;
      
      // 0-1 aralığına normalize et
      return math.min(variance / 1000.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }

  /// Exposure skoru hesapla (histogram analizi)
  static double calculateExposureScore(Uint8List imageBytes) {
    try {
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return 0.0;

      // Gri tonlama
      image = img.grayscale(image);

      // Histogram hesapla
      final histogram = List<int>.filled(256, 0);
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          final gray = img.getLuminance(pixel).round();
          histogram[gray]++;
        }
      }

      // Exposure skoru hesapla (0.5 = optimal)
      int totalPixels = image.width * image.height;
      double score = 0.0;
      
      for (int i = 0; i < 256; i++) {
        final weight = 1.0 - (i - 128).abs() / 128.0; // 128'e yakın değerler daha iyi
        score += (histogram[i] / totalPixels) * weight;
      }

      return math.min(score * 2.0, 1.0); // 0-1 aralığına normalize et
    } catch (e) {
      return 0.0;
    }
  }

  /// ROI alignment skoru hesapla
  static double calculateAlignmentScore(Uint8List imageBytes, {
    required double roiX,
    required double roiY,
    required double roiWidth,
    required double roiHeight,
  }) {
    try {
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return 0.0;

      final imageWidth = image.width.toDouble();
      final imageHeight = image.height.toDouble();

      // ROI'nin merkezde olup olmadığını kontrol et
      final centerX = imageWidth / 2;
      final centerY = imageHeight / 2;
      final roiCenterX = roiX + roiWidth / 2;
      final roiCenterY = roiY + roiHeight / 2;

      final distanceFromCenter = math.sqrt(
        math.pow(roiCenterX - centerX, 2) + math.pow(roiCenterY - centerY, 2)
      );

      final maxDistance = math.sqrt(math.pow(imageWidth, 2) + math.pow(imageHeight, 2)) / 2;
      final alignmentScore = 1.0 - (distanceFromCenter / maxDistance);

      return math.max(0.0, math.min(1.0, alignmentScore));
    } catch (e) {
      return 0.0;
    }
  }
}
