class SlotLabelGenerator {
  static const int rowCount = 6;
  static const int colCount = 13;
  static const int totalSlots = rowCount * colCount; // 78

  /// Index'ten slot label oluştur (0-77 → A-04, A-05, ..., F-16)
  static String generate(int index) {
    if (index < 0 || index >= totalSlots) {
      throw ArgumentError('Index must be between 0 and ${totalSlots - 1}');
    }

    final row = index ~/ colCount; // 0-5
    final col = index % colCount;  // 0-12
    
    final rowLabel = String.fromCharCode(65 + row); // A-F
    final colNumber = 4 + col; // 04-16
    
    return '$rowLabel-${colNumber.toString().padLeft(2, '0')}';
  }

  /// Label'dan (row, col) parse et (A-04 → (0, 0))
  static (int row, int col) parse(String label) {
    if (label.length < 4 || !label.contains('-')) {
      throw ArgumentError('Invalid label format: $label');
    }

    final parts = label.split('-');
    if (parts.length != 2) {
      throw ArgumentError('Invalid label format: $label');
    }

    final rowLabel = parts[0];
    final colNumber = int.tryParse(parts[1]);

    if (rowLabel.length != 1 || colNumber == null) {
      throw ArgumentError('Invalid label format: $label');
    }

    final row = rowLabel.codeUnitAt(0) - 65; // A=0, B=1, ..., F=5
    final col = colNumber - 4; // 04=0, 05=1, ..., 16=12

    if (row < 0 || row >= rowCount || col < 0 || col >= colCount) {
      throw ArgumentError('Label out of range: $label');
    }

    return (row, col);
  }

  /// Label'dan index'e çevir (A-04 → 0)
  static int labelToIndex(String label) {
    final (row, col) = parse(label);
    return row * colCount + col;
  }

  /// Index'ten row label (0 → A, 1 → B, ..., 5 → F)
  static String getRowLabel(int index) {
    final row = index ~/ colCount;
    return String.fromCharCode(65 + row);
  }

  /// Index'ten col number (0 → 04, 1 → 05, ..., 12 → 16)
  static int getColNumber(int index) {
    final col = index % colCount;
    return 4 + col;
  }

  /// Tüm slot label'larını listele
  static List<String> getAllLabels() {
    return List.generate(totalSlots, (index) => generate(index));
  }

  /// Row'a göre slot label'larını grupla
  static Map<String, List<String>> getLabelsByRow() {
    final Map<String, List<String>> result = {};
    
    for (int i = 0; i < totalSlots; i++) {
      final label = generate(i);
      final rowLabel = getRowLabel(i);
      
      result[rowLabel] ??= [];
      result[rowLabel]!.add(label);
    }
    
    return result;
  }

  /// Servis alanları için özel label'lar
  static List<String> getServiceLabels() {
    return ['YIKAMA', 'BAKIM'];
  }

  /// Servis alanı mı kontrol et
  static bool isServiceArea(String label) {
    return getServiceLabels().contains(label);
  }
}

