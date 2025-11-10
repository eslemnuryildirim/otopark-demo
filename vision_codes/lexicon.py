"""
Renault/Dacia kod sözlüğü ve fuzzy eşleştirme modülü
"""
import difflib
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class CodeInfo:
    """Kod bilgisi sınıfı"""
    code: str
    manufacturer: str
    model: str
    category: str
    confidence: float = 1.0


class RenaultDaciaLexicon:
    """Renault/Dacia kod sözlüğü ve eşleştirme sınıfı"""
    
    def __init__(self):
        self.wmi_codes = {
            'VF1': 'Renault (Fransa)',
            'UU1': 'Dacia (Fransa)',
        }
        
        self.model_codes = {
            'RJA': 'Clio',
            'RJK': 'Express Van', 
            'RFK': 'Kangoo Multix/Van',
            'RCP': 'Megane E-Tech',
            'RFB': 'Megane Sedan',
            'P01': 'R5 E-Tech',
            'JLO': 'Traffic Combi',
            'FLO': 'Traffic Panelvan',
            'RHN': 'Austral',
            'RJF': 'Duster',
            'RDB': 'Master Kamyonet',
            'RDA': 'Master Panelvan',
            'DJF': 'Sandero Stepway',
        }
        
        # Tüm geçerli kodlar
        self.all_codes = {**self.wmi_codes, **self.model_codes}
        
        # Karışık karakter düzeltmeleri
        self.char_replacements = {
            'O': '0', 'I': '1', 'S': '5', 'B': '8', 
            'G': '6', 'Z': '2', 'Q': '0', 'D': '0'
        }
    
    def normalize_text(self, text: str) -> str:
        """Metni normalize et"""
        if not text:
            return ""
            
        # Büyük harfe çevir ve gereksiz karakterleri kaldır
        normalized = text.upper().strip()
        
        # Sadece harf ve rakam bırak
        normalized = ''.join(c for c in normalized if c.isalnum())
        
        # Karışık karakterleri düzelt
        for old_char, new_char in self.char_replacements.items():
            normalized = normalized.replace(old_char, new_char)
            
        return normalized
    
    def find_exact_match(self, text: str) -> Optional[CodeInfo]:
        """Tam eşleşme ara"""
        normalized = self.normalize_text(text)
        
        if normalized in self.wmi_codes:
            return CodeInfo(
                code=normalized,
                manufacturer=self.wmi_codes[normalized],
                model="",
                category="WMI",
                confidence=1.0
            )
        
        if normalized in self.model_codes:
            return CodeInfo(
                code=normalized,
                manufacturer="Renault/Dacia",
                model=self.model_codes[normalized],
                category="Model",
                confidence=1.0
            )
        
        return None
    
    def find_fuzzy_match(self, text: str, threshold: float = 0.8) -> List[CodeInfo]:
        """Fuzzy eşleşme ara"""
        normalized = self.normalize_text(text)
        if not normalized or len(normalized) < 3:
            return []
        
        matches = []
        
        for code, info in self.all_codes.items():
            # Levenshtein distance ile benzerlik hesapla
            similarity = difflib.SequenceMatcher(None, normalized, code).ratio()
            
            if similarity >= threshold:
                category = "WMI" if code in self.wmi_codes else "Model"
                manufacturer = self.wmi_codes.get(code, "Renault/Dacia")
                model = self.model_codes.get(code, "")
                
                matches.append(CodeInfo(
                    code=code,
                    manufacturer=manufacturer,
                    model=model,
                    category=category,
                    confidence=similarity
                ))
        
        # Güven skoruna göre sırala
        matches.sort(key=lambda x: x.confidence, reverse=True)
        return matches
    
    def find_best_match(self, text: str, threshold: float = 0.8) -> Optional[CodeInfo]:
        """En iyi eşleşmeyi bul"""
        # Önce tam eşleşme ara
        exact_match = self.find_exact_match(text)
        if exact_match:
            return exact_match
        
        # Fuzzy eşleşme ara
        fuzzy_matches = self.find_fuzzy_match(text, threshold)
        if fuzzy_matches:
            return fuzzy_matches[0]
        
        return None
    
    def extract_vin_candidates(self, text: str) -> List[str]:
        """VIN adaylarını çıkar"""
        import re
        
        # VIN pattern'leri
        patterns = [
            r'VF1[A-Z0-9]{10,16}',  # Renault VIN
            r'UU1[A-Z0-9]{10,16}',  # Dacia VIN
            r'[A-HJ-NPR-Z0-9]{8,17}',  # Genel VIN
        ]
        
        candidates = []
        for pattern in patterns:
            matches = re.findall(pattern, text.upper())
            candidates.extend(matches)
        
        return list(set(candidates))  # Duplikatları kaldır
    
    def validate_vin(self, vin: str) -> bool:
        """VIN doğruluğunu kontrol et"""
        if not vin or len(vin) < 8:
            return False
        
        # Geçerli VIN karakterleri
        valid_chars = set('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789')
        if not all(c in valid_chars for c in vin):
            return False
        
        # WMI kontrolü
        if len(vin) >= 3:
            wmi = vin[:3]
            if wmi in ['VF1', 'UU1']:
                return True
        
        return True
    
    def get_code_info(self, code: str) -> Optional[Dict]:
        """Kod bilgisini al"""
        normalized = self.normalize_text(code)
        
        if normalized in self.wmi_codes:
            return {
                'code': normalized,
                'type': 'WMI',
                'manufacturer': self.wmi_codes[normalized],
                'description': f"World Manufacturer Identifier: {self.wmi_codes[normalized]}"
            }
        
        if normalized in self.model_codes:
            return {
                'code': normalized,
                'type': 'Model',
                'manufacturer': 'Renault/Dacia',
                'model': self.model_codes[normalized],
                'description': f"Model Code: {self.model_codes[normalized]}"
            }
        
        return None


# Global lexicon instance
lexicon = RenaultDaciaLexicon()


