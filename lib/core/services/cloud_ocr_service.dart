import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Cloud OCR Servisi
/// Production için cloud-based OCR çözümleri
class CloudOcrService {
  // TODO: Production'da bu değerleri environment variable'dan al
  static const String? _googleCloudApiKey = null; // Google Cloud Vision API Key
  static const String? _awsAccessKey = null; // AWS Access Key
  static const String? _awsSecretKey = null; // AWS Secret Key
  
  /// Google Cloud Vision API ile OCR
  static Future<List<String>> extractVinWithGoogleVision(Uint8List imageBytes) async {
    if (_googleCloudApiKey == null) {
      print('⚠️ Google Cloud Vision API key yapılandırılmamış');
      return [];
    }
    
    try {
      print('🔍 Google Cloud Vision OCR başlatılıyor...');
      
      final base64Image = base64Encode(imageBytes);
      
      final response = await http.post(
        Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=$_googleCloudApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'TEXT_DETECTION', 'maxResults': 10}
              ]
            }
          ]
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final textAnnotations = data['responses'][0]['textAnnotations'] ?? [];
        
        final vins = <String>[];
        for (final annotation in textAnnotations) {
          final text = annotation['description'] as String?;
          if (text != null && _isPotentialVin(text)) {
            vins.add(text);
          }
        }
        
        print('✅ Google Cloud Vision OCR tamamlandı: ${vins.length} VIN bulundu');
        return vins;
      }
      
      return [];
    } catch (e) {
      print('❌ Google Cloud Vision OCR hatası: $e');
      return [];
    }
  }
  
  /// AWS Textract ile OCR
  static Future<List<String>> extractVinWithAwsTextract(Uint8List imageBytes) async {
    if (_awsAccessKey == null || _awsSecretKey == null) {
      print('⚠️ AWS credentials yapılandırılmamış');
      return [];
    }
    
    // AWS Textract implementation
    // Not: AWS SDK gerektirir (aws_signature_v4, etc.)
    print('⚠️ AWS Textract henüz implement edilmedi');
    return [];
  }
  
  /// Firebase Functions ile OCR (Önerilen)
  /// Backend'de Python OCR çalıştırılır
  /// 
  /// Test için: Firebase Emulator kullan (http://localhost:5001)
  /// Production için: Cloud Functions URL'i kullan
  static Future<List<String>> extractVinWithFirebaseFunctions(Uint8List imageBytes) async {
    try {
      print('🔍 Firebase Functions OCR başlatılıyor...');
      
      final base64Image = base64Encode(imageBytes);
      
      // Test için: Emulator URL (development)
      // Production için: Cloud Functions URL'i kullan
      const isTestMode = true; // Production'da false yap
      final functionsUrl = isTestMode
          ? 'http://localhost:5001/otopark-demo/us-central1/ocrVin' // Emulator
          : 'https://us-central1-otopark-demo.cloudfunctions.net/ocrVin'; // Production
      
      print('📡 Functions URL: $functionsUrl');
      
      final response = await http.post(
        Uri.parse(functionsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': base64Image,
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final vins = List<String>.from(data['vins'] ?? []);
        final mode = data['mode'] ?? 'unknown';
        
        print('✅ Firebase Functions OCR tamamlandı (mode: $mode): ${vins.length} VIN bulundu');
        return vins;
      }
      
      print('❌ Firebase Functions OCR hatası: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e) {
      print('❌ Firebase Functions OCR hatası: $e');
      return [];
    }
  }
  
  /// VIN potansiyel kontrolü
  static bool _isPotentialVin(String text) {
    final cleaned = text.toUpperCase().replaceAll(RegExp(r'[^A-HJ-NPR-Z0-9]'), '');
    return cleaned.length >= 8 && cleaned.length <= 17;
  }
}

