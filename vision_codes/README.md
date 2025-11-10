# Renault/Dacia Kod Tespit Modülü

Bu modül, görüntülerde Renault ve Dacia araç kodlarını tespit etmek için geliştirilmiş profesyonel bir görsel işleme sistemidir.

## Özellikler

- **WMI Tespiti**: VF1 (Renault), UU1 (Dacia)
- **Model Kodu Tespiti**: RJA (Clio), RJK (Express Van), RFK (Kangoo), vb.
- **Gelişmiş OCR**: Tesseract ve PaddleOCR desteği
- **Fuzzy Eşleştirme**: Benzer kodları tespit etme
- **ROI Tespiti**: Otomatik metin bölgesi bulma
- **Görselleştirme**: Sonuçları görüntü üzerinde gösterme

## Kurulum

```bash
pip install -r requirements.txt
```

## Kullanım

### Python API

```python
from vision_codes import VisionPipeline

# Pipeline oluştur
pipeline = VisionPipeline(ocr_type='tesseract')

# Görüntüyü işle
image = cv2.imread('image.jpg')
results = pipeline.process_image(image)

# Sonuçları göster
for result in results:
    print(f"Kod: {result.code}")
    print(f"Üretici: {result.manufacturer}")
    print(f"Model: {result.model}")
    print(f"Güven: {result.confidence}")
```

### Komut Satırı

```bash
# Temel kullanım
python -m vision_codes.cli image.jpg

# Görselleştirme ile
python -m vision_codes.cli image.jpg --visualize

# JSON çıktı
python -m vision_codes.cli image.jpg --json

# Özel parametreler
python -m vision_codes.cli image.jpg --confidence 0.8 --fuzzy-threshold 0.9
```

## Desteklenen Kodlar

### WMI Kodları
- `VF1`: Renault (Fransa)
- `UU1`: Dacia (Fransa)

### Model Kodları
- `RJA`: Clio
- `RJK`: Express Van
- `RFK`: Kangoo Multix/Van
- `RCP`: Megane E-Tech
- `RFB`: Megane Sedan
- `P01`: R5 E-Tech
- `JLO`: Traffic Combi
- `FLO`: Traffic Panelvan
- `RHN`: Austral
- `RJF`: Duster
- `RDB`: Master Kamyonet
- `RDA`: Master Panelvan
- `DJF`: Sandero Stepway

## Modül Yapısı

```
vision_codes/
├── __init__.py          # Modül başlatma
├── pipeline.py          # Ana pipeline
├── lexicon.py           # Kod sözlüğü
├── preprocess.py        # Görüntü ön işleme
├── detector.py          # ROI tespiti
├── ocr.py              # OCR arayüzü
├── cli.py              # Komut satırı aracı
├── example.py          # Örnek kullanım
└── tests/              # Test dosyaları
    ├── test_lexicon.py
    ├── test_preprocess.py
    └── test_pipeline.py
```

## Gereksinimler

- Python 3.8+
- OpenCV 4.8+
- NumPy 1.24+
- Tesseract OCR
- SciPy (opsiyonel)

## Lisans

MIT License


