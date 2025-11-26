import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jawaramobile_1/services/barang_service.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color primaryColor;

  const ProductCard({
    super.key, 
    required this.item, 
    required this.primaryColor
  });

  // --- Helper Internal ---
  String _safeGet(Map<String, dynamic> data, String key, [String defaultValue = '-']) {
    final value = data[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  String _formatRupiah(dynamic harga) {
    int price = int.tryParse(harga.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  @override
  Widget build(BuildContext context) {
    final String nama = _safeGet(item, 'barang_nama');
    final String hargaRaw = _safeGet(item, 'barang_harga', '0');
    final String hargaFormat = _formatRupiah(hargaRaw);
    final String alamat = _safeGet(item, 'alamat_penjual', 'Kota Malang');
    final String stok = _safeGet(item, 'barang_stok', '0');
    final String idBarang = _safeGet(item, 'barang_id');
    final String namaPenjual = _safeGet(item, 'nama_penjual', 'Penjual Jawara');

    // Logic Gambar
    String rawFoto = item['barang_foto']?.toString() ?? "";
    String finalFotoUrl = "";
    if (rawFoto.isNotEmpty) {
      if (!rawFoto.startsWith('http')) {
        finalFotoUrl = "${BarangService.baseImageUrl}$rawFoto";
      } else {
        finalFotoUrl = rawFoto;
      }
    }

    // Logic Kategori
    String kategoriBersih = '-';
    if (item['kategori'] != null) {
      if (item['kategori'] is Map) {
        kategoriBersih = item['kategori']['kategori_nama'] ?? '-';
      } else {
        kategoriBersih = item['kategori'].toString();
      }
    }

    return InkWell(
      onTap: () {
        final Map<String, String> dataDetail = {
          'id': idBarang,
          'nama': nama,
          'kategori': kategoriBersih,
          'harga': hargaRaw,
          'stok': stok,
          'alamat_penjual': alamat,
          'foto': finalFotoUrl,
          'nama_penjual': namaPenjual,
        };
        context.push('/detail-barang-beli', extra: dataDetail);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: finalFotoUrl.isNotEmpty
                          ? Image.network(
                              finalFotoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, _) => Container(
                                color: Colors.grey[100],
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            )
                          : Container(color: Colors.grey[200]),
                    ),
                    Positioned(
                      top: 8,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                        ),
                        child: const Text("Terlaris", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            
            // Info Text
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nama,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.2),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hargaFormat,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 10, color: Colors.grey),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                alamat,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 12, color: Colors.amber[700]),
                            const Text(" 4.8 ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            Container(width: 1, height: 10, color: Colors.grey),
                            const Text(" Terjual 100+", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ],
                    )
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

class EmptyProductState extends StatelessWidget {
  const EmptyProductState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text("Barang tidak ditemukan", style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}