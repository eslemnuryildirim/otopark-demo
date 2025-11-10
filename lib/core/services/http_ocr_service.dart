import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'ocr_config.dart';

/// HTTP OCR Servisi - Python sunucu ile iletişim
class HttpOcrService {
  static Future<String> get _baseUrl async => await OcrConfig.getServerUrl();
  
  /// VIN okuma - Python sunucu üzerinden
  static Future<List<String>> extractVin(Uint8List imageBytes) async {
    try {
      print('🔍 HTTP OCR başlatılıyor...');
      
      // 1. Base URL'i al
      final baseUrl = await _baseUrl;
      print('📡 OCR Sunucu URL: $baseUrl');
      
      // 2. Görüntüyü base64'e çevir
      final base64Image = base64Encode(imageBytes);
      
      // 3. HTTP isteği gönder
      final response = await http.post(
        Uri.parse('$baseUrl/ocr/vin'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image': base64Image,
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final vins = List<String>.from(data['vins'] ?? []);
        
        print('✅ HTTP OCR tamamlandı: ${vins.length} VIN bulundu');
        return vins;
        
      } else {
        print('❌ HTTP OCR hatası: ${response.statusCode} - ${response.body}');
        return [];
      }
      
    } catch (e) {
      print('❌ HTTP OCR hatası: $e');
      return [];
    }
  }
  
  /// Sunucu sağlık kontrolü
  static Future<bool> checkServerHealth() async {
    try {
      final url = await _baseUrl;
      print('🔍 Sunucu sağlık kontrolü: $url');
      
      final response = await http.get(
        Uri.parse('$url/health'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        print('✅ OCR sunucusu çalışıyor: $url');
        return true;
      }
      
      print('⚠️ OCR sunucusu yanıt vermedi: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Sunucu sağlık kontrolü hatası: $e');
      if (Platform.isIOS && !Platform.isMacOS) {
        final currentIp = await OcrConfig.getMacIpAddress();
        if (currentIp == null || currentIp.isEmpty) {
          print('💡 iOS cihazda Mac IP adresi gerekli!');
          print('   AppBar\'daki ayarlar ikonuna tıklayıp Mac IP\'sini girin.');
          print('   Mac IP\'sini bulmak için Mac\'te: ifconfig | grep "inet "');
        } else {
          print('💡 Mevcut IP: $currentIp');
          print('   IP adresi yanlış olabilir veya Python sunucusu çalışmıyor.');
          print('   Mac\'te Python sunucusunu başlatın: ./start_ocr_server_mac.sh');
        }
      }
      return false;
    }
  }
}

