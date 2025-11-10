# 🚀 Production OCR Kurulum Kılavuzu

## 📋 Durum

Şu anda OCR için **Python sunucusu** kullanılıyor. Bu sadece **development** için çalışır. Production'da cloud-based bir çözüm gerekiyor.

## 🎯 Production Çözüm Seçenekleri

### 1. Firebase Functions (Önerilen) ⭐

**Avantajlar:**
- Zaten Firebase kullanıyorsunuz
- Python OCR kodunuzu direkt kullanabilirsiniz
- Otomatik scaling
- Ücretsiz tier mevcut

**Kurulum:**

1. **Firebase Functions oluştur:**
```bash
firebase init functions
cd functions
npm install
```

2. **functions/index.js** dosyasına OCR endpoint ekle:
```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Python OCR'ı çalıştırmak için Cloud Functions için Python runtime kullan
// veya Node.js'te Python'u spawn et
exports.ocrVin = functions.https.onRequest(async (req, res) => {
  // Python OCR kodunu buraya entegre et
  // veya Python'u child_process ile çalıştır
});
```

3. **Flutter'da kullan:**
```dart
// lib/core/services/simple_ocr_service.dart içinde
final cloudVins = await CloudOcrService.extractVinWithFirebaseFunctions(imageBytes);
```

---

### 2. Google Cloud Vision API

**Avantajlar:**
- Çok doğru OCR
- Kolay entegrasyon
- Ücretsiz tier: 1000 istek/ay

**Kurulum:**

1. **Google Cloud Console'da proje oluştur**
2. **Vision API'yi aktif et**
3. **API Key oluştur**
4. **Flutter'da kullan:**
```dart
// lib/core/services/cloud_ocr_service.dart içinde
final vins = await CloudOcrService.extractVinWithGoogleVision(imageBytes);
```

**Maliyet:** İlk 1000 istek/ay ücretsiz, sonrası $1.50/1000 istek

---

### 3. AWS Textract

**Avantajlar:**
- Güçlü OCR
- AWS ekosistemi

**Kurulum:**

1. **AWS hesabı oluştur**
2. **Textract servisini aktif et**
3. **IAM credentials oluştur**
4. **Flutter'da kullan:**
```dart
final vins = await CloudOcrService.extractVinWithAwsTextract(imageBytes);
```

**Maliyet:** İlk 1000 sayfa/ay ücretsiz, sonrası $1.50/1000 sayfa

---

### 4. Custom Backend API

**Avantajlar:**
- Tam kontrol
- Python OCR kodunuzu kullanabilirsiniz

**Kurulum:**

1. **Backend oluştur** (Flask/FastAPI/Django)
2. **Python OCR kodunu deploy et** (Heroku, Railway, Render, etc.)
3. **Flutter'da kullan:**
```dart
// HttpOcrService'i production URL'e yönlendir
static const String _baseUrl = 'https://your-backend.com/api';
```

---

## 🔧 Hızlı Başlangıç: Firebase Functions

### Adım 1: Firebase Functions Kurulumu

```bash
cd /Users/eslemnuryildirim/otopark-demo
firebase init functions
```

### Adım 2: Python OCR'ı Functions'a Entegre Et

`functions/package.json`:
```json
{
  "dependencies": {
    "firebase-functions": "^4.0.0",
    "firebase-admin": "^11.0.0"
  }
}
```

`functions/index.js`:
```javascript
const functions = require('firebase-functions');
const { spawn } = require('child_process');

exports.ocrVin = functions.https.onRequest(async (req, res) => {
  // CORS
  res.set('Access-Control-Allow-Origin', '*');
  
  if (req.method === 'OPTIONS') {
    res.set('Access-Control-Allow-Methods', 'POST');
    res.set('Access-Control-Allow-Headers', 'Content-Type');
    res.status(204).send('');
    return;
  }
  
  const { image } = req.body;
  if (!image) {
    return res.status(400).json({ error: 'Image required' });
  }
  
  // Python OCR'ı çalıştır
  // Not: Python runtime için Cloud Functions Python runtime kullanılmalı
  // veya Python'u Docker container'da çalıştır
  
  // Şimdilik basit bir örnek:
  return res.json({ vins: [], message: 'OCR endpoint - implement edilmeli' });
});
```

### Adım 3: Deploy

```bash
firebase deploy --only functions
```

### Adım 4: Flutter'da Kullan

`lib/core/services/cloud_ocr_service.dart` dosyasında Firebase Functions URL'ini güncelle.

---

## 📱 Development vs Production

### Development (Şu anki)
- ✅ Python sunucusu localhost'ta çalışır
- ✅ `OcrServerManager` otomatik başlatır (Mac'te)
- ✅ Hızlı test için ideal

### Production
- ✅ Cloud OCR servisi kullanılır
- ✅ Firebase Functions veya Google Cloud Vision
- ✅ Her cihazdan erişilebilir
- ✅ Scaling otomatik

---

## 🎯 Önerilen Yaklaşım

1. **Development:** Python sunucusu (mevcut)
2. **Production:** Firebase Functions + Python OCR
   - Python OCR kodunuzu direkt kullanabilirsiniz
   - Zaten Firebase kullanıyorsunuz
   - Ekstra servis gerektirmez

---

## 📚 Kaynaklar

- [Firebase Functions Documentation](https://firebase.google.com/docs/functions)
- [Google Cloud Vision API](https://cloud.google.com/vision/docs)
- [AWS Textract](https://aws.amazon.com/textract/)

