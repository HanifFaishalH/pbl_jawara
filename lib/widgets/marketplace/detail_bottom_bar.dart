import 'package:flutter/material.dart';

class DetailBottomBar extends StatelessWidget {
  final bool isLoading;
  final bool isStokAvailable;
  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;
  final Color jawaraColor;

  const DetailBottomBar({
    super.key,
    required this.isLoading,
    required this.isStokAvailable,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.jawaraColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, -3))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: (isStokAvailable && !isLoading) ? onAddToCart : null,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: jawaraColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isLoading
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: jawaraColor))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_shopping_cart, size: 18, color: jawaraColor),
                      const SizedBox(width: 8),
                      Text("Keranjang", style: TextStyle(color: jawaraColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isStokAvailable ? onBuyNow : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: jawaraColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Beli Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}