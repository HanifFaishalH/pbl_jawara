import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import Widget Modular
import '../../widgets/marketplace/detail_product_sec.dart';
import '../../widgets/marketplace/detail_payment_sec.dart';
import '../../widgets/marketplace/detail_header_sec.dart';
// import '../../widgets/marketplace/detail_helpers.dart'; // Helper jika dibutuhkan

class DetailRiwayatPesananPage extends StatelessWidget {
  final Map<String, dynamic> pesanan;

  const DetailRiwayatPesananPage({super.key, required this.pesanan});

  @override
  Widget build(BuildContext context) {
    final String status = pesanan['status'] ?? 'Pending';
    final String kodeTransaksi = pesanan['transaksi_kode'] ?? '-';
    final String tanggal = pesanan['created_at']?.toString() ?? DateTime.now().toString();
    final int totalHarga = pesanan['total_harga'] ?? 0;
    
    List<dynamic> items = [];
    if (pesanan['detail'] != null && pesanan['detail'] is List) {
      items = pesanan['detail'];
    }

    // --- AMBIL DATA PENJUAL ---
    String namaPenjual = 'Penjual Tidak Diketahui';
    String alamatPenjual = 'Lokasi Tidak Tersedia';

    if (items.isNotEmpty) {
      final barangData = items[0]['barang'];
      if (barangData != null && barangData['user'] != null) {
        final userData = barangData['user'];
        String depan = userData['user_nama_depan'] ?? '';
        String belakang = userData['user_nama_belakang'] ?? '';
        namaPenjual = "$depan $belakang".trim();
        if (namaPenjual.isEmpty) namaPenjual = "User #${userData['user_id']}";
        alamatPenjual = userData['user_alamat'] ?? 'Alamat belum diatur oleh penjual';
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white, 
        elevation: 0.5,
        title: const Text(
          "Rincian Pesanan", 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DetailHeaderSection(
              status: status, 
              namaPenjual: namaPenjual, 
              alamatPenjual: alamatPenjual
            ),
            const SizedBox(height: 8),
            DetailProductSection(items: items),
            const SizedBox(height: 8),
            DetailPaymentSection(
              totalHarga: totalHarga, 
              kodeTransaksi: kodeTransaksi, 
              tanggal: tanggal
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
      // Bottom Navigation Bar dihapus sesuai permintaan
    );
  }
}