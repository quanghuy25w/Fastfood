import 'package:intl/intl.dart';

/// Cung cap cac ham format du lieu hien thi (gia tien, ngay gio, so luong...).
///
/// Giup UI hien thi thong nhat va than thien voi nguoi dung.
/// Duoc su dung rong rai trong Product, Cart, Order, Address.
class AppFormatters {
  AppFormatters._();

  /// Format so thanh tien te VN. Vi du: 10000 -> 10.000\u20AB.
  static String formatCurrency(
    num? value, {
    String symbol = '\u20AB',
    int decimalDigits = 0,
  }) {
    final amount = value ?? 0;
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: decimalDigits,
    );

    final formatted = formatter.format(amount).replaceAll('\u00A0', '').trim();
    return '$formatted$symbol';
  }

  /// Format so luong san pham. Vi du: 3 -> 3 mon.
  static String formatQuantity(int? quantity, {String unit = 'mon'}) {
    return '${quantity ?? 0} $unit';
  }

  /// Format DateTime thanh chuoi de doc theo pattern.
  static String formatDateTime(
    DateTime? dateTime, {
    String pattern = 'dd/MM/yyyy HH:mm',
    String fallback = '-',
  }) {
    if (dateTime == null) {
      return fallback;
    }

    return DateFormat(pattern, 'vi_VN').format(dateTime);
  }

  /// Format ngay. Vi du: 19/03/2026.
  static String formatDate(
    DateTime? dateTime, {
    String pattern = 'dd/MM/yyyy',
    String fallback = '-',
  }) {
    return formatDateTime(dateTime, pattern: pattern, fallback: fallback);
  }

  /// Format gio. Vi du: 14:30.
  static String formatTime(
    DateTime? dateTime, {
    String pattern = 'HH:mm',
    String fallback = '-',
  }) {
    return formatDateTime(dateTime, pattern: pattern, fallback: fallback);
  }

  /// Parse string ngay gio (ISO hoac SQLite) roi format ra chuoi de doc.
  static String formatDateTimeFromString(
    String? value, {
    String pattern = 'dd/MM/yyyy HH:mm',
    String fallback = '-',
  }) {
    final parsed = _tryParseDateTime(value);
    return formatDateTime(parsed, pattern: pattern, fallback: fallback);
  }

  /// Chuan hoa hien thi so dien thoai de de doc.
  /// Vi du: 0987654321 -> 0987 654 321.
  static String formatPhone(String? phone, {String fallback = '-'}) {
    final raw = phone?.trim() ?? '';
    if (raw.isEmpty) {
      return fallback;
    }

    if (raw.startsWith('+84')) {
      final local = raw.substring(3).replaceAll(RegExp(r'\D'), '');
      if (local.isEmpty) {
        return raw;
      }

      if (local.length == 9) {
        return '+84 ${local.substring(0, 3)} ${local.substring(3, 6)} ${local.substring(6)}';
      }

      if (local.length == 10) {
        return '+84 ${local.substring(0, 4)} ${local.substring(4, 7)} ${local.substring(7)}';
      }

      return '+84 ${_chunkBy3(local)}';
    }

    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return raw;
    }

    if (digits.length == 10) {
      return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
    }

    if (digits.length == 11) {
      return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7, 11)}';
    }

    if (digits.length == 9) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    }

    return _chunkBy3(digits);
  }

  /// Viet hoa chu cai dau chuoi.
  static String capitalize(String? value, {String fallback = ''}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return fallback;
    }

    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  /// Cat chuoi dai va them dau ... de tranh vo layout UI.
  static String truncate(
    String? value, {
    int maxLength = 30,
    String ellipsis = '...',
  }) {
    final text = value?.trim() ?? '';
    if (text.length <= maxLength) {
      return text;
    }

    final keepLength = maxLength - ellipsis.length;
    if (keepLength <= 0) {
      return ellipsis;
    }

    return '${text.substring(0, keepLength)}$ellipsis';
  }

  static DateTime? _tryParseDateTime(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }

    final direct = DateTime.tryParse(raw);
    if (direct != null) {
      return direct;
    }

    if (raw.contains(' ')) {
      return DateTime.tryParse(raw.replaceFirst(' ', 'T'));
    }

    return null;
  }

  static String _chunkBy3(String digits) {
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }
}
