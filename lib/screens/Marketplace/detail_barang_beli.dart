import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/keranjang_service.dart';

class DetailBarangBeli extends StatefulWidget {
  final Map<String, String> barangData;

  const DetailBarangBeli({super.key, required this.barangData});

  @override
  State<DetailBarangBeli> createState() => _DetailBarangBeliState();
}

class _DetailBarangBeliState extends State<DetailBarangBeli> {
  bool _isLoadingCart = false;

  Future<void> _addToCart() async {
    setState(() => _isLoadingCart = true);

    int idBarang = int.tryParse(widget.barangData['id'] ?? '0') ?? 0;
    
    // Memanggil Service untuk insert ke database
    bool success = await KeranjangService().addToCart(idBarang, 1);

    setState(() => _isLoadingCart = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil masuk keranjang!"), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menambahkan ke keranjang"), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildVerticalDetail(BuildContext context, String label, String value, Color? color) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color ?? theme.colorScheme.onSurface)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String nama = widget.barangData['nama'] ?? '-';
    final String kategori = widget.barangData['kategori'] ?? '-';
    final String harga = widget.barangData['harga'] ?? '0';
    // Gunakan 'alamat_penjual' sesuai dengan respon JSON Laravel
    final String alamat = widget.barangData['alamat_penjual'] ?? '-';
    final String fotoUrl = widget.barangData['foto'] ?? '';
    final int stok = int.tryParse(widget.barangData['stok'] ?? '0') ?? 0;
    final Color stokColor = stok > 0 ? Colors.blue.shade700 : Colors.red.shade700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text("Detail Produk", style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- GAMBAR ---
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
                  ? Image.network(fotoUrl, fit: BoxFit.cover, errorBuilder: (ctx, err, _) => const Icon(Icons.broken_image, size: 50))
                  : const Icon(Icons.image_not_supported, size: 50),
            ),
            const SizedBox(height: 20),

            // --- INFO ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          ],
        ),
      ),
      
      // --- DUA TOMBOL AKSI ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            // 1. Tombol Keranjang
            Expanded(
              child: OutlinedButton.icon(
                onPressed: (stok > 0 && !_isLoadingCart) ? _addToCart : null,
                icon: _isLoadingCart 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Icon(Icons.shopping_cart_outlined),
                label: Text(_isLoadingCart ? "Proses..." : "Keranjang"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: theme.colorScheme.primary),
                  foregroundColor: theme.colorScheme.primary, // Warna teks
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 2. Tombol Beli Langsung
            Expanded(
              child: ElevatedButton.icon(
                onPressed: stok > 0
                    ? () {
                        context.push('/checkout-barang', extra: widget.barangData);
                      }
                    : null,
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text("Beli Sekarang", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}