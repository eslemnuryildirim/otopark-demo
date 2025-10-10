import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otopark_demo/core/utils/ocr_helper.dart';
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

  @override
  void dispose() {
    _plateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
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
              controller: _plateController,
              decoration: InputDecoration(
                labelText: 'Şase',
                prefixIcon: const Icon(Icons.badge),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () async {
                    final scanned = await _scanChassisNumber(context);
                    if (scanned != null) {
                      _plateController.text = scanned;
                    }
                  },
                  tooltip: 'Şase Tara (OCR)',
                ),
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

  Future<String?> _scanChassisNumber(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    
    // Kamera ile fotoğraf çek
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    
    if (image == null) return null;
    
    try {
      // Gelişmiş OCR ile metni tanı (görüntü iyileştirme + Tesseract)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şase okunuyor...')),
        );
      }
      
      final lines = await OcrHelper.extractTextFromImage(image.path);
      
      if (lines.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Şase numarası okunamadı. Fotoğrafı daha net çekin.')),
          );
        }
        return null;
      }
      
      // Kullanıcıya okunan metinleri göster
      if (context.mounted) {
        return showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Şase Seçin'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: lines.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(lines[index]),
                    onTap: () => Navigator.pop(context, lines[index]),
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
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
    
    return null;
  }
}
