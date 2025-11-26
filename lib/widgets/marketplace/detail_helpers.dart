import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailHelpers {
  static const Color jawaraColor = Color(0xFF26547C);

  static String formatRupiah(dynamic harga) {
    int price = int.tryParse(harga.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  static String formatTanggal(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai': return const Color(0xFF2A9D8F);
      case 'dibatalkan': return const Color(0xFFE63946);
      case 'menunggu_diambil': return const Color(0xFFE76F51);
      case 'diproses': return const Color(0xFF457B9D);
      default: return Colors.blueGrey;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'selesai': return Icons.check_circle_outline;
      case 'dibatalkan': return Icons.cancel_outlined;
      case 'menunggu_diambil': return Icons.storefront;
      case 'diproses': return Icons.sync;
      default: return Icons.info_outline;
    }
  }
}