import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetailPesananMasuk extends StatelessWidget {
  final Map<String, String> pesananData;

  const DetailPesananMasuk({super.key, required this.pesananData});

  // Helper untuk mendapatkan warna status
  Color _getStatusColor(String status) {
    if (status.contains('Menunggu')) return Colors.orange.shade700;
    if (status.contains('Selesai')) return Colors.green.shade700;
    return Colors.grey.shade700;
  }

  // Widget untuk menampilkan baris detail secara vertikal
  Widget _buildVerticalDetail(
      BuildContext context, String label, String value, {Color? valueColor}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status = pesananData['status'] ?? 'Tidak Diketahui';
    final isPending = status.contains('Menunggu');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          "Detail Pesanan #${pesananData['id']}",
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Pesanan (Chip besar di atas)
            Chip(
              padding: const EdgeInsets.all(8),
              backgroundColor: _getStatusColor(status),
              label: Text(
                status,
                style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // Detail Pesanan
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVerticalDetail(
                        context, "Nama Barang", pesananData['nama_barang'] ?? '-'),
                    const Divider(),
                    _buildVerticalDetail(
                        context, "Pembeli", pesananData['pembeli'] ?? '-'),
                    const Divider(),
                    _buildVerticalDetail(
                        context, "Tanggal Pesanan", pesananData['tanggal'] ?? '-'),
                    const Divider(),
                    _buildVerticalDetail(
                      context,
                      "ID Pesanan",
                      pesananData['id'] ?? '-',
                      valueColor: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Aksi
            if (isPending)
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Tambahkan logika untuk update status pesanan
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Pesanan berhasil ditandai 'Selesai'."),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.pop(); // Kembali setelah aksi
                },
                icon: const Icon(Icons.done_all, color: Colors.white),
                label: Text(
                  "Tandai Pesanan Selesai",
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            else
              Text(
                "Pesanan ini sudah selesai.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}