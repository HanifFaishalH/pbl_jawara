import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetailBarangBeli extends StatelessWidget {
  // Data ini diterima dari 'extra' saat push dari DaftarPembelian
  final Map<String, String> barangData;

  const DetailBarangBeli({super.key, required this.barangData});

  // Widget kecil untuk menampilkan baris detail
  Widget _buildVerticalDetail(
      BuildContext context, String label, String value, Color? color) {
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

    // Parsing data agar aman
    final String nama = barangData['nama'] ?? '-';
    final String kategori = barangData['kategori'] ?? '-';
    final String harga = barangData['harga'] ?? '0';
    final String alamat = barangData['alamat'] ?? '-';
    final String fotoUrl = barangData['foto'] ?? '';
    
    // Parsing stok ke integer untuk logika tombol
    final int stok = int.tryParse(barangData['stok'] ?? '0') ?? 0;
    final Color stokColor = stok > 0 ? Colors.blue.shade700 : Colors.red.shade700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          "Detail Produk",
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- GAMBAR UTAMA ---
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
              ),
              clipBehavior: Clip.antiAlias,
              child: fotoUrl.isNotEmpty
                  ? Image.network(
                      fotoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 50, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text("Gambar tidak dimuat", style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported, size: 50, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text("Tidak ada gambar", style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
            ),
            const SizedBox(height: 20),

            // --- KARTU INFORMASI ---
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
                    _buildVerticalDetail(context, "Nama Barang", nama, null),
                    const Divider(),
                    _buildVerticalDetail(context, "Kategori", kategori, null),
                    const Divider(),
                    _buildVerticalDetail(context, "Harga", "Rp $harga", Colors.green.shade700),
                    const Divider(),
                    _buildVerticalDetail(context, "Stok Tersedia", "$stok Pcs", stokColor),
                    const Divider(),
                    _buildVerticalDetail(context, "Lokasi Penjual", alamat, null),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- TOMBOL BELI ---
            ElevatedButton.icon(
              onPressed: stok > 0
                  ? () {
                      // Masuk ke checkout dengan membawa data yang sama
                      context.push('/checkout-barang', extra: barangData);
                    }
                  : null, // Tombol mati jika stok 0
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
                disabledBackgroundColor: Colors.grey, // Warna saat disabled
              ),
            ),
          ],
        ),
      ),
    );
  }
}