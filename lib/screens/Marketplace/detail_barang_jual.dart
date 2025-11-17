import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetailBarang extends StatelessWidget {
  // Data Barang diterima melalui constructor
  final Map<String, String> barangData;

  const DetailBarang({super.key, required this.barangData});

  // Widget helper untuk membuat baris detail (Label: Value)
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor ?? theme.colorScheme.onSurface,
              ),
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

    void _showDeleteConfirmation() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Hapus Barang"),
            content: Text(
                "Yakin ingin menghapus barang ${barangData['nama']}?"),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implementasi logika hapus barang
                  context.pop(); // Tutup dialog
                  context.pop(); // Kembali ke DaftarBarang
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text("Barang ${barangData['nama']} berhasil dihapus"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700),
                child: const Text("Hapus", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          "Detail Barang",
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        actions: [
          // Button Edit
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // TODO: Implementasi navigasi ke halaman Edit Barang
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur Edit belum diimplementasikan")),
              );
            },
          ),
          // Button Hapus
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _showDeleteConfirmation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar Barang Placeholder
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.image_search_outlined,
                      size: 60,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Gambar Barang: ${barangData['nama']}",
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Detail Informasi",
              style: theme.textTheme.titleLarge,
            ),
            const Divider(height: 30),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildDetailRow(context, "Nama Barang", barangData['nama'] ?? '-'),
                    const Divider(height: 1),
                    _buildDetailRow(
                      context,
                      "Harga",
                      barangData['harga'] ?? 'Rp 0',
                      valueColor: Colors.green.shade700,
                    ),
                    const Divider(height: 1),
                    _buildDetailRow(context, "Stok", barangData['stok'] ?? '0'),
                    const Divider(height: 1),
                    _buildDetailRow(context, "Kategori (ML)", barangData['kategori'] ?? 'Tidak Terdeteksi'),
                    const Divider(height: 1),
                    _buildDetailRow(context, "Alamat Penjual", barangData['alamat'] ?? 'Tidak Tersedia'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}