import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/transaksi_service.dart';

class RiwayatPesananPage extends StatefulWidget {
  const RiwayatPesananPage({super.key});

  @override
  State<RiwayatPesananPage> createState() => _RiwayatPesananPageState();
}

class _RiwayatPesananPageState extends State<RiwayatPesananPage> {
  late Future<List<dynamic>> _futureRiwayat;

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

  // Fungsi Batalkan
  Future<void> _batalkanPesanan(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Batalkan Pesanan?"),
        content: const Text("Stok barang akan dikembalikan dan pesanan dibatalkan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Tidak")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Ya, Batalkan")),
        ],
      ),
    ) ?? false;

    if (confirm) {
      bool success = await TransaksiService().updateStatusTransaksi(id, 'dibatalkan');
      if (success) {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pesanan berhasil dibatalkan.")));
        _refreshData();
      } else {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membatalkan.")));
      }
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'selesai') return Colors.green;
    if (status == 'dibatalkan') return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: const Text("Pesanan Saya", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/daftar-pembelian'), 
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureRiwayat,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));

          final data = snapshot.data ?? [];
          if (data.isEmpty) return const Center(child: Text("Belum ada riwayat transaksi."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final trx = data[index];
              final String status = trx['status'] ?? 'pending';
              final int trxId = trx['transaksi_id'];
              
              // Cek apakah tombol batal perlu muncul
              bool bisaBatal = (status == 'menunggu_diambil' || status == 'pending');

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Order #${trx['transaksi_kode']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status.toUpperCase().replaceAll('_', ' '), 
                              style: TextStyle(color: _getStatusColor(status), fontSize: 12, fontWeight: FontWeight.bold)
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      if (trx['detail'] != null)
                        ...((trx['detail'] as List).map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text("- ${item['barang']['barang_nama']} (${item['jumlah']}x)"),
                        ))),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total: Rp ${trx['total_harga']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          
                          if (bisaBatal)
                            OutlinedButton(
                              onPressed: () => _batalkanPesanan(trxId),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text("Batalkan"),
                            )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}