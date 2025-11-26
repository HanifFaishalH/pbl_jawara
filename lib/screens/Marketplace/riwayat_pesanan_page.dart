import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/transaksi_service.dart';
import '../../widgets/marketplace/riwayat_order.dart';

class RiwayatPesananPage extends StatefulWidget {
  const RiwayatPesananPage({super.key});

  @override
  State<RiwayatPesananPage> createState() => _RiwayatPesananPageState();
}

class _RiwayatPesananPageState extends State<RiwayatPesananPage> {
  late Future<List<dynamic>> _futureRiwayat;
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
    // 1. Dialog Konfirmasi
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Batalkan Pesanan?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin? Stok barang akan dikembalikan dan pesanan tidak dapat dipulihkan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Tidak", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Ya, Batalkan", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      bool success = await TransaksiService().updateStatusTransaksi(id, 'dibatalkan');
      
      if (!mounted) return;

      if (success) {
        _refreshData(); // Refresh Data
        _showSuccessDialog(); // Tampilkan Pop-up Sukses
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membatalkan pesanan"), backgroundColor: Colors.red));
      }
    }
  }

  void _showSuccessDialog() {
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
                const Text("Pesanan Dibatalkan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Status pesanan telah diperbarui.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: jawaraColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
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
                // Panggil Widget Card yang sudah dipisah
                return RiwayatOrderCard(
                  trx: data[index],
                  jawaraColor: jawaraColor,
                  onTap: () => context.push('/detail-riwayat-pesanan', extra: data[index]),
                  onCancel: (id) => _batalkanPesanan(id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}