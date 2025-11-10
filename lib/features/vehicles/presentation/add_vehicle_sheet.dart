import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otopark_demo/core/services/simple_ocr_service.dart';
import 'package:otopark_demo/core/utils/vin_decoder.dart';
import 'package:otopark_demo/core/utils/validators.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle.dart';
import 'package:otopark_demo/features/vehicles/domain/vehicle_status.dart';
import 'package:otopark_demo/features/vehicles/providers/vehicle_providers.dart';

class AddVehicleSheet extends ConsumerStatefulWidget {
  const AddVehicleSheet({super.key});

  @override
  ConsumerState<AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends ConsumerState<AddVehicleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _vinController = TextEditingController();
  final _productionYearController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _plateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _vinController.dispose();
    _productionYearController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _addVehicle() async {
    if (_formKey.currentState?.validate() ?? false) {
      final uuid = ref.read(uuidProvider);
      final newVehicle = Vehicle(
        id: uuid.v4(),
        plate: _plateController.text.trim(),
        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
        color: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
        status: VehicleStatus.parked, // Varsayılan olarak parked
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(vehiclesProvider.notifier).addVehicle(newVehicle);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Araç başarıyla eklendi!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Yeni Araç Ekle',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _vinController,
              decoration: InputDecoration(
                labelText: 'Şase Numarası (VIN)',
                prefixIcon: const Icon(Icons.badge),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () => _scanVin(context),
                      tooltip: 'Şase Tara (OCR)',
                    ),
                    if (_vinController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _vinController.clear();
                          _brandController.clear();
                          _productionYearController.clear();
                          _ageController.clear();
                        },
                      ),
                  ],
                ),
              ),
              onChanged: (vin) {
                if (vin.length >= 10) {
                  _updateVinInfo(vin);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _plateController,
              decoration: const InputDecoration(
                labelText: 'Plaka',
                prefixIcon: Icon(Icons.directions_car),
                hintText: '34 ABC 123',
              ),
              validator: (value) => Validators.validatePlate(value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Marka',
                prefixIcon: Icon(Icons.branding_watermark),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model',
                prefixIcon: Icon(Icons.car_rental),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _productionYearController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Üretim Yılı',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Yaş',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Renk',
                prefixIcon: Icon(Icons.color_lens),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addVehicle,
                icon: const Icon(Icons.save),
                label: const Text('Kaydet'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// VIN bilgilerini güncelle (marka, üretim yılı, yaş)
  void _updateVinInfo(String vin) {
    final brand = VinDecoder.getBrandFromVin(vin);
    final productionYear = VinDecoder.getProductionYear(vin);
    final age = VinDecoder.getAge(vin);
    
    if (brand != 'Bilinmiyor') {
      _brandController.text = brand;
    }
    
    if (productionYear != null) {
      _productionYearController.text = productionYear.toString();
    }
    
    if (age != null) {
      _ageController.text = '$age yaşında';
    }
  }

  /// VIN tara (kamera veya galeri)
  Future<void> _scanVin(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    
    // Kaynak seçimi
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şase Numarası Tara'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    
    if (source == null) return;
    
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 90,
    );
    
    if (image == null) return;
    
    try {
      // Yükleme dialog'u göster
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PopScope(
            canPop: false,
            child: const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Şase numarası okunuyor...'),
                  SizedBox(height: 8),
                  Text(
                    'Görüntü işleme ile VIN taranıyor',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }
      
      // Görüntüyü byte array'e çevir
      final imageBytes = await image.readAsBytes();
      
      // OCR ile VIN oku
      final vins = await SimpleOcrService.extractVin(imageBytes);
      
      // Yükleme dialog'unu kapat
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      if (vins.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Şase numarası okunamadı. Lütfen tekrar deneyin.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      
      // Kullanıcıya okunan VIN'leri göster
      if (context.mounted) {
        final selectedVin = await showDialog<String>(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text('${vins.length} VIN Bulundu'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'En uygun şase numarasını seçin:',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: vins.length,
                      itemBuilder: (context, index) {
                        final vin = vins[index];
                        final brand = VinDecoder.getBrandFromVin(vin);
                        final year = VinDecoder.getProductionYear(vin);
                        
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${index + 1}'),
                            ),
                            title: Text(
                              vin,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontFamily: 'monospace',
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${vin.length} karakter'),
                                if (brand != 'Bilinmiyor') Text('Marka: $brand'),
                                if (year != null) Text('Üretim: $year'),
                              ],
                            ),
                            onTap: () => Navigator.pop(context, vin),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
            ],
          ),
        );
        
        if (selectedVin != null) {
          _vinController.text = selectedVin;
          _updateVinInfo(selectedVin);
        }
      }
    } catch (e) {
      // Hata durumunda yükleme dialog'unu kapat
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ OCR Hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
