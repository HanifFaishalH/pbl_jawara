import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jawaramobile_1/services/barang_service.dart';

class RiwayatOrderCard extends StatelessWidget {
  final dynamic trx;
  final VoidCallback onTap;
  final Function(int id) onCancel;
  final Color jawaraColor;

  const RiwayatOrderCard({
    super.key,
    required this.trx,
    required this.onTap,
    required this.onCancel,
    this.jawaraColor = const Color(0xFF26547C),
  });

  // --- HELPER INTERNEAL (Hanya untuk UI Card ini) ---

  String _formatRupiah(dynamic harga) {
    int price = int.tryParse(harga.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  String _formatTanggal(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai': return const Color(0xFF2A9D8F);
      case 'dibatalkan': return const Color(0xFFE63946);
      case 'menunggu_diambil': return const Color(0xFFE76F51);
      case 'diproses': return const Color(0xFF457B9D);
      default: return Colors.blueGrey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu_diambil': return 'Menunggu Diambil';
      case 'pending': return 'Menunggu Konfirmasi';
      default: return status[0].toUpperCase() + status.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String status = trx['status'] ?? 'pending';
    final int trxId = trx['transaksi_id'];
    
    // Logika Tombol Batal
    final bool bisaBatal = (status == 'menunggu_diambil' || status == 'pending');

    // Parsing Data Barang Pertama
    List details = trx['detail'] ?? [];
    Map<String, dynamic> firstItem = details.isNotEmpty ? details[0] : {};
    String barangNama = firstItem['barang']?['barang_nama'] ?? 'Barang';
    int barangJml = firstItem['jumlah'] ?? 0;
    
    String rawFoto = firstItem['barang']?['barang_foto']?.toString() ?? '';
    String fotoUrl = '';
    if (rawFoto.isNotEmpty) {
       fotoUrl = rawFoto.startsWith('http') ? rawFoto : "${BarangService.baseImageUrl}$rawFoto";
    }

    int itemCount = details.length;
    String otherItemsText = itemCount > 1 ? "+ ${itemCount - 1} barang lainnya" : "";

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            // 1. HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(_formatTanggal(trx['created_at']), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(trx['transaksi_kode'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getStatusColor(status).withOpacity(0.2))
                    ),
                    child: Text(
                      _getStatusLabel(status),
                      style: TextStyle(color: _getStatusColor(status), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            // 2. CONTENT (Preview Produk)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60, height: 60, color: Colors.grey[100],
                      child: fotoUrl.isNotEmpty
                        ? Image.network(fotoUrl, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.image, color: Colors.grey))
                        : const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(barangNama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text("$barangJml barang", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        if (itemCount > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(otherItemsText, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // 3. FOOTER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Belanja", style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(_formatRupiah(trx['total_harga']), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: jawaraColor)),
                    ],
                  ),
                  
                  if (bisaBatal)
                    OutlinedButton(
                      onPressed: () => onCancel(trxId),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.shade200),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        visualDensity: VisualDensity.compact
                      ),
                      child: const Text("Batalkan"),
                    )
                  else 
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: jawaraColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        visualDensity: VisualDensity.compact
                      ),
                      child: const Text("Lihat Detail", style: TextStyle(color: Colors.white)),
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