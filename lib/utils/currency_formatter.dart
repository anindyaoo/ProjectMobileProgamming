import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String newText = newValue.text;

    // 1. Deteksi input titik (.) sebagai request desimal (ganti jadi koma)
    // Cek apakah karakter terakhir yang diketik adalah titik
    if (newValue.selection.baseOffset > 0) {
      int cursor = newValue.selection.baseOffset;
      // Pastikan cursor valid dan karakter sebelumnya adalah titik
      if (cursor <= newText.length &&
          newText.substring(cursor - 1, cursor) == '.') {
        // Ganti titik dengan koma
        newText =
            '${newText.substring(0, cursor - 1)},${newText.substring(cursor)}';
      }
    }

    // 2. Bersihkan format: Hapus semua titik (pemisah ribuan)
    newText = newText.replaceAll('.', '');

    // 3. Validasi Karakter: Hanya izinkan angka dan koma
    if (!RegExp(r'^[0-9,]*$').hasMatch(newText)) {
      // Jika ada karakter ilegal (selain angka dan koma), kembalikan old value
      return oldValue;
    }

    // 4. Validasi Multiple Koma: Tidak boleh lebih dari satu koma
    if (','.allMatches(newText).length > 1) {
      return oldValue;
    }

    // 5. Split Integer dan Decimal
    List<String> parts = newText.split(',');
    String integerPart = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
    String decimalPart = parts.length > 1 ? parts[1] : '';

    // Handle leading zeros: "05" -> "5", tapi "0" -> "0"
    if (integerPart.length > 1 && integerPart.startsWith('0')) {
      integerPart = int.parse(integerPart).toString();
    }

    String formattedInteger = '';
    if (integerPart.isNotEmpty) {
      final formatter = NumberFormat('#,###', 'id_ID');
      try {
        formattedInteger = formatter.format(int.parse(integerPart));
      } catch (e) {
        formattedInteger = integerPart;
      }
    } else {
      // Jika integer part kosong (misal user ketik ,5 atau hapus semua angka depan)
      if (newText.startsWith(',')) {
        formattedInteger = '0';
      }
    }

    // 6. Gabungkan Kembali
    String finalString = formattedInteger;

    if (parts.length > 1 || newText.endsWith(',')) {
      finalString += ',$decimalPart';
    }

    return TextEditingValue(
      text: finalString,
      selection: TextSelection.collapsed(offset: finalString.length),
    );
  }

  /// Mengubah string terformat (misal "1.000.000,50") menjadi double (1000000.50)
  static double parseFormattedValue(String value) {
    if (value.isEmpty) return 0.0;
    // Hapus titik ribuan
    String cleaned = value.replaceAll('.', '');
    // Ganti koma desimal jadi titik untuk parsing
    cleaned = cleaned.replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Mengubah double menjadi string terformat IDR
  static String formatAmount(double amount) {
    // Cek apakah integer (tidak ada desimal)
    if (amount % 1 == 0) {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: '',
        decimalDigits: 0,
      );
      return formatter.format(amount).trim();
    } else {
      // Jika ada desimal, tampilkan flexible
      final formatter = NumberFormat.decimalPattern('id_ID');
      return formatter.format(amount);
    }
  }
}
