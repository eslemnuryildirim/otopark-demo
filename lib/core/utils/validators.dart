/// Form validation utilities
class Validators {
  /// Şase validation (basit versiyon)
  static String? validatePlate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şase gereklidir';
    }
    if (value.length < 3) {
      return 'Şase en az 3 karakter olmalıdır';
    }
    return null;
  }

  /// Genel boş alan kontrolü
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName gereklidir';
    }
    return null;
  }
}

