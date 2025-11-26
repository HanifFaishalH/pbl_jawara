import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CartBottomBar extends StatelessWidget {
  final int totalSelectedPrice;
  final int selectedCount;
  final VoidCallback onCheckout;
  final Color primaryColor;

  const CartBottomBar({
    super.key,
    required this.totalSelectedPrice,
    required this.selectedCount,
    required this.onCheckout,
    this.primaryColor = const Color(0xFF26547C),
  });

  String _formatRupiah(int price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Total Harga", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  _formatRupiah(totalSelectedPrice),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                "Checkout ($selectedCount)",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}