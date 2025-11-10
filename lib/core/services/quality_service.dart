import 'dart:typed_data';
import 'package:otopark_demo/core/models/quality_metrics.dart';
import 'package:otopark_demo/core/services/image_processing_service.dart';

/// Görüntü kalite analiz servisi
class QualityService {
  static const int _debounceMs = 500; // 500ms debounce
  static DateTime? _lastAnalysis;
  static QualityMetrics? _lastMetrics;

  /// Görüntü kalitesini analiz et (debounced)
  static Future<QualityMetrics> analyzeQuality(
    Uint8List imageBytes, {
    required double roiX,
    required double roiY,
    required double roiWidth,
    required double roiHeight,
    bool force = false,
  }) async {
    final now = DateTime.now();
    
    // Debounce kontrolü
    if (!force && 
        _lastAnalysis != null && 
        now.difference(_lastAnalysis!).inMilliseconds < _debounceMs &&
        _lastMetrics != null) {
      return _lastMetrics!;
    }

    try {
      // Paralel olarak metrikleri hesapla
      final blurScore = ImageProcessingService.calculateBlurScore(imageBytes);
      final exposureScore = ImageProcessingService.calculateExposureScore(imageBytes);
      final alignmentScore = ImageProcessingService.calculateAlignmentScore(
        imageBytes,
        roiX: roiX,
        roiY: roiY,
        roiWidth: roiWidth,
        roiHeight: roiHeight,
      );

      // Genel skor hesapla (ağırlıklı ortalama)
      final overallScore = (
        blurScore * 0.4 +      // Blur en önemli
        exposureScore * 0.3 +  // Exposure ikinci
        alignmentScore * 0.3   // Alignment üçüncü
      );

      // Hareket stabilitesi (basit implementasyon)
      final isStable = blurScore > 0.2; // Blur skoru yüksekse stabil

      final metrics = QualityMetrics(
        blurScore: blurScore,
        exposureScore: exposureScore,
        alignmentScore: alignmentScore,
        overallScore: overallScore,
        isStable: isStable,
        status: _getStatusMessage(blurScore, exposureScore, alignmentScore, overallScore, isStable),
      );

      _lastAnalysis = now;
      _lastMetrics = metrics;

      return metrics;
    } catch (e) {
      // Hata durumunda varsayılan değerler
      return QualityMetrics(
        blurScore: 0.0,
        exposureScore: 0.0,
        alignmentScore: 0.0,
        overallScore: 0.0,
        isStable: false,
        status: "Analyzing...",
      );
    }
  }

  /// Durum mesajını belirle
  static String _getStatusMessage(
    double blurScore,
    double exposureScore,
    double alignmentScore,
    double overallScore,
    bool isStable,
  ) {
    if (overallScore >= QualityMetrics.minOverallScore && isStable) {
      return "Sharp! Ready to scan";
    } else if (blurScore < QualityMetrics.minBlurScore) {
      return "Hold steady";
    } else if (exposureScore < QualityMetrics.minExposureScore) {
      return "Too dark";
    } else if (alignmentScore < QualityMetrics.minAlignmentScore) {
      return "Center the VIN";
    } else if (!isStable) {
      return "Hold still";
    } else {
      return "Adjust position";
    }
  }

  /// Kalite geçmişini temizle
  static void clearCache() {
    _lastAnalysis = null;
    _lastMetrics = null;
  }
}


