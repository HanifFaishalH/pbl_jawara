import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckoutItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Function(int delta) onUpdateQty;
  final Color primaryColor;

  const CheckoutItemCard({
    super.key,
    required this.item,
    required this.onUpdateQty,
    this.primaryColor = const Color(0xFF26547C),
  });

  String _formatRupiah(int price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  @override
  Widget build(BuildContext context) {
    int harga = int.tryParse(item['harga'].toString()) ?? 0;
    int qty = int.tryParse(item['jumlah'].toString()) ?? 1;
    String alamat = item['alamat_penjual'] ?? '-';
    String foto = item['foto'] ?? '';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Toko / Lokasi
          Row(
            children: [
              const Icon(Icons.store, size: 16, color: Colors.black54),
              const SizedBox(width: 6),
              Expanded(
                child: Text(alamat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const Divider(height: 20),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 70, height: 70, color: Colors.grey[100],
                  child: foto.isNotEmpty
                    ? Image.network(foto, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.image))
                    : const Icon(Icons.image, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              
              // Detail
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['nama'] ?? '-', style: const TextStyle(fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(_formatRupiah(harga), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // Qty Editor
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => onUpdateQty(-1),
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Icon(Icons.remove, size: 14, color: Colors.grey[600]))
                    ),
                    Text("$qty", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    InkWell(
                      onTap: () => onUpdateQty(1),
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Icon(Icons.add, size: 14, color: primaryColor))
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}