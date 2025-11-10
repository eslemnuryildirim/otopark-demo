/// VIN Decoder - VIN'den bilgi çıkarma
class VinDecoder {
  /// VIN'den üretim yılı çıkar
  /// VIN'in 10. karakteri model yılı gösterir
  static int? getProductionYear(String vin) {
    if (vin.length < 10) return null;
    
    final yearChar = vin[9].toUpperCase();
    
    // Model yılı kodları (1980-2030)
    // A=1980, B=1981, ..., Y=2000
    // 1=2001, 2=2002, ..., 9=2009
    // A=2010, B=2011, ..., Y=2030
    final yearMap = {
      'A': [1980, 2010],
      'B': [1981, 2011],
      'C': [1982, 2012],
      'D': [1983, 2013],
      'E': [1984, 2014],
      'F': [1985, 2015],
      'G': [1986, 2016],
      'H': [1987, 2017],
      'J': [1988, 2018],
      'K': [1989, 2019],
      'L': [1990, 2020],
      'M': [1991, 2021],
      'N': [1992, 2022],
      'P': [1993, 2023],
      'R': [1994, 2024],
      'S': [1995, 2025],
      'T': [1996, 2026],
      'V': [1997, 2027],
      'W': [1998, 2028],
      'X': [1999, 2029],
      'Y': [2000, 2030],
      '1': 2001,
      '2': 2002,
      '3': 2003,
      '4': 2004,
      '5': 2005,
      '6': 2006,
      '7': 2007,
      '8': 2008,
      '9': 2009,
    };
    
    final yearValue = yearMap[yearChar];
    if (yearValue == null) return null;
    
    // Eğer liste ise (A-Y harfleri için iki yıl var), şu anki yıla göre seç
    if (yearValue is List) {
      final currentYear = DateTime.now().year;
      final yearList = yearValue as List<int>;
      // 2010'dan sonraki yılları tercih et
      try {
        return yearList.firstWhere(
          (year) => year >= 2010 && year <= currentYear,
        );
      } catch (e) {
        // Bulunamazsa ilk yılı döndür
        return yearList.first;
      }
    }
    
    return yearValue as int;
  }
  
  /// VIN'den yaş hesapla (şu anki yıl - üretim yılı)
  static int? getAge(String vin) {
    final productionYear = getProductionYear(vin);
    if (productionYear == null) return null;
    
    final currentYear = DateTime.now().year;
    return currentYear - productionYear;
  }
  
  /// VIN'den marka bilgisi çıkar (WMI - World Manufacturer Identifier)
  static String getBrandFromVin(String vin) {
    if (vin.length < 3) return 'Bilinmiyor';
    
    final wmi = vin.substring(0, 3);
    
    // WMI kodları
    final wmiMap = {
      '1HG': 'Honda',
      '1H1': 'Honda',
      'WBA': 'BMW',
      'WBS': 'BMW',
      'WDB': 'Mercedes-Benz',
      'WDC': 'Mercedes-Benz',
      'WDD': 'Mercedes-Benz',
      'WAU': 'Audi',
      'WA1': 'Audi',
      '1FT': 'Ford',
      '1F1': 'Ford',
      '1FA': 'Ford',
      '1J4': 'Jeep',
      '1G1': 'Chevrolet',
      '1G4': 'Chevrolet',
      '1N4': 'Nissan',
      '1N6': 'Nissan',
      'VF1': 'Renault',
      'VF3': 'Renault',
      'UU1': 'Dacia',
      'UU2': 'Dacia',
      'ZFA': 'Fiat',
      'ZFF': 'Ferrari',
      'WMW': 'MINI',
      'WVW': 'Volkswagen',
      'WV1': 'Volkswagen',
      'WV2': 'Volkswagen',
      'YS3': 'Saab',
      'YV1': 'Volvo',
      'YV2': 'Volvo',
      '1M1': 'Mack',
      '1M2': 'Mack',
      '1M3': 'Mack',
      '1M4': 'Mack',
      '1M9': 'Mack',
      '4T1': 'Toyota',
      '4T3': 'Toyota',
      '4T4': 'Toyota',
      'JT1': 'Toyota',
      'JT2': 'Toyota',
      'JT3': 'Toyota',
      'JT4': 'Toyota',
      'JT5': 'Toyota',
      'JT6': 'Toyota',
      'JT7': 'Toyota',
      'JT8': 'Toyota',
      'JT9': 'Toyota',
      'JTD': 'Toyota',
      'JTE': 'Toyota',
      'JTF': 'Toyota',
      'JTG': 'Toyota',
      'JTH': 'Toyota',
      'JTJ': 'Toyota',
      'JTK': 'Toyota',
      'JTL': 'Toyota',
      'JTM': 'Toyota',
      'JTN': 'Toyota',
      'JTP': 'Toyota',
      'JTR': 'Toyota',
      'JTS': 'Toyota',
      'JTT': 'Toyota',
      'JTU': 'Toyota',
      'JTV': 'Toyota',
      'JTW': 'Toyota',
      'JTX': 'Toyota',
      'JTY': 'Toyota',
      'JTZ': 'Toyota',
    };
    
    return wmiMap[wmi] ?? 'Bilinmiyor';
  }
}

