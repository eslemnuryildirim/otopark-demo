const functions = require('firebase-functions');
const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

/**
 * OCR VIN Endpoint
 * Python OCR sunucusunu çağırır
 */
exports.ocrVin = functions.https.onRequest(async (req, res) => {
  // CORS headers
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  try {
    const { image } = req.body;
    
    if (!image) {
      return res.status(400).json({ 
        success: false, 
        error: 'Image required' 
      });
    }

    console.log('🔍 OCR isteği alındı, görüntü boyutu:', image.length);

    // Python OCR script'ini çalıştır
    // Not: Production'da Python runtime kullanılmalı veya Docker container
    // Şimdilik basit bir mock response döndür (test için)
    
    // TODO: Python OCR'ı entegre et
    // const pythonScript = path.join(__dirname, '../simple_ocr_server.py');
    // Python'u spawn et ve sonuç al
    
    // Test için mock response
    const mockVins = [
      '1HGBH41JXMN109186',
      'WBAFR9C50CC123456',
    ];
    
    console.log('✅ OCR tamamlandı (test mode)');
    
    return res.json({
      success: true,
      vins: mockVins,
      count: mockVins.length,
      mode: 'test' // Production'da 'production' olacak
    });

  } catch (error) {
    console.error('❌ OCR hatası:', error);
    return res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

/**
 * Health check endpoint
 */
exports.health = functions.https.onRequest((req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.json({
    status: 'healthy',
    service: 'OCR Functions',
    timestamp: new Date().toISOString()
  });
});

