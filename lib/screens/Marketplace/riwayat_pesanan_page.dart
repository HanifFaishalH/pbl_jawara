import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jawaramobile_1/services/transaksi_service.dart';
import 'package:jawaramobile_1/services/barang_service.dart';

class RiwayatPesananPage extends StatefulWidget {
  const RiwayatPesananPage({super.key});

  @override
  State<RiwayatPesananPage> createState() => _RiwayatPesananPageState();
}

class _RiwayatPesananPageState extends State<RiwayatPesananPage> {
  late Future<List<dynamic>> _futureRiwayat;

  // Warna Utama Jawara
  final Color jawaraColor = const Color(0xFF26547C);

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _futureRiwayat = TransaksiService().fetchRiwayatPesanan();
    });
  }

  Future<void> _batalkanPesanan(int id) async {
    // 1. Dialog Konfirmasi Awal
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Batalkan Pesanan?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin? Stok barang akan dikembalikan dan pesanan tidak dapat dipulihkan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text("Tidak", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Ya, Batalkan", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      // Tampilkan loading indicator (opsional, untuk UX yang lebih baik)
      // showDialog(context: context, barrierDismissible: false, builder: (c) => Center(child: CircularProgressIndicator()));
      
      bool success = await TransaksiService().updateStatusTransaksi(id, 'dibatalkan');
      
      // Navigator.pop(context); // Tutup loading jika ada

      if (!mounted) return;

      if (success) {
        _refreshData(); // Refresh data di background

        // 2. TAMPILKAN POP UP SUKSES (DIALOG)
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green[600], size: 72),
                    const SizedBox(height: 16),
                    const Text(
                      "Pesanan Dibatalkan",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Status pesanan telah diperbarui.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: jawaraColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(context), // Tutup Dialog
                        child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal membatalkan pesanan"), backgroundColor: Colors.red)
        );
      }
    }
  }

  // --- HELPER FUNCTIONS ---

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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: jawaraColor,
        title: const Text("Pesanan Saya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/daftar-pembelian'),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureRiwayat,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text("Terjadi kesalahan: ${snapshot.error}", textAlign: TextAlign.center),
              ],
            ));
          }

          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("Belum ada riwayat pesanan", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildOrderCard(data[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(dynamic trx) {
    final String status = trx['status'] ?? 'pending';
    final int trxId = trx['transaksi_id'];
    final bool bisaBatal = (status == 'menunggu_diambil' || status == 'pending');
    
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
      onTap: () {
        context.push('/detail-riwayat-pesanan', extra: trx);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            // HEADER
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
                            Text(
                              _formatTanggal(trx['created_at']), 
                              style: const TextStyle(fontSize: 12, color: Colors.grey)
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trx['transaksi_kode'] ?? '-', 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
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

            // CONTENT
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60, height: 60,
                      color: Colors.grey[100],
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
                        Text(
                          barangNama, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
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

            // FOOTER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Belanja", style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(
                        _formatRupiah(trx['total_harga']), 
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: jawaraColor)
                      ),
                    ],
                  ),
                  
                  if (bisaBatal)
                    OutlinedButton(
                      onPressed: () => _batalkanPesanan(trxId),
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
                      onPressed: () {
                        context.push('/detail-riwayat-pesanan', extra: trx);
                      },
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