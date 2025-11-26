import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jawaramobile_1/services/barang_service.dart';

class DetailRiwayatPesananPage extends StatelessWidget {
  final Map<String, dynamic> pesanan;

  const DetailRiwayatPesananPage({super.key, required this.pesanan});

  // --- WARNA UTAMA ---
  final Color jawaraColor = const Color(0xFF26547C);

  // --- HELPER FUNCTIONS ---
  String _formatRupiah(dynamic harga) {
    int price = int.tryParse(harga.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  String _formatTanggal(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return const Color(0xFF2A9D8F); 
      
      case 'dibatalkan':
        return const Color(0xFFE63946); 
      
      case 'menunggu_diambil':
        return const Color(0xFFE76F51); 
      
      case 'diproses':
        return const Color(0xFF457B9D); 
      
      default:
        return Colors.blueGrey; 
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'selesai': return Icons.check_circle_outline;
      case 'dibatalkan': return Icons.cancel_outlined;
      case 'menunggu_diambil': return Icons.storefront;
      case 'diproses': return Icons.sync;
      default: return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Normalisasi Data
    final String status = pesanan['status'] ?? 'Pending';
    final String kodeTransaksi = pesanan['transaksi_kode'] ?? '-';
    final String tanggal = pesanan['created_at']?.toString() ?? DateTime.now().toString();
    
    // Parsing Items
    List<dynamic> items = [];
    if (pesanan['detail'] != null && pesanan['detail'] is List) {
      items = pesanan['detail'];
    }

    // --- LOGIKA BARU: AMBIL DATA PENJUAL DARI USER YANG POSTING ---
    String namaPenjual = 'Penjual Tidak Diketahui';
    String alamatPenjual = 'Lokasi Tidak Tersedia';

    // Kita ambil info penjual dari barang pertama di list
    if (items.isNotEmpty) {
      final barangData = items[0]['barang'];
      
      // Cek apakah data barang dan user (pemilik barang) tersedia
      if (barangData != null && barangData['user'] != null) {
        final userData = barangData['user'];

        // 1. Ambil Nama (Gabungan Depan + Belakang)
        String depan = userData['user_nama_depan'] ?? '';
        String belakang = userData['user_nama_belakang'] ?? '';
        namaPenjual = "$depan $belakang".trim();
        if (namaPenjual.isEmpty) namaPenjual = "User #${userData['user_id']}";

        // 2. Ambil Alamat User
        alamatPenjual = userData['user_alamat'] ?? 'Alamat belum diatur oleh penjual';
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text("Rincian Pesanan", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. STATUS HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              color: _getStatusColor(status),
              child: Row(
                children: [
                  Icon(_getStatusIcon(status), color: Colors.white, size: 30),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pesanan ${status[0].toUpperCase()}${status.substring(1).replaceAll('_', ' ')}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Terima kasih telah berbelanja",
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. INFO PENJUAL & ALAMAT
            _buildSectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Penjual
                  Row(
                    children: [
                      const Icon(Icons.store, color: Colors.black87, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          namaPenjual, 
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Tombol Chat Kecil (Visual)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: jawaraColor),
                          borderRadius: BorderRadius.circular(4)
                        ),
                        child: Text("Chat", style: TextStyle(fontSize: 10, color: jawaraColor, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(height: 1),
                  ),
                  // Alamat Pengambilan
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.grey, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Lokasi Pengambilan", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text(
                              alamatPenjual, 
                              style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.3)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 3. DAFTAR PRODUK
            _buildSectionContainer(
              padding: const EdgeInsets.all(0),
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
            ),

            const SizedBox(height: 8),

            // 4. RINCIAN PEMBAYARAN
            _buildSectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Rincian Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  _buildPaymentRow("Metode Pembayaran", "Tunai"),
                  _buildPaymentRow("Total Harga Barang", _formatRupiah(pesanan['total_harga'])),
                  _buildPaymentRow("Biaya Layanan", "Rp 0"),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Belanja", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(_formatRupiah(pesanan['total_harga']), 
                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: jawaraColor)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 5. INFO FAKTUR
            _buildSectionContainer(
              child: Column(
                children: [
                  _buildInfoRow("No. Pesanan", kodeTransaksi, canCopy: true, context: context),
                  const SizedBox(height: 8),
                  _buildInfoRow("Waktu Pemesanan", _formatTanggal(tanggal), context: context),
                ],
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSectionContainer({required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(16)}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: child,
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
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(6),
            ),
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
                Text("$qty x ${_formatRupiah(harga)}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("Total Harga", style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text(_formatRupiah(harga * qty), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value, style: TextStyle(color: Colors.grey[800], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool canCopy = false, required BuildContext context}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Row(
          children: [
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
            if (canCopy)
              InkWell(
                onTap: () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Disalin ke papan klip"), duration: Duration(seconds: 1)));
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Text("SALIN", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: jawaraColor)),
                ),
              )
          ],
        )
      ],
    );
  }
}