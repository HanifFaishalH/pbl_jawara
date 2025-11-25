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
    _futurePesanan = TransaksiService().fetchPesananMasuk();
  }

  Future<void> _refreshData() async {
    setState(() {
      _futurePesanan = TransaksiService().fetchPesananMasuk();
    });
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('menunggu') || s.contains('pending')) return Colors.orange;
    if (s.contains('selesai')) return Colors.green;
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
            if (snapshot.hasError) return Center(child: Text("Gagal memuat: ${snapshot.error}"));

            final pesananList = snapshot.data ?? [];
            if (pesananList.isEmpty) return const Center(child: Text("Belum ada pesanan masuk."));

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: pesananList.length,
              itemBuilder: (context, index) {
                final item = pesananList[index];
                
                // DATA MAPPING
                final String idTransaksi = item['transaksi_id']?.toString() ?? '-';
                final String namaBarang = item['barang_nama'] ?? 'Barang';
                final String pembeli = item['user_nama'] ?? 'Pembeli'; 
                final String status = item['status'] ?? 'Menunggu';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.receipt, color: Colors.blue),
                    title: Text("Order #$idTransaksi", style: theme.textTheme.titleMedium),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Barang: $namaBarang"),
                        Text("Pembeli: $pembeli"),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(status, style: const TextStyle(color: Colors.white)),
                      backgroundColor: _getStatusColor(status),
                    ),
                    onTap: () {
                      context.push('/detail-pesanan-masuk', extra: item);
                    },
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