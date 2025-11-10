/// Araç parçaları enum'ı
enum CarPart {
  // Ön tampon ve farlar
  frontBumper('Ön Tampon', 'front_bumper'),
  frontLeftLight('Ön Sol Far', 'front_left_light'),
  frontRightLight('Ön Sağ Far', 'front_right_light'),
  
  // Arka tampon ve stop lambaları
  rearBumper('Arka Tampon', 'rear_bumper'),
  rearLeftLight('Arka Sol Stop', 'rear_left_light'),
  rearRightLight('Arka Sağ Stop', 'rear_right_light'),
  
  // Sol taraf kapılar ve çamurluklar
  frontLeftDoor('Ön Sol Kapı', 'front_left_door'),
  frontLeftFender('Ön Sol Çamurluk', 'front_left_fender'),
  rearLeftDoor('Arka Sol Kapı', 'rear_left_door'),
  rearLeftFender('Arka Sol Çamurluk', 'rear_left_fender'),
  
  // Sağ taraf kapılar ve çamurluklar
  frontRightDoor('Ön Sağ Kapı', 'front_right_door'),
  frontRightFender('Ön Sağ Çamurluk', 'front_right_fender'),
  rearRightDoor('Arka Sağ Kapı', 'rear_right_door'),
  rearRightFender('Arka Sağ Çamurluk', 'rear_right_fender'),
  
  // Orta gövde
  hood('Kaput', 'hood'),
  roof('Tavan', 'roof'),
  trunk('Bagaj', 'trunk'),
  
  // Camlar
  frontWindshield('Ön Cam', 'front_windshield'),
  rearWindshield('Arka Cam', 'rear_windshield'),
  frontLeftWindow('Ön Sol Cam', 'front_left_window'),
  frontRightWindow('Ön Sağ Cam', 'front_right_window'),
  rearLeftWindow('Arka Sol Cam', 'rear_left_window'),
  rearRightWindow('Arka Sağ Cam', 'rear_right_window');

  const CarPart(this.displayName, this.id);
  
  final String displayName;
  final String id;
  
  /// Parçanın kategorisini döndürür
  CarPartCategory get category {
    switch (this) {
      case CarPart.frontBumper:
      case CarPart.frontLeftLight:
      case CarPart.frontRightLight:
        return CarPartCategory.front;
      case CarPart.rearBumper:
      case CarPart.rearLeftLight:
      case CarPart.rearRightLight:
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
      case CarPart.hood:
      case CarPart.roof:
      case CarPart.trunk:
        return CarPartCategory.center;
      case CarPart.frontWindshield:
      case CarPart.rearWindshield:
      case CarPart.frontLeftWindow:
      case CarPart.frontRightWindow:
      case CarPart.rearLeftWindow:
      case CarPart.rearRightWindow:
        return CarPartCategory.windows;
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

