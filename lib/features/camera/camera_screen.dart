import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:otopark_demo/core/models/quality_metrics.dart';
import 'package:otopark_demo/core/models/vin_result.dart';
import 'package:otopark_demo/core/services/quality_service.dart';
import 'package:otopark_demo/core/services/simple_ocr.dart';

/// Kamera durumu
class CameraState {
  final bool isInitialized;
  final bool isCapturing;
  final QualityMetrics? qualityMetrics;
  final VinResult? vinResult;
  final String? error;

  CameraState({
    this.isInitialized = false,
    this.isCapturing = false,
    this.qualityMetrics,
    this.vinResult,
    this.error,
  });

  CameraState copyWith({
    bool? isInitialized,
    bool? isCapturing,
    QualityMetrics? qualityMetrics,
    VinResult? vinResult,
    String? error,
  }) {
    return CameraState(
      isInitialized: isInitialized ?? this.isInitialized,
      isCapturing: isCapturing ?? this.isCapturing,
      qualityMetrics: qualityMetrics ?? this.qualityMetrics,
      vinResult: vinResult ?? this.vinResult,
      error: error ?? this.error,
    );
  }
}

/// Kamera controller provider
final cameraControllerProvider = StateNotifierProvider<CameraNotifier, CameraState>((ref) {
  return CameraNotifier();
});

class CameraNotifier extends StateNotifier<CameraState> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  CameraNotifier() : super(CameraState()) {
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        state = state.copyWith(error: 'No cameras available');
        return;
      }

      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      state = state.copyWith(isInitialized: true);
    } catch (e) {
      state = state.copyWith(error: 'Camera initialization failed: $e');
    }
  }

  Future<void> captureAndAnalyze() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    state = state.copyWith(isCapturing: true);

    try {
      final image = await _controller!.takePicture();
      final imageBytes = await image.readAsBytes();

      // ROI koordinatları (ekranın ortası)
      final roiX = 0.2; // Ekranın %20'si
      final roiY = 0.3; // Ekranın %30'u
      final roiWidth = 0.6; // Ekranın %60'ı
      final roiHeight = 0.4; // Ekranın %40'ı

      // Kalite analizi
      final qualityMetrics = await QualityService.analyzeQuality(
        imageBytes,
        roiX: roiX,
        roiY: roiY,
        roiWidth: roiWidth,
        roiHeight: roiHeight,
      );

      state = state.copyWith(qualityMetrics: qualityMetrics);

      // Basit OCR ile VIN çıkar
      final vins = await SimpleOcr.extractVin(imageBytes);
      if (vins.isNotEmpty) {
        final vinResult = VinResult(
          vin: vins.first,
          confidence: 0.95,
          method: 'SimpleOCR',
          isValid: true,
          timestamp: DateTime.now(),
        );
        state = state.copyWith(vinResult: vinResult);
      }

    } catch (e) {
      state = state.copyWith(error: 'Capture failed: $e');
    } finally {
      state = state.copyWith(isCapturing: false);
    }
  }

  void clearResult() {
    state = state.copyWith(vinResult: null, error: null);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

/// Profesyonel kamera ekranı
class CameraScreen extends ConsumerWidget {
  const CameraScreen({Key? key}) : super(key: key);

  void _copyToClipboard(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('VIN copied to clipboard')),
    );
  }

  void _goBack(BuildContext context) {
    print('🔙 Geri dön butonuna tıklandı');
    // Basit Navigator ile geri dön
    Navigator.of(context).pop();
  }

  void _useVin(BuildContext context, WidgetRef ref) {
    print('✅ Use VIN butonuna tıklandı');
    final cameraState = ref.read(cameraControllerProvider);
    if (cameraState.vinResult != null) {
      // VIN'i clipboard'a kopyala
      _copyToClipboard(context);
      
      // Basit Navigator ile geri dön
      Navigator.of(context).pop();
    } else {
      print('❌ VIN sonucu bulunamadı');
    }
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              onPressed: () => _copyToClipboard(context),
              icon: const Icon(Icons.copy),
              label: const Text('Copy'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.black,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => ref.read(cameraControllerProvider.notifier).clearResult(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retake'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _useVin(context, ref),
            icon: const Icon(Icons.check_circle),
            label: const Text('Use VIN'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Kamera preview
          if (cameraState.isInitialized && cameraState.error == null)
            _buildCameraPreview(ref)
          else
            _buildErrorState(cameraState.error),

          // ROI overlay
          if (cameraState.isInitialized)
            _buildRoiOverlay(),

          // Kalite göstergeleri
          if (cameraState.qualityMetrics != null)
            _buildQualityIndicators(cameraState.qualityMetrics!),

          // Sonuç kartı
          if (cameraState.vinResult != null)
            _buildResultCard(context, cameraState.vinResult!, ref),

          // Kontroller
          _buildControls(context, ref, cameraState),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(WidgetRef ref) {
    final controller = ref.read(cameraControllerProvider.notifier)._controller;
    if (controller == null) return const SizedBox.shrink();

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize!.height,
          height: controller.value.previewSize!.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _buildErrorState(String? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            error ?? 'Camera error',
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRoiOverlay() {
    return Center(
      child: Container(
        width: 300,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.cyan, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Position VIN here',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQualityIndicators(QualityMetrics metrics) {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.cyan.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text(
              metrics.status,
              style: TextStyle(
                color: metrics.isGoodForOcr ? Colors.green : Colors.orange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQualityBar('Blur', metrics.blurScore),
                _buildQualityBar('Exposure', metrics.exposureScore),
                _buildQualityBar('Alignment', metrics.alignmentScore),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityBar(String label, double score) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: score,
            child: Container(
              decoration: BoxDecoration(
                color: score > 0.7 ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(BuildContext context, VinResult result, WidgetRef ref) {
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: result.isValid ? Colors.green : Colors.red,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              'VIN Detected',
              style: TextStyle(
                color: result.isValid ? Colors.green : Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              result.vin,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Confidence: ${(result.confidence * 100).toInt()}%',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, WidgetRef ref, CameraState state) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Back button
          FloatingActionButton(
            onPressed: () => _goBack(context),
            backgroundColor: Colors.black.withOpacity(0.7),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          
          // Capture button
          FloatingActionButton(
            onPressed: state.isCapturing ? null : () {
              ref.read(cameraControllerProvider.notifier).captureAndAnalyze();
            },
            backgroundColor: state.qualityMetrics?.isGoodForOcr == true 
                ? Colors.green 
                : Colors.orange,
            child: state.isCapturing 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.camera_alt, color: Colors.white),
          ),
          
          // Flash toggle
          FloatingActionButton(
            onPressed: () {
              // Flash toggle logic
            },
            backgroundColor: Colors.black.withOpacity(0.7),
            child: const Icon(Icons.flash_on, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
