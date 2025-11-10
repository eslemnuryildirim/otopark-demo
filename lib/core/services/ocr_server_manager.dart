import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

/// OCR Sunucu Yöneticisi
/// Python OCR sunucusunu otomatik başlatır ve yönetir
class OcrServerManager {
  static Process? _serverProcess;
  static bool _isStarting = false;
  static Timer? _healthCheckTimer;
  
  /// Sunucuyu başlat (eğer çalışmıyorsa)
  static Future<bool> startServerIfNeeded() async {
    // iOS cihazda Python çalışmaz, sadece macOS'ta çalıştır
    if (Platform.isIOS && !Platform.isMacOS) {
      print('⚠️ iOS cihazda Python OCR sunucusu çalıştırılamaz');
      print('💡 Python sunucusunu Mac bilgisayarınızda manuel olarak başlatın: python3 simple_ocr_server.py');
      return false;
    }
    
    if (_isStarting) {
      print('⏳ Sunucu zaten başlatılıyor...');
      return false;
    }
    
    // Önce sunucunun çalışıp çalışmadığını kontrol et
    final isRunning = await checkServerHealth();
    if (isRunning) {
      print('✅ OCR sunucusu zaten çalışıyor');
      return true;
    }
    
    _isStarting = true;
    
    try {
      print('🚀 Python OCR sunucusu başlatılıyor...');
      
      // Python script'inin yolunu bul
      final scriptPath = await _getServerScriptPath();
      if (scriptPath == null) {
        print('❌ OCR sunucu scripti bulunamadı');
        _isStarting = false;
        return false;
      }
      
      // Python'un yüklü olup olmadığını kontrol et
      try {
        final pythonCheck = await Process.run('which', ['python3']);
        if (pythonCheck.exitCode != 0) {
          print('❌ Python3 bulunamadı. Lütfen Python3 yükleyin.');
          _isStarting = false;
          return false;
        }
        print('✅ Python3 bulundu: ${pythonCheck.stdout.toString().trim()}');
      } catch (e) {
        print('❌ Python3 kontrolü başarısız: $e');
        _isStarting = false;
        return false;
      }
      
      // Python process'ini başlat
      print('🚀 Python process başlatılıyor: python3 $scriptPath');
      _serverProcess = await Process.start(
        'python3',
        [scriptPath],
        mode: ProcessStartMode.detached,
        runInShell: true, // Shell'de çalıştır (PATH'i bulabilmek için)
      );
      
      // Process'in çıktısını dinle (opsiyonel)
      _serverProcess!.stdout.transform(utf8.decoder).listen(
        (data) {
          print('📝 OCR Server: $data');
        },
      );
      
      _serverProcess!.stderr.transform(utf8.decoder).listen(
        (data) {
          print('⚠️ OCR Server Error: $data');
        },
      );
      
      // Process'in çıkışını dinle
      _serverProcess!.exitCode.then((code) {
        print('⚠️ OCR sunucusu kapandı (exit code: $code)');
        _serverProcess = null;
        _isStarting = false;
      });
      
      // Sunucunun başlamasını bekle (5 saniye)
      print('⏳ Sunucunun başlaması bekleniyor...');
      await Future.delayed(const Duration(seconds: 5));
      
      // Sağlık kontrolü yap
      final isHealthy = await checkServerHealth();
      if (isHealthy) {
        print('✅ OCR sunucusu başarıyla başlatıldı');
        _startHealthCheck();
        _isStarting = false;
        return true;
      } else {
        print('⚠️ OCR sunucusu başlatıldı ama sağlık kontrolü başarısız');
        _isStarting = false;
        return false;
      }
      
    } catch (e) {
      print('❌ OCR sunucusu başlatılamadı: $e');
      _isStarting = false;
      return false;
    }
  }
  
  /// Sunucu script'inin yolunu bul
  static Future<String?> _getServerScriptPath() async {
    try {
      // Flutter proje root'unu bul
      final currentDir = Directory.current;
      print('🔍 Script aranıyor, mevcut dizin: ${currentDir.path}');
      
      // Farklı olası konumları dene
      final possiblePaths = [
        '${currentDir.path}/simple_ocr_server.py',
        '${currentDir.path}/../simple_ocr_server.py',
        '${currentDir.path}/../../simple_ocr_server.py',
      ];
      
      for (final path in possiblePaths) {
        final scriptFile = File(path);
        if (await scriptFile.exists()) {
          print('✅ Script bulundu: ${scriptFile.absolute.path}');
          return scriptFile.absolute.path;
        }
        print('❌ Script bulunamadı: $path');
      }
      
      // iOS cihazda çalışıyorsa, script'e erişim olmayabilir
      if (Platform.isIOS) {
        print('⚠️ iOS cihazda Python script\'ine erişim sınırlı olabilir');
        print('💡 Çözüm: Python sunucusunu manuel olarak başlatın: python3 simple_ocr_server.py');
      }
      
      return null;
    } catch (e) {
      print('❌ Script path bulunamadı: $e');
      return null;
    }
  }
  
  /// Sunucu sağlık kontrolü
  static Future<bool> checkServerHealth() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/health'),
      ).timeout(const Duration(seconds: 2));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Periyodik sağlık kontrolü başlat
  static void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      final isHealthy = await checkServerHealth();
      if (!isHealthy && _serverProcess != null) {
        print('⚠️ OCR sunucusu çalışmıyor, yeniden başlatılıyor...');
        await stopServer();
        await startServerIfNeeded();
      }
    });
  }
  
  /// Sunucuyu durdur
  static Future<void> stopServer() async {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    
    if (_serverProcess != null) {
      print('🛑 OCR sunucusu durduruluyor...');
      _serverProcess!.kill();
      await _serverProcess!.exitCode;
      _serverProcess = null;
      print('✅ OCR sunucusu durduruldu');
    }
  }
  
  /// Sunucunun çalışıp çalışmadığını kontrol et
  static bool isServerRunning() {
    return _serverProcess != null;
  }
}

