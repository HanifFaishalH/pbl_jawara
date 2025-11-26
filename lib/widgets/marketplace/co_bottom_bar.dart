import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckoutBottomBar extends StatelessWidget {
  final int grandTotal;
  final bool isProcessing;
  final VoidCallback onCheckout;
  final Color primaryColor;

  const CheckoutBottomBar({
    super.key,
    required this.grandTotal,
    required this.isProcessing,
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
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Total Tagihan", style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(_formatRupiah(grandTotal), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: isProcessing ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: isProcessing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Buat Pesanan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }
}