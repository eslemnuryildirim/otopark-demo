#!/bin/bash

# Python OCR Sunucusunu Başlat
# Bu script Python OCR sunucusunu başlatır

echo "🐍 Python OCR Sunucusu başlatılıyor..."

# Python'un yüklü olup olmadığını kontrol et
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 bulunamadı. Lütfen Python3 yükleyin."
    exit 1
fi

# Gerekli paketlerin yüklü olup olmadığını kontrol et
echo "📦 Gerekli paketler kontrol ediliyor..."
python3 -c "import cv2, flask, flask_cors" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "⚠️  Gerekli paketler yüklü değil. Yükleniyor..."
    pip3 install -r requirements_simple.txt
fi

# Sunucuyu başlat
echo "🚀 OCR Sunucusu başlatılıyor (http://localhost:8080)..."
echo "📝 Durdurmak için Ctrl+C basın"
echo ""

python3 simple_ocr_server.py

