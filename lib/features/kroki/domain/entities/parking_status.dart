enum ParkingStatus {
  available,
  occupied,
  maintenance,
  reserved,
}

// Basit string döndürme fonksiyonları
String getStatusText(ParkingStatus status) {
  switch (status) {
    case ParkingStatus.available:
      return 'Boş';
    case ParkingStatus.occupied:
      return 'Dolu';
    case ParkingStatus.maintenance:
      return 'Bakımda';
    case ParkingStatus.reserved:
      return 'Rezerve';
  }
}
