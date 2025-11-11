import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import '../domain/car_part.dart';
import '../domain/expertiz_status.dart';
import 'dart:typed_data';

/// SVG tabanlı araç şeması widget'ı
/// 
/// **Sorun Analizi:**
/// 1. SVG'de transform var: `translate(156.5 219.5) rotate(-90) translate(-188.5 -144.5)`
/// 2. Tıklama koordinatları viewBox'a ölçekleniyor ama transform tersine çevrilmiyor
/// 3. Path bounding box'ları transform öncesi koordinatlarda, render'da transform uygulanıyor
/// 
/// **Çözüm:**
/// - Mask tabanlı tıklama: SVG rasterize edilirken transform zaten uygulanıyor
/// - Fallback: Bounding-box tabanlı tıklama (transform'u tersine çevirerek)
class SvgCarSchemaWidget extends StatefulWidget {
  final Map<CarPart, ExpertizStatus> partStatuses;
  final Function(CarPart part)? onPartTap;
  final bool isInteractive;
  final double? width;
  final double? height;
  final bool debugMode; // Debug modu: tıklanan yeri göster

  const SvgCarSchemaWidget({
    super.key,
    required this.partStatuses,
    this.onPartTap,
    this.isInteractive = true,
    this.width,
    this.height,
    this.debugMode = false, // Varsayılan olarak kapalı
  });

  @override
  State<SvgCarSchemaWidget> createState() => _SvgCarSchemaWidgetState();
}

class _SvgCarSchemaWidgetState extends State<SvgCarSchemaWidget> {
  String? _svgString;
  Map<String, CarPart> _pathToPartMap = {};

  // Mask tabanlı tıklama için
  ui.Image? _maskImage;
  Uint8List? _maskPixels;
  final Map<int, CarPart> _colorToPart = {};
  static const int viewBoxWidth = 300;
  static const int viewBoxHeight = 430;
  
  // Debug modu için tıklama noktaları
  final List<Offset> _debugTapPoints = [];
  final List<String> _debugTapLabels = [];

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  Future<void> _loadSvg() async {
    try {
      final svgString = await rootBundle.loadString('assets/car_schema.svg');
      setState(() {
        _svgString = svgString;
        _pathToPartMap = _extractPathToPartMap(svgString);
      });

      // Mask hazırla (transform zaten SVG render'ında uygulanacak)
      await _prepareMaskImage();
    } catch (e) {
      print('❌ SVG yükleme hatası: $e');
    }
  }

  /// SVG'den path ID'lerini çıkar ve CarPart ile eşleştir
  Map<String, CarPart> _extractPathToPartMap(String svg) {
    final map = <String, CarPart>{};
    for (final part in CarPart.values) {
      if (svg.contains('id="${part.id}"')) {
        map[part.id] = part;
      }
    }
    return map;
  }

  /// Mask SVG oluşturup rasterize eder
  /// Her parça için benzersiz renk kullanır, böylece piksel okuma ile parça tespiti yapılır
  Future<void> _prepareMaskImage() async {
    if (_svgString == null) return;

    // 1. Her parça için benzersiz renk oluştur
    _colorToPart.clear();
    int idx = 1;
    for (final part in CarPart.values) {
      final colorInt = _colorForIndex(idx);
      _colorToPart[colorInt] = part;
      idx++;
    }

    // 2. Mask SVG oluştur: Her path'in fill'ini benzersiz renkle değiştir
    var maskSvg = _svgString!;
    for (final entry in _pathToPartMap.entries) {
      final id = entry.key;
      final part = entry.value;
      final colorInt = _colorToPart.keys.firstWhere((k) => _colorToPart[k] == part);
      final hex = _hexFromArgb(colorInt);

      // Path tag'inde fill attribute'unu bul ve değiştir
      final idPattern = RegExp('(id="$id"[^>]*)(>)', dotAll: true);
      maskSvg = maskSvg.replaceAllMapped(idPattern, (m) {
        final before = m.group(1)!;
        final cleaned = before.replaceAll(RegExp(r'fill="[^"]*"'), '');
        return '$cleaned fill="$hex"${m.group(2)}';
      });
    }

    // 3. SVG'yi rasterize et (viewBox boyutunda)
    // NOT: flutter_svg render ederken transform'u otomatik uygular
    // Mask rasterize için widget tree gerekiyor, bu yüzden şimdilik devre dışı
    // Fallback olarak bounding-box tabanlı tıklama kullanılacak
    print('ℹ️ Mask rasterize şimdilik devre dışı, bounding-box fallback kullanılıyor');
  }

  /// Index'e göre benzersiz ARGB rengi üret
  int _colorForIndex(int idx) {
    // 24-bit renk dağılımı (alpha = 0xFF)
    final r = ((idx * 7) % 256);
    final g = ((idx * 13) % 256);
    final b = ((idx * 17) % 256);
    return (0xFF << 24) | (r << 16) | (g << 8) | b;
  }

  /// ARGB int -> "#RRGGBB" hex string
  String _hexFromArgb(int argb) {
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }

  /// SVG'yi duruma göre renklendir
  /// SADECE id'si olan path'leri renklendirir (iskelet/outline path'lerini renklendirmez)
  String _colorizeSvg(String svg, Map<CarPart, ExpertizStatus> partStatuses) {
    String coloredSvg = svg;
    
    for (final entry in partStatuses.entries) {
      final part = entry.key;
      final status = entry.value;
      final color = _getStatusColor(status);
      
      // ID'yi içeren path tag'ini bul (id path içinde)
      // Pattern: <path ... id="B0201" ... >
      // ÖNEMLİ: Sadece id'si olan path'leri renklendir (iskelet path'leri id'siz)
      final pathPattern = RegExp(
        r'<path[^>]*id="' + RegExp.escape(part.id) + r'"[^>]*>',
        dotAll: true,
      );
      
      final pathMatch = pathPattern.firstMatch(coloredSvg);
      
      if (pathMatch != null) {
        final pathTag = pathMatch.group(0)!;
        
        // Mevcut fill'i kaldır ve yeni fill ekle
        String newPathTag = pathTag.replaceAll(RegExp(r'fill="[^"]*"'), '');
        newPathTag = newPathTag.replaceAll(RegExp(r"fill='[^']*'"), '');
        
        // Fill yoksa ekle
        if (!newPathTag.contains('fill=')) {
          // > karakterinden önce fill ekle
          newPathTag = newPathTag.replaceFirst('>', ' fill="$color">');
        } else {
          // Fill zaten var (olmamalı ama güvenlik için)
          newPathTag = newPathTag.replaceFirst(
            RegExp(r'fill="[^"]*"'),
            'fill="$color"',
          );
        }
        
        // Sadece bu path'i değiştir (ilk eşleşen)
        coloredSvg = coloredSvg.replaceFirst(pathTag, newPathTag);
      } else {
        // Debug: Parça bulunamadı
        print('⚠️ Parça bulunamadı: ${part.displayName} (${part.id})');
      }
    }
    
    return coloredSvg;
  }

  String _getStatusColor(ExpertizStatus status) {
    switch (status) {
      case ExpertizStatus.original:
        return '#4CAF50';
      case ExpertizStatus.localPainted:
        return '#FFE94D';
      case ExpertizStatus.painted:
        return '#FF9800';
      case ExpertizStatus.replaced:
        return '#9C27B0';
      case ExpertizStatus.damaged:
        return '#F44336';
      case ExpertizStatus.scratched:
        return '#FFC107';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_svgString == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final coloredSvg = _colorizeSvg(_svgString!, widget.partStatuses);
    final width = widget.width ?? 300.0;
    final height = widget.height ?? 430.0;
    
    return Container(
      width: width,
      height: height,
      child: GestureDetector(
        onTapDown: (details) {
          if (!widget.isInteractive || widget.onPartTap == null) return;
          
          // 1. Tıklama koordinatını viewBox'a ölçekle
          final localPosition = details.localPosition;
          final svgX = (localPosition.dx / width) * viewBoxWidth;
          final svgY = (localPosition.dy / height) * viewBoxHeight;
          
          // Debug: Widget boyutu ve tıklama bilgisi
          print('📐 Widget boyutu: ${width.toStringAsFixed(1)} x ${height.toStringAsFixed(1)}');
          print('🖱️ Tıklama: (${localPosition.dx.toStringAsFixed(1)}, ${localPosition.dy.toStringAsFixed(1)}) -> SVG: (${svgX.toStringAsFixed(1)}, ${svgY.toStringAsFixed(1)})');
          
          // 2. Mask tabanlı tıklama (öncelikli)
          CarPart? clickedPart = _getPartFromMaskAt(svgX, svgY);
          
          if (clickedPart != null) {
            print('🎯 Parça bulundu (mask): ${clickedPart.displayName} (${clickedPart.id})');
            widget.onPartTap?.call(clickedPart);
            return;
          }
          
          // 3. Fallback: Bounding-box tabanlı tıklama
          // Transform'u tersine çevirerek path koordinatlarıyla karşılaştır
          clickedPart = _findPartAtPositionWithTransform(svgX, svgY);
          
          if (clickedPart != null) {
            print('🎯 Parça bulundu (fallback): ${clickedPart.displayName} (${clickedPart.id})');
            
            // Debug modu: Tıklama noktasını kaydet
            if (widget.debugMode) {
              setState(() {
                _debugTapPoints.add(localPosition);
                final clickX = svgX / viewBoxWidth;
                final clickY = svgY / viewBoxHeight;
                _debugTapLabels.add('${clickedPart!.displayName}\n(${clickX.toStringAsFixed(2)}, ${clickY.toStringAsFixed(2)})');
              });
            }
            
            widget.onPartTap?.call(clickedPart);
          } else {
            print('⚠️ Tıklanan konumda parça bulunamadı');
            
            // Debug modu: Tıklama noktasını kaydet (parça bulunamadı)
            if (widget.debugMode) {
              setState(() {
                _debugTapPoints.add(localPosition);
                final clickX = svgX / viewBoxWidth;
                final clickY = svgY / viewBoxHeight;
                _debugTapLabels.add('Bulunamadı\n(${clickX.toStringAsFixed(2)}, ${clickY.toStringAsFixed(2)})');
              });
            }
          }
        },
        child: Stack(
          children: [
            SvgPicture.string(
              coloredSvg,
              fit: BoxFit.contain,
              width: width,
              height: height,
            ),
            // Debug modu: Tıklanan noktaları göster
            if (widget.debugMode)
              ...List.generate(_debugTapPoints.length, (index) {
                final point = _debugTapPoints[index];
                final label = _debugTapLabels[index];
                return Positioned(
                  left: point.dx - 10,
                  top: point.dy - 10,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            // Debug modu: Koordinat etiketleri
            if (widget.debugMode)
              ...List.generate(_debugTapPoints.length, (index) {
                final point = _debugTapPoints[index];
                final label = _debugTapLabels[index];
                return Positioned(
                  left: point.dx + 15,
                  top: point.dy - 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  /// Mask'ten piksel okuyup CarPart döndürür
  /// NOT: Mask rasterize edilirken transform zaten uygulanmış, bu yüzden direkt koordinat kullanılabilir
  CarPart? _getPartFromMaskAt(double svgX, double svgY) {
    if (_maskPixels == null) {
      return null;
    }

    final x = svgX.round().clamp(0, viewBoxWidth - 1);
    final y = svgY.round().clamp(0, viewBoxHeight - 1);

    final idx = (y * viewBoxWidth + x) * 4;
    if (idx + 3 >= _maskPixels!.length) return null;

    final r = _maskPixels![idx];
    final g = _maskPixels![idx + 1];
    final b = _maskPixels![idx + 2];
    final a = _maskPixels![idx + 3];
    final colorInt = (a << 24) | (r << 16) | (g << 8) | b;

    return _colorToPart[colorInt];
  }

  /// Oran bazlı koordinat tabanlı tıklama (basit ve güvenilir)
  /// 
  /// **Yaklaşım:** Her parça için sabit koordinatlar (0-1 arası oran) tanımlı.
  /// Tıklama koordinatlarını viewBox'a göre orana çevirip, en yakın parçayı bulur.
  CarPart? _findPartAtPositionWithTransform(double svgX, double svgY) {
    // Tıklama koordinatlarını orana çevir (0-1 arası)
    final clickX = svgX / viewBoxWidth;
    final clickY = svgY / viewBoxHeight;
    
    print('🔍 Tıklama: ($svgX, $svgY) -> Oran: (${clickX.toStringAsFixed(3)}, ${clickY.toStringAsFixed(3)})');
    print('📋 Tüm parçalar ve mesafeleri:');
    
    CarPart? closestPart;
    double minDistance = double.infinity;
    
    // Her parça için mesafe hesapla ve göster
    for (final part in CarPart.values) {
      final dx = clickX - part.x;
      final dy = clickY - part.y;
      final distance = dx * dx + dy * dy; // Kare mesafe (sqrt'e gerek yok)
      
      if (distance < minDistance) {
        minDistance = distance;
        closestPart = part;
      }
      
      // Tüm parçaları göster (mesafe sıralı)
      print('  ${part.displayName.padRight(20)}: Mesafe: ${distance.toStringAsFixed(4)} (koordinat: ${part.x.toStringAsFixed(2)}, ${part.y.toStringAsFixed(2)})');
    }
    
    // Tolerans: 0.02 oran = yaklaşık 6-9 piksel (viewBox'a göre)
    // Hassas koordinatlar için daha dar tolerans
    if (closestPart != null && minDistance < 0.02) {
      print('✅ Seçilen parça: ${closestPart.displayName} (mesafe: ${minDistance.toStringAsFixed(4)})');
      return closestPart;
    }
    
    print('⚠️ Parça bulunamadı (en yakın mesafe: ${minDistance.toStringAsFixed(4)}, parça: ${closestPart?.displayName})');
    return null;
  }
  
  /// Rect'i transform'a göre dönüştür
  /// Transform: translate(156.5 219.5) rotate(-90) translate(-188.5 -144.5)
  /// 
  /// **NOT:** flutter_svg zaten transform'u uyguluyor, bu yüzden tıklama koordinatları
  /// transform SONRASI. Path bounding box'ları transform ÖNCESİ, bu yüzden onları
  /// transform'a göre dönüştürmemiz gerekiyor.
  Rect _applyTransformToRect(Rect rect) {
    // Transform'u köşelere uygula
    final corners = [
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.bottom),
      Offset(rect.left, rect.bottom),
    ];
    
    final transformedCorners = corners.map((corner) {
      // Transform sırası: translate(-188.5 -144.5) -> rotate(-90) -> translate(156.5 219.5)
      // 1. translate(-188.5 -144.5): Döndürme merkezine taşı
      final step1 = Offset(corner.dx - 188.5, corner.dy - 144.5);
      
      // 2. rotate(-90): (x, y) -> (y, -x) [saat yönü tersi]
      final step2 = Offset(step1.dy, -step1.dx);
      
      // 3. translate(156.5 219.5): Son konuma taşı
      return Offset(step2.dx + 156.5, step2.dy + 219.5);
    }).toList();
    
    // Transformed köşelerden bounding box oluştur
    double minX = transformedCorners[0].dx;
    double maxX = transformedCorners[0].dx;
    double minY = transformedCorners[0].dy;
    double maxY = transformedCorners[0].dy;
    
    for (final corner in transformedCorners) {
      minX = minX < corner.dx ? minX : corner.dx;
      maxX = maxX > corner.dx ? maxX : corner.dx;
      minY = minY < corner.dy ? minY : corner.dy;
      maxY = maxY > corner.dy ? maxY : corner.dy;
    }
    
    final result = Rect.fromLTRB(minX, minY, maxX, maxY);
    
    // Debug: Transform sonucunu yazdır (sadece ilk birkaç parça için)
    // print('  🔄 Transform: (${rect.left.toStringAsFixed(1)},${rect.top.toStringAsFixed(1)} ${rect.width.toStringAsFixed(1)}x${rect.height.toStringAsFixed(1)}) -> (${result.left.toStringAsFixed(1)},${result.top.toStringAsFixed(1)} ${result.width.toStringAsFixed(1)}x${result.height.toStringAsFixed(1)})');
    
    return result;
  }

  /// Parçaların bounding box'larını parse et (transform öncesi koordinatlarda)
  Map<CarPart, Rect> _getPartPositions() {
    if (_svgString == null) return {};
    
    final positions = <CarPart, Rect>{};
    
    for (final part in CarPart.values) {
      final rect = _parsePathBounds(_svgString!, part.id);
      if (rect != null) {
        positions[part] = rect;
        // Debug: Transform öncesi ve sonrası bounding box'ları yazdır
        final transformedRect = _applyTransformToRect(rect);
        print('📦 ${part.displayName}: Orijinal: (${rect.left.toStringAsFixed(1)}, ${rect.top.toStringAsFixed(1)}, ${rect.width.toStringAsFixed(1)}, ${rect.height.toStringAsFixed(1)}) -> Transform: (${transformedRect.left.toStringAsFixed(1)}, ${transformedRect.top.toStringAsFixed(1)}, ${transformedRect.width.toStringAsFixed(1)}, ${transformedRect.height.toStringAsFixed(1)})');
      }
    }
    
    return positions;
  }
  
  /// Path'in bounding box'ını parse et (transform öncesi koordinatlarda)
  Rect? _parsePathBounds(String svg, String partId) {
    final idPattern = RegExp('id="$partId"');
    final idMatch = idPattern.firstMatch(svg);
    if (idMatch == null) return null;
    
    final beforeId = svg.substring(0, idMatch.start);
    final pathStart = beforeId.lastIndexOf('<path');
    if (pathStart == -1) return null;
    
    final tagEnd = svg.indexOf('>', pathStart);
    if (tagEnd == -1) return null;
    
    final pathTag = svg.substring(pathStart, tagEnd + 1);
    var dMatch = RegExp(r'd="([^"]*)"').firstMatch(pathTag);
    
    if (dMatch == null) {
      final afterTag = svg.substring(tagEnd + 1, tagEnd + 500);
      dMatch = RegExp(r'd="([^"]*)"').firstMatch(afterTag);
    }
    
    if (dMatch == null) return null;
    
    final pathData = dMatch.group(1)!;
    final allPoints = <Offset>[];
    _parsePathData(pathData, allPoints);
    
    if (allPoints.isEmpty) return null;
    
    double minX = allPoints.first.dx;
    double maxX = allPoints.first.dx;
    double minY = allPoints.first.dy;
    double maxY = allPoints.first.dy;
    
    for (final point in allPoints) {
      minX = minX < point.dx ? minX : point.dx;
      maxX = maxX > point.dx ? maxX : point.dx;
      minY = minY < point.dy ? minY : point.dy;
      maxY = maxY > point.dy ? maxY : point.dy;
    }
    
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
  
  /// Path data'yı parse et ve tüm noktaları topla
  /// SVG path komutlarını doğru şekilde işler: M, L, C, H, V, Z, vb.
  void _parsePathData(String pathData, List<Offset> points) {
    if (pathData.isEmpty) return;
    
    // Path komutlarını ve sayıları ayır
    final commandPattern = RegExp(r'([MmLlHhVvCcSsQqTtAaZz])');
    final numberPattern = RegExp(r'[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?');
    
    double currentX = 0;
    double currentY = 0;
    double startX = 0;
    double startY = 0;
    
    int i = 0;
    String? lastCommand;
    
    while (i < pathData.length) {
      // Boşlukları atla
      if (pathData[i].trim().isEmpty) {
        i++;
        continue;
      }
      
      // Komut mu?
      final commandMatch = commandPattern.matchAsPrefix(pathData, i);
      if (commandMatch != null) {
        lastCommand = commandMatch.group(1);
        i = commandMatch.end;
        continue;
      }
      
      // Sayıları bul
      final numberMatch = numberPattern.matchAsPrefix(pathData, i);
      if (numberMatch == null) {
        i++;
        continue;
      }
      
      final numbers = <double>[];
      int numIndex = numberMatch.start;
      while (numIndex < pathData.length) {
        final numMatch = numberPattern.matchAsPrefix(pathData, numIndex);
        if (numMatch == null) break;
        final num = double.tryParse(numMatch.group(0)!) ?? 0.0;
        numbers.add(num);
        numIndex = numMatch.end;
      }
      
      if (numbers.isEmpty) {
        i++;
        continue;
      }
      
      // Komuta göre işle
      final cmd = lastCommand ?? 'L';
      final isRelative = cmd == cmd.toLowerCase();
      
      switch (cmd.toUpperCase()) {
        case 'M': // Move to
          if (numbers.length >= 2) {
            if (isRelative) {
              currentX += numbers[0];
              currentY += numbers[1];
            } else {
              currentX = numbers[0];
              currentY = numbers[1];
            }
            startX = currentX;
            startY = currentY;
            points.add(Offset(currentX, currentY));
            
            // Kalan sayılar L komutu olarak işlenir
            for (int j = 2; j < numbers.length; j += 2) {
              if (j + 1 < numbers.length) {
                if (isRelative) {
                  currentX += numbers[j];
                  currentY += numbers[j + 1];
                } else {
                  currentX = numbers[j];
                  currentY = numbers[j + 1];
                }
                points.add(Offset(currentX, currentY));
              }
            }
          }
          break;
          
        case 'L': // Line to
          for (int j = 0; j < numbers.length; j += 2) {
            if (j + 1 < numbers.length) {
              if (isRelative) {
                currentX += numbers[j];
                currentY += numbers[j + 1];
              } else {
                currentX = numbers[j];
                currentY = numbers[j + 1];
              }
              points.add(Offset(currentX, currentY));
            }
          }
          break;
          
        case 'H': // Horizontal line
          for (int j = 0; j < numbers.length; j++) {
            if (isRelative) {
              currentX += numbers[j];
            } else {
              currentX = numbers[j];
            }
            points.add(Offset(currentX, currentY));
          }
          break;
          
        case 'V': // Vertical line
          for (int j = 0; j < numbers.length; j++) {
            if (isRelative) {
              currentY += numbers[j];
            } else {
              currentY = numbers[j];
            }
            points.add(Offset(currentX, currentY));
          }
          break;
          
        case 'C': // Cubic Bezier (6 sayı: x1 y1 x2 y2 x y)
          for (int j = 0; j < numbers.length; j += 6) {
            if (j + 5 < numbers.length) {
              // Kontrol noktalarını da ekle (curve bounding box için)
              final x1 = isRelative ? currentX + numbers[j] : numbers[j];
              final y1 = isRelative ? currentY + numbers[j + 1] : numbers[j + 1];
              final x2 = isRelative ? currentX + numbers[j + 2] : numbers[j + 2];
              final y2 = isRelative ? currentY + numbers[j + 3] : numbers[j + 3];
              
              if (isRelative) {
                currentX += numbers[j + 4];
                currentY += numbers[j + 5];
              } else {
                currentX = numbers[j + 4];
                currentY = numbers[j + 5];
              }
              
              // Kontrol noktaları ve son nokta
              points.add(Offset(x1, y1));
              points.add(Offset(x2, y2));
              points.add(Offset(currentX, currentY));
            }
          }
          break;
          
        case 'S': // Smooth cubic Bezier (4 sayı: x2 y2 x y, x1 y1 önceki komuttan alınır)
          double prevX2 = currentX;
          double prevY2 = currentY;
          for (int j = 0; j < numbers.length; j += 4) {
            if (j + 3 < numbers.length) {
              // İlk kontrol noktası önceki komutun ikinci kontrol noktasının yansıması
              final x1 = 2 * currentX - prevX2;
              final y1 = 2 * currentY - prevY2;
              
              final x2 = isRelative ? currentX + numbers[j] : numbers[j];
              final y2 = isRelative ? currentY + numbers[j + 1] : numbers[j + 1];
              
              if (isRelative) {
                currentX += numbers[j + 2];
                currentY += numbers[j + 3];
              } else {
                currentX = numbers[j + 2];
                currentY = numbers[j + 3];
              }
              
              prevX2 = x2;
              prevY2 = y2;
              
              points.add(Offset(x1, y1));
              points.add(Offset(x2, y2));
              points.add(Offset(currentX, currentY));
            }
          }
          break;
          
        case 'Z': // Close path
          if (points.isNotEmpty) {
            currentX = startX;
            currentY = startY;
          }
          break;
          
        default:
          // Diğer komutlar için basit yaklaşım: sayıları x,y çiftleri olarak işle
          for (int j = 0; j < numbers.length; j += 2) {
            if (j + 1 < numbers.length) {
              if (isRelative) {
                currentX += numbers[j];
                currentY += numbers[j + 1];
              } else {
                currentX = numbers[j];
                currentY = numbers[j + 1];
              }
              points.add(Offset(currentX, currentY));
            }
          }
      }
      
      i = numIndex;
    }
  }
}

