/// Araç parçaları enum'ı - HTML kodlarına göre
enum CarPart {
  // HTML kodlarına göre parçalar
  // Koordinatlar: (x, y) 0-1 arası oran (görselin boyutuna göre ölçeklenir)
  // Kullanıcının test ederek verdiği gerçek koordinatlar
  // X: 0 = sol, 1 = sağ
  // Y: 0 = üst, 1 = alt
  frontBumper('Ön Tampon', 'B01201', 0.52, 0.03),
  hood('Motor Kaputu', 'B01001', 0.53, 0.13),
  frontLeftFender('Sol Ön Çamurluk', 'B01101', 0.35, 0.06),
  frontLeftDoor('Sol Ön Kapı', 'B0801', 0.35, 0.17),
  rearLeftDoor('Sol Arka Kapı', 'B0701', 0.37, 0.22),
  rearLeftFender('Sol Arka Çamurluk', 'B0301', 0.35, 0.25),
  frontRightFender('Sağ Ön Çamurluk', 'B0901', 0.66, 0.08),
  frontRightDoor('Sağ Ön Kapı', 'B0501', 0.66, 0.18),
  rearRightDoor('Sağ Arka Kapı', 'B0401', 0.65, 0.22),
  rearRightFender('Sağ Arka Çamurluk', 'B0101', 0.65, 0.29),
  trunk('Bagaj', 'B0201', 0.45, 0.28),
  rearBumper('Arka Tampon', 'B01301', 0.45, 0.33),
  roof('Tavan', 'B0601', 0.52, 0.21);

  const CarPart(this.displayName, this.id, this.x, this.y);
  
  final String displayName;
  final String id;
  /// X koordinatı (0-1 arası oran)
  final double x;
  /// Y koordinatı (0-1 arası oran)
  final double y;
  
  /// HTML kodundan CarPart'a dönüştür
  static CarPart? fromCode(String code) {
    try {
      return CarPart.values.firstWhere((part) => part.id == code);
    } catch (e) {
      return null;
    }
  }
  
  /// Parçanın kategorisini döndürür
  CarPartCategory get category {
    switch (this) {
      case CarPart.frontBumper:
      case CarPart.hood:
        return CarPartCategory.front;
      case CarPart.rearBumper:
      case CarPart.trunk:
        return CarPartCategory.rear;
      case CarPart.frontLeftDoor:
      case CarPart.frontLeftFender:
      case CarPart.rearLeftDoor:
      case CarPart.rearLeftFender:
        return CarPartCategory.leftSide;
      case CarPart.frontRightDoor:
      case CarPart.frontRightFender:
      case CarPart.rearRightDoor:
      case CarPart.rearRightFender:
        return CarPartCategory.rightSide;
      case CarPart.roof:
        return CarPartCategory.center;
    }
  }
}

/// Araç parça kategorileri
enum CarPartCategory {
  front('Ön'),
  rear('Arka'),
  leftSide('Sol Yan'),
  rightSide('Sağ Yan'),
  center('Orta'),
  windows('Camlar');

  const CarPartCategory(this.displayName);
  final String displayName;
}

