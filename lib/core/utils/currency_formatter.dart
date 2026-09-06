import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _numberFormat = NumberFormat.decimalPattern('id_ID');

  /// Formats double value to Rupiah string format, e.g. Rp 1.500.000
  static String formatRupiah(num val) {
    return _currencyFormat.format(val);
  }

  /// Formats double value without symbol, e.g. 1.500.000
  static String formatNumber(num val) {
    return _numberFormat.format(val);
  }

  /// Formats DateTime to Indonesian date string e.g. 06 Sep 2026
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  /// Formats DateTime to readable ISO date YYYY-MM-DD
  static String formatDateShort(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Parses text input string to double safely
  static double parseDouble(String text) {
    if (text.isEmpty) return 0.0;
    String cleanText = text.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanText) ?? 0.0;
  }
}
