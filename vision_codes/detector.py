"""
ROI (Region of Interest) tespit modülü
"""
import cv2
import numpy as np
from typing import List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class BoundingBox:
    """Sınırlayıcı kutu sınıfı"""
    x: int
    y: int
    width: int
    height: int
    confidence: float = 1.0
    label: str = ""


class ROIDetector:
    """ROI tespit sınıfı"""
    
    def __init__(self):
        self.min_area = 100
        self.max_area = 50000
        self.min_aspect_ratio = 0.1
        self.max_aspect_ratio = 10.0
    
    def detect_by_contours(self, image: np.ndarray) -> List[BoundingBox]:
        """Kontur tabanlı ROI tespiti"""
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        else:
            gray = image.copy()
        
        # Görüntüyü ön işle
        preprocessed = self._preprocess_for_detection(gray)
        
        # Konturları bul
        contours, _ = cv2.findContours(preprocessed, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        # ROI'leri filtrele
        rois = []
        for contour in contours:
            bbox = self._contour_to_bbox(contour)
            if self._is_valid_roi(bbox, image.shape):
                rois.append(bbox)
        
        # ROI'leri alan büyüklüğüne göre sırala
        rois.sort(key=lambda x: x.width * x.height, reverse=True)
        
        return rois
    
    def detect_by_hough_lines(self, image: np.ndarray) -> List[BoundingBox]:
        """Hough çizgileri tabanlı ROI tespiti"""
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        else:
            gray = image.copy()
        
        # Kenar tespiti
        edges = cv2.Canny(gray, 50, 150)
        
        # Hough çizgileri
        lines = cv2.HoughLinesP(edges, 1, np.pi/180, threshold=50, minLineLength=30, maxLineGap=10)
        
        if lines is None:
            return []
        
        # Çizgileri grupla ve ROI'leri oluştur
        rois = self._lines_to_rois(lines, image.shape)
        
        return rois
    
    def detect_by_template_matching(self, image: np.ndarray, template: np.ndarray) -> List[BoundingBox]:
        """Şablon eşleştirme tabanlı ROI tespiti"""
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        else:
            gray = image.copy()
        
        if len(template.shape) == 3:
            template_gray = cv2.cvtColor(template, cv2.COLOR_BGR2GRAY)
        else:
            template_gray = template.copy()
        
        # Şablon eşleştirme
        result = cv2.matchTemplate(gray, template_gray, cv2.TM_CCOEFF_NORMED)
        
        # Eşleşmeleri bul
        locations = np.where(result >= 0.7)  # 0.7 eşik değeri
        locations = list(zip(*locations[::-1]))
        
        rois = []
        for pt in locations:
            x, y = pt
            h, w = template_gray.shape
            rois.append(BoundingBox(x, y, w, h, result[y, x], "template_match"))
        
        return rois
    
    def detect_text_regions(self, image: np.ndarray) -> List[BoundingBox]:
        """Metin bölgelerini tespit et"""
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        else:
            gray = image.copy()
        
        # MSER (Maximally Stable Extremal Regions) kullan
        mser = cv2.MSER_create()
        regions, _ = mser.detectRegions(gray)
        
        rois = []
        for region in regions:
            # Bölgeyi sınırlayıcı kutuya çevir
            x, y, w, h = cv2.boundingRect(region)
            bbox = BoundingBox(x, y, w, h, 0.8, "text_region")
            
            if self._is_valid_roi(bbox, image.shape):
                rois.append(bbox)
        
        return rois
    
    def detect_largest_roi(self, image: np.ndarray) -> Optional[BoundingBox]:
        """En büyük ROI'yi tespit et"""
        rois = self.detect_by_contours(image)
        
        if not rois:
            return None
        
        # En büyük ROI'yi döndür
        return max(rois, key=lambda x: x.width * x.height)
    
    def crop_roi(self, image: np.ndarray, bbox: BoundingBox) -> np.ndarray:
        """ROI'yi kırp"""
        x, y, w, h = bbox.x, bbox.y, bbox.width, bbox.height
        
        # Sınırları kontrol et
        h_img, w_img = image.shape[:2]
        x = max(0, min(x, w_img - 1))
        y = max(0, min(y, h_img - 1))
        w = min(w, w_img - x)
        h = min(h, h_img - y)
        
        return image[y:y+h, x:x+w]
    
    def _preprocess_for_detection(self, image: np.ndarray) -> np.ndarray:
        """Tespit için ön işleme"""
        # Gaussian blur
        blurred = cv2.GaussianBlur(image, (5, 5), 0)
        
        # Adaptif eşikleme
        thresh = cv2.adaptiveThreshold(
            blurred, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 2
        )
        
        # Morfolojik işlemler
        kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (2, 2))
        morphed = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel)
        
        return morphed
    
    def _contour_to_bbox(self, contour: np.ndarray) -> BoundingBox:
        """Konturu sınırlayıcı kutuya çevir"""
        x, y, w, h = cv2.boundingRect(contour)
        return BoundingBox(x, y, w, h)
    
    def _is_valid_roi(self, bbox: BoundingBox, image_shape: Tuple[int, ...]) -> bool:
        """ROI'nin geçerli olup olmadığını kontrol et"""
        area = bbox.width * bbox.height
        aspect_ratio = bbox.width / bbox.height if bbox.height > 0 else 0
        
        return (self.min_area <= area <= self.max_area and
                self.min_aspect_ratio <= aspect_ratio <= self.max_aspect_ratio and
                bbox.x >= 0 and bbox.y >= 0 and
                bbox.x + bbox.width <= image_shape[1] and
                bbox.y + bbox.height <= image_shape[0])
    
    def _lines_to_rois(self, lines: np.ndarray, image_shape: Tuple[int, ...]) -> List[BoundingBox]:
        """Çizgileri ROI'lere çevir"""
        if len(lines) == 0:
            return []
        
        # Çizgileri grupla
        grouped_lines = self._group_lines(lines)
        
        rois = []
        for group in grouped_lines:
            if len(group) >= 2:  # En az 2 çizgi gerekli
                bbox = self._group_to_bbox(group)
                if self._is_valid_roi(bbox, image_shape):
                    rois.append(bbox)
        
        return rois
    
    def _group_lines(self, lines: np.ndarray) -> List[List[np.ndarray]]:
        """Çizgileri grupla"""
        groups = []
        used = set()
        
        for i, line1 in enumerate(lines):
            if i in used:
                continue
            
            group = [line1]
            used.add(i)
            
            for j, line2 in enumerate(lines[i+1:], i+1):
                if j in used:
                    continue
                
                if self._lines_are_similar(line1[0], line2[0]):
                    group.append(line2)
                    used.add(j)
            
            groups.append(group)
        
        return groups
    
    def _lines_are_similar(self, line1: np.ndarray, line2: np.ndarray) -> bool:
        """İki çizginin benzer olup olmadığını kontrol et"""
        x1, y1, x2, y2 = line1
        x3, y3, x4, y4 = line2
        
        # Mesafe kontrolü
        dist1 = np.sqrt((x1 - x3)**2 + (y1 - y3)**2)
        dist2 = np.sqrt((x2 - x4)**2 + (y2 - y4)**2)
        
        return dist1 < 20 and dist2 < 20  # 20 piksel eşik değeri
    
    def _group_to_bbox(self, lines: List[np.ndarray]) -> BoundingBox:
        """Çizgi grubunu sınırlayıcı kutuya çevir"""
        all_points = []
        for line in lines:
            x1, y1, x2, y2 = line[0]
            all_points.extend([(x1, y1), (x2, y2)])
        
        all_points = np.array(all_points)
        x, y, w, h = cv2.boundingRect(all_points.astype(np.int32))
        
        return BoundingBox(x, y, w, h)


