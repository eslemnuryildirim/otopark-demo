#!/usr/bin/env python3
"""
Python OCR Server for Flutter App
Profesyonel VIN/WMI tanıma servisi
"""

import cv2
import numpy as np
import pytesseract
import json
import base64
from flask import Flask, request, jsonify
from flask_cors import CORS
import Levenshtein

app = Flask(__name__)
CORS(app)

# Renault/Dacia kodları
WMI_CODES = {
    "VF1": "Renault (France)",
    "UU1": "Dacia (France)",
}

MODEL_CODES = {
    "RJA": "Clio",
    "RJK": "Express Van", 
    "RFK": "Kangoo Multix/Van",
    "RCP": "Megane E-Tech",
    "RFB": "Megane Sedan",
    "P01": "R5 E-Tech",
    "JLO": "Traffic Combi",
    "FLO": "Traffic Panelvan",
    "RHN": "Austral",
    "RJF": "Duster",
    "RDB": "Master Kamyonet",
    "RDA": "Master Panelvan",
    "DJF": "Sandero Stepway",
}

def preprocess_image(image_bytes):
    """Profesyonel görüntü işleme"""
    # Bytes'ı OpenCV image'e çevir
    nparr = np.frombuffer(image_bytes, np.uint8)
    image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    
    # Gri tonlama
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    
    # CLAHE (Contrast Limited Adaptive Histogram Equalization)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8))
    clahe_result = clahe.apply(gray)
    
    # Adaptive threshold
    thresh = cv2.adaptiveThreshold(
        clahe_result, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, 
        cv2.THRESH_BINARY, 11, 2
    )
    
    # Morphological operations
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (2, 2))
    morphed = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel)
    
    return morphed

def extract_vins_with_tesseract(image_bytes):
    """Tesseract ile VIN çıkarma"""
    try:
        # Görüntüyü işle
        processed = preprocess_image(image_bytes)
        
        # Tesseract OCR
        text = pytesseract.image_to_string(
            processed, 
            config='--psm 6 --oem 3 -c tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
        )
        
        # VIN'leri filtrele
        vins = []
        lines = text.split('\n')
        
        for line in lines:
            line = line.strip().upper()
            if len(line) >= 8:
                # Renault/Dacia VIN pattern'leri
                if (line.startswith('VF1') or line.startswith('UU1') or 
                    any(code in line for code in MODEL_CODES.keys())):
                    vins.append(line)
        
        return vins
        
    except Exception as e:
        print(f"Tesseract error: {e}")
        return []

def fuzzy_match(text, dictionary, threshold=0.8):
    """Fuzzy matching"""
    matches = []
    for code, description in dictionary.items():
        similarity = Levenshtein.ratio(text.upper(), code.upper())
        if similarity >= threshold:
            matches.append((code, description, similarity))
    return matches

@app.route('/ocr', methods=['POST'])
def ocr_endpoint():
    """OCR endpoint"""
    try:
        data = request.json
        image_base64 = data.get('image')
        
        if not image_base64:
            return jsonify({'error': 'No image provided'}), 400
        
        # Base64'ü decode et
        image_bytes = base64.b64decode(image_base64)
        
        # VIN'leri çıkar
        vins = extract_vins_with_tesseract(image_bytes)
        
        if not vins:
            return jsonify({
                'success': False,
                'vins': [],
                'message': 'No VINs found'
            })
        
        # En iyi VIN'i seç
        best_vin = vins[0] if vins else ""
        
        # WMI ve model analizi
        manufacturer = None
        models = []
        
        # WMI kontrolü
        for wmi, desc in WMI_CODES.items():
            if best_vin.startswith(wmi):
                manufacturer = desc
                break
        
        # Model kodu kontrolü
        for code, model in MODEL_CODES.items():
            if code in best_vin:
                models.append(model)
        
        # Fuzzy matching
        if not manufacturer:
            fuzzy_wmi = fuzzy_match(best_vin, WMI_CODES, 0.7)
            if fuzzy_wmi:
                manufacturer = fuzzy_wmi[0][1]
        
        if not models:
            fuzzy_models = fuzzy_match(best_vin, MODEL_CODES, 0.7)
            models = [match[1] for match in fuzzy_models]
        
        return jsonify({
            'success': True,
            'vins': vins,
            'best_vin': best_vin,
            'manufacturer': manufacturer,
            'models': models,
            'confidence': 0.9
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({'status': 'OK', 'service': 'Python OCR Server'})

if __name__ == '__main__':
    print("🐍 Python OCR Server başlatılıyor...")
    print("📱 Flutter uygulamasından bağlanabilirsiniz")
    print("🌐 Server: http://localhost:8080")
    app.run(host='0.0.0.0', port=8080, debug=True)
