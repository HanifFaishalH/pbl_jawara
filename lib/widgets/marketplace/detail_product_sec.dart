import 'package:flutter/material.dart';
import 'package:jawaramobile_1/services/barang_service.dart';
import 'detail_helpers.dart';

class DetailProductSection extends StatelessWidget {
  final List<dynamic> items;

  const DetailProductSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Detail Produk", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          const Divider(height: 1),
          ...items.map((item) => _buildProductItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> detail) {
    final item = detail['barang'];
    final int qty = detail['jumlah'] ?? 0;
    final int harga = detail['harga'] ?? 0;
    
    String rawFoto = item['barang_foto']?.toString() ?? '';
    String fotoUrl = '';
    if (rawFoto.isNotEmpty) {
      fotoUrl = rawFoto.startsWith('http') ? rawFoto : "${BarangService.baseImageUrl}$rawFoto";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(6)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: fotoUrl.isNotEmpty
                ? Image.network(fotoUrl, fit: BoxFit.cover, errorBuilder: (_,__,___)=> const Icon(Icons.image, color: Colors.grey))
                : const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['barang_nama'] ?? 'Nama Barang',
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text("$qty x ${DetailHelpers.formatRupiah(harga)}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("Total Harga", style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text(DetailHelpers.formatRupiah(harga * qty), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }
}