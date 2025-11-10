"""
Komut satırı aracı
"""
import argparse
import cv2
import numpy as np
from pathlib import Path
import json
from typing import List

from .pipeline import VisionPipeline, DetectionResult


def main():
    """Ana fonksiyon"""
    parser = argparse.ArgumentParser(description='Renault/Dacia kod tespit aracı')
    parser.add_argument('input', help='Giriş görüntü dosyası')
    parser.add_argument('-o', '--output', help='Çıkış dosyası (opsiyonel)')
    parser.add_argument('--ocr', choices=['tesseract', 'paddle'], default='tesseract',
                       help='OCR motoru seçimi')
    parser.add_argument('--tesseract-path', help='Tesseract yolu (Windows için)')
    parser.add_argument('--confidence', type=float, default=0.7,
                       help='Minimum güven skoru (0.0-1.0)')
    parser.add_argument('--fuzzy-threshold', type=float, default=0.8,
                       help='Fuzzy eşleşme eşiği (0.0-1.0)')
    parser.add_argument('--visualize', action='store_true',
                       help='Sonuçları görselleştir')
    parser.add_argument('--json', action='store_true',
                       help='JSON formatında çıktı')
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='Detaylı çıktı')
    
    args = parser.parse_args()
    
    # Pipeline'ı oluştur
    pipeline = VisionPipeline(
        ocr_type=args.ocr,
        tesseract_path=args.tesseract_path
    )
    
    # Parametreleri ayarla
    pipeline.min_confidence = args.confidence
    pipeline.fuzzy_threshold = args.fuzzy_threshold
    
    # Görüntüyü yükle
    image = cv2.imread(args.input)
    if image is None:
        print(f"Hata: Görüntü yüklenemedi: {args.input}")
        return 1
    
    if args.verbose:
        print(f"Görüntü yüklendi: {image.shape}")
    
    # İşle
    results = pipeline.process_image(image)
    
    if args.verbose:
        print(f"Tespit edilen kod sayısı: {len(results)}")
    
    # Sonuçları göster
    if args.json:
        print(json.dumps([result_to_dict(r) for r in results], indent=2))
    else:
        print_results(results)
    
    # Görselleştir
    if args.visualize:
        vis_image = pipeline.visualize_results(image, results)
        
        if args.output:
            output_path = args.output
        else:
            input_path = Path(args.input)
            output_path = input_path.parent / f"{input_path.stem}_result{input_path.suffix}"
        
        cv2.imwrite(str(output_path), vis_image)
        print(f"Görselleştirilmiş sonuç kaydedildi: {output_path}")
    
    return 0


def print_results(results: List[DetectionResult]):
    """Sonuçları yazdır"""
    if not results:
        print("Hiç kod tespit edilmedi.")
        return
    
    print(f"\nTespit edilen {len(results)} kod:")
    print("-" * 50)
    
    for i, result in enumerate(results, 1):
        print(f"{i}. Kod: {result.code}")
        print(f"   Üretici: {result.manufacturer}")
        if result.model:
            print(f"   Model: {result.model}")
        print(f"   Kategori: {result.category}")
        print(f"   Güven: {result.confidence:.2f}")
        print(f"   Yöntem: {result.method}")
        print(f"   Konum: {result.bbox}")
        print()


def result_to_dict(result: DetectionResult) -> dict:
    """DetectionResult'u dict'e çevir"""
    return {
        'code': result.code,
        'manufacturer': result.manufacturer,
        'model': result.model,
        'category': result.category,
        'confidence': result.confidence,
        'bbox': result.bbox,
        'method': result.method
    }


if __name__ == '__main__':
    exit(main())


