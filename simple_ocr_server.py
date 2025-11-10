#!/usr/bin/env python3
"""
Basit VIN OCR Sunucusu
OpenCV + Flask (PaddleOCR olmadan)
"""

import cv2 as cv
import numpy as np
import re
import base64
import io
from flask import Flask, request, jsonify
from flask_cors import CORS
import logging

# Logging ayarları
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

def preprocess_image(image_bytes):
    """Görüntü ön işleme - CLAHE, unsharp, threshold"""
    try:
        # Bytes'tan OpenCV Mat'e
        nparr = np.frombuffer(image_bytes, np.uint8)
        img = cv.imdecode(nparr, cv.IMREAD_COLOR)
        
        if img is None:
            raise Exception("Görüntü decode edilemedi")
        
        # 1. Gri tonlama
        gray = cv.cvtColor(img, cv.COLOR_BGR2GRAY)
        
        # 2. Denoising
        denoised = cv.fastNlMeansDenoising(gray, None, h=7, templateWindowSize=7, searchWindowSize=21)
        
        # 3. CLAHE (Contrast Limited Adaptive Histogram Equalization)
        clahe = cv.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
        clahe_result = clahe.apply(denoised)
        
        # 4. Unsharp masking
        blur = cv.GaussianBlur(clahe_result, (0, 0), 1.2)
        sharp = cv.addWeighted(clahe_result, 1.5, blur, -0.5, 0)
        
        # 5. Adaptive threshold
        thresh = cv.adaptiveThreshold(
            sharp, 255, cv.ADAPTIVE_THRESH_GAUSSIAN_C, cv.THRESH_BINARY, 35, 15
        )
        
        # 6. Morphological operations (noise removal)
        kernel = cv.getStructuringElement(cv.MORPH_RECT, (2, 2))
        morphed = cv.morphologyEx(thresh, cv.MORPH_CLOSE, kernel)
        
        # 7. Bytes'a çevir
        _, processed_bytes = cv.imencode('.png', morphed)
        
        return processed_bytes.tobytes()
        
    except Exception as e:
        logger.error(f"Preprocessing hatası: {e}")
        return image_bytes  # Hata durumunda orijinal görüntüyü döndür

def clean_vin(vin):
    """VIN temizleme (I→1, O→0, Q→0)"""
    return vin.upper().translate(str.maketrans('IOQ', '100')).replace(' ', '')

def is_valid_vin_format(vin):
    """VIN format kontrolü"""
    vin_regex = re.compile(r'^[A-HJ-NPR-Z0-9]{11,17}$')
    return bool(vin_regex.match(vin))

def validate_vin_check_digit(vin):
    """VIN check digit doğrulama"""
    if len(vin) != 17:
        return False
    
    try:
        # VIN karakter değerleri
        char_values = {
            **{str(i): i for i in range(10)},
            **dict(zip("ABCDEFGHJKLMNPRSTUVWXYZ", 
                      [1,2,3,4,5,6,7,8,1,2,3,4,5,6,7,8,9,2,3,4,5,6,7,8,9]))
        }
        
        # Ağırlık çarpanları
        weights = [8,7,6,5,4,3,2,10,0,9,8,7,6,5,4,3,2]
        
        total = sum(char_values[ch] * weights[i] for i, ch in enumerate(vin))
        check_digit = total % 11
        expected_check_digit = 'X' if check_digit == 10 else str(check_digit)
        
        return vin[8] == expected_check_digit
        
    except Exception as e:
        logger.error(f"Check digit doğrulama hatası: {e}")
        return False

def extract_vin_from_image(image_bytes):
    """Mock VIN çıkarma (gerçek OCR yerine)"""
    try:
        logger.info("Mock VIN OCR başlatılıyor...")
        
        # 1. Preprocessing (görüntü kalitesini artır)
        processed_image = preprocess_image(image_bytes)
        logger.info("Preprocessing tamamlandı")
        
        # 2. Mock VIN'ler döndür (gerçek OCR yerine)
        mock_vins = [
            'WBA12345678901234',
            'VF1ABC12345678901', 
            '1HGBH41JXMN109186',
            'UU1XYZ98765432109',
            'WDB12345678901234'
        ]
        
        # Rastgele 1-2 VIN seç
        import random
        selected_vins = random.sample(mock_vins, random.randint(1, 2))
        
        # VIN doğrulama
        valid_vins = []
        for vin in selected_vins:
            cleaned = clean_vin(vin)
            if is_valid_vin_format(cleaned):
                valid_vins.append(cleaned)
        
        logger.info(f"Mock VIN'ler: {valid_vins}")
        return valid_vins
        
    except Exception as e:
        logger.error(f"Mock VIN çıkarma hatası: {e}")
        return []

@app.route('/ocr/vin', methods=['POST'])
def ocr_vin():
    """VIN OCR endpoint"""
    try:
        data = request.get_json()
        
        if 'image' not in data:
            return jsonify({'error': 'Görüntü bulunamadı'}), 400
        
        # Base64'ten bytes'a çevir
        image_data = base64.b64decode(data['image'])
        
        # VIN çıkar
        vins = extract_vin_from_image(image_data)
        
        return jsonify({
            'success': True,
            'vins': vins,
            'count': len(vins)
        })
        
    except Exception as e:
        logger.error(f"API hatası: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    """Sağlık kontrolü"""
    return jsonify({'status': 'healthy', 'service': 'Simple VIN OCR'})

if __name__ == '__main__':
    logger.info("Basit VIN OCR sunucusu başlatılıyor...")
    app.run(host='0.0.0.0', port=8080, debug=False)

