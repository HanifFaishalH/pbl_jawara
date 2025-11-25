import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/transaksi_service.dart';

class PesananMasuk extends StatefulWidget {
  const PesananMasuk({super.key});

  @override
  State<PesananMasuk> createState() => _PesananMasukState();
}

class _PesananMasukState extends State<PesananMasuk> {
  late Future<List<dynamic>> _futurePesanan;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _futurePesanan = TransaksiService().fetchPesananMasuk();
    });
  }

  Future<void> _selesaikanPesanan(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selesaikan Pesanan?"),
        content: const Text("Pastikan barang sudah diambil pembeli."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Ya, Selesai")),
        ],
      ),
    ) ?? false;

    if (confirm) {
      bool success = await TransaksiService().updateStatusTransaksi(id, 'selesai');
      if (success) {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Status pesanan selesai!")));
        _refreshData();
      } else {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal update status.")));
      }
    }
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('menunggu') || s.contains('pending')) return Colors.orange;
    if (s.contains('selesai')) return Colors.green;
    if (s.contains('dibatalkan')) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: const Text("Pesanan Masuk 📦", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<dynamic>>(
          future: _futurePesanan,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            
            final pesananList = snapshot.data ?? [];
            if (pesananList.isEmpty) return const Center(child: Text("Belum ada pesanan masuk."));

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: pesananList.length,
              itemBuilder: (context, index) {
                final item = pesananList[index];
                final String status = item['status'] ?? 'Menunggu';
                final int idTransaksi = item['transaksi_id']; // Penting

                bool showButtonSelesai = (status == 'menunggu_diambil' || status == 'pending');

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.receipt, color: Colors.blue),
                        title: Text("Order ID: $idTransaksi"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Barang: ${item['barang_nama']}"),
                            Text("Pembeli: ${item['user_nama']}"),
                            Text("Total: Rp ${item['total_harga']}"),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(
                            status.replaceAll('_', ' '), 
                            style: const TextStyle(color: Colors.white, fontSize: 10)
                          ),
                          backgroundColor: _getStatusColor(status),
                        ),
                      ),
                      
                      // Tombol Selesai (Hanya muncul jika belum selesai/batal)
                      if (showButtonSelesai)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _selesaikanPesanan(idTransaksi),
                              icon: const Icon(Icons.check_circle, size: 18),
                              label: const Text("Tandai Selesai (Barang Diambil)"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}