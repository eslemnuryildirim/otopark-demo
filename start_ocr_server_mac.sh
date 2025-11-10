#!/bin/bash

# Python OCR Sunucusunu Mac'te Başlat
# iOS cihazdan erişilebilmesi için 0.0.0.0'da dinler

echo "🐍 Python OCR Sunucusu başlatılıyor (Mac)..."
echo "📱 iOS cihazdan erişim için hazırlanıyor..."

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

# Mac'in IP adresini al
MAC_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "localhost")
echo "💻 Mac IP Adresi: $MAC_IP"
echo "📱 iOS cihazdan erişim için: http://$MAC_IP:8080"
echo ""

# Sunucuyu başlat (tüm ağ arayüzlerinde dinle)
echo "🚀 OCR Sunucusu başlatılıyor (http://0.0.0.0:8080)..."
echo "📝 Durdurmak için Ctrl+C basın"
echo ""

python3 simple_ocr_server.py

