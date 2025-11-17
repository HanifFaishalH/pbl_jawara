import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Import DetailPesananMasuk yang baru
import 'detail_pesanan_masuk.dart'; // Sesuaikan path import Anda

class PesananMasuk extends StatelessWidget {
  const PesananMasuk({super.key});

  // Data dummy pesanan
  final List<Map<String, String>> _pesanan = const [
    {
      "id": "P001",
      "nama_barang": "Batik Cap Kawung",
      "pembeli": "Bapak Hilmi",
      "status": "Menunggu Pengambilan",
      "tanggal": "18 November 2025",
    },
    {
      "id": "P002",
      "nama_barang": "Meja Kayu Jati",
      "pembeli": "Ibu Azizah",
      "status": "Selesai",
      "tanggal": "15 November 2025",
    },
  ];

  Color _getStatusColor(String status) {
    if (status.contains('Menunggu')) return Colors.orange;
    if (status.contains('Selesai')) return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          "Pesanan Masuk 📦",
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _pesanan.isEmpty
          ? Center(
              child: Text(
                "Tidak ada pesanan masuk.",
                style: theme.textTheme.titleMedium,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _pesanan.length,
              itemBuilder: (context, index) {
                final item = _pesanan[index];
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.receipt, color: Colors.blue),
                    title: Text("Pesanan #${item['id']}",
                        style: theme.textTheme.titleMedium),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("Barang: ${item['nama_barang']}"),
                        Text("Pembeli: ${item['pembeli']}"),
                        Text("Tanggal: ${item['tanggal']}"),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        item['status']!,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _getStatusColor(item['status']!),
                    ),
                    // PEMBARUAN NAVIGASI
                    onTap: () {
                      context.push('/detail-pesanan-masuk', extra: item);
                    },
                  ),
                );
              },
            ),
    );
  }
}