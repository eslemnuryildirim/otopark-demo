"""
Ana pipeline modülü - detect -> crop -> recognize
"""
import cv2
import numpy as np
from typing import List, Dict, Optional, Tuple
from dataclasses import dataclass

from .lexicon import RenaultDaciaLexicon, CodeInfo
from .preprocess import ImagePreprocessor
from .detector import ROIDetector, BoundingBox
from .ocr import OCRManager, OCRResult


@dataclass
class DetectionResult:
    """Tespit sonucu sınıfı"""
    code: str
    manufacturer: str
    model: str
    category: str
    confidence: float
    bbox: Tuple[int, int, int, int]
    method: str  # 'exact', 'fuzzy', 'ocr'


class VisionPipeline:
    """Ana görsel işleme pipeline'ı"""
    
    def __init__(self, ocr_type: str = 'tesseract', tesseract_path: Optional[str] = None):
        self.lexicon = RenaultDaciaLexicon()
        self.preprocessor = ImagePreprocessor()
        self.detector = ROIDetector()
        self.ocr = OCRManager(ocr_type, tesseract_path)
        
        # Pipeline parametreleri
        self.min_confidence = 0.7
        self.fuzzy_threshold = 0.8
    
    def process_image(self, image: np.ndarray) -> List[DetectionResult]:
        """Görüntüyü işle ve kodları tespit et"""
        results = []
        
        # 1. ROI'leri tespit et
        rois = self.detector.detect_by_contours(image)
        
        if not rois:
            # ROI bulunamazsa tüm görüntüyü kullan
            rois = [BoundingBox(0, 0, image.shape[1], image.shape[0])]
        
        # 2. Her ROI için işlem yap
        for roi in rois:
            # ROI'yi kırp
            cropped = self.detector.crop_roi(image, roi)
            
            if cropped.size == 0:
                continue
            
            # ROI'yi işle
            roi_results = self._process_roi(cropped, roi)
            results.extend(roi_results)
        
        # 3. Sonuçları filtrele ve sırala
        results = self._filter_and_rank_results(results)
        
        return results
    
    def _process_roi(self, roi_image: np.ndarray, bbox: BoundingBox) -> List[DetectionResult]:
        """ROI'yi işle"""
        results = []
        
        # 1. Ön işleme
        preprocessed = self.preprocessor.preprocess_for_ocr(roi_image)
        
        # 2. OCR ile metin çıkar
        ocr_result = self.ocr.extract_text_with_confidence(preprocessed, '--psm 6')
        
        if not ocr_result.text:
            return results
        
        # 3. Metni analiz et
        text_results = self._analyze_text(ocr_result.text)
        
        # 4. Sonuçları dönüştür
        for text_result in text_results:
            # Bounding box'ı orijinal görüntüye göre ayarla
            adjusted_bbox = (
                bbox.x + ocr_result.bbox[0],
                bbox.y + ocr_result.bbox[1],
                ocr_result.bbox[2],
                ocr_result.bbox[3]
            )
            
            results.append(DetectionResult(
                code=text_result.code,
                manufacturer=text_result.manufacturer,
                model=text_result.model,
                category=text_result.category,
                confidence=text_result.confidence * ocr_result.confidence,
                bbox=adjusted_bbox,
                method='ocr'
            ))
        
        return results
    
    def _analyze_text(self, text: str) -> List[CodeInfo]:
        """Metni analiz et ve kodları bul"""
        results = []
        
        # 1. Tam eşleşme ara
        exact_match = self.lexicon.find_exact_match(text)
        if exact_match:
            results.append(exact_match)
            return results
        
        # 2. VIN adaylarını çıkar
        vin_candidates = self.lexicon.extract_vin_candidates(text)
        
        for vin in vin_candidates:
            if self.lexicon.validate_vin(vin):
                # VIN'i analiz et
                vin_info = self._analyze_vin(vin)
                if vin_info:
                    results.append(vin_info)
        
        # 3. Fuzzy eşleşme ara
        fuzzy_matches = self.lexicon.find_fuzzy_match(text, self.fuzzy_threshold)
        results.extend(fuzzy_matches)
        
        return results
    
    def _analyze_vin(self, vin: str) -> Optional[CodeInfo]:
        """VIN'i analiz et"""
        if len(vin) < 3:
            return None
        
        # WMI kontrolü
        wmi = vin[:3]
        if wmi in self.lexicon.wmi_codes:
            return CodeInfo(
                code=vin,
                manufacturer=self.lexicon.wmi_codes[wmi],
                model="",
                category="VIN",
                confidence=0.9
            )
        
        # Model kodu kontrolü
        for model_code, model_name in self.lexicon.model_codes.items():
            if model_code in vin:
                return CodeInfo(
                    code=vin,
                    manufacturer="Renault/Dacia",
                    model=model_name,
                    category="VIN",
                    confidence=0.8
                )
        
        return None
    
    def _filter_and_rank_results(self, results: List[DetectionResult]) -> List[DetectionResult]:
        """Sonuçları filtrele ve sırala"""
        # Güven skoruna göre filtrele
        filtered = [r for r in results if r.confidence >= self.min_confidence]
        
        # Duplikatları kaldır (aynı kod)
        unique_results = {}
        for result in filtered:
            key = result.code
            if key not in unique_results or result.confidence > unique_results[key].confidence:
                unique_results[key] = result
        
        # Güven skoruna göre sırala
        final_results = list(unique_results.values())
        final_results.sort(key=lambda x: x.confidence, reverse=True)
        
        return final_results
    
    def process_image_with_roi_detection(self, image: np.ndarray) -> List[DetectionResult]:
        """ROI tespiti ile görüntü işleme"""
        results = []
        
        # 1. Metin bölgelerini tespit et
        text_regions = self.preprocessor.detect_text_regions(image)
        
        if not text_regions:
            # Metin bölgesi bulunamazsa tüm görüntüyü kullan
            return self.process_image(image)
        
        # 2. Her metin bölgesi için işlem yap
        for x, y, w, h in text_regions:
            # Bölgeyi kırp
            region = image[y:y+h, x:x+w]
            
            if region.size == 0:
                continue
            
            # Bölgeyi işle
            region_results = self._process_roi(region, BoundingBox(x, y, w, h))
            results.extend(region_results)
        
        # 3. Sonuçları filtrele ve sırala
        results = self._filter_and_rank_results(results)
        
        return results
    
    def get_best_result(self, image: np.ndarray) -> Optional[DetectionResult]:
        """En iyi sonucu al"""
        results = self.process_image(image)
        return results[0] if results else None
    
    def get_all_results(self, image: np.ndarray) -> List[DetectionResult]:
        """Tüm sonuçları al"""
        return self.process_image(image)
    
    def visualize_results(self, image: np.ndarray, results: List[DetectionResult]) -> np.ndarray:
        """Sonuçları görselleştir"""
        vis_image = image.copy()
        
        for i, result in enumerate(results):
            x, y, w, h = result.bbox
            
            # Renk seç (güven skoruna göre)
            if result.confidence >= 0.9:
                color = (0, 255, 0)  # Yeşil - yüksek güven
            elif result.confidence >= 0.7:
                color = (0, 255, 255)  # Sarı - orta güven
            else:
                color = (0, 0, 255)  # Kırmızı - düşük güven
            
            # Dikdörtgen çiz
            cv2.rectangle(vis_image, (x, y), (x + w, y + h), color, 2)
            
            # Etiket ekle
            label = f"{result.code} ({result.confidence:.2f})"
            cv2.putText(vis_image, label, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.7, color, 2)
        
        return vis_image


