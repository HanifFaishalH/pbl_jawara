import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jawaramobile_1/services/keranjang_service.dart';

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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
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
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menambahkan ke keranjang"), backgroundColor: Colors.red),
      );
    }
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
    
    // --- AMBIL NAMA PENJUAL DARI DATA YG DIKIRIM ---
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
                    // 1. HEADER GAMBAR
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            color: Colors.grey[200],
                            child: fotoUrl.isNotEmpty
                                ? Image.network(fotoUrl, fit: BoxFit.cover)
                                : const Center(child: Icon(Icons.image, size: 60, color: Colors.grey)),
                          ),
                        ),
                        Positioned(
                          top: 10, left: 10,
                          child: CircleAvatar(
                            backgroundColor: Colors.black26,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => context.pop(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 2. INFO UTAMA
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(hargaFmt, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: jawaraColor)),
                          const SizedBox(height: 8),
                          Text(nama, style: const TextStyle(fontSize: 16, height: 1.3, color: Colors.black87)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.amber[700]),
                              const SizedBox(width: 4),
                              const Text("4.8", style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 8),
                              Container(height: 12, width: 1, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text("Terjual 100+", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Container(height: 8, color: Colors.grey[100]),

                    // 3. INFO PENJUAL
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Informasi Penjual", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.store, size: 14, color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  penjual,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(height: 1, color: Colors.grey),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Dikirim dari", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    const SizedBox(height: 2),
                                    Text(alamat, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Container(height: 8, color: Colors.grey[100]),

                    // 4. DETAIL PRODUK
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Detail Produk", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 16),
                          _buildDetailRow("Kategori", kategori),
                          _buildDetailRow("Stok", "$stok pcs"),
                          _buildDetailRow("Kondisi", "Baru"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // BOTTOM BAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, -3))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: (stok > 0 && !_isLoadingCart) ? _addToCart : null,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: jawaraColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoadingCart
                        ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: jawaraColor))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_shopping_cart, size: 18, color: jawaraColor),
                              const SizedBox(width: 8),
                              Text("Keranjang", style: TextStyle(color: jawaraColor, fontWeight: FontWeight.bold)),
                            ],
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: stok > 0 ? () => context.push('/checkout-barang', extra: widget.barangData) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: jawaraColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Beli Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.black54))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}