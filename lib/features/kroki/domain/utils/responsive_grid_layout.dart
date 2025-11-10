import 'package:flutter/material.dart';

class ResponsiveGridLayout {
  static const int rowCount = 6;
  static const int colCount = 13;
  static const double rowSpacing = 8.0;
  static const double colSpacing = 8.0;
  static const double verticalPadding = 32.0; // top + bottom
  static const double horizontalPadding = 32.0; // left + right
  static const double headerHeight = 80.0; // stats header
  static const double minSlotSize = 60.0;
  static const double maxSlotSize = 120.0;

  /// Ekran yüksekliğinden optimal slot boyutunu hesapla
  static double calculateSlotSize(double screenHeight) {
    final availableHeight = screenHeight 
      - headerHeight 
      - verticalPadding 
      - (rowSpacing * (rowCount - 1));
    
    final calculatedSize = availableHeight / rowCount;
    
    // Min/Max sınırları içinde tut
    return calculatedSize.clamp(minSlotSize, maxSlotSize);
  }

  /// Ekran genişliğine göre horizontal scroll gerekli mi?
  static bool shouldEnableHorizontalScroll(double screenWidth) {
    final requiredWidth = (colCount * minSlotSize) 
      + horizontalPadding 
      + (colSpacing * (colCount - 1));
    
    return screenWidth < requiredWidth;
  }

  /// Grid için gerekli toplam genişlik
  static double calculateRequiredWidth(double slotSize) {
    return (colCount * slotSize) 
      + horizontalPadding 
      + (colSpacing * (colCount - 1));
  }

  /// Grid için gerekli toplam yükseklik
  static double calculateRequiredHeight(double slotSize) {
    return (rowCount * slotSize) 
      + headerHeight 
      + verticalPadding 
      + (rowSpacing * (rowCount - 1));
  }

  /// Responsive grid boyutları
  static ResponsiveGridSizes calculateSizes(Size screenSize) {
    final slotSize = calculateSlotSize(screenSize.height);
    final enableHorizontalScroll = shouldEnableHorizontalScroll(screenSize.width);
    final requiredWidth = calculateRequiredWidth(slotSize);
    final requiredHeight = calculateRequiredHeight(slotSize);

    return ResponsiveGridSizes(
      slotSize: slotSize,
      enableHorizontalScroll: enableHorizontalScroll,
      requiredWidth: requiredWidth,
      requiredHeight: requiredHeight,
      rowCount: rowCount,
      colCount: colCount,
    );
  }

  /// Breakpoint'lere göre responsive davranış
  static ResponsiveBreakpoint getBreakpoint(double screenWidth) {
    if (screenWidth < 600) {
      return ResponsiveBreakpoint.mobile;
    } else if (screenWidth < 900) {
      return ResponsiveBreakpoint.tablet;
    } else {
      return ResponsiveBreakpoint.desktop;
    }
  }

  /// Breakpoint'e göre özel ayarlar
  static ResponsiveGridSizes getBreakpointSizes(Size screenSize) {
    final breakpoint = getBreakpoint(screenSize.width);
    final baseSizes = calculateSizes(screenSize);

    switch (breakpoint) {
      case ResponsiveBreakpoint.mobile:
        return baseSizes.copyWith(
          slotSize: baseSizes.slotSize.clamp(50.0, 70.0),
          enableHorizontalScroll: true,
        );
      case ResponsiveBreakpoint.tablet:
        return baseSizes.copyWith(
          slotSize: baseSizes.slotSize.clamp(70.0, 90.0),
          enableHorizontalScroll: baseSizes.requiredWidth > screenSize.width,
        );
      case ResponsiveBreakpoint.desktop:
        return baseSizes.copyWith(
          slotSize: baseSizes.slotSize.clamp(80.0, 120.0),
          enableHorizontalScroll: false,
        );
    }
  }
}

class ResponsiveGridSizes {
  final double slotSize;
  final bool enableHorizontalScroll;
  final double requiredWidth;
  final double requiredHeight;
  final int rowCount;
  final int colCount;

  ResponsiveGridSizes({
    required this.slotSize,
    required this.enableHorizontalScroll,
    required this.requiredWidth,
    required this.requiredHeight,
    required this.rowCount,
    required this.colCount,
  });

  ResponsiveGridSizes copyWith({
    double? slotSize,
    bool? enableHorizontalScroll,
    double? requiredWidth,
    double? requiredHeight,
    int? rowCount,
    int? colCount,
  }) {
    return ResponsiveGridSizes(
      slotSize: slotSize ?? this.slotSize,
      enableHorizontalScroll: enableHorizontalScroll ?? this.enableHorizontalScroll,
      requiredWidth: requiredWidth ?? this.requiredWidth,
      requiredHeight: requiredHeight ?? this.requiredHeight,
      rowCount: rowCount ?? this.rowCount,
      colCount: colCount ?? this.colCount,
    );
  }
}

enum ResponsiveBreakpoint {
  mobile,
  tablet,
  desktop,
}

