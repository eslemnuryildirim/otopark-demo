"""
Örnek kullanım dosyası
"""
import cv2
import numpy as np
from pipeline import VisionPipeline


def main():
    """Örnek kullanım"""
    # Pipeline'ı oluştur
    pipeline = VisionPipeline(ocr_type='tesseract')
    
    # Örnek görüntü oluştur (gerçek kullanımda cv2.imread() kullanın)
    image = create_sample_image()
    
    # Görüntüyü işle
    results = pipeline.process_image(image)
    
    # Sonuçları göster
    print(f"Tespit edilen {len(results)} kod:")
    for i, result in enumerate(results, 1):
        print(f"{i}. {result.code} - {result.manufacturer} - {result.model} (Güven: {result.confidence:.2f})")
    
    # Görselleştir
    vis_image = pipeline.visualize_results(image, results)
    cv2.imshow('Sonuçlar', vis_image)
    cv2.waitKey(0)
    cv2.destroyAllWindows()


def create_sample_image():
    """Örnek görüntü oluştur"""
    # Beyaz arka plan
    image = np.ones((400, 800, 3), dtype=np.uint8) * 255
    
    # Metin ekle
    font = cv2.FONT_HERSHEY_SIMPLEX
    cv2.putText(image, 'VF1ABC123DEF456GHI', (50, 100), font, 1, (0, 0, 0), 2)
    cv2.putText(image, 'RJA - Clio', (50, 150), font, 1, (0, 0, 0), 2)
    cv2.putText(image, 'UU1XYZ789JKL012MNO', (50, 200), font, 1, (0, 0, 0), 2)
    cv2.putText(image, 'RFK - Kangoo', (50, 250), font, 1, (0, 0, 0), 2)
    
    return image


if __name__ == '__main__':
    main()


