# 🔍 OCR (Görüntü İşleme) Kullanım Kılavuzu

## 🚀 Hızlı Başlangıç

### Python OCR Sunucusu (Önerilen - Gerçek OCR)

Python OCR sunucusu OpenCV kullanarak gerçek OCR yapar ve VIN numaralarını okur.

#### 1. Gerekli Paketleri Yükle

```bash
pip3 install -r requirements_simple.txt
```

#### 2. Sunucuyu Başlat

**macOS/Linux:**
```bash
chmod +x start_ocr_server.sh
./start_ocr_server.sh
```

**veya manuel:**
```bash
python3 simple_ocr_server.py
```

Sunucu `http://localhost:8080` adresinde çalışacak.

#### 3. Flutter Uygulamasını Çalıştır

Sunucu çalışırken Flutter uygulaması otomatik olarak Python OCR'ı kullanacak.

---

## 📱 Uygulama İçinde Kullanım

1. **Araçlar Sekmesi** → "Araç Ekle" → Şase alanındaki kamera ikonuna tıkla
2. **Kroki Sayfası** → Boş slota tıkla → "Araç Kaydet" → Şase alanındaki kamera ikonuna tıkla
3. Fotoğraf çek veya galeriden seç
4. OCR otomatik olarak şase numarasını okuyacak

---

## 🔧 OCR Yöntemleri (Öncelik Sırası)

1. **Python OCR Sunucusu** (Gerçek OCR - OpenCV)
   - En doğru sonuçlar
   - Sunucu çalışmalı (`http://localhost:8080`)

2. **Yerel Görüntü İşleme** (Fallback)
   - Basit görüntü işleme
   - Mock VIN'ler döndürür (test için)

---

## ⚠️ Sorun Giderme

### Python Sunucusu Çalışmıyor

```bash
# Port kontrolü
lsof -i :8080

# Sunucuyu farklı port'ta başlat
PORT=8081 python3 simple_ocr_server.py
```

### OCR Sonuç Vermiyor

1. Fotoğraf kalitesini kontrol et (net, iyi aydınlatılmış)
2. Şase numarasının görünür olduğundan emin ol
3. Python sunucusu loglarını kontrol et

### Mock VIN'ler Görünüyor

Python sunucusu çalışmıyor demektir. `start_ocr_server.sh` scriptini çalıştırın.

---

## 📚 Teknik Detaylar

- **Python OCR**: OpenCV + Pattern Matching
- **Görüntü İşleme**: CLAHE, Denoising, Adaptive Threshold
- **VIN Doğrulama**: Format kontrolü, Check digit (opsiyonel)
- **Fallback**: Basit görüntü işleme + Mock VIN'ler

---

## 🎯 Sonraki Adımlar

Gerçek OCR için:
1. Python sunucusunu başlatın (`./start_ocr_server.sh`)
2. Flutter uygulamasını çalıştırın
3. Şase fotoğrafı çekin

Mock VIN'ler yerine gerçek OCR sonuçları göreceksiniz! 🎉

