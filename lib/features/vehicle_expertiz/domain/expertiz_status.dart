import 'package:flutter/material.dart';

/// Ekspertiz durumu enum'ı
enum ExpertizStatus {
  original('Orijinal', Colors.green, Icons.check_circle),
  localPainted('Lokal Boyalı', Colors.blue, Icons.brush),
  painted('Boyalı', Colors.orange, Icons.palette),
  replaced('Değişen', Colors.purple, Icons.swap_horiz),
  damaged('Hasarlı', Colors.red, Icons.warning),
  scratched('Çizik', Colors.amber, Icons.content_cut);

  const ExpertizStatus(this.displayName, this.color, this.icon);
  
  final String displayName;
  final Color color;
  final IconData icon;
  
  /// Durumun ciddiyet seviyesi (0: En iyi, 5: En kötü)
  int get severityLevel {
    switch (this) {
      case ExpertizStatus.original:
        return 0;
      case ExpertizStatus.localPainted:
        return 1;
      case ExpertizStatus.painted:
        return 2;
      case ExpertizStatus.scratched:
        return 3;
      case ExpertizStatus.replaced:
        return 4;
      case ExpertizStatus.damaged:
        return 5;
    }
  }
  
  /// Durumun açıklaması
  String get description {
    switch (this) {
      case ExpertizStatus.original:
        return 'Araç orijinal durumda, herhangi bir müdahale yok';
      case ExpertizStatus.localPainted:
        return 'Sadece belirli bölgelerde boya işlemi yapılmış';
      case ExpertizStatus.painted:
        return 'Parça tamamen yeniden boyanmış';
      case ExpertizStatus.replaced:
        return 'Parça değiştirilmiş, orijinal değil';
      case ExpertizStatus.damaged:
        return 'Parçada ciddi hasar mevcut';
      case ExpertizStatus.scratched:
        return 'Parçada çizik veya hafif hasar var';
    }
  }
}

