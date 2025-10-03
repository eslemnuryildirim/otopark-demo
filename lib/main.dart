import 'package:flutter/material.dart';
import 'dart:async';

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
                  const Icon(
                    Icons.local_parking,
                    size: 64,
                    color: Colors.blue,
                  ),
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
  // Park yeri düzeni: 7 satır, farklı sütun sayıları
  // 1. satır: 13 park yeri (A1-A13)
  // 2. satır: araç koridoru
  // 3-4. satır: 13 park yeri (B1-B13, C1-C13)
  // 5. satır: araç koridoru  
  // 6-7. satır: 14 park yeri (D1-D14, E1-E14)
  // 8. satır: araç koridoru
  // 9. satır: 13 park yeri (F1-F13)
  
  List<List<String>> _parkingLayout = [
    ['A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'A9', 'A10', 'A11', 'A12', 'A13'],
    [], // Araç koridoru
    ['B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B9', 'B10', 'B11', 'B12', 'B13'],
    ['C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11', 'C12', 'C13'],
    [], // Araç koridoru
    ['D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8', 'D9', 'D10', 'D11', 'D12', 'D13', 'D14'],
    ['E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8', 'E9', 'E10', 'E11', 'E12', 'E13', 'E14'],
    [], // Araç koridoru
    ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', 'F13'],
  ];
  
  Map<String, bool> _occupiedSpots = {};
  int _totalSpots = 0;
  String _searchResult = '';
  String? _selectedSpot;
  Timer? _timer;

  int get _availableSpots => _totalSpots - _occupiedSpots.values.where((occupied) => occupied).length;

  @override
  void initState() {
    super.initState();
    _initializeParkingSpots();
    _startTimer();
  }

  void _initializeParkingSpots() {
    _totalSpots = 0;
    for (var row in _parkingLayout) {
      for (var spot in row) {
        if (spot.isNotEmpty) {
          _occupiedSpots[spot] = false;
          _totalSpots++;
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
      final foundCar = _parkedCars.firstWhere(
        (car) => car['plaka'].toLowerCase().contains(_searchController.text.toLowerCase()),
        orElse: () => {},
      );
      
      if (foundCar.isNotEmpty) {
        setState(() {
          _searchResult = 'Araç bulundu!\nPlaka: ${foundCar['plaka']}\nGiriş: ${_formatTime(foundCar['girisZamani'])}';
        });
      } else {
        setState(() {
          _searchResult = 'Araç bulunamadı!';
        });
      }
    } else {
      _showSnackBar('Lütfen plaka girin!');
    }
  }

  void _removeCar(int id) {
    final car = _parkedCars.firstWhere((car) => car['id'] == id);
    setState(() {
      _parkedCars.removeWhere((car) => car['id'] == id);
      _occupiedSpots[car['parkYeri']] = false;
    });
    _showSnackBar('Araç çıkarıldı! Park Yeri ${car['parkYeri']} boşaldı');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Sol taraf - Otopark Kroki
            Expanded(
              flex: 1,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                              '$_availableSpots / $_totalSpots',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _availableSpots > 10 ? Colors.green.shade800 : Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Kroki Grid
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: _parkingLayout.asMap().entries.map((rowEntry) {
                                int rowIndex = rowEntry.key;
                                List<String> row = rowEntry.value;
                                
                                if (row.isEmpty) {
                                  // Araç koridoru
                                  return Container(
                                    height: 20,
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'ARAÇ KORİDORU',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  // Park yeri satırı
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: row.map((spotName) {
                                        bool isOccupied = _occupiedSpots[spotName] == true;
                                        bool isSelected = _selectedSpot == spotName;
                                        
                                        Color spotColor;
                                        if (isSelected) {
                                          spotColor = Colors.blue;
                                        } else if (isOccupied) {
                                          spotColor = Colors.red;
                                        } else {
                                          spotColor = Colors.green;
                                        }
                                        
                                        // Park edilen araç bilgilerini bul
                                        Map<String, dynamic>? parkedCar;
                                        if (isOccupied) {
                                          parkedCar = _parkedCars.firstWhere(
                                            (car) => car['parkYeri'] == spotName,
                                            orElse: () => {},
                                          );
                                        }

                                        return Tooltip(
                                          message: isOccupied && parkedCar != null
                                              ? 'Plaka: ${parkedCar['plaka']}\n'
                                                'Marka: ${parkedCar['marka']}\n'
                                                'Model: ${parkedCar['model']}\n'
                                                'Renk: ${parkedCar['renk']}\n'
                                                'Yıl: ${parkedCar['yil']}\n'
                                                'Süre: ${_calculateDuration(parkedCar['girisZamani'])}'
                                              : 'Park Yeri: $spotName\nDurum: ${isOccupied ? 'Dolu' : 'Boş'}',
                                          child: GestureDetector(
                                            onTap: () => _selectSpot(spotName),
                                            child: Container(
                                              width: 40,
                                              height: 30,
                                              margin: const EdgeInsets.symmetric(horizontal: 2),
                                              decoration: BoxDecoration(
                                                color: spotColor,
                                                borderRadius: BorderRadius.circular(4),
                                                border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  spotName,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                }
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              const Text('Boş', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              const Text('Dolu', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
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
              ),
            ),
            const SizedBox(width: 16),
            // Sağ taraf - Otopark Sistemi
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // Araç Kaydet
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Araç Kaydet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          // Plaka
                          TextField(
                            controller: _plakaController,
                            decoration: const InputDecoration(
                              labelText: 'Araç Plakası',
                              hintText: '34 ABC 123',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.directions_car),
                            ),
                            textCapitalization: TextCapitalization.characters,
                          ),
                          const SizedBox(height: 12),
                          // Marka ve Model
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _markaController,
                                  decoration: const InputDecoration(
                                    labelText: 'Marka',
                                    hintText: 'Toyota',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.branding_watermark),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _modelController,
                                  decoration: const InputDecoration(
                                    labelText: 'Model',
                                    hintText: 'Corolla',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.car_rental),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Renk ve Yıl
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _renkController,
                                  decoration: const InputDecoration(
                                    labelText: 'Renk',
                                    hintText: 'Beyaz',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.palette),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _yilController,
                                  decoration: const InputDecoration(
                                    labelText: 'Yıl',
                                    hintText: '2020',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.calendar_today),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Seçili Park Yeri
                          if (_selectedSpot != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_parking, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Seçili Park Yeri: $_selectedSpot',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _parkCar,
                            icon: const Icon(Icons.add),
                            label: const Text('Park Et'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
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
                              labelText: 'Plaka Ara',
                              hintText: '34 ABC 123',
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
                              child: Text(
                                _searchResult,
                                style: TextStyle(
                                  color: _searchResult.contains('bulundu') ? Colors.green.shade800 : Colors.red.shade800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}


