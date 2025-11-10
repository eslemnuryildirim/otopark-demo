"""
Görüntü ön işleme modülü - deskew, dewarp, threshold, morfoloji
"""
import cv2
import numpy as np
from typing import Tuple, Optional
from scipy import ndimage


class ImagePreprocessor:
    """Görüntü ön işleme sınıfı"""
    
    def __init__(self):
        self.clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    
    def deskew_image(self, image: np.ndarray) -> np.ndarray:
        """Görüntüyü düzelt (eğikliği gider)"""
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        else:
            gray = image.copy()
        
        # Kenar tespiti
        edges = cv2.Canny(gray, 50, 150, apertureSize=3)
        
        # Hough transform ile çizgileri bul
        lines = cv2.HoughLines(edges, 1, np.pi/180, threshold=100)
        
        if lines is not None:
            # Açıları hesapla
            angles = []
            for line in lines:
                rho, theta = line[0]
                angle = theta - np.pi/2
                angles.append(angle)
            
            # Medyan açıyı al
            median_angle = np.median(angles)
            
            # Açı küçükse düzeltme yap
            if abs(median_angle) > 0.1:  # 0.1 radyan = ~5.7 derece
                # Rotasyon matrisi
                h, w = gray.shape
                center = (w // 2, h // 2)
                rotation_matrix = cv2.getRotationMatrix2D(center, -median_angle * 180 / np.pi, 1.0)
                
                # Döndür
                if len(image.shape) == 3:
                    return cv2.warpAffine(image, rotation_matrix, (w, h), flags=cv2.INTER_CUBIC)
                else:
                    return cv2.warpAffine(gray, rotation_matrix, (w, h), flags=cv2.INTER_CUBIC)
        
        return image
    
    def enhance_contrast(self, image: np.ndarray) -> np.ndarray:
        """Kontrastı artır (CLAHE)"""
        if len(image.shape) == 3:
            # BGR'yi LAB'ye çevir
            lab = cv2.cvtColor(image, cv2.COLOR_BGR2LAB)
            l, a, b = cv2.split(lab)
            
            # L kanalına CLAHE uygula
            l = self.clahe.apply(l)
            
            # LAB'yi tekrar BGR'ye çevir
            lab = cv2.merge([l, a, b])
            return cv2.cvtColor(lab, cv2.COLOR_LAB2BGR)
        else:
            # Gri tonlama için direkt CLAHE
            return self.clahe.apply(image)
    
    def adaptive_threshold(self, image: np.ndarray, method: str = 'sauvola') -> np.ndarray:
        """Adaptif eşikleme"""
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        else:
            gray = image.copy()
        
        if method == 'sauvola':
            # Sauvola eşikleme
            return self._sauvola_threshold(gray)
        elif method == 'mean':
            # Mean adaptif eşikleme
            return cv2.adaptiveThreshold(
                gray, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, 11, 2
            )
        else:  # gaussian
            # Gaussian adaptif eşikleme
            return cv2.adaptiveThreshold(
                gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 2
            )
    
    def _sauvola_threshold(self, image: np.ndarray, window_size: int = 15, k: float = 0.2) -> np.ndarray:
        """Sauvola adaptif eşikleme"""
        # Yerel ortalama ve standart sapma hesapla
        mean = cv2.GaussianBlur(image.astype(np.float32), (window_size, window_size), 0)
        sqr_mean = cv2.GaussianBlur((image.astype(np.float32) ** 2), (window_size, window_size), 0)
        variance = sqr_mean - (mean ** 2)
        std_dev = np.sqrt(np.maximum(variance, 0))
        
        # Sauvola formülü
        threshold = mean * (1 + k * (std_dev / 128 - 1))
        
        # Eşikleme uygula
        binary = np.where(image > threshold, 255, 0).astype(np.uint8)
        return binary
    
    def morphological_operations(self, image: np.ndarray, operation: str = 'close') -> np.ndarray:
        """Morfolojik işlemler"""
        if operation == 'close':
            # Kapanma işlemi (gürültüyü azaltır)
            kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (2, 2))
            return cv2.morphologyEx(image, cv2.MORPH_CLOSE, kernel)
        elif operation == 'open':
            # Açma işlemi (küçük nesneleri kaldırır)
            kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (2, 2))
            return cv2.morphologyEx(image, cv2.MORPH_OPEN, kernel)
        elif operation == 'dilate':
            # Genişletme
            kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (2, 2))
            return cv2.dilate(image, kernel, iterations=1)
        elif operation == 'erode':
            # Aşındırma
            kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (2, 2))
            return cv2.erode(image, kernel, iterations=1)
        else:
            return image
    
    def denoise_image(self, image: np.ndarray, method: str = 'bilateral') -> np.ndarray:
        """Gürültü azaltma"""
        if method == 'bilateral':
            # Bilateral filtre (kenarları korur)
            if len(image.shape) == 3:
                return cv2.bilateralFilter(image, 9, 75, 75)
            else:
                return cv2.bilateralFilter(image, 9, 75, 75)
        elif method == 'gaussian':
            # Gaussian filtre
            return cv2.GaussianBlur(image, (5, 5), 0)
        elif method == 'median':
            # Median filtre
            return cv2.medianBlur(image, 5)
        else:
            return image
    
    def sharpen_image(self, image: np.ndarray) -> np.ndarray:
        """Görüntüyü keskinleştir"""
        # Unsharp mask
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        else:
            gray = image.copy()
        
        # Gaussian blur
        blurred = cv2.GaussianBlur(gray, (0, 0), 2.0)
        
        # Unsharp mask
        sharpened = cv2.addWeighted(gray, 1.5, blurred, -0.5, 0)
        
        if len(image.shape) == 3:
            # Renkli görüntü için
            lab = cv2.cvtColor(image, cv2.COLOR_BGR2LAB)
            l, a, b = cv2.split(lab)
            l = sharpened
            lab = cv2.merge([l, a, b])
            return cv2.cvtColor(lab, cv2.COLOR_LAB2BGR)
        else:
            return sharpened
    
    def preprocess_for_ocr(self, image: np.ndarray) -> np.ndarray:
        """OCR için tam ön işleme pipeline'ı"""
        # 1. Eğikliği düzelt
        deskewed = self.deskew_image(image)
        
        # 2. Kontrastı artır
        enhanced = self.enhance_contrast(deskewed)
        
        # 3. Gürültüyü azalt
        denoised = self.denoise_image(enhanced, 'bilateral')
        
        # 4. Keskinleştir
        sharpened = self.sharpen_image(denoised)
        
        # 5. Adaptif eşikleme
        thresholded = self.adaptive_threshold(sharpened, 'sauvola')
        
        # 6. Morfolojik işlemler
        morphed = self.morphological_operations(thresholded, 'close')
        
        return morphed
    
    def detect_text_regions(self, image: np.ndarray) -> List[Tuple[int, int, int, int]]:
        """Metin bölgelerini tespit et"""
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        else:
            gray = image.copy()
        
        # Kenar tespiti
        edges = cv2.Canny(gray, 50, 150)
        
        # Konturları bul
        contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        # Metin bölgelerini filtrele
        text_regions = []
        for contour in contours:
            x, y, w, h = cv2.boundingRect(contour)
            
            # En-boy oranı kontrolü (metin için uygun)
            aspect_ratio = w / h if h > 0 else 0
            area = w * h
            
            # Metin bölgesi kriterleri
            if (0.1 < aspect_ratio < 10 and  # En-boy oranı
                area > 100 and  # Minimum alan
                h > 10 and w > 10):  # Minimum boyut
                text_regions.append((x, y, w, h))
        
        return text_regions


