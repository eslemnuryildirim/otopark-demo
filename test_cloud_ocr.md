# 🧪 Cloud OCR Test Kılavuzu

Production'a geçmeden önce cloud OCR'ı test etmek için bu adımları takip edin.

## 🚀 Hızlı Test: Firebase Functions Emulator

### 1. Firebase CLI Kurulumu

```bash
npm install -g firebase-tools
firebase login
```

### 2. Functions Kurulumu

```bash
cd /Users/eslemnuryildirim/otopark-demo
firebase init functions
# Seçenekler:
# - JavaScript kullan
# - ESLint: Hayır
# - Dependencies install: Evet
```

### 3. Emulator'ü Başlat

```bash
cd functions
npm install
cd ..
firebase emulators:start --only functions
```

Emulator `http://localhost:5001` adresinde çalışacak.

### 4. Flutter'da Test URL'ini Güncelle

`lib/core/services/cloud_ocr_service.dart` dosyasında:

```dart
// Emulator URL'i
static const String _functionsUrl = 'http://localhost:5001/YOUR_PROJECT_ID/us-central1/ocrVin';
```

### 5. Test Et

Flutter uygulamasında şase fotoğrafı çekin ve cloud OCR'ın çalışıp çalışmadığını kontrol edin.

---

## 🧪 Alternatif: Basit Test Backend

Daha basit bir test için Python sunucusunu cloud-like bir şekilde çalıştırabilirsiniz:

```bash
# Python sunucusunu başlat (zaten var)
python3 simple_ocr_server.py
```

Bu zaten çalışıyor ve test için yeterli! 🎉

---

## ✅ Test Checklist

- [ ] Firebase Functions Emulator çalışıyor
- [ ] Flutter uygulaması emulator'e bağlanabiliyor
- [ ] OCR isteği gönderiliyor
- [ ] VIN sonuçları dönüyor
- [ ] Hata durumları handle ediliyor

---

## 🎯 Sonuç

Test başarılıysa, production'a geçiş yapabilirsiniz:
1. `firebase deploy --only functions`
2. Production URL'ini güncelleyin
3. Cloud OCR'ı aktif edin

