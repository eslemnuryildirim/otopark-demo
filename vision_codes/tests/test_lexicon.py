"""
Lexicon modülü testleri
"""
import unittest
from ..lexicon import RenaultDaciaLexicon, CodeInfo


class TestRenaultDaciaLexicon(unittest.TestCase):
    """RenaultDaciaLexicon test sınıfı"""
    
    def setUp(self):
        self.lexicon = RenaultDaciaLexicon()
    
    def test_normalize_text(self):
        """Metin normalizasyonu testi"""
        # Test cases
        test_cases = [
            ("vf1abc123", "VF1ABC123"),
            ("uu1-xyz-456", "UU1XYZ456"),
            ("rja@test#", "RJA0TEST0"),
            ("", ""),
            ("   ", ""),
        ]
        
        for input_text, expected in test_cases:
            with self.subTest(input_text=input_text):
                result = self.lexicon.normalize_text(input_text)
                self.assertEqual(result, expected)
    
    def test_find_exact_match(self):
        """Tam eşleşme testi"""
        # WMI testleri
        wmi_result = self.lexicon.find_exact_match("VF1")
        self.assertIsNotNone(wmi_result)
        self.assertEqual(wmi_result.code, "VF1")
        self.assertEqual(wmi_result.manufacturer, "Renault (Fransa)")
        self.assertEqual(wmi_result.category, "WMI")
        
        # Model testleri
        model_result = self.lexicon.find_exact_match("RJA")
        self.assertIsNotNone(model_result)
        self.assertEqual(model_result.code, "RJA")
        self.assertEqual(model_result.model, "Clio")
        self.assertEqual(model_result.category, "Model")
        
        # Geçersiz kod
        invalid_result = self.lexicon.find_exact_match("INVALID")
        self.assertIsNone(invalid_result)
    
    def test_find_fuzzy_match(self):
        """Fuzzy eşleşme testi"""
        # Benzer kodlar
        fuzzy_results = self.lexicon.find_fuzzy_match("VF2", threshold=0.8)
        self.assertGreater(len(fuzzy_results), 0)
        self.assertEqual(fuzzy_results[0].code, "VF1")
        
        # Çok düşük eşik
        no_results = self.lexicon.find_fuzzy_match("COMPLETELY_DIFFERENT", threshold=0.9)
        self.assertEqual(len(no_results), 0)
    
    def test_extract_vin_candidates(self):
        """VIN aday çıkarma testi"""
        text = "VF1ABC123DEF456GHI UU1XYZ789JKL012MNO"
        candidates = self.lexicon.extract_vin_candidates(text)
        
        self.assertIn("VF1ABC123DEF456GHI", candidates)
        self.assertIn("UU1XYZ789JKL012MNO", candidates)
    
    def test_validate_vin(self):
        """VIN doğrulama testi"""
        # Geçerli VIN'ler
        valid_vins = ["VF1ABC123DEF456GHI", "UU1XYZ789JKL012MNO"]
        for vin in valid_vins:
            with self.subTest(vin=vin):
                self.assertTrue(self.lexicon.validate_vin(vin))
        
        # Geçersiz VIN'ler
        invalid_vins = ["", "ABC", "VF1ABC123DEF456GHI123", "VF1ABC123DEF456GHI!"]
        for vin in invalid_vins:
            with self.subTest(vin=vin):
                self.assertFalse(self.lexicon.validate_vin(vin))
    
    def test_get_code_info(self):
        """Kod bilgisi alma testi"""
        # WMI bilgisi
        wmi_info = self.lexicon.get_code_info("VF1")
        self.assertIsNotNone(wmi_info)
        self.assertEqual(wmi_info['type'], 'WMI')
        self.assertEqual(wmi_info['manufacturer'], 'Renault (Fransa)')
        
        # Model bilgisi
        model_info = self.lexicon.get_code_info("RJA")
        self.assertIsNotNone(model_info)
        self.assertEqual(model_info['type'], 'Model')
        self.assertEqual(model_info['model'], 'Clio')
        
        # Geçersiz kod
        invalid_info = self.lexicon.get_code_info("INVALID")
        self.assertIsNone(invalid_info)


if __name__ == '__main__':
    unittest.main()


