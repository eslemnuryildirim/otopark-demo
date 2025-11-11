# 🔍 Python Dışında Görüntü İşleme Seçenekleri

## 📊 Karşılaştırma Tablosu

| Seçenek | On-Device | Hız | Doğruluk | Maliyet | Kurulum |
|---------|-----------|-----|----------|---------|---------|
| **Google ML Kit** | ✅ | ⚡⚡⚡ | ⭐⭐⭐⭐ | Ücretsiz | Orta |
| **Tesseract OCR** | ✅ | ⚡⚡ | ⭐⭐⭐ | Ücretsiz | Zor |
| **Cloud Vision** | ❌ | ⚡⚡⚡ | ⭐⭐⭐⭐⭐ | $1.50/1K | Kolay |
| **AWS Textract** | ❌ | ⚡⚡⚡ | ⭐⭐⭐⭐⭐ | $1.50/1K | Orta |
| **Flutter Image** | ✅ | ⚡⚡⚡⚡ | ❌ (OCR yok) | Ücretsiz | Kolay |

---

## 1. 🎯 Google ML Kit (ÖNERİLEN)

### Avantajlar
- ✅ **On-device**: İnternet gerektirmez
- ✅ **Hızlı**: ~1-2 saniye
- ✅ **Ücretsiz**: Tamamen ücretsiz
- ✅ **Doğru**: Google'ın ML modeli
- ✅ **Kolay entegrasyon**: Flutter paketi mevcut

### Dezavantajlar
- ⚠️ Firebase ile versiyon çakışması (çözülebilir)
- ⚠️ iOS için native bağımlılıklar

### Kurulum

```yaml
# pubspec.yaml
dependencies:
  google_mlkit_text_recognition: ^0.13.0
```

```dart
// lib/core/services/mlkit_ocr_service.dart
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MlKitOcrService {
  static Future<List<String>> extractVin(Uint8List imageBytes) async {
    try {
      // Geçici dosya oluştur
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/vin_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(imageBytes);
      
      // ML Kit ile OCR
      final inputImage = InputImage.fromFilePath(tempFile.path);
      final textRecognizer = TextRecognizer();
      
      final recognizedText = await textRecognizer.processImage(inputImage);
      
      // VIN'leri filtrele
      final vins = _extractVins(recognizedText.text);
      
      // Temizlik
      await textRecognizer.close();
      await tempFile.delete();
      
      return vins;
    } catch (e) {
      print('❌ ML Kit OCR hatası: $e');
      return [];
    }
  }
  
  static List<String> _extractVins(String text) {
    // VIN pattern: 17 karakter, alfanumerik
    final vinPattern = RegExp(r'[A-HJ-NPR-Z0-9]{17}');
    return vinPattern.allMatches(text).map((m) => m.group(0)!).toList();
  }
}
```

### Firebase Çakışması Çözümü

```ruby
# ios/Podfile
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # Versiyon çakışmasını önle
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      
      # GoogleUtilities versiyonunu sabitle
      if target.name == 'GoogleUtilities'
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1'
      end
    end
  end
end
```

---

## 2. 📚 Tesseract OCR

### Avantajlar
- ✅ Açık kaynak
- ✅ Özelleştirilebilir
- ✅ Offline çalışır

### Dezavantajlar
- ⚠️ Kurulum karmaşık
- ⚠️ Daha yavaş (~3-5 saniye)
- ⚠️ Native bağımlılıklar (tessdata dosyaları)

### Kurulum

```yaml
# pubspec.yaml
dependencies:
  flutter_tesseract_ocr: ^0.2.0
```

```dart
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

class TesseractOcrService {
  static Future<List<String>> extractVin(Uint8List imageBytes) async {
    try {
      final text = await FlutterTesseractOcr.extractText(
        imageBytes,
        language: 'eng',
        args: {
          'preserve_interword_spaces': '1',
        },
      );
      
      return _extractVins(text);
    } catch (e) {
      print('❌ Tesseract OCR hatası: $e');
      return [];
    }
  }
}
```

---

## 3. ☁️ Cloud OCR Servisleri

### Google Cloud Vision API

```dart
// lib/core/services/cloud_ocr_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class CloudVisionOcrService {
  static const String _apiKey = 'YOUR_API_KEY';
  static const String _apiUrl = 'https://vision.googleapis.com/v1/images:annotate';
  
  static Future<List<String>> extractVin(Uint8List imageBytes) async {
    try {
      final base64Image = base64Encode(imageBytes);
      
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
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
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final textAnnotations = data['responses'][0]['textAnnotations'] ?? [];
        
        if (textAnnotations.isNotEmpty) {
          final fullText = textAnnotations[0]['description'] ?? '';
          return _extractVins(fullText);
        }
      }
      
      return [];
    } catch (e) {
      print('❌ Cloud Vision hatası: $e');
      return [];
    }
  }
}
```

**Maliyet:** İlk 1000 istek/ay ücretsiz, sonrası $1.50/1000 istek

---

### AWS Textract

```dart
import 'package:aws_textract/aws_textract.dart';

class AwsTextractOcrService {
  static Future<List<String>> extractVin(Uint8List imageBytes) async {
    // AWS SDK kullanarak Textract çağrısı
    // Detaylar: https://pub.dev/packages/aws_textract
  }
}
```

**Maliyet:** İlk 1000 sayfa/ay ücretsiz, sonrası $1.50/1000 sayfa

---

## 4. 🖼️ Flutter Image Paketi (Zaten Kullanılıyor)

Mevcut `image` paketi ile görüntü preprocessing yapılıyor, ancak OCR yok.

```dart
// lib/core/services/simple_image_processor.dart
import 'package:image/image.dart' as img;

// Gri tonlama, kontrast, gamma düzeltme vb.
// OCR için başka bir servis gerekli
```

---

## 5. 📱 Native Platform Channels

### iOS Vision Framework

```swift
// ios/Runner/VisionOcrChannel.swift
import Vision
import UIKit

class VisionOcrChannel {
  static func extractText(from imageData: Data) -> String {
    guard let image = UIImage(data: imageData) else { return "" }
    
    var recognizedText = ""
    let request = VNRecognizeTextRequest { request, error in
      guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
      
      for observation in observations {
        guard let topCandidate = observation.topCandidates(1).first else { continue }
        recognizedText += topCandidate.string + " "
      }
    }
    
    request.recognitionLevel = .accurate
    let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
    try? handler.perform([request])
    
    return recognizedText
  }
}
```

### Android ML Kit (Native)

```kotlin
// android/app/src/main/kotlin/.../MlKitOcrChannel.kt
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions

class MlKitOcrChannel {
  fun extractText(imageBytes: ByteArray): String {
    val image = InputImage.fromByteArray(imageBytes, ...)
    val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
    
    // Async işlem
    recognizer.process(image)
      .addOnSuccessListener { visionText ->
        return visionText.text
      }
  }
}
```

---

## 🎯 Öneri: Google ML Kit'i Tekrar Deneyelim

Firebase çakışmasını çözmek için:

1. **CocoaPods versiyonlarını güncelle**
2. **Podfile'da versiyon sabitleme yap**
3. **ML Kit'i tekrar entegre et**

Hangi seçeneği tercih edersiniz?

