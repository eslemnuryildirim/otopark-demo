"""
Renault/Dacia kod tespit modülü
"""

from .pipeline import VisionPipeline, DetectionResult
from .lexicon import RenaultDaciaLexicon, CodeInfo
from .preprocess import ImagePreprocessor
from .detector import ROIDetector, BoundingBox
from .ocr import OCRManager, OCRResult, TesseractOCR, PaddleOCR

__version__ = "1.0.0"
__author__ = "Renault/Dacia Vision Team"

__all__ = [
    'VisionPipeline',
    'DetectionResult', 
    'RenaultDaciaLexicon',
    'CodeInfo',
    'ImagePreprocessor',
    'ROIDetector',
    'BoundingBox',
    'OCRManager',
    'OCRResult',
    'TesseractOCR',
    'PaddleOCR'
]


