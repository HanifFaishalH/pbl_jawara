import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jawaramobile_1/services/barang_service.dart';

class CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isSelected;
  final Function(bool?) onSelect;
  final Function(int delta) onUpdateQty;
  final VoidCallback onDelete;
  final Color primaryColor;

  const CartItemCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onSelect,
    required this.onUpdateQty,
    required this.onDelete,
    this.primaryColor = const Color(0xFF26547C),
  });

  String _formatRupiah(dynamic harga) {
    int price = int.tryParse(harga.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  @override
  Widget build(BuildContext context) {
    final String nama = item['barang_nama'] ?? '-';
    final String hargaRaw = item['barang_harga']?.toString() ?? '0';
    final int qty = int.tryParse(item['jumlah'].toString()) ?? 1;
    
    String rawFoto = item['barang_foto']?.toString() ?? '';
    String fotoUrl = '';
    if (rawFoto.isNotEmpty) {
      fotoUrl = rawFoto.startsWith('http') ? rawFoto : "${BarangService.baseImageUrl}$rawFoto";
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                activeColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                value: isSelected,
                onChanged: onSelect,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 75, height: 75,
                color: Colors.grey[200],
                child: fotoUrl.isNotEmpty
                    ? Image.network(fotoUrl, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.image_not_supported, color: Colors.grey))
                    : const Icon(Icons.image, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nama, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(_formatRupiah(hargaRaw), style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => onUpdateQty(-1),
                              child: Container(width: 30, alignment: Alignment.center, child: Icon(Icons.remove, size: 16, color: Colors.grey[600])),
                            ),
                            Container(
                              width: 30,
                              decoration: BoxDecoration(border: Border.symmetric(vertical: BorderSide(color: Colors.grey.shade300))),
                              alignment: Alignment.center,
                              child: Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                            InkWell(
                              onTap: () => onUpdateQty(1),
                              child: Container(width: 30, alignment: Alignment.center, child: Icon(Icons.add, size: 16, color: primaryColor)),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: onDelete,
                        child: const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.delete_outline, color: Colors.grey, size: 22)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}