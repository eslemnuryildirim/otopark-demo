"""
OCR arayüzü modülü - Tesseract ve PaddleOCR desteği
"""
import cv2
import numpy as np
from typing import List, Dict, Optional, Tuple
import pytesseract
from dataclasses import dataclass


@dataclass
class OCRResult:
    """OCR sonuç sınıfı"""
    text: str
    confidence: float
    bbox: Tuple[int, int, int, int]  # x, y, w, h
    word_confidences: List[float] = None


class TesseractOCR:
    """Tesseract OCR sınıfı"""
    
    def __init__(self, tesseract_path: Optional[str] = None):
        if tesseract_path:
            pytesseract.pytesseract.tesseract_cmd = tesseract_path
    
    def extract_text(self, image: np.ndarray, config: str = '--psm 6') -> str:
        """Metin çıkar"""
        try:
            text = pytesseract.image_to_string(image, config=config)
            return text.strip()
        except Exception as e:
            print(f"Tesseract OCR hatası: {e}")
            return ""
    
    def extract_text_with_confidence(self, image: np.ndarray, config: str = '--psm 6') -> OCRResult:
        """Güven skoru ile metin çıkar"""
        try:
            # Metin ve güven skorları
            data = pytesseract.image_to_data(image, config=config, output_type=pytesseract.Output.DICT)
            
            # Geçerli kelimeleri filtrele
            words = []
            confidences = []
            bboxes = []
            
            for i in range(len(data['text'])):
                text = data['text'][i].strip()
                conf = int(data['conf'][i])
                
                if text and conf > 0:
                    words.append(text)
                    confidences.append(conf / 100.0)  # 0-1 aralığına çevir
                    
                    # Bounding box
                    x, y, w, h = data['left'][i], data['top'][i], data['width'][i], data['height'][i]
                    bboxes.append((x, y, w, h))
            
            # Tüm metni birleştir
            full_text = ' '.join(words)
            
            # Ortalama güven skoru
            avg_confidence = np.mean(confidences) if confidences else 0.0
            
            # Genel bounding box
            if bboxes:
                x_min = min(bbox[0] for bbox in bboxes)
                y_min = min(bbox[1] for bbox in bboxes)
                x_max = max(bbox[0] + bbox[2] for bbox in bboxes)
                y_max = max(bbox[1] + bbox[3] for bbox in bboxes)
                general_bbox = (x_min, y_min, x_max - x_min, y_max - y_min)
            else:
                general_bbox = (0, 0, 0, 0)
            
            return OCRResult(
                text=full_text,
                confidence=avg_confidence,
                bbox=general_bbox,
                word_confidences=confidences
            )
            
        except Exception as e:
            print(f"Tesseract OCR hatası: {e}")
            return OCRResult("", 0.0, (0, 0, 0, 0))
    
    def extract_text_regions(self, image: np.ndarray) -> List[OCRResult]:
        """Metin bölgelerini çıkar"""
        try:
            # Metin bölgelerini tespit et
            data = pytesseract.image_to_data(image, config='--psm 6', output_type=pytesseract.Output.DICT)
            
            results = []
            current_text = ""
            current_confidences = []
            current_bbox = None
            
            for i in range(len(data['text'])):
                text = data['text'][i].strip()
                conf = int(data['conf'][i])
                
                if text and conf > 0:
                    x, y, w, h = data['left'][i], data['top'][i], data['width'][i], data['height'][i]
                    
                    if current_bbox is None:
                        current_bbox = (x, y, w, h)
                        current_text = text
                        current_confidences = [conf / 100.0]
                    else:
                        # Aynı satırda mı kontrol et
                        if abs(y - current_bbox[1]) < 10:  # 10 piksel tolerans
                            current_text += " " + text
                            current_confidences.append(conf / 100.0)
                            # Bounding box'ı genişlet
                            current_bbox = (
                                min(current_bbox[0], x),
                                min(current_bbox[1], y),
                                max(current_bbox[0] + current_bbox[2], x + w) - min(current_bbox[0], x),
                                max(current_bbox[1] + current_bbox[3], y + h) - min(current_bbox[1], y)
                            )
                        else:
                            # Yeni satır, önceki sonucu kaydet
                            if current_text:
                                results.append(OCRResult(
                                    text=current_text,
                                    confidence=np.mean(current_confidences),
                                    bbox=current_bbox,
                                    word_confidences=current_confidences
                                ))
                            
                            # Yeni satır başlat
                            current_text = text
                            current_confidences = [conf / 100.0]
                            current_bbox = (x, y, w, h)
            
            # Son sonucu kaydet
            if current_text:
                results.append(OCRResult(
                    text=current_text,
                    confidence=np.mean(current_confidences),
                    bbox=current_bbox,
                    word_confidences=current_confidences
                ))
            
            return results
            
        except Exception as e:
            print(f"Tesseract OCR hatası: {e}")
            return []


class PaddleOCR:
    """PaddleOCR sınıfı (mock)"""
    
    def __init__(self):
        self.available = False
        try:
            from paddleocr import PaddleOCR
            self.ocr = PaddleOCR(use_angle_cls=True, lang='en')
            self.available = True
        except ImportError:
            print("PaddleOCR yüklü değil. Tesseract kullanılacak.")
    
    def extract_text(self, image: np.ndarray) -> str:
        """Metin çıkar"""
        if not self.available:
            return ""
        
        try:
            result = self.ocr.ocr(image, cls=True)
            if result and result[0]:
                texts = [line[1][0] for line in result[0]]
                return ' '.join(texts)
            return ""
        except Exception as e:
            print(f"PaddleOCR hatası: {e}")
            return ""
    
    def extract_text_with_confidence(self, image: np.ndarray) -> OCRResult:
        """Güven skoru ile metin çıkar"""
        if not self.available:
            return OCRResult("", 0.0, (0, 0, 0, 0))
        
        try:
            result = self.ocr.ocr(image, cls=True)
            if result and result[0]:
                texts = []
                confidences = []
                bboxes = []
                
                for line in result[0]:
                    bbox, (text, conf) = line
                    texts.append(text)
                    confidences.append(conf)
                    
                    # Bounding box'ı düzelt
                    x_coords = [point[0] for point in bbox]
                    y_coords = [point[1] for point in bbox]
                    x, y = min(x_coords), min(y_coords)
                    w = max(x_coords) - x
                    h = max(y_coords) - y
                    bboxes.append((int(x), int(y), int(w), int(h)))
                
                full_text = ' '.join(texts)
                avg_confidence = np.mean(confidences) if confidences else 0.0
                
                # Genel bounding box
                if bboxes:
                    x_min = min(bbox[0] for bbox in bboxes)
                    y_min = min(bbox[1] for bbox in bboxes)
                    x_max = max(bbox[0] + bbox[2] for bbox in bboxes)
                    y_max = max(bbox[1] + bbox[3] for bbox in bboxes)
                    general_bbox = (x_min, y_min, x_max - x_min, y_max - y_min)
                else:
                    general_bbox = (0, 0, 0, 0)
                
                return OCRResult(
                    text=full_text,
                    confidence=avg_confidence,
                    bbox=general_bbox,
                    word_confidences=confidences
                )
            
            return OCRResult("", 0.0, (0, 0, 0, 0))
            
        except Exception as e:
            print(f"PaddleOCR hatası: {e}")
            return OCRResult("", 0.0, (0, 0, 0, 0))


class OCRManager:
    """OCR yönetici sınıfı"""
    
    def __init__(self, ocr_type: str = 'tesseract', tesseract_path: Optional[str] = None):
        self.ocr_type = ocr_type.lower()
        
        if self.ocr_type == 'tesseract':
            self.ocr = TesseractOCR(tesseract_path)
        elif self.ocr_type == 'paddle':
            self.ocr = PaddleOCR()
        else:
            raise ValueError(f"Desteklenmeyen OCR türü: {ocr_type}")
    
    def extract_text(self, image: np.ndarray, config: str = '--psm 6') -> str:
        """Metin çıkar"""
        if self.ocr_type == 'tesseract':
            return self.ocr.extract_text(image, config)
        else:
            return self.ocr.extract_text(image)
    
    def extract_text_with_confidence(self, image: np.ndarray, config: str = '--psm 6') -> OCRResult:
        """Güven skoru ile metin çıkar"""
        if self.ocr_type == 'tesseract':
            return self.ocr.extract_text_with_confidence(image, config)
        else:
            return self.ocr.extract_text_with_confidence(image)
    
    def extract_text_regions(self, image: np.ndarray) -> List[OCRResult]:
        """Metin bölgelerini çıkar"""
        if self.ocr_type == 'tesseract':
            return self.ocr.extract_text_regions(image)
        else:
            # PaddleOCR için basit implementasyon
            result = self.ocr.extract_text_with_confidence(image)
            return [result] if result.text else []


