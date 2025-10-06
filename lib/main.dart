import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const OtoparkApp());
}

class OtoparkApp extends StatelessWidget {
  const OtoparkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otopark Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false, // Sarı-siyah banner'ı kaldır
    );
  }
}

// Login Sayfası
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Kullanıcı adı ve şifre girin!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simüle edilmiş giriş işlemi
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (_usernameController.text == 'admin' && _passwordController.text == '123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else {
      _showSnackBar('Kullanıcı adı veya şifre hatalı!');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildRenaultLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Buhari Otomotiv logosu
          Container(
            width: 50,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                'BUHARI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Otomotiv',
            style: TextStyle(
              color: Colors.blue.shade800,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.blueAccent],
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRenaultLogo(),
                  const SizedBox(height: 16),
                  Text(
                    'Otopark Yönetim Sistemi',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Şifre',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Giriş Yap'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Demo: admin / 123',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Ana Dashboard Sayfası
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _plakaController = TextEditingController();
  final TextEditingController _markaController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _renkController = TextEditingController();
  final TextEditingController _yilController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _parkedCars = [];
  
  // Servis alanları için yeni layout
  List<List<String>> _parkingLayout = [
    // Servis alanları - Üst kısım
    ['YIK1', 'YIK2', 'CAM1', 'DET1', 'PAS1', 'PAS2'],
    [], // Servis koridoru
    // Ana park alanları
    ['A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'A9', 'A10', 'A11', 'A12', 'A13', 'A14', 'A15', 'A16'],
    [], // Araç koridoru
    ['B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B9', 'B10', 'B11', 'B12', 'B13', 'B14', 'B15', 'B16'],
    ['C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11', 'C12', 'C13', 'C14', 'C15', 'C16'],
    [], // Araç koridoru
    ['D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8', 'D9', 'D10', 'D11', 'D12', 'D13', 'D14', 'D15', 'D16'],
    ['E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8', 'E9', 'E10', 'E11', 'E12', 'E13', 'E14', 'E15', 'E16'],
    [], // Araç koridoru
    ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', 'F13', 'F14', 'F15', 'F16'],
  ];
  
  Map<String, bool> _occupiedSpots = {};
  Map<String, bool> _serviceAreas = {};
  Map<String, String> _serviceAreaTypes = {};
  Map<String, Map<String, dynamic>> _serviceBookings = {};
  Map<String, Map<String, dynamic>> _serviceAreaCars = {}; // Servis alanındaki araçlar
  Map<String, String> _carStatuses = {}; // Araç durumları (şase -> durum)
  Map<String, DateTime> _statusChangeTimes = {}; // Durum değişim zamanları
  int _totalSpots = 0;
  int _totalServiceAreas = 0;
  String _searchResult = '';
  String? _selectedSpot;
  Timer? _timer;
  
  // Basitleştirilmiş görsel işleme değişkenleri
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _recognizedText;
  bool _isProcessingImage = false;
  String? _imageProcessingStatus;
  double _imageProcessingProgress = 0.0;

  int get _availableSpots => _totalSpots - _occupiedSpots.values.where((occupied) => occupied).length;
  int get _availableServiceAreas => _totalServiceAreas - _serviceAreas.values.where((occupied) => occupied).length;

  @override
  void initState() {
    super.initState();
    _initializeParkingSpots();
    _startTimer();
  }

  void _initializeParkingSpots() {
    _totalSpots = 0;
    _totalServiceAreas = 0;
    
    // Servis alanlarını tanımla
    _serviceAreaTypes = {
      'YIK1': 'İç Yıkama',
      'YIK2': 'Dış Yıkama', 
      'CAM1': 'Cam-Kaput',
      'DET1': 'Detaylı İç Temizlik',
      'PAS1': 'Pasta Cila (İkinci El)',
      'PAS2': 'Pasta Cila (0 Araç)',
    };
    
    for (var row in _parkingLayout) {
      for (var spot in row) {
        if (spot.isNotEmpty) {
          if (_serviceAreaTypes.containsKey(spot)) {
            // Servis alanı
            _serviceAreas[spot] = false;
            _totalServiceAreas++;
          } else {
            // Park yeri
          _occupiedSpots[spot] = false;
          _totalSpots++;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
    setState(() {
          // Timer her saniye çalışacak ve UI'ı güncelleyecek
        });
      }
    });
  }

  void _parkCar() {
    if (_plakaController.text.isNotEmpty && 
        _markaController.text.isNotEmpty && 
        _modelController.text.isNotEmpty && 
        _renkController.text.isNotEmpty && 
        _yilController.text.isNotEmpty && 
        _selectedSpot != null) {
      
      String spotName = _selectedSpot!;
      if (_occupiedSpots[spotName] == true) {
        _showSnackBar('Bu park yeri dolu!');
        return;
      }

      setState(() {
        _parkedCars.add({
          'plaka': _plakaController.text,
          'marka': _markaController.text,
          'model': _modelController.text,
          'renk': _renkController.text,
          'yil': _yilController.text,
          'parkYeri': spotName,
          'girisZamani': DateTime.now(),
          'id': DateTime.now().millisecondsSinceEpoch,
        });
        _occupiedSpots[spotName] = true;
        _clearForm();
      });
      
      // Araç durumunu güncelle
      _updateCarStatus(_plakaController.text, 'Otopark Alanında');
      
      _showSnackBar('Araç park edildi! Park Yeri: $spotName');
    } else {
      _showSnackBar('Lütfen tüm bilgileri doldurun ve park yeri seçin!');
    }
  }

  void _clearForm() {
    _plakaController.clear();
    _markaController.clear();
    _modelController.clear();
    _renkController.clear();
    _yilController.clear();
    _selectedSpot = null;
  }

  void _selectSpot(String spotName) {
    if (_occupiedSpots[spotName] != true) {
      setState(() {
        _selectedSpot = spotName;
      });
      _showSnackBar('Park Yeri $spotName seçildi');
    } else {
      _showSnackBar('Bu park yeri dolu!');
    }
  }

  void _searchCar() {
    if (_searchController.text.isNotEmpty) {
      final chassisNumber = _searchController.text.toUpperCase();
      
      // Park edilmiş araçlarda ara
      final foundCar = _parkedCars.firstWhere(
        (car) => car['plaka'].toUpperCase().contains(chassisNumber),
        orElse: () => {},
      );
      
      // Servis alanındaki araçlarda ara
      Map<String, dynamic>? foundServiceCar;
      for (var car in _serviceAreaCars.values) {
        if (car['plaka'].toString().toUpperCase().contains(chassisNumber)) {
          foundServiceCar = car;
          break;
        }
      }
      
      if (foundCar.isNotEmpty) {
        String status = _getCarStatus(foundCar['plaka']);
        DateTime? statusTime = _getStatusChangeTime(foundCar['plaka']);
        String statusInfo = statusTime != null ? _formatTime(statusTime) : 'Bilinmiyor';
        
        setState(() {
          _searchResult = '''Araç bulundu!
Şase: ${foundCar['plaka']}
Marka: ${foundCar['marka']} ${foundCar['model']}
Renk: ${foundCar['renk']}
Yıl: ${foundCar['yil']}
Park Yeri: ${foundCar['parkYeri']}
Durum: $status
Durum Değişimi: $statusInfo
Giriş: ${_formatTime(foundCar['girisZamani'])}''';
        });
      } else if (foundServiceCar != null) {
        String status = _getCarStatus(foundServiceCar['plaka']);
        DateTime? statusTime = _getStatusChangeTime(foundServiceCar['plaka']);
        String statusInfo = statusTime != null ? _formatTime(statusTime) : 'Bilinmiyor';
        
        setState(() {
          _searchResult = '''Araç bulundu!
Şase: ${foundServiceCar?['plaka'] ?? 'Bilinmiyor'}
Marka: ${foundServiceCar?['marka'] ?? 'Bilinmiyor'} ${foundServiceCar?['model'] ?? 'Bilinmiyor'}
Renk: ${foundServiceCar?['renk'] ?? 'Bilinmiyor'}
Yıl: ${foundServiceCar?['yil'] ?? 'Bilinmiyor'}
Servis Alanı: ${foundServiceCar?['serviceArea'] ?? 'Bilinmiyor'}
Servis Türü: ${foundServiceCar?['serviceType'] ?? 'Bilinmiyor'}
Durum: $status
Durum Değişimi: $statusInfo
Giriş: ${foundServiceCar?['girisZamani'] != null ? _formatTime(foundServiceCar!['girisZamani']) : 'Bilinmiyor'}''';
        });
      } else {
        setState(() {
          _searchResult = 'Araç bulunamadı!';
        });
      }
    } else {
      _showSnackBar('Lütfen şase numarası girin!');
    }
  }

  void _removeCar(int id) {
    final car = _parkedCars.firstWhere((car) => car['id'] == id);
    setState(() {
      _parkedCars.removeWhere((car) => car['id'] == id);
      _occupiedSpots[car['parkYeri']] = false;
    });
    
    // Araç durumunu güncelle
    _updateCarStatus(car['plaka'], 'Teslim Edildi');
    
    _showSnackBar('Araç çıkarıldı! Park Yeri ${car['parkYeri']} boşaldı');
  }


  void _releaseServiceArea(String areaName) {
    // Eğer servis alanında araç varsa, araç durumunu güncelle
    if (_serviceAreaCars.containsKey(areaName)) {
      String chassisNumber = _serviceAreaCars[areaName]!['plaka'];
      _updateCarStatus(chassisNumber, 'Teslim Edildi');
      _clearParkingSpotForCar(chassisNumber);
    }
    
    setState(() {
      _serviceAreas[areaName] = false;
      _serviceBookings.remove(areaName);
      _serviceAreaCars.remove(areaName);
    });
    _showSnackBar('Servis alanı serbest bırakıldı! $areaName');
  }

  // Araç durumunu güncelle
  void _updateCarStatus(String chassisNumber, String status) {
    setState(() {
      _carStatuses[chassisNumber] = status;
      _statusChangeTimes[chassisNumber] = DateTime.now();
    });
  }

  // Araç durumunu al
  String _getCarStatus(String chassisNumber) {
    return _carStatuses[chassisNumber] ?? 'Bilinmiyor';
  }

  // Durum değişim zamanını al
  DateTime? _getStatusChangeTime(String chassisNumber) {
    return _statusChangeTimes[chassisNumber];
  }

  // Belirli bir araç için park alanını boşalt
  void _clearParkingSpotForCar(String chassisNumber) {
    // Park edilmiş araçlar listesinde ara
    for (int i = 0; i < _parkedCars.length; i++) {
      if (_parkedCars[i]['plaka'] == chassisNumber) {
        String spotName = _parkedCars[i]['parkYeri'];
        setState(() {
          _parkedCars.removeAt(i);
          _occupiedSpots[spotName] = false;
        });
        // Mesajı sadece debug için göster, kullanıcıya gösterme
        print('Park alanı boşaltıldı: $spotName');
        break;
      }
    }
  }

  // Mevcut araçları seçme dialogu
  void _showCarSelectionDialog(String areaName) {
    if (_parkedCars.isEmpty) {
      _showSnackBar('Park edilmiş araç bulunamadı!');
      return;
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.car_repair, color: Colors.blue),
              const SizedBox(width: 8),
              Text('${_serviceAreaTypes[areaName]} - Araç Seç'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: _parkedCars.length,
              itemBuilder: (context, index) {
                final car = _parkedCars[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.directions_car, color: Colors.green),
                    title: Text('${car['marka']} ${car['model']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Şase: ${car['plaka']}'),
                        Text('Renk: ${car['renk']} - Yıl: ${car['yil']}'),
                        Text('Park Yeri: ${car['parkYeri']}'),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _moveCarToServiceArea(car, areaName);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Seç'),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
          ],
        );
      },
    );
  }

  // Araçı servis alanına taşı
  void _moveCarToServiceArea(Map<String, dynamic> car, String areaName) {
    setState(() {
      _serviceAreas[areaName] = true;
      _serviceAreaCars[areaName] = {
        'plaka': car['plaka'],
        'marka': car['marka'],
        'model': car['model'],
        'renk': car['renk'],
        'yil': car['yil'],
        'serviceArea': areaName,
        'serviceType': _serviceAreaTypes[areaName],
        'girisZamani': DateTime.now(),
        'id': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Park alanından kaldır
      _parkedCars.removeWhere((c) => c['id'] == car['id']);
      _occupiedSpots[car['parkYeri']] = false;
    });
    
    // Araç durumunu güncelle
    String status = _serviceAreaTypes[areaName] ?? 'Servis Alanında';
    _updateCarStatus(car['plaka'], status);
    
    _showSnackBar('Araç ${_serviceAreaTypes[areaName]} alanına taşındı!');
  }

  // Mevcut servis alanından diğerine taşı
  void _transferCarToServiceArea(Map<String, dynamic> car, String newAreaName) {
    String oldAreaName = car['serviceArea'];
    
    setState(() {
      // Eski alanı boşalt
      _serviceAreas[oldAreaName] = false;
      _serviceAreaCars.remove(oldAreaName);
      
      // Yeni alana taşı
      _serviceAreas[newAreaName] = true;
      _serviceAreaCars[newAreaName] = {
        'plaka': car['plaka'],
        'marka': car['marka'],
        'model': car['model'],
        'renk': car['renk'],
        'yil': car['yil'],
        'serviceArea': newAreaName,
        'serviceType': _serviceAreaTypes[newAreaName],
        'girisZamani': DateTime.now(), // Yeni alana giriş zamanı
        'id': DateTime.now().millisecondsSinceEpoch,
      };
    });
    
    // Araç durumunu güncelle
    String newStatus = _serviceAreaTypes[newAreaName] ?? 'Servis Alanında';
    _updateCarStatus(car['plaka'], newStatus);
    
    _showSnackBar('Araç ${_serviceAreaTypes[oldAreaName]} alanından ${_serviceAreaTypes[newAreaName]} alanına taşındı!');
  }

  // Mevcut alan dışındaki boş servis alanlarını getir
  List<String> _getAvailableServiceAreas(String currentArea) {
    List<String> availableAreas = [];
    
    for (String area in _serviceAreaTypes.keys) {
      if (area != currentArea && _serviceAreas[area] == false) {
        availableAreas.add(area);
      }
    }
    
    return availableAreas;
  }

  // Mobil için satır oluşturma fonksiyonu
  List<Widget> _createMobileRows(List<String> row) {
    List<Widget> mobileRows = [];
    int itemsPerRow = 4; // Her satırda 4 öğe
    
    for (int i = 0; i < row.length; i += itemsPerRow) {
      List<String> rowChunk = row.skip(i).take(itemsPerRow).toList();
      mobileRows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: rowChunk.map((spotName) => _buildParkSpot(spotName, isMobile: true)).toList(),
        ),
      );
      if (i + itemsPerRow < row.length) {
        mobileRows.add(const SizedBox(height: 4));
      }
    }
    
    return mobileRows;
  }

  // Servis alanı item'ı oluşturma fonksiyonu
  Widget _buildServiceAreaItem(String areaName, String serviceType, bool isOccupied) {
    return GestureDetector(
      onTap: () {
        if (isOccupied) {
          // Servis alanında araç varsa detayları göster
          if (_serviceAreaCars.containsKey(areaName)) {
            _showServiceAreaCarDetailsDialog(context, _serviceAreaCars[areaName]!);
          } else {
            _releaseServiceArea(areaName);
          }
        } else {
          // Mevcut araçları seçme formu aç
          _showCarSelectionDialog(areaName);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isOccupied ? Colors.orange : Colors.blue,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isOccupied ? Colors.orange.shade700 : Colors.blue.shade700,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.car_repair,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '$areaName\n$serviceType',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isOccupied ? 'Dolu' : 'Boş',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Park spot widget'ı oluşturma fonksiyonu
  Widget _buildParkSpot(String spotName, {bool isMobile = false}) {
    bool isServiceArea = _serviceAreaTypes.containsKey(spotName);
    bool isOccupied = isServiceArea 
        ? (_serviceAreas[spotName] == true)
        : (_occupiedSpots[spotName] == true);
    bool isSelected = _selectedSpot == spotName;
    
    Color spotColor;
    IconData spotIcon;
    if (isServiceArea) {
      if (isSelected) {
        spotColor = Colors.purple;
      } else if (isOccupied) {
        spotColor = Colors.orange;
      } else {
        spotColor = Colors.blue;
      }
      spotIcon = Icons.car_repair;
    } else {
      if (isSelected) {
        spotColor = Colors.blue;
      } else if (isOccupied) {
        spotColor = Colors.red;
      } else {
        spotColor = Colors.green;
      }
      spotIcon = Icons.local_parking;
    }
    
    // Park edilen araç bilgilerini bul
    Map<String, dynamic>? parkedCar;
    if (isOccupied && !isServiceArea) {
      parkedCar = _parkedCars.firstWhere(
        (car) => car['parkYeri'] == spotName,
        orElse: () => {},
      );
    }

    return Tooltip(
      message: isServiceArea
          ? (isOccupied && _serviceAreaCars.containsKey(spotName)
              ? '${_serviceAreaTypes[spotName]}\nTıklayın - Araç detaylarını görüntüle'
              : '${_serviceAreaTypes[spotName]}\nDurum: ${isOccupied ? 'Dolu' : 'Boş'}')
          : (isOccupied && parkedCar != null
          ? 'Tıklayın - Detayları görüntüle'
              : 'Park Yeri: $spotName\nDurum: ${isOccupied ? 'Dolu' : 'Boş'}'),
      child: GestureDetector(
        onTap: () {
          if (isServiceArea) {
            if (isOccupied) {
              if (_serviceAreaCars.containsKey(spotName)) {
                _showServiceAreaCarDetailsDialog(context, _serviceAreaCars[spotName]!);
              } else {
                _releaseServiceArea(spotName);
              }
            } else {
              _showCarSelectionDialog(spotName);
            }
          } else if (isOccupied && parkedCar != null) {
            _showCarDetailsDialog(context, parkedCar);
          } else {
            _selectSpot(spotName);
            _showCarRegistrationForm(spotName);
          }
        },
        child: Container(
          width: isMobile 
              ? (isServiceArea ? 25 : 20)
              : (isServiceArea ? 50 : 40),
          height: isMobile 
              ? (isServiceArea ? 18 : 15)
              : (isServiceArea ? 35 : 30),
          margin: EdgeInsets.symmetric(
            horizontal: isMobile ? 0.5 : 2,
          ),
          decoration: BoxDecoration(
            color: spotColor,
            borderRadius: BorderRadius.circular(4),
            border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
          ),
          child: Center(
            child: isServiceArea
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        spotIcon,
                        color: Colors.white,
                        size: isMobile ? 8 : 12,
                      ),
                      Text(
                        spotName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 5 : 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Text(
                    spotName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 6 : 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // Araç durumu değiştirme dialogu
  void _showStatusChangeDialog(String chassisNumber) {
    String currentStatus = _getCarStatus(chassisNumber);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Araç Durumu Değiştir'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Şase: $chassisNumber'),
              const SizedBox(height: 8),
              Text('Mevcut Durum: $currentStatus'),
              const SizedBox(height: 16),
              const Text('Yeni Durum Seçin:'),
              const SizedBox(height: 8),
              ...['Otopark Alanında', 'Araç Yıkamada', 'Araç Estetikte', 'Araç Teslimat Alanına Götürüldü', 'Araç Teslim Edildi']
                  .map((status) => ListTile(
                        title: Text(status),
                        leading: Radio<String>(
                          value: status,
                          groupValue: currentStatus,
                          onChanged: (String? value) {
                            if (value != null) {
                              _updateCarStatus(chassisNumber, value);
                              
                              // Eğer araç servis alanına veya teslim edildiyse park alanını boşalt
                              if (value == 'Araç Yıkamada' || 
                                  value == 'Araç Estetikte' || 
                                  value == 'Araç Teslimat Alanına Götürüldü' || 
                                  value == 'Araç Teslim Edildi') {
                                _clearParkingSpotForCar(chassisNumber);
                              }
                              
                              Navigator.pop(context);
                              _showSnackBar('Durum güncellendi: $value');
                              // Sorgulama sonucunu yenile
                              _searchCar();
                            }
                          },
                        ),
                      ))
                  .toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showServiceAreaCarDetailsDialog(BuildContext context, Map<String, dynamic> car) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.car_repair, color: Colors.blue),
              const SizedBox(width: 8),
              Text('${car['serviceType']} - ${car['serviceArea']}'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Şase: ${car['plaka']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Marka: ${car['marka']}'),
              Text('Model: ${car['model']}'),
              Text('Renk: ${car['renk']}'),
              Text('Yıl: ${car['yil']}'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${car['plaka']} numaralı araç ${car['serviceType'].toLowerCase()}da',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Süre: ${_formatTime(car['girisZamani'])}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Diğer Servis Alanlarına Taşı:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _getAvailableServiceAreas(car['serviceArea'])
                    .map((area) => ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _transferCarToServiceArea(car, area);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text(_serviceAreaTypes[area] ?? area),
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Kapat'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _releaseServiceArea(car['serviceArea']);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Çıkar'),
            ),
          ],
        );
      },
    );
  }

  // Gelişmiş fotoğraf çekme ve OCR
  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isProcessingImage = true;
        _imageProcessingStatus = 'Fotoğraf çekiliyor...';
        _imageProcessingProgress = 0.2;
      });

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 95,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (image != null) {
        setState(() {
          _imageProcessingStatus = 'Fotoğraf işleniyor...';
          _imageProcessingProgress = 0.5;
        });

        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = File(image.path);
          _selectedImageBytes = bytes;
          _imageProcessingStatus = 'Metin tanınıyor...';
          _imageProcessingProgress = 0.8;
        });
        
        // Gelişmiş OCR işlemi
        await _advancedOCR();
      }
    } catch (e) {
      setState(() {
        _isProcessingImage = false;
        _imageProcessingStatus = null;
        _imageProcessingProgress = 0.0;
      });
      _showSnackBar('Fotoğraf çekilirken hata oluştu: $e');
    }
  }

  // Gelişmiş OCR - çoklu deneme
  Future<void> _advancedOCR() async {
    if (_selectedImage == null) return;
    
    try {
      if (kIsWeb) {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _recognizedText = "Web'de OCR desteklenmiyor.";
          _isProcessingImage = false;
          _imageProcessingStatus = null;
          _imageProcessingProgress = 0.0;
        });
        _showSnackBar('Web\'de OCR desteklenmiyor.');
      } else {
        // Çoklu OCR denemesi
        List<String> results = [];
        
        // 1. Normal OCR
        try {
          final textRecognizer1 = TextRecognizer(script: TextRecognitionScript.latin);
          final inputImage1 = InputImage.fromFile(_selectedImage!);
          final result1 = await textRecognizer1.processImage(inputImage1);
          results.add('Normal: ${result1.text}');
          textRecognizer1.close();
        } catch (e) {
          results.add('Normal OCR Hatası: $e');
        }
        
        // 2. Daha agresif OCR ayarları
        try {
          final textRecognizer2 = TextRecognizer(script: TextRecognitionScript.latin);
          final inputImage2 = InputImage.fromFile(_selectedImage!);
          final result2 = await textRecognizer2.processImage(inputImage2);
          results.add('Agresif: ${result2.text}');
          textRecognizer2.close();
        } catch (e) {
          results.add('Agresif OCR Hatası: $e');
        }
        
        // En iyi sonucu seç
        String bestResult = _selectBestOCRResult(results);
        
        setState(() {
          _recognizedText = bestResult;
          _imageProcessingStatus = 'Tamamlandı!';
          _imageProcessingProgress = 1.0;
        });

        // Şase numarasını çıkar
        _extractChassisFromText(bestResult);
        
        // İşlem tamamlandıktan sonra durumu sıfırla
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isProcessingImage = false;
              _imageProcessingStatus = null;
              _imageProcessingProgress = 0.0;
            });
          }
        });
      }
    } catch (e) {
      _showSnackBar('OCR hatası: $e');
      setState(() {
        _isProcessingImage = false;
        _imageProcessingStatus = null;
        _imageProcessingProgress = 0.0;
      });
    }
  }

  // En iyi OCR sonucunu seç
  String _selectBestOCRResult(List<String> results) {
    if (results.isEmpty) return "OCR sonucu bulunamadı";
    
    // En uzun ve en temiz sonucu seç
    String bestResult = results.first;
    int maxLength = 0;
    
    for (String result in results) {
      String cleanResult = result.split(': ').length > 1 ? result.split(': ')[1] : result;
      if (cleanResult.length > maxLength && !cleanResult.contains('Hatası')) {
        bestResult = cleanResult;
        maxLength = cleanResult.length;
      }
    }
    
    return bestResult;
  }

  // Şase numarasını metinden çıkar
  void _extractChassisFromText(String text) {
    if (text.isEmpty) return;
    
    // Metni temizle
    String cleanText = text.replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();
    
    // Şase numarası ara (17 karakter)
    RegExp chassisPattern = RegExp(r'[A-Z0-9]{17}');
    Match? match = chassisPattern.firstMatch(cleanText);
      
      if (match != null) {
        String chassisNumber = match.group(0)!;
        _plakaController.text = chassisNumber;
      _showSnackBar('✅ Şase numarası bulundu: $chassisNumber');
      } else {
      // 13-17 karakter arası ara
      RegExp flexiblePattern = RegExp(r'[A-Z0-9]{13,17}');
      Match? flexibleMatch = flexiblePattern.firstMatch(cleanText);
        
        if (flexibleMatch != null) {
          String chassisNumber = flexibleMatch.group(0)!;
          _plakaController.text = chassisNumber;
        _showSnackBar('⚠️ Olası şase numarası: $chassisNumber');
        } else {
        _showSnackBar('❌ Şase numarası bulunamadı. Manuel girin.');
      }
    }
  }



  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resim Seç'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera ile Çek'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Seç'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showManualEditDialog() {
    final TextEditingController editController = TextEditingController(text: _recognizedText ?? '');
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Metni Manuel Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editController,
                decoration: const InputDecoration(
                  labelText: 'Tanınan Metin',
                  hintText: 'Metni buraya düzenleyin...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.characters,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _recognizedText = editController.text;
                });
                Navigator.pop(context);
                _extractChassisFromText(editController.text);
                _showSnackBar('Metin güncellendi!');
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _retryOCR() {
    if (_selectedImage != null) {
      setState(() {
        _isProcessingImage = true;
        _imageProcessingStatus = 'OCR tekrar çalıştırılıyor...';
        _imageProcessingProgress = 0.1;
        _recognizedText = null;
      });
      
      _advancedOCR();
    }
  }

  void _showCarRegistrationForm(String spotName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _serviceAreaTypes.containsKey(spotName) 
                            ? [Colors.blue.shade600, Colors.blue.shade800]
                            : [Colors.green.shade600, Colors.green.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _serviceAreaTypes.containsKey(spotName) 
                              ? Icons.car_repair 
                              : Icons.add_circle,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _serviceAreaTypes.containsKey(spotName) 
                              ? '${_serviceAreaTypes[spotName]} - Araç Kaydet'
                              : 'Araç Kaydet - $spotName',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Form Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Şase Numarası
                        TextField(
                          controller: _plakaController,
                          decoration: InputDecoration(
                            labelText: 'Araç Şase Numarası',
                            hintText: '1HGBH41JXMN109186',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.directions_car),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: _showImageSourceDialog,
                              tooltip: 'Kamera ile Şase Numarası Çek',
                            ),
                          ),
                          textCapitalization: TextCapitalization.characters,
                        ),
                        const SizedBox(height: 16),
                        
                        // Seçilen resim ve OCR sonucu
                        if (_selectedImageBytes != null) ...[
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                _selectedImageBytes!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Görüntü işleme durumu
                          if (_isProcessingImage) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          value: _imageProcessingProgress,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _imageProcessingStatus ?? 'İşleniyor...',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: _imageProcessingProgress,
                                    backgroundColor: Colors.blue.shade100,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          
                          // Gelişmiş OCR sonuç gösterimi
                          if (_recognizedText != null && !_isProcessingImage) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.text_fields, color: Colors.green.shade700, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'OCR Sonucu:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _recognizedText!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Düzeltme önerileri
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.blue.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.auto_fix_high, color: Colors.blue.shade700, size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Yaygın OCR Hataları:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade700,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'V↔T, F↔E, 1↔I, 0↔O, 5↔S, 8↔B, 6↔G, 2↔Z',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.blue.shade600,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                                  
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _showManualEditDialog(),
                                          icon: const Icon(Icons.edit, size: 16),
                                          label: const Text('Düzenle'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _retryOCR(),
                                          icon: const Icon(Icons.refresh, size: 16),
                                          label: const Text('Tekrar'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                        
                        // Marka
                        TextField(
                          controller: _markaController,
                          decoration: const InputDecoration(
                            labelText: 'Marka',
                            hintText: 'Toyota',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.branding_watermark),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Model
                        TextField(
                          controller: _modelController,
                          decoration: const InputDecoration(
                            labelText: 'Model',
                            hintText: 'Corolla',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.car_rental),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Renk
                        TextField(
                          controller: _renkController,
                          decoration: const InputDecoration(
                            labelText: 'Renk',
                            hintText: 'Beyaz',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.palette),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Yıl
                        TextField(
                          controller: _yilController,
                          decoration: const InputDecoration(
                            labelText: 'Yıl',
                            hintText: '2020',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 24),
                        
                        // Butonlar
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.close),
                                label: const Text('İptal'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isProcessingImage ? null : _parkCar,
                                icon: _isProcessingImage 
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.add),
                                label: Text(_isProcessingImage ? 'İşleniyor...' : 'Kaydet'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCarDetailsDialog(BuildContext context, Map<String, dynamic> car) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.directions_car,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Araç Detayları',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Plaka
                        _buildDetailRow(
                          icon: Icons.confirmation_number,
                          label: 'Plaka',
                          value: car['plaka'],
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 20),
                        
                        // Marka ve Model
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailRow(
                                icon: Icons.branding_watermark,
                                label: 'Marka',
                                value: car['marka'],
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDetailRow(
                                icon: Icons.car_rental,
                                label: 'Model',
                                value: car['model'],
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Renk ve Yıl
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailRow(
                                icon: Icons.palette,
                                label: 'Renk',
                                value: car['renk'],
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDetailRow(
                                icon: Icons.calendar_today,
                                label: 'Yıl',
                                value: car['yil'],
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Park Yeri
                        _buildDetailRow(
                          icon: Icons.local_parking,
                          label: 'Park Yeri',
                          value: car['parkYeri'],
                          color: Colors.purple,
                        ),
                        const SizedBox(height: 20),
                        
                        // Giriş Zamanı
                        _buildDetailRow(
                          icon: Icons.access_time,
                          label: 'Giriş Zamanı',
                          value: _formatTime(car['girisZamani']),
                          color: Colors.teal,
                        ),
                        const SizedBox(height: 20),
                        
                        // Park Süresi
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade50, Colors.blue.shade100],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.timer,
                                    color: Colors.blue.shade700,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Park Süresi',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _calculateDuration(car['girisZamani']),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Butonlar
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _selectSpot(car['parkYeri']);
                                },
                                icon: const Icon(Icons.edit_location),
                                label: const Text('Park Yerini Seç'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _removeCar(car['id']);
                                },
                                icon: const Icon(Icons.exit_to_app),
                                label: const Text('Araç Çıkar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _calculateDuration(DateTime startTime) {
    final now = DateTime.now();
    final duration = now.difference(startTime);
    
    int days = duration.inDays;
    int hours = duration.inHours % 24;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    
    if (days > 0) {
      return '${days}g ${hours}s ${minutes}dk';
    } else if (hours > 0) {
      return '${hours}s ${minutes}dk ${seconds}sn';
    } else if (minutes > 0) {
      return '${minutes}dk ${seconds}sn';
    } else {
      return '${seconds}sn';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Otopark Yönetim Sistemi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Ekran genişliğine göre layout belirle
          bool isMobile = constraints.maxWidth < 768;
          bool isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
          
          if (isMobile) {
            // Mobil: Dikey layout
            return _buildMobileLayout();
          } else if (isTablet) {
            // Tablet: Yarı yarıya layout
            return _buildTabletLayout();
          } else {
            // Desktop: Yan yana layout
            return _buildDesktopLayout();
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Otopark Kroki - Mobilde üstte
          _buildParkingMapCard(isMobile: true),
          const SizedBox(height: 12),
          // Otopark Sistemi - Mobilde altta
          _buildParkingSystemCard(isMobile: true),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Sol taraf - Otopark Kroki
          Expanded(
            flex: 1,
            child: _buildParkingMapCard(),
          ),
          const SizedBox(width: 16),
          // Sağ taraf - Otopark Sistemi
          Expanded(
            flex: 1,
            child: _buildParkingSystemCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Sol taraf - Otopark Kroki
          Expanded(
            flex: 1,
            child: _buildParkingMapCard(),
          ),
          const SizedBox(width: 16),
          // Sağ taraf - Otopark Sistemi
          Expanded(
            flex: 1,
            child: _buildParkingSystemCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingMapCard({bool isMobile = false}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
        child: Column(
          children: [
            const Icon(
              Icons.map,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            Text(
              'Otopark Kroki',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            // Otopark Durumu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _availableSpots > 10 ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_parking,
                    color: _availableSpots > 10 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
            Text(
                    'Park: $_availableSpots/$_totalSpots',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _availableSpots > 10 ? Colors.green.shade800 : Colors.red.shade800,
                    ),
            ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.car_repair,
                    color: _availableServiceAreas > 2 ? Colors.blue : Colors.orange,
                  ),
                  const SizedBox(width: 8),
            Text(
                    'Servis: $_availableServiceAreas/$_totalServiceAreas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _availableServiceAreas > 2 ? Colors.blue.shade800 : Colors.orange.shade800,
                    ),
            ),
          ],
        ),
      ),
            const SizedBox(height: 16),
            // Kroki Grid - Responsive height (increased for service areas)
            SizedBox(
              height: isMobile 
                  ? MediaQuery.of(context).size.height * 0.3  // Mobilde çok daha küçük
                  : MediaQuery.of(context).size.height * 0.5, // Desktop'ta normal
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 4 : 8),
                  child: Column(
                    children: _parkingLayout.asMap().entries.map((rowEntry) {
                      List<String> row = rowEntry.value;
                      
                      if (row.isEmpty) {
                        // Koridor - satır indeksine göre farklı etiketler
                        bool isServiceCorridor = rowEntry.key == 1; // İkinci satır servis koridoru
                        return Container(
                          height: 20,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isServiceCorridor ? Colors.blue.shade100 : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              isServiceCorridor ? 'SERVİS KORİDORU' : 'ARAÇ KORİDORU',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isServiceCorridor ? Colors.blue.shade800 : Colors.grey,
                              ),
                            ),
                          ),
                        );
                      } else {
                        // Park yeri satırı
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: isMobile 
                              ? Column(
                                  children: _createMobileRows(row),
                                )
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: row.map((spotName) => _buildParkSpot(spotName, isMobile: false)).toList(),
                            ),
                          ),
                        );
                      }
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    const Text('Boş Park', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 4),
                    const Text('Dolu Park', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                        color: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    const Text('Boş Servis', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    const Text('Dolu Servis', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('Seçili', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingSystemCard({bool isMobile = false}) {
    return Column(
      children: [
        // Araç Sorgula
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Araç Sorgula',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Şase Numarası Ara',
                    hintText: '1HGBH41JXMN109186',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _searchCar,
                  icon: const Icon(Icons.search),
                  label: const Text('Sorgula'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                if (_searchResult.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _searchResult.contains('bulundu') ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                      _searchResult,
                      style: TextStyle(
                        color: _searchResult.contains('bulundu') ? Colors.green.shade800 : Colors.red.shade800,
                        fontSize: 12,
                          ),
                        ),
                        if (_searchResult.contains('bulundu')) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showStatusChangeDialog(_searchController.text),
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('Durum Değiştir'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Servis Alanları Yönetimi
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Servis Alanları (${_availableServiceAreas}/$_totalServiceAreas)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                isMobile 
                    ? Column(
                        children: _serviceAreaTypes.entries.map((entry) {
                          String areaName = entry.key;
                          String serviceType = entry.value;
                          bool isOccupied = _serviceAreas[areaName] == true;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: _buildServiceAreaItem(areaName, serviceType, isOccupied),
                          );
                        }).toList(),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _serviceAreaTypes.entries.map((entry) {
                    String areaName = entry.key;
                    String serviceType = entry.value;
                    bool isOccupied = _serviceAreas[areaName] == true;
                    
                    return _buildServiceAreaItem(areaName, serviceType, isOccupied);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Park Edilen Araçlar
        Expanded(
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Park Edilen Araçlar (${_parkedCars.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _parkedCars.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_parking_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Henüz park edilen araç yok',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _parkedCars.length,
                            itemBuilder: (context, index) {
                              final car = _parkedCars[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.directions_car, size: 20),
                                  title: Text(
                                    car['plaka'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${car['marka']} ${car['model']} - ${car['renk']} (${car['yil']})',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      Text(
                                        'Park Yeri: ${car['parkYeri']} | Giriş: ${_formatTime(car['girisZamani'])}',
                                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Süre: ${_calculateDuration(car['girisZamani'])}',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.exit_to_app, size: 20),
                                    onPressed: () => _removeCar(car['id']),
                                    color: Colors.red,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}