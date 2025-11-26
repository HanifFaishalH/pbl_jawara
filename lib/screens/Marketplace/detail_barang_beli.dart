import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jawaramobile_1/services/keranjang_service.dart';

// Import Widgets Modular
import '../../widgets/marketplace/detail_image_header.dart';
import '../../widgets/marketplace/detail_info_sec.dart';
import '../../widgets/marketplace/detail_bottom_bar.dart';

class DetailBarangBeli extends StatefulWidget {
  final Map<String, String> barangData;

  const DetailBarangBeli({super.key, required this.barangData});

  @override
  State<DetailBarangBeli> createState() => _DetailBarangBeliState();
}

class _DetailBarangBeliState extends State<DetailBarangBeli> {
  bool _isLoadingCart = false;
  final Color jawaraColor = const Color(0xFF26547C);

  Future<void> _addToCart() async {
    setState(() => _isLoadingCart = true);
    int idBarang = int.tryParse(widget.barangData['id'] ?? '0') ?? 0;
    bool success = await KeranjangService().addToCart(idBarang, 1);
    setState(() => _isLoadingCart = false);

    if (!mounted) return;

    if (success) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menambahkan ke keranjang"), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 70),
              const SizedBox(height: 16),
              const Text("Berhasil!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Barang berhasil masuk keranjang", textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: jawaraColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _formatRupiah(String harga) {
    int price = int.tryParse(harga) ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  @override
  Widget build(BuildContext context) {
    final String nama = widget.barangData['nama'] ?? '-';
    final String kategori = widget.barangData['kategori'] ?? '-';
    final String hargaRaw = widget.barangData['harga'] ?? '0';
    final String hargaFmt = _formatRupiah(hargaRaw);
    final String alamat = widget.barangData['alamat_penjual'] ?? 'Lokasi Penjual';
    final String penjual = widget.barangData['nama_penjual'] ?? 'Penjual Jawara';
    final String fotoUrl = widget.barangData['foto'] ?? '';
    final int stok = int.tryParse(widget.barangData['stok'] ?? '0') ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    DetailImageHeader(fotoUrl: fotoUrl),

                    // INFO UTAMA
                    MainInfoSection(
                      nama: nama, 
                      hargaFmt: hargaFmt, 
                      jawaraColor: jawaraColor
                    ),

                    Container(height: 8, color: Colors.grey[100]),

                    // INFO PENJUAL
                    SellerInfoSection(
                      penjual: penjual, 
                      alamat: alamat, 
                      jawaraColor: jawaraColor
                    ),

                    Container(height: 8, color: Colors.grey[100]),

                    // DETAIL PRODUK
                    ProductSpecsSection(
                      kategori: kategori, 
                      stok: "$stok pcs"
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // BOTTOM BAR
            DetailBottomBar(
              isLoading: _isLoadingCart,
              isStokAvailable: stok > 0,
              jawaraColor: jawaraColor,
              onAddToCart: _addToCart,
              onBuyNow: () => context.push('/checkout-barang', extra: widget.barangData),
            ),
          ],
        ),
      ),
    );
  }
}