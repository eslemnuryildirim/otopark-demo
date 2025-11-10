#!/usr/bin/env python3
"""
Buhari Otomotiv App Icon Creator
Sarı-siyah tema ile uygulama ikonu oluşturur
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_buhari_icon():
    """Buhari Otomotiv temasında icon oluştur"""
    
    # 1024x1024 boyutunda icon
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 255))  # Siyah arka plan
    draw = ImageDraw.Draw(img)
    
    # Sarı daire (ana logo)
    margin = 50
    draw.ellipse([margin, margin, size-margin, size-margin], 
                 fill=(255, 215, 0, 255),  # Sarı
                 outline=(0, 0, 0, 255),   # Siyah kenar
                 width=20)
    
    # İç siyah daire
    inner_margin = 150
    draw.ellipse([inner_margin, inner_margin, size-inner_margin, size-inner_margin], 
                 fill=(0, 0, 0, 255))  # Siyah
    
    # "B" harfi (büyük)
    try:
        # Font boyutu hesapla
        font_size = 400
        font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", font_size)
    except:
        # Fallback font
        font = ImageFont.load_default()
    
    # "B" harfini çiz
    text = "B"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    x = (size - text_width) // 2
    y = (size - text_height) // 2 - 50  # Biraz yukarı
    
    draw.text((x, y), text, fill=(255, 215, 0, 255), font=font)  # Sarı "B"
    
    # "Buhari" yazısı (alt kısım)
    try:
        small_font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", 80)
    except:
        small_font = ImageFont.load_default()
    
    buhari_text = "Buhari"
    bbox = draw.textbbox((0, 0), buhari_text, font=small_font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    x = (size - text_width) // 2
    y = size - 150  # Alt kısım
    
    draw.text((x, y), buhari_text, fill=(255, 215, 0, 255), font=small_font)  # Sarı "Buhari"
    
    return img

def main():
    """Ana fonksiyon"""
    print("🎨 Buhari Otomotiv App Icon oluşturuluyor...")
    
    # Icon oluştur
    icon = create_buhari_icon()
    
    # PNG olarak kaydet
    output_path = "assets/icon/buhari_icon.png"
    icon.save(output_path, "PNG")
    
    print(f"✅ Icon oluşturuldu: {output_path}")
    print("📱 Sarı-siyah Buhari Otomotiv teması")
    print("🔄 Şimdi 'flutter pub get' ve 'flutter pub run flutter_launcher_icons:main' çalıştır")

if __name__ == "__main__":
    main()

