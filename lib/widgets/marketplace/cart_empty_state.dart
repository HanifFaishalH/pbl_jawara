import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CartEmptyState extends StatelessWidget {
  final Color primaryColor;

  const CartEmptyState({super.key, this.primaryColor = const Color(0xFF26547C)});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Keranjang Kosong", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text("Yuk, isi keranjangmu dengan barang impian!", style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => context.go('/daftar-pembelian'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryColor),
              foregroundColor: primaryColor,
            ),
            child: const Text("Belanja Sekarang"),
          )
        ],
      ),
    );
  }
}