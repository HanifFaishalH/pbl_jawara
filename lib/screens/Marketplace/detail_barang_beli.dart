import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetailBarangBeli extends StatelessWidget {
  final Map<String, String> barangData;

  const DetailBarangBeli({super.key, required this.barangData});

  // Fungsi helper baru untuk tampilan vertikal
  Widget _buildVerticalDetail(
      BuildContext context, String label, String value, Color? color) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label (di atas)
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          // Value (di bawah, lebih menonjol)
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color ?? theme.colorScheme.onSurface,
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

    // Mengambil nilai stok dan menkonversinya
    final int stok = int.tryParse(barangData['stok'] ?? '0') ?? 0;
    final Color stokColor = stok > 0 ? Colors.blue.shade700 : Colors.red.shade700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          "Detail ${barangData['nama']}",
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar Barang Placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.pink.shade50,
              ),
              child: const Center(
                child: Icon(Icons.palette, size: 50, color: Colors.pink),
              ),
            ),
            const SizedBox(height: 20),
            
            // Detail Barang
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                // Mengubah Column untuk menampilkan item detail vertikal
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVerticalDetail(
                        context, 
                        "Nama Barang",
                        barangData['nama'] ?? '-', 
                        null
                    ),
                    const Divider(),
                    _buildVerticalDetail(
                        context, 
                        "Kategori",
                        barangData['kategori'] ?? '-', 
                        null
                    ),
                    const Divider(),
                    _buildVerticalDetail(
                        context,
                        "Harga",
                        barangData['harga'] ?? 'Rp 0',
                        Colors.green.shade700,
                    ),
                    const Divider(),
                    _buildVerticalDetail(
                        context,
                        "Stok Tersedia",
                        barangData['stok'] ?? '0',
                        stokColor,
                    ),
                    const Divider(),
                    _buildVerticalDetail(
                        context, 
                        "Alamat Pengambilan",
                        barangData['alamat'] ?? '-', 
                        null
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Button Beli
            ElevatedButton.icon(
              onPressed: stok > 0
                  ? () {
                      // Navigasi ke halaman Checkout
                      context.push('/checkout-barang', extra: barangData);
                    }
                  : null, // Dinonaktifkan jika stok 0
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: Text(
                stok > 0 ? "Beli Sekarang" : "Stok Habis",
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBackgroundColor: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}