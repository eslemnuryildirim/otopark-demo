import 'package:intl/intl.dart';

/// Tarih ve format utilities
class Formatters {
  /// Tarih formatı: 10 Eki 2025, 14:30
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('d MMM yyyy, HH:mm').format(dateTime);
  }

  /// Sadece tarih: 10 Eki 2025
  static String formatDate(DateTime dateTime) {
    return DateFormat('d MMM yyyy').format(dateTime);
  }

  /// Sadece saat: 14:30
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Göreceli zaman: "2 saat önce", "3 gün önce"
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
}

