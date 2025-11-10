import 'package:flutter/material.dart';
import 'ocr_config.dart';
import 'http_ocr_service.dart';

/// OCR IP Ayarları Dialog'u
/// iOS cihazda Mac IP adresini ayarlamak için
class OcrIpSetupDialog extends StatefulWidget {
  const OcrIpSetupDialog({super.key});

  @override
  State<OcrIpSetupDialog> createState() => _OcrIpSetupDialogState();
}

class _OcrIpSetupDialogState extends State<OcrIpSetupDialog> {
  late final TextEditingController _ipController;
  bool _isTesting = false;
  bool _isConnected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIpAddress();
  }

  Future<void> _loadIpAddress() async {
    final ip = await OcrConfig.getMacIpAddress();
    _ipController = TextEditingController(text: ip ?? '');
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _isConnected = false;
    });

    // IP'yi geçici olarak kaydet
    final testIp = _ipController.text.trim();
    if (testIp.isNotEmpty) {
      await OcrConfig.setMacIpAddress(testIp);
    }

    // Bağlantıyı test et
    final isHealthy = await HttpOcrService.checkServerHealth();

    setState(() {
      _isTesting = false;
      _isConnected = isHealthy;
    });

    if (isHealthy && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ OCR sunucusuna bağlanıldı!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ OCR sunucusuna bağlanılamadı.\nIP: $testIp\nMac\'te Python sunucusunu başlattınız mı?'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _saveIp() async {
    final ip = _ipController.text.trim();
    if (ip.isNotEmpty) {
      await OcrConfig.setMacIpAddress(ip);
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Mac IP adresi kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      await OcrConfig.setMacIpAddress(null);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.settings_ethernet, color: Colors.blue),
          SizedBox(width: 8),
          Text('OCR Sunucu Ayarları'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'iOS cihazda Mac\'in IP adresini girin:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: 'Mac IP Adresi',
                hintText: '192.168.1.100',
                prefixIcon: const Icon(Icons.computer),
                suffixIcon: _isTesting
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          _isConnected ? Icons.check_circle : Icons.refresh,
                          color: _isConnected ? Colors.green : Colors.blue,
                        ),
                        onPressed: _isTesting ? null : _testConnection,
                        tooltip: 'Bağlantıyı Test Et',
                      ),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text, // number yerine text (nokta için)
              inputFormatters: [], // IP formatı için özel formatter eklenebilir
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Mac IP Adresi Nasıl Bulunur?'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mac\'inizde terminal açın ve şu komutu çalıştırın:'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          child: const Text(
                            'ifconfig | grep "inet "',
                            style: TextStyle(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('veya'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          child: const Text(
                            'ipconfig getifaddr en0',
                            style: TextStyle(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Çıkan IP adresini (örn: 192.168.1.100) buraya girin.'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Tamam'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.help_outline),
              label: const Text('Mac IP\'sini Nasıl Bulurum?'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saveIp,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}

