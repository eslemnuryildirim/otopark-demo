/// Görüntü kalite metrikleri
class QualityMetrics {
  final double blurScore;      // Laplacian variance (0-1, higher = sharper)
  final double exposureScore;  // Histogram exposure (0-1, 0.5 = optimal)
  final double alignmentScore; // ROI alignment (0-1, higher = better centered)
  final double overallScore;   // Combined quality score (0-1)
  final bool isStable;         // Motion stability
  final String status;         // Human readable status

  QualityMetrics({
    required this.blurScore,
    required this.exposureScore,
    required this.alignmentScore,
    required this.overallScore,
    required this.isStable,
    required this.status,
  });

  /// Quality thresholds
  static const double minBlurScore = 0.3;
  static const double minExposureScore = 0.2;
  static const double minAlignmentScore = 0.6;
  static const double minOverallScore = 0.7;

  /// Check if quality is sufficient for OCR
  bool get isGoodForOcr => 
      blurScore >= minBlurScore &&
      exposureScore >= minExposureScore &&
      alignmentScore >= minAlignmentScore &&
      overallScore >= minOverallScore &&
      isStable;

  /// Get status message
  String getStatusMessage() {
    if (overallScore >= minOverallScore && isStable) {
      return "Sharp! Ready to scan";
    } else if (blurScore < minBlurScore) {
      return "Hold steady";
    } else if (exposureScore < minExposureScore) {
      return "Too dark";
    } else if (alignmentScore < minAlignmentScore) {
      return "Center the VIN";
    } else if (!isStable) {
      return "Hold still";
    } else {
      return "Adjust position";
    }
  }

  @override
  String toString() => 'QualityMetrics(overall: $overallScore, status: $status)';
}


