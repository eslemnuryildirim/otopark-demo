import 'package:shared_preferences/shared_preferences.dart';

/// OCR Yapılandırması
/// Mac IP adresini ve diğer ayarları burada sakla
class OcrConfig {
  static const String _ipKey = 'ocr_mac_ip_address';
  
  // Python OCR sunucu portu
  static const int serverPort = 8080;
  
  // Mac IP adresini yükle (SharedPreferences'tan)
  static Future<String?> loadMacIpAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ip = prefs.getString(_ipKey);
      if (ip != null && ip.isNotEmpty) {
        print('📱 Mac IP adresi yüklendi: $ip');
        return ip;
      }
    } catch (e) {
      print('⚠️ IP adresi yüklenemedi: $e');
    }
    return null;
  }
  
  // Mac IP adresini kaydet (SharedPreferences'a)
  static Future<void> saveMacIpAddress(String? ip) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (ip != null && ip.isNotEmpty) {
        await prefs.setString(_ipKey, ip);
        print('✅ Mac IP adresi kaydedildi: $ip');
      } else {
        await prefs.remove(_ipKey);
        print('🗑️ Mac IP adresi silindi');
      }
    } catch (e) {
      print('❌ IP adresi kaydedilemedi: $e');
    }
  }
  
  // Mac IP adresini al (iOS cihazdan erişim için)
  static Future<String> getServerUrl() async {
    final ip = await loadMacIpAddress();
    if (ip != null && ip.isNotEmpty) {
      return 'http://$ip:$serverPort';
    }
    return 'http://localhost:$serverPort';
  }
  
  // Mac IP adresini ayarla (hem memory'de hem SharedPreferences'ta)
  static Future<void> setMacIpAddress(String? ip) async {
    await saveMacIpAddress(ip);
  }
  
  // Mevcut IP adresini al (sync)
  static Future<String?> getMacIpAddress() async {
    return await loadMacIpAddress();
  }
}

