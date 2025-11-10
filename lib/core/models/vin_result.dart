/// VIN OCR sonucu
class VinResult {
  final String vin;
  final double confidence;
  final String method;
  final bool isValid;
  final String? error;
  final DateTime timestamp;

  VinResult({
    required this.vin,
    required this.confidence,
    required this.method,
    required this.isValid,
    this.error,
    required this.timestamp,
  });

  /// VIN regex validation: ^(?=.{17}$)(?!.*[IOQ])[A-HJ-NPR-Z0-9]+$
  static bool validateVin(String vin) {
    if (vin.length != 17) return false;
    if (vin.contains(RegExp(r'[IOQ]'))) return false;
    return RegExp(r'^[A-HJ-NPR-Z0-9]+$').hasMatch(vin);
  }

  /// ISO-3779 VIN checksum validation
  static bool validateChecksum(String vin) {
    if (vin.length != 17) return false;
    
    // VIN checksum calculation
    final weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2];
    final transliteration = {
      'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'F': 6, 'G': 7, 'H': 8,
      'J': 1, 'K': 2, 'L': 3, 'M': 4, 'N': 5, 'P': 7, 'R': 9,
      'S': 2, 'T': 3, 'U': 4, 'V': 5, 'W': 6, 'X': 7, 'Y': 8, 'Z': 9,
      '0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9,
    };

    int sum = 0;
    for (int i = 0; i < 17; i++) {
      if (i == 8) continue; // Skip check digit position
      final char = vin[i];
      final value = transliteration[char] ?? 0;
      sum += value * weights[i];
    }

    final checkDigit = sum % 11;
    final expectedCheckDigit = checkDigit == 10 ? 'X' : checkDigit.toString();
    return vin[8] == expectedCheckDigit;
  }

  @override
  String toString() => 'VinResult(vin: $vin, confidence: $confidence, valid: $isValid)';
}


